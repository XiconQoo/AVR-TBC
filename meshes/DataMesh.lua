local ADDON_NAME="AVR"
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, true)

local pairs = pairs
local ipairs = ipairs
local remove = table.remove
local insert = table.insert

local Core=AVR

local unpackDouble=AVRUnpackDouble
local packDouble=AVRPackDouble

AVRDataMesh={Embed=Core.Embed}
AVRDataMesh.meshInfo={
	class="AVRDataMesh",
	derived=false,
	guiCreateNew=false,
	guiName=nil,
	receivable=true
}

AVRDataMesh.class="AVRDataMesh"
function AVRDataMesh:New()
	if self ~= AVRDataMesh then return end
	local s=AVRMesh:New()
	AVRDataMesh:Embed(s)
	s.class=AVRDataMesh.meshInfo.class
	s.vertexData={}
	s.lineData={}
	s.triangleData={}
	s.lineWidth=32
	s.highres=false
	return s
end

function AVRDataMesh:SetLineWidth(w)
	self.lineWidth=math.floor(w)
	if w~=nil then
		for i=1,#self.lineData do
			self.lineData[i].width=self.lineWidth
		end
	end
	self.vertices=nil
end

function AVRDataMesh:GetOptions()
	local o=AVRMesh.GetOptions(self)
	o.args.yardStick = {
		type = "group",
		name = L["Data mesh properties"],
		inline = true,
		order = 80,
		args = {
			lineWidth= {
				type = "range",
				name = L["Line width"],
				order = 10,
				width = "full",
				min = 0, max=255, step=1.0, bigStep=1.0
			}
		}
	}
	return o
end

function AVRDataMesh:CaptureMesh()
	self.vertexData=self.vertices
	self.lineData=self.lines
	self.triangleData=self.triangles
	self.vertices=nil
	self.lines=nil
	self.triangles=nil
end

function AVRDataMesh:GenerateMesh()
	local v
	for i=1,#self.vertexData do
		v=self.vertexData[i]
		insert(self.vertices,{v[1],v[2],v[3],0,0,0,0,0})
	end
	self.lines=self.lineData
	self.triangles=self.triangleData
	AVRMesh.GenerateMesh(self)
end

function AVRDataMesh:AddDataVertex(x,y,z)
	insert(self.vertexData,{x,y,z,0,0,0,0,0})
	self.vertices=nil
	return #self.vertexData
end

function AVRDataMesh:FindDataVertex(x,y,z)
	for i,v in ipairs(self.vertexData) do
		if v[1]==x and v[2]==y and v[3]==z then return i end
	end
	return nil
end

function AVRDataMesh:AddOrFindDataVertex(x,y,z)
	return self:FindDataVertex(x,y,z) or self:AddDataVertex(x,y,z)
end

function AVRDataMesh:AddDataLine(line,y1,z1,x2,y2,z2,width,a,r,g,b)
	if y1~=nil then
		if width==nil then width=self.lineWidth end
		local v1=self:AddOrFindDataVertex(line,y1,z1)
		local v2=self:AddOrFindDataVertex(x2,y2,z2)
		insert(self.lines,AVRLine:New(v1,v2,width,a,r,g,b))
	else
		insert(self.lines,line)
	end
	self.vertices=nil
end

function AVRDataMesh:AddDataTriangle(triangle,y1,z1,x2,y2,z2,x3,y3,z3,a,r,g,b)
	if y1~=nil then
		local v1=self:AddOrFindDataVertex(triangle,y1,z1)
		local v2=self:AddOrFindDataVertex(x2,y2,z2)
		local v3=self:AddOrFindDataVertex(x3,y3,z3)
		insert(self.triangleData,AVRTriangle:New(v1,v2,v3,a,r,g,b))
	else
		insert(self.triangleData,triangle)
	end
	self.vertices=nil
end


function AVRDataMesh:DeleteDataTriangle(triangle)
	for i=1,#self.triangleData do
		if self.triangleData[i]==triangle then
			remove(self.triangleData,i)
			break
		end
	end
	self.vertices=nil
end

function AVRDataMesh:DeleteDataLine(line)
	for i=1,#self.lineData do
		if self.lineData[i]==line then
			remove(self.lineData,i)
			break
		end
	end
	self.vertices=nil
end

function AVRDataMesh:DeleteDataVertex(index)
	local removeTriangles={}
	for i=1,#self.triangleData do
		local t=self.triangleData[i]
		if t.v1==index then insert(removeTriangles,t)
		elseif t.v1>index then t.v1=t.v1-1 end
		if t.v2==index then insert(removeTriangles,t)
		elseif t.v2>index then t.v2=t.v2-1 end
		if t.v3==index then insert(removeTriangles,t)
		elseif t.v3>index then t.v3=t.v3-1 end
	end
	local removeLines={}
	for i=1,#self.lineData do
		local l=self.lineData[i]
		if l.v1==index then insert(removeLines,l)
		elseif l.v1>index then l.v1=l.v1-1 end
		if l.v2==index then insert(removeLines,l)
		elseif l.v2>index then l.v2=l.v2-1 end
	end
	remove(self.vertexData,index)
	
	for i,t in ipairs(removeTriangles) do
		self:DeleteDataTriangle(t)
	end
	for i,l in ipairs(removeLines) do
		self:DeleteDataLine(l)
	end
	
	self.vertices=nil
end

function AVRDataMesh:Pack()
	local s=AVRMesh.Pack(self)
	s.highres=self.highres
	s.lineWidth=self.lineWidth
	local bs=AVRByteStream:New()
	local v
	if self.highres then
		for i=1,#self.vertexData do
			v=self.vertexData[i]
			bs:WriteDouble(v[1])
			bs:WriteDouble(v[2])
			bs:WriteDouble(v[3])
		end
	else
		for i=1,#self.vertexData do
			v=self.vertexData[i]
			bs:WriteHalf(v[1])
			bs:WriteHalf(v[2])
			bs:WriteHalf(v[3])
		end
	end
	bs:FlushBuffer()
	s.vd=bs.data
	
	bs=AVRByteStream:New()
	for i=1,#self.lineData do
		self.lineData[i]:Pack(bs)
	end
	bs:FlushBuffer()
	s.ld=bs.data

	bs=AVRByteStream:New()
	for i=1,#self.triangleData do
		self.triangleData[i]:Pack(bs)
	end
	bs:FlushBuffer()
	s.td=bs.data
	return s
end

function AVRDataMesh:Unpack(s)
	AVRMesh.Unpack(self,s)
	self.lineWidth=s.lineWidth
	self.highres=s.highres or false
	self.vertexData={}
	self.lineData={}
	self.triangleData={}
	
	local bs=AVRByteStream:New({data=s.vd})
	if self.highres then
		while not bs:IsEOS() do
			local v={0,0,0,0,0,0,0,0}
			v[1]=bs:ReadDouble()
			v[2]=bs:ReadDouble()
			v[3]=bs:ReadDouble()
			insert(self.vertexData,v)
		end
	else
		while not bs:IsEOS() do
			local v={0,0,0,0,0,0,0,0}
			v[1]=bs:ReadHalf()
			v[2]=bs:ReadHalf()
			v[3]=bs:ReadHalf()
			insert(self.vertexData,v)
		end
	end
	
	bs=AVRByteStream:New({data=s.ld})
	while not bs:IsEOS() do
		local v=AVRLine:New()
		v:Unpack(bs)
		insert(self.lineData,v)
	end

	bs=AVRByteStream:New({data=s.td})
	while not bs:IsEOS() do
		local v=AVRTriangle:New()
		v:Unpack(bs)
		insert(self.triangleData,v)
	end
	self.vertices=nil
end

AVR:RegisterMeshClass(AVRDataMesh)
