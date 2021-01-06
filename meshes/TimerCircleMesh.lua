local ADDON_NAME="AVR"
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, true)

local _G = _G
local sin = math.sin
local cos = math.cos
local pi = math.pi
local floor = math.floor

local Core=AVR

local unpackDouble=AVRUnpackDouble
local packDouble=AVRPackDouble

AVRTimerCircleMesh={Embed=Core.Embed}
AVRTimerCircleMesh.meshInfo={
	class="AVRTimerCircleMesh",
	derived=false,
	guiCreateNew=false,
	guiName=L["Timer circle"],
	receivable=true
}
function AVRTimerCircleMesh:New(radius,segments)
	if self ~= AVRTimerCircleMesh then return end
	local s=AVRMesh:New()
	AVRTimerCircleMesh:Embed(s)
	s.class=AVRTimerCircleMesh.meshInfo.class
	s.radius=radius or 10
	s.segments=segments or 30
	s.vertices=nil
	s.name=L["Timer circle"]
	s.duration=10
	s.expiration=GetTime()+10
	s.removeOnExpire=false
	s.r2=1.0
	s.g2=1.0
	s.b2=1.0
	s.a2=0.5
	return s
end

function AVRTimerCircleMesh:SetTimer(duration, expiration)
	self.duration=duration
	self.expiration=expiration or GetTime()+duration
	self.vertices=nil
end

function AVRTimerCircleMesh:SetColor2(r,g,b,a)
	if r~=nil then self.r2=r end
	if g~=nil then self.g2=g end
	if b~=nil then self.b2=b end
	if a~=nil then self.a2=a end
	self.vertices=nil
	return self
end

function AVRTimerCircleMesh:Pack()
	local s=AVRMesh.Pack(self)
	s.rad=packDouble(self.radius)
	s.seg=self.segments
	s.dur=packDouble(self.duration)
	s.exp=packDouble(self.expiration)
	s.roe=self.removeOnExpire
	s.r2=packDouble(self.r2)
	s.g2=packDouble(self.g2)
	s.b2=packDouble(self.b2)
	s.a2=packDouble(self.a2)
	return s
end

function AVRTimerCircleMesh:Unpack(s)
	AVRMesh.Unpack(self,s)
	self.radius=unpackDouble(s.rad) or 10
	self.segments=s.seg or 30
	self.vertices=nil
	self.duration=unpackDouble(s.dur) or 10
	self.expiration=unpackDouble(s.exp) or GetTime()+self.duration
	if s.roe~=nil then self.removeOnExpire=s.roe
	else self.removeOnExpire=false end
	self.r2=unpackDouble(s.r2) or 1.0
	self.g2=unpackDouble(s.g2) or 1.0
	self.b2=unpackDouble(s.b2) or 1.0
	self.a2=unpackDouble(s.a2) or 0.5
	self.vertices=nil
end

function AVRTimerCircleMesh:SetRemoveOnExpire(value)
	self.removeOnExpire=value
	if value and self.expiration==nil then
		self:Remove()
	end
end

function AVRTimerCircleMesh:SetRadius(radius)
	self.radius=radius
	self.vertices=nil
	return self
end
function AVRTimerCircleMesh:SetSegments(segments)
	self.segments=math.floor(segments)
	self.vertices=nil
	return self
end



function AVRTimerCircleMesh:GenerateMesh()

	local a
	local oy=self.radius
	local ox=0
	local x,y
	
	for i=1,self.segments do
		a=pi*2/self.segments*i
		
		x=sin(a)*self.radius
		y=cos(a)*self.radius
		
		local t=self:AddTriangle(0,0,0,ox,oy,0,x,y,0)
		t.r=self.r2
		t.g=self.g2
		t.b=self.b2
		t.a=self.a2
		
		ox,oy=x,y
	end
	
	self.timeV=self:AddVertex(0,0,0)
	self.timeT1=AVRTriangle:New(1,0,self.timeV)
	self.timeT2=AVRTriangle:New(1,self.timeV,0)
	self.timeV=self.vertices[self.timeV]
	self.timeT2.r=self.r2
	self.timeT2.g=self.g2
	self.timeT2.b=self.b2
	self.timeT2.a=self.a2
	self.timeT1.visible=false
	self.timeT2.visible=false
	self:AddTriangle(self.timeT1)
	self:AddTriangle(self.timeT2)

	local ca=cos(self.meshRotateZ)
	local sa=sin(self.meshRotateZ)
	self.MA,self.MB,self.MC,self.MD=
		ca*self.meshScaleX,-sa*self.meshScaleY,
		sa*self.meshScaleX, ca*self.meshScaleY

	AVRMesh.GenerateMesh(self)
end

function AVRTimerCircleMesh:OnUpdate(threed)
	if self.expiration~=nil or self.vertices==nil then
		if self.vertices==nil or self.lines==nil or self.triangles==nil or self.textures==nil then
			self.vertices={}
			self.lines={}
			self.triangles={}
			self.textures={}
			self:GenerateMesh()
		end

		local t=GetTime()
		local tri

		if self.expiration==nil or t>=self.expiration then
			if self.removeOnExpire then
				self.visible=false
				self:Remove()
				return
			end
			for i=1,self.segments do
				tri=self.triangles[i]
				tri.r=nil
				tri.g=nil
				tri.b=nil
				tri.a=nil
				tri.visible=true
			end
			self.timeT1.visible=false
			self.timeT2.visible=false
			self.expiration=nil
		elseif t>=self.expiration-self.duration then
			local d=(t-self.expiration+self.duration)/self.duration
			
			local s=floor(d*self.segments+1)
			for i=1,s-1 do
				tri=self.triangles[i]
				tri.r=nil
				tri.g=nil
				tri.b=nil
				tri.a=nil
				tri.visible=true
			end
			tri=self.triangles[s]
			tri.visible=false
			
			local x=sin(d*2*pi)*self.radius
			local y=cos(d*2*pi)*self.radius
			
			local v=self.timeV
			
			v[1],v[2]=self.MA*x+self.MB*y+self.meshTranslateX,
					self.MC*x+self.MD*y+self.meshTranslateY
			
			self.timeT1.v2=tri.v2
			self.timeT2.v3=tri.v3
			self.timeT1.visible=true
			self.timeT2.visible=true
			
		end
	end

	AVRMesh.OnUpdate(self,threed)
end

AVR:RegisterMeshClass(AVRTimerCircleMesh)
