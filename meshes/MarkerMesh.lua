local ADDON_NAME="AVR"
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, true)

local _G = _G
local sin = math.sin
local cos = math.cos
local pi = math.pi

local Core=AVR

local unpackDouble=AVRUnpackDouble
local packDouble=AVRPackDouble

AVRMarkerMesh={Embed=Core.Embed}
AVRMarkerMesh.meshInfo={
	class="AVRMarkerMesh",
	derived=false,
	guiCreateNew=false,
	guiName=nil,
	receivable=true
}
AVRMarkerMesh.class="AVRMarkerMesh"
function AVRMarkerMesh:New(radius,spokes)
	if self ~= AVRMarkerMesh then return end
	local s=AVRMesh:New()
	AVRMarkerMesh:Embed(s)
	s.class=AVRMarkerMesh.class
	s.radius=radius or 1
	s.spokes=spokes or 6
	s.classColor=false
	s.vertices=nil
	s.line=false
	s.lineVertex=nil
	s.lineWidth=128
	s.useTexture=false
	s.name="Marker"
	return s
end

function AVRMarkerMesh:GetOptions()
	local o=AVRMesh.GetOptions(self)
	o.args.marker = {
		type = "group",
		name = L["Marker properties"],
		inline = true,
		order = 80,
		args = {
			radius = {
				type = "range",
				name = L["Radius"],
				order = 10,
				width = "full",
				min = 0.0, max=10, bigStep=0.5
			},					
			spokes = {
				type = "range",
				name = L["Spokes"],
				order = 20,
				width = "full",
				min = 4, max=10, step=2.0
			},
			classColor = {
				type = "toggle",
				name = L["Class color"],
				order = 30,
				width = "full"
			},
			line = {
				type = "toggle",
				name = L["Draw line"],
				desc = L["Draw line desc"],
				order = 40,
				width = "full"
			},
			useTexture = {
				type = "toggle",
				name = L["Use texture"],
				desc = L["Use texture desc marker"],
				order = 50,
				width = "full",
			} 
		}
	}
	return o
end

function AVRMarkerMesh:SetUseTexture(value)
	self.useTexture=value
	self.vertices=nil
end
function AVRMarkerMesh:GetUseTexture()
	return self.useTexture
end

function AVRMarkerMesh:SetLine(value)
	self.line=value
	self.vertices=nil
end
function AVRMarkerMesh:GetLine()
	return self.line
end

function AVRMarkerMesh:SetRadius(radius)
	self.radius=radius
	self.vertices=nil
end
function AVRMarkerMesh:GetRadius()
	return self.radius
end

function AVRMarkerMesh:SetLineWidth(width)
	self.lineWidth=width
	self.vertices=nil
end
function AVRMarkerMesh:GetLineWidth()
	return self.lineWidth
end

function AVRMarkerMesh:SetSpokes(spokes)
	self.spokes=spokes
	self.vertices=nil
end
function AVRMarkerMesh:GetSpokes()
	return self.spokes
end

function AVRMarkerMesh:SetClassColor(value)
	self.classColor=value
end
function AVRMarkerMesh:GetClassColor()
	return self.classColor
end

function AVRMarkerMesh:Pack()
	local s=AVRMesh.Pack(self)
	s.rad=self.radius
	s.spo=self.spokes
	s.clc=self.classColor
	s.lin=self.line
	s.liw=self.lineWidth
	s.utx=self.useTexture
	return s
end

function AVRMarkerMesh:Unpack(s)
	AVRMesh.Unpack(self,s)
	self.radius=s.rad or 1
	self.spokes=s.spo or 6
	self.lineWidth=s.liw or 128
	if s.clc==nil then self.classColor=false
	else self.classColor=s.clc end
	if s.lin==nil then self.line=false
	else self.line=s.lin end
	if s.utx==nil then self.useTexture=false
	else self.useTexture=s.utx end
	self.vertices=nil
end

local cps={}
for i=1,5 do
	cps[i*2-1]=-cos(2*pi/5*(i-1))
	cps[i*2]=sin(2*pi/5*(i-1))
end

function AVRMarkerMesh:GenerateMesh()
	if self.useTexture then
		local t=self:AddTexture( cps[1]*self.radius,cps[2]*self.radius,0,
						cps[3]*self.radius,cps[4]*self.radius,0,
						cps[5]*self.radius,cps[6]*self.radius,0,
						cps[7]*self.radius,cps[8]*self.radius,0,
						cps[9]*self.radius,cps[10]*self.radius,0,
						"marker")
		--t.rotateTexture=false
	else
		local a
		local ox=self.radius
		local oy=0
		local x,y
		
		for i=1,self.spokes do
			a=pi*2/self.spokes*i
			
			x=cos(a)*self.radius
			y=sin(a)*self.radius
			
			if (i%2)==0 then
				self:AddTriangle(0,0,0,ox,oy,0,x,y,0,nil,0,0,0)
			else
				self:AddTriangle(0,0,0,ox,oy,0,x,y,0)
			end
			
			ox,oy=x,y
		end
	end
	
	if self.line then
		local v2=self:AddOrFindVertex(0,0,0)
		self.lineVertex=self:AddVertex(0,0,0)
		local l=AVRLine:New(v2,self.lineVertex,self.lineWidth)
		self:AddLine(l)
	end
	
	AVRMesh.GenerateMesh(self)
end

function AVRMarkerMesh:OnUpdate(threed)
	if self.classColor then
		local cls=nil
		if self.followUnit then
			_,cls=UnitClass(self.followUnit)
		elseif self.followPlayer then
			_,cls=UnitClass("player")
		end
		if cls then
			local c=RAID_CLASS_COLORS[cls]
			if c then self:SetColor(c.r,c.g,c.b) 
			else self:SetColor(1.0,1.0,1.0) end
		end
	end
	if self.line then
		if self.vertices==nil or self.lines==nil or self.triangles==nil or self.textures==nil then
			self.vertices={}
			self.lines={}
			self.triangles={}
			self.textures={}
			self:GenerateMesh()
		end
	
		local unit=(self.followUnit or (self.followPlayer and "player") or nil)
		local px,py=threed:GetUnitPosition("player")
		local v=self.vertices[self.lineVertex]
		v[1]=nil
		if px~=0 or py~=0 then
			if unit then
				local ux,uy=threed:GetUnitPosition(unit)
				if ux~=0 or uy~=0 then 
					v[1]=px-ux
					v[2]=py-uy
				end
			else
				v[1]=px
				v[2]=py
			end
		end
		if v[1]==nil then
			v[1]=self.vertices[1][1]
			v[2]=self.vertices[1][2]
		end
	end
	AVRMesh.OnUpdate(self,threed)
end

AVR:RegisterMeshClass(AVRMarkerMesh)
