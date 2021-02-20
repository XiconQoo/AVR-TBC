local ADDON_NAME="AVR"
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, true)

local _G = _G
local sin = math.sin
local cos = math.cos
local pi = math.pi

local Core=AVR

local unpackDouble=AVRUnpackDouble
local packDouble=AVRPackDouble

AVRCompass={}
AVRCompass.meshInfo={
	class="AVRCompass",
	derived=true,
	guiCreateNew=true,
	guiName=L["Compass"],
	receivable=false
}
function AVRCompass:New()
	if self ~= AVRCompass then return end
	local mesh=AVRDataMesh:New()
	mesh:AddLineData({	
		{	0,		20,		0,		0,		-10,	0,		nil}, -- n - s
		{	-10,	0,		0,		10,		0,		0,		nil}, -- w - e
		{	-4,		-4,		0,		4,		4,		0,		nil}, -- sw - ne
		{	-4,		4,		0,		4,		-4,		0,		nil}, -- nw - se
		
		{	2,		8,		0,		2,		12,		0,		nil}, -- n
		{	2,		12,		0,		5,		8,		0,		nil},
		{	5,		8,		0,		5,		12,		0,		nil},

		{	5,		-7,		0,		2,		-7,		0,		nil}, -- s
		{	2,		-7,		0,		2,		-9,		0,		nil},
		{	2,		-9,		0,		5,		-9,		0,		nil},
		{	5,		-9,		0,		5,		-11,	0,		nil},
		{	5,		-11,	0,		2,		-11,	0,		nil},

		{	10,		2,		0,		8,		2,		0,		nil}, -- e
		{	8,		2,		0,		8,		6,		0,		nil},
		{	8,		6,		0,		10,		6,		0,		nil},
		{	8,		4,		0,		9,		4,		0,		nil},

		{	-13,	6,		0,		-11,	2,		0,		nil}, -- w
		{	-11,	2,		0,		-10,	4,		0,		nil},
		{	-10,	4,		0,		-9,		2,		0,		nil},
		{	-9,		2,		0,		-7,		6,		0,		nil}
	})
	mesh:CaptureMesh()
	mesh.followPlayer=true
	mesh.name=L["Compass"]
	return mesh
end

AVRVargoth={}
AVRVargoth.meshInfo={
	class="AVRVargoth",
	derived=true,
	guiCreateNew=true,
	guiName=L["Vargoth"],
	receivable=false
}
function AVRVargoth:New()
	if self ~= AVRVargoth then return end
	local mesh=AVRCircleMesh:New(0.5)
	mesh:TranslateMesh(-2.15,2.15,0)
	mesh.followPlayer=true
	mesh.followRotation=true
	mesh.name=L["Vargoth"]
	return mesh
end

AVRBlink={}
AVRBlink.meshInfo={
	class="AVRBlink",
	derived=true,
	guiCreateNew=true,
	guiName=L["Blink"],
	receivable=false
}
function AVRBlink:New()
	if self ~= AVRBlink then return end
	local mesh=AVRCircleMesh:New(0.5)
	mesh:TranslateMesh(0,20,0)
	mesh.followPlayer=true
	mesh.followRotation=true
	mesh.name=L["Blink"]
	return mesh
end

AVRPositionCrosshair={}
AVRPositionCrosshair.meshInfo={
	class="AVRPositionCrosshain",
	derived=true,
	guiCreateNew=true,
	guiName=L["Position Crosshair"],
	receivable=false
}
function AVRPositionCrosshair:New(scale)
	if self ~= AVRPositionCrosshair then return end
	local mesh=AVRDataMesh:New()
	scale=scale or 0.5
	mesh:AddLineData({	
		{	0,		5,		0,		0,		-5,		0,		0},
		{	5,		0,		0,		-5,		0,		0,		0}
	},scale)	
	mesh:CaptureMesh()
	mesh.followPlayer=true
	mesh.followRotation=true
	mesh.name=L["Position Crosshair"]
	return mesh
end

AVRUnitMarker={}
AVRUnitMarker.meshInfo={
	class="AVRUnitMarker",
	derived=true,
	guiCreateNew=true,
	guiName=L["Unit marker"],
	receivable=false
}
function AVRUnitMarker:New(unit)
	if self ~= AVRUnitMarker then return end
	local mesh=AVRMarkerMesh:New()
	mesh.followUnit=unit
	mesh.name=L["Unit marker"]
	mesh:SetColor(nil,nil,nil,0.25)
	return mesh
end

--[[ -- This doesn't get saved properly and is very experimantal in any case
AVRTargetMarker={}
AVRTargetMarker.meshInfo={
	class="AVRTargetMarker",
	derived=true,
	guiCreateNew=false,
	guiName=nil,
	receivable=false
}function AVRTargetMarker:New(height)
	if self ~= AVRTargetMarker then return end
	local mesh=AVRMarkerMesh:New()
	local oldUpdate=mesh.OnUpdate
	local ix,iy,px,py
	mesh.OnUpdate=function(threed)
		oldUpdate(self,threed)
		
		px,py=Core:GetTargetPlatePos()
		if px==nil then 
			self.visible=false
			return
		end
		self.visible=true
		threed:InvertCameraMatrix()
		ix,iy,_=threed:InverseProject(px,py,self.height-threed.playerHeight)
		self.translateX,self.translateY=self.translateX+ix,self.translateY+iy
	end
	mesh.unit=unit
	mesh.height=height or 2.5
	mesh.name=L["Target marker"]
	
	return mesh
end
]]

AVR:RegisterMeshClass(AVRCompass,L["Compass"])
AVR:RegisterMeshClass(AVRVargoth,L["Vargoth"])
AVR:RegisterMeshClass(AVRBlink,L["Blink location"])
AVR:RegisterMeshClass(AVRPositionCrosshair,L["Position Crosshair"])
AVR:RegisterMeshClass(AVRUnitMarker,L["Unit marker"])
--AVR:RegisterMeshClass(AVRTargetMarker,L["Target marker"])
