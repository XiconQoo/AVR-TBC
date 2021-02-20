local ADDON_NAME="AVR"
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, true)

local _G = _G
local sin = math.sin
local cos = math.cos
local pi = math.pi

local Core=AVR

local unpackDouble=AVRUnpackDouble
local packDouble=AVRPackDouble

AVRConeMesh={Embed=Core.Embed}
AVRConeMesh.meshInfo={
	class="AVRConeMesh",
	derived=false,
	guiCreateNew=true,
	guiName=L["Cone"],
	receivable=true
}
function AVRConeMesh:New(radius,angle,segments,dashed,circle,width)
	if self ~= AVRConeMesh then return end
	local s=AVRMesh:New()
	AVRConeMesh:Embed(s)
	s.class=AVRConeMesh.meshInfo.class
	s.radius=radius or 10
	s.angle=angle or 30
	s.angleR=s.angle*pi/180
	s.segments=segments or max(3,math.ceil(s.angleR/(2*pi)*30))
	s.dashed=dashed or false	
	if circle~=nil then s.circle=circle
	else s.circle=true end
	s.lineWidth=width
	s.vertices=nil
	s.name=L["Cone"]
	return s
end

function AVRConeMesh:Pack()
	local s=AVRMesh.Pack(self)
	s.rad=packDouble(self.radius)
	s.ang=packDouble(self.angle)
	s.seg=self.segments
	s.das=self.dashed
	s.cir=circle
	s.lw=self.lineWidth
	return s
end

function AVRConeMesh:Unpack(s)
	AVRMesh.Unpack(self,s)
	self.radius=unpackDouble(s.rad) or 10
	self.angle=unpackDouble(s.ang) or 30
	self.angleR=self.angle*pi/180
	self.segments=s.seg or max(3,math.ceil(self.angleR/(2*pi)*30))
	self.dashed=s.das or false
	self.lineWidth=s.lw
	if s.cir then self.circle=s.cir
	else self.circle=true end
	self.vertices=nil
end

function AVRConeMesh:SetRadius(radius)
	self.radius=radius
	self.vertices=nil
	return self
end
function AVRConeMesh:SetAngle(angle)
	self.angle=angle
	self.angleR=self.angle*pi/180
	self.vertices=nil
	return self
end
function AVRConeMesh:SetSegments(segments)
	self.segments=math.floor(segments)
	self.vertices=nil
	return self
end
function AVRConeMesh:SetDashed(dashed)
	self.dashed=dashed
	self.vertices=nil
	return self
end
function AVRConeMesh:SetCircle(circle)
	self.circle=circle
	self.vertices=nil
	return self
end

function AVRConeMesh:GetOptions()
	local o=AVRMesh.GetOptions(self)
	o.args.cone = {
		type = "group",
		name = L["Cone properties"],
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
			angle = {
				type = "range",
				name = L["Angle"],
				order = 15,
				width = "full",
				min = 0.0, max=360, bigStep=1.0
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
				width = "full"
			},
			circle = {
				type = "toggle",
				name = L["Circle"],
				order = 40,
				width = "full"
			}
		}
	}
	return o
end

function AVRConeMesh:GenerateMesh()

	local a
	local ox=cos(pi/2-self.angleR/2)*self.radius
	local oy=sin(pi/2-self.angleR/2)*self.radius
	local ex=cos(pi/2+self.angleR/2)*self.radius
	local ey=sin(pi/2+self.angleR/2)*self.radius
	local x,y
	
	self:AddLine(0,0,0,ox,oy,0,self.lineWidth)
	self:AddLine(0,0,0,ex,ey,0,self.lineWidth)
	
	if self.circle then
		for i=1,self.segments do
			a=pi/2-self.angleR/2+self.angleR/self.segments*i
			
			x=cos(a)*self.radius
			y=sin(a)*self.radius
			
			if not self.dashed or (i%2)==0 then
				self:AddLine(ox,oy,0,x,y,0,self.lineWidth)
			end
			
			ox,oy=x,y
		end
	end
	
	AVRMesh.GenerateMesh(self)
end

AVR:RegisterMeshClass(AVRConeMesh)
