local ADDON_NAME="AVR"
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, true)

local _G = _G
local sin = math.sin
local cos = math.cos
local pi = math.pi

local Core=AVR

local unpackDouble=AVRUnpackDouble
local packDouble=AVRPackDouble

AVRYardStickMesh={Embed=Core.Embed}
AVRYardStickMesh.meshInfo={
	class="AVRYardStickMesh",
	derived=false,
	guiCreateNew=true,
	guiName=L["Yard stick"],
	receivable=true
}
function AVRYardStickMesh:New(max,min,vertical,divisions)
	if self ~= AVRYardStickMesh then return end
	local s=AVRMesh:New()
	AVRYardStickMesh:Embed(s)
	s.class=AVRYardStickMesh.meshInfo.class
	s.min=min and math.floor(min) or 0
	s.max=max and math.ceil(max) or 10
	s.divisions=divisions or 2
	if vertical~=nil then s.vertical=vertical
	else s.vertical=false end
	s.vertices=nil
	s.followPlayer=true
	s.followRotation=true
	s.name=L["Yard stick"]
	return s
end

function AVRYardStickMesh:Pack()
	local s=AVRMesh.Pack(self)
	s.min=self.min
	s.max=self.max
	s.ver=self.vertical
	s.div=self.divisions
	return s
end

function AVRYardStickMesh:Unpack(s)
	AVRMesh.Unpack(self,s)
	self.min=s.min or 0
	self.max=s.max or 10
	self.vertical=s.ver or false
	self.divisions=s.div or 2
	self.vertices=nil
end


function AVRYardStickMesh:SetMin(min)
	self.min=math.floor(min)
	self.vertices=nil
	return self
end
function AVRYardStickMesh:SetMax(max)
	self.max=math.ceil(max)
	self.vertices=nil
	return self
end
function AVRYardStickMesh:SetDivisions(divisions)
	self.divisions=math.floor(divisions)
	self.vertices=nil
	return self
end
function AVRYardStickMesh:SetVertical(vertical)
	self.vertical=vertical
	self.vertices=nil
	return self
end


function AVRYardStickMesh:GetOptions()
	local o=AVRMesh.GetOptions(self)
	o.args.yardStick = {
		type = "group",
		name = L["Yard stick properties"],
		inline = true,
		order = 80,
		args = {
			min= {
				type = "range",
				name = L["Min"],
				order = 10,
				width = "full",
				min = -100, max=100, step=1.0, bigStep=1.0
			},					
			max= {
				type = "range",
				name = L["Max"],
				order = 20,
				width = "full",
				min = -100, max=100, step=1.0, bigStep=1.0
			},
			vertical = {
				type = "toggle",
				name = L["Vertical"],
				order = 30,
				width = "full"
			},
			divisions = {
				name = L["Divisions"],
				type = "range",
				order = 40,
				min = 1,
				max = 100,
				bigStep = 1
			},
		}
	}
	return o
end
function AVRYardStickMesh:GenerateMesh()
	local s=0
	local w=0
	local h=0
	while s<=(self.max-self.min)*self.divisions do
		h=self.min+1/self.divisions*s
		if (s%self.divisions)==0 then w=0.2
		elseif (s%(self.divisions/2))==0 then w=0.1
		elseif (s%(self.divisions/4))==0 then w=0.085
		elseif (s%(self.divisions/10))==0 then w=0.07
		else w=0.05 end
	
		if self.vertical then self:AddLine(-w,0,h, w,0,h, 0)
		else self:AddLine(-w,h,0, w,h,0, 0) end
		s=s+1
	end
	if self.vertical then self:AddLine(0,0,self.min, 0,0,self.max, 0)
	else self:AddLine(0,self.min,0, 0,self.max,0, 0) end
	
	AVRMesh.GenerateMesh(self)
end

AVR:RegisterMeshClass(AVRYardStickMesh)
