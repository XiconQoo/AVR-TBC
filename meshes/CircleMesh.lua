local ADDON_NAME="AVR"
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, true)

local _G = _G
local sin = math.sin
local cos = math.cos
local pi = math.pi

local Core=AVR

local unpackDouble=AVRUnpackDouble
local packDouble=AVRPackDouble

AVRCircleMesh={Embed=Core.Embed}
AVRCircleMesh.meshInfo={
	class="AVRCircleMesh",
	derived=false,
	guiCreateNew=true,
	guiName=L["Circle"],
	receivable=true
}
function AVRCircleMesh:New(radius,segments,dashed,width)
	if self ~= AVRCircleMesh then return end
	local s=AVRMesh:New()
	AVRCircleMesh:Embed(s)
	s.class=AVRCircleMesh.meshInfo.class
	s.radius=radius or 10
	s.segments=segments or 30
	s.dashed=dashed or false	
	s.lineWidth=width
	s.vertices=nil
	s.name=L["Circle"]
	return s
end

function AVRCircleMesh:SetRadius(radius)
	self.radius=radius
	self.vertices=nil
	return self
end
function AVRCircleMesh:SetSegments(segments)
	self.segments=math.floor(segments)
	self.vertices=nil
	return self
end
function AVRCircleMesh:SetDashed(dashed)
	self.dashed=dashed
	self.vertices=nil
	return self
end

function AVRCircleMesh:GetOptions()
	local o=AVRMesh.GetOptions(self)
	o.args.circle = {
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
			dashed = {
				type = "toggle",
				name = L["Dashed"],
				order = 30,
				width = "full",
			}
		}
	}
	return o
end

function AVRCircleMesh:GenerateMesh()
	local a
	local ox=self.radius
	local oy=0
	local x,y
	
	for i=1,self.segments do
		a=pi*2/self.segments*i
		
		x=cos(a)*self.radius
		y=sin(a)*self.radius
		
		if not self.dashed or (i%2)==0 then
			self:AddLine(ox,oy,0,x,y,0,self.lineWidth)
		end
		
		ox,oy=x,y
	end
	
	AVRMesh.GenerateMesh(self)
end

function AVRCircleMesh:Pack()
	local s=AVRMesh.Pack(self)
	s.rad=packDouble(self.radius)
	s.seg=self.segments
	s.das=self.dashed
	s.lw=self.lineWidth
	return s
end

function AVRCircleMesh:Unpack(s)
	AVRMesh.Unpack(self,s)
	self.radius=unpackDouble(s.rad) or 10
	self.segments=s.seg or 30
	if s.das~=nil then self.dashed=s.das
	else self.dashed=false end
	self.lw=s.lw
	self.vertices=nil
end

AVR:RegisterMeshClass(AVRCircleMesh)
