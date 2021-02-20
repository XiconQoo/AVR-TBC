local ADDON_NAME="AVR"
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, true)

local _G = _G
local sin = math.sin
local cos = math.cos
local pi = math.pi
local sqrt = math.sqrt
local atan2 = math.atan2

local Core=AVR

local unpackDouble=AVRUnpackDouble
local packDouble=AVRPackDouble

AVRArrowMesh={Embed=Core.Embed}
AVRArrowMesh.meshInfo={
	class="AVRArrowMesh",
	derived=false,
	guiCreateNew=true,
	guiName=L["Arrow"],
	receivable=true
}
function AVRArrowMesh:New(radius,width,headSize)
	if self ~= AVRArrowMesh then return end
	local s=AVRMesh:New()
	AVRArrowMesh:Embed(s)
	s.class=AVRArrowMesh.meshInfo.class
	s.length=length or 10
	s.width=width or 1
	s.headSize=headSize or 2
	s.vertices=nil
	s.name=L["Arrow"]
	s.a=0.25
	return s
end

function AVRArrowMesh:Pack()
	local s=AVRMesh.Pack(self)
	s.len=packDouble(self.length)
	s.wid=packDouble(self.width)
	s.hes=packDouble(self.headSize)
	return s
end

function AVRArrowMesh:Unpack(s)
	AVRMesh.Unpack(self,s)
	self.length=unpackDouble(s.len) or 10
	self.width=unpackDouble(s.wid) or 1
	self.headSize=unpackDouble(s.hes) or 2
	self.vertices=nil
end

function AVRArrowMesh:SetLength(length)
	self.length=length
	self.vertices=nil
	return self
end
function AVRArrowMesh:SetWidth(width)
	self.width=width
	self.vertices=nil
	return self
end
function AVRArrowMesh:SetHeadSize(headSize)
	self.headSize=headSize
	self.vertices=nil
	return self
end


function AVRArrowMesh:GetOptions()
	local o=AVRMesh.GetOptions(self)
	o.args.filledCircle = {
		type = "group",
		name = L["Arrow properties"],
		inline = true,
		order = 80,
		args = {
			length = {
				type = "range",
				name = L["Length"],
				order = 10,
				width = "full",
				min = 0, max=100, bigStep=0.5
			},					
			width = {
				type = "range",
				name = L["Width"],
				order = 20,
				width = "full",
				min = 0, max=100, bigStep=0.5
			},
			headSize = {
				type = "range",
				name = L["Head size"],
				order = 30,
				width = "full",
				min = 0, max=100, bigStep=0.5
			}
		}
	}
	return o
end

function AVRArrowMesh:PointTo(sx,sy,ex,ey)
	local dx=ex-sx
	local dy=ey-sy
	local a=atan2(dy,dx)-pi/2
	local cx=(sx+ex)/2
	local cy=(sy+ey)/2
	self.length=sqrt(dx*dx+dy*dy)
	self:SetMeshTranslate(cx,cy,0)
	self:SetMeshRotation(a)
	self.vertices=nil
end

function AVRArrowMesh:GenerateMesh()
	local w2=self.width/2
	local l2=self.length/2
	if self.length-self.headSize>0 and self.width>0 then
		self:AddTriangle(-w2,-l2,0, -w2,l2-self.headSize, 0,w2,-l2,0)
		self:AddTriangle(-w2,l2-self.headSize,0, w2,l2-self.headSize,0, w2,-l2,0)
	end
	if self.headSize>0 then
		self:AddTriangle(-self.headSize,l2-self.headSize,0, 0,l2,0, self.headSize,l2-self.headSize,0)
	end

	AVRMesh.GenerateMesh(self)
end


AVR:RegisterMeshClass(AVRArrowMesh)
