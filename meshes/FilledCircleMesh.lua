local ADDON_NAME="AVR"
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, true)

local _G = _G
local sin = math.sin
local cos = math.cos
local pi = math.pi

local Core=AVR

local unpackDouble=AVRUnpackDouble
local packDouble=AVRPackDouble

AVRFilledCircleMesh={Embed=Core.Embed}
AVRFilledCircleMesh.meshInfo={
	class="AVRFilledCircleMesh",
	derived=false,
	guiCreateNew=true,
	guiName=L["Filled circle"],
	receivable=true
}
function AVRFilledCircleMesh:New(radius,segments)
	if self ~= AVRFilledCircleMesh then return end
	local s=AVRMesh:New()
	AVRFilledCircleMesh:Embed(s)
	s.class=AVRFilledCircleMesh.meshInfo.class
	s.radius=radius or 10
	s.segments=segments or 30
	s.vertices=nil
	s.name=L["Filled circle"]
	s.useTexture=false
	s.a=0.25
	return s
end

function AVRFilledCircleMesh:Pack()
	local s=AVRMesh.Pack(self)
	s.rad=packDouble(self.radius)
	s.seg=self.segments
	s.utx=self.useTexture
	return s
end

function AVRFilledCircleMesh:Unpack(s)
	AVRMesh.Unpack(self,s)
	self.radius=unpackDouble(s.rad) or 10
	self.segments=s.seg or 30
	if s.utx==nil then self.useTexture=false
	else self.useTexture=s.utx end
	
	self.vertices=nil
end

function AVRFilledCircleMesh:SetUseTexture(value)
	self.useTexture=value
	self.vertices=nil
end
function AVRFilledCircleMesh:GetUseTexture()
	return self.useTexture
end

function AVRFilledCircleMesh:SetRadius(radius)
	self.radius=radius
	self.vertices=nil
	return self
end
function AVRFilledCircleMesh:SetSegments(segments)
	self.segments=math.floor(segments)
	self.vertices=nil
	return self
end

function AVRFilledCircleMesh:GetOptions()
	local o=AVRMesh.GetOptions(self)
	o.args.filledCircle = {
		type = "group",
		name = L["Circle properties"],
		inline = true,
		order = 80,
		args = {
			radius = {
				type = "range",
				name = L["Radius"],
				order = 10,
				width = "full",
				min = 0.0, max=500, bigStep=1.0
			},					
			segments = {
				type = "range",
				name = L["Segments"],
				order = 20,
				width = "full",
				min = 3, max=200, step=1, bigStep=1
			},
			useTexture = {
				type = "toggle",
				name = L["Use texture"],
				desc = L["Use texture desc"],
				order = 30,
				width = "full",
			} 
		}
	}
	return o
end


local cps={}
for i=1,5 do
	cps[i*2-1]=-cos(2*pi/5*(i-1))
	cps[i*2]=sin(2*pi/5*(i-1))
end

function AVRFilledCircleMesh:GenerateMesh()
	if self.useTexture then
		local t=self:AddTexture( cps[1]*self.radius,cps[2]*self.radius,0,
						cps[3]*self.radius,cps[4]*self.radius,0,
						cps[5]*self.radius,cps[6]*self.radius,0,
						cps[7]*self.radius,cps[8]*self.radius,0,
						cps[9]*self.radius,cps[10]*self.radius,0,
						"filledcircle")
		t.rotateTexture=false
	else
		local a
		local ox=self.radius
		local oy=0
		local x,y
		
		for i=1,self.segments do
			a=pi*2/self.segments*i
			
			x=cos(a)*self.radius
			y=sin(a)*self.radius
			
			self:AddTriangle(0,0,0,ox,oy,0,x,y,0)
			
			ox,oy=x,y
		end
	end
	
	AVRMesh.GenerateMesh(self)
end


AVR:RegisterMeshClass(AVRFilledCircleMesh)
