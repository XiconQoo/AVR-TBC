local ADDON_NAME="AVR"
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, true)

local _G = _G
local pairs = pairs
local ipairs = ipairs
local remove = table.remove
local insert = table.insert
local max = math.max
local min = math.min
local abs = math.abs
local atan2 = math.atan2
local sin = math.sin
local cos = math.cos
local type = type
local select = select
local next = next
local GetTime = GetTime
local deg2rad = math.pi/180.0
local pi = math.pi
local tostring,tonumber=tostring,tonumber
local strlen=string.len

local raidID={}
local partyID={}
for i=1,40 do raidID[i]="raid"..i end
for i=1,4 do partyID[i]="party"..i end


AVRRangeWarningScene={Embed=AVR.Embed}
-- Info table for AVR. Needed by AVR:RegisterSceneClass which is called at the very end of this file.
AVRRangeWarningScene.sceneInfo={
	class="AVRRangeWarningScene",	-- String used to identify this scene class
	guiName=L["Range Warning"],		-- User visible name
	guiCreateNew=true, 				-- User can create range warning scenes from the normal options
	receivable=true 				-- Can receive range warning scenes from others
}
--- Constructor for range warning scene. As all scenes should do, 
-- only requires the first parameter.
function AVRRangeWarningScene:New(threed,range,radius)
	if self ~= AVRRangeWarningScene then return end
	local s=AVRScene:New(threed) -- Extends normal AVRScene
	AVRRangeWarningScene:Embed(s)
	
	-- Set range warning specific options
	s.class=AVRRangeWarningScene.sceneInfo.class
	s.range=range or 10
	s.radius=radius or 1
	s.rangeSq=s.range*s.range
	s.spokes=6
	s.circleMesh=nil
	s.line=false
	s.useTexture=false
	s.classColor=false
	s.color={1.0,1.0,1.0,0.5}
	s.markerMeshes={}
	s:SetCircle(true)
	s.autoFireOptionChanges=false
	s.name=L["Range warning"]
	return s
end

--- Clears all marker meshes, they will be created again as needed.
-- Called when user changes the appearance of them in any way.
function AVRRangeWarningScene:ClearMarkerMeshes()
	for i,m in ipairs(self.markerMeshes) do
		m:Remove()
	end
	self.markerMeshes={}
end

-- Getters and setters for options

function AVRRangeWarningScene:SetLine(value)
	self.line=value
	self:ClearMarkerMeshes()
end
function AVRRangeWarningScene:GetLine()
	return self.line
end

function AVRRangeWarningScene:SetRange(range)
	self.range=range
	self.rangeSq=self.range*self.range
	if self.circleMesh~=nil then
		self.circleMesh:SetRadius(self.range)
	end
end

function AVRRangeWarningScene:SetRadius(radius)
	self.radius=radius
	self:ClearMarkerMeshes()
end

function AVRRangeWarningScene:SetColor(r,g,b,a)
	self.color={r,g,b,a}
	self:ClearMarkerMeshes()
	self:SetCircle(self.circle,true)
end

function AVRRangeWarningScene:SetCircle(value,remake)
	if remake and self.circleMesh then
		self.circleMesh:Remove()
		self.circleMesh=nil
	end
	
	self.circle=value
	if self.circle and self.circleMesh==nil then
		self.circleMesh=AVRCircleMesh:New(self.range)
		self.circleMesh:SetColor(self.color[1],self.color[2],self.color[3],self.color[4])
		self.circleMesh.followPlayer=true
	elseif not self.circle and self.circleMesh~=nil then
		self.circleMesh:Remove()
		self.circleMesh=nil
	end
end
function AVRRangeWarningScene:GetCircle()
	return self.circle
end

function AVRRangeWarningScene:GetSpokes()
	return self.spokes
end
function AVRRangeWarningScene:SetSpokes(spokes)
	self.spokes=spokes
	self:ClearMarkerMeshes()
end

function AVRRangeWarningScene:GetClassColor()
	return self.classColor
end
function AVRRangeWarningScene:SetClassColor(value)
	self.classColor=value
	self:ClearMarkerMeshes()
end

function AVRRangeWarningScene:SetUseTexture(value)
	self.useTexture=value
	self:ClearMarkerMeshes()
end
function AVRRangeWarningScene:GetUseTexture()
	return self.useTexture
end

-- Completely override normal options.
function AVRRangeWarningScene:GetOptions()
	local original=AVRScene.GetOptions(self)
	local ret={
		type = "group",
		name = (self.from and (self.from..": "..self.name) or self.name),
		get = function(info) 
			if type(info)~="string" then info=info[#info] end
			local func="Get"..string.upper(string.sub(info,1,1))..string.sub(info,2)
			if self[func] then return self[func](self) 
			else return self[info] end
		end,
		set = function(info,val)
			if type(info)~="string" then info=info[#info] end
			local func="Set"..string.upper(string.sub(info,1,1))..string.sub(info,2)
			if self[func] then self[func](self,val)
			else self[info]=val end
		end,
		args = {
			name = {
				type = "input",
				name = L["Name"],
				order = 10,
				width = "full",
				set = 	function(_,val)
							self.name=val
							AVR:OptionsChanged()
						end
			},
			visible = {
				type = "toggle",
				name = L["Visible"],
				order = 15
			},
			select = {
				type = "toggle",
				name = L["Select"],
				order = 20,
				get =	function(_)
							if AVR:GetSceneManager():GetSelectedScene()==self then return true
							else return false end
						end,
				set =	function(_,val)
							if val then AVR:GetSceneManager():SetSelectedScene(self)
							else AVR:GetSceneManager():SetSelectedScene(nil) end
						end
			},
			remove = {
				type = "execute",
				name = L["Remove scene"],
				desc = L["Remove scene desc"],
				order = 30,
				width = "full",
				confirm = true,
				func = function() self:Remove() end
			},
			range = {
				type = "range",
				name = L["Range"],
				desc = L["Range range desc"],
				order = 40,
				width = "full",
				min = 0.0, max=500, bigStep=1.0
			},
			radius = {
				type = "range",
				name = L["Radius"],
				desc = L["Range radius desc"],
				order = 50,
				width = "full",
				min = 0.0, max=30, bigStep=0.5
			},
			circle = {
				type = "toggle",
				name = L["Draw circle"],
				desc = L["Draw circle desc"],
				order = 60,
			},
			line = {
				type = "toggle",
				name = L["Draw line"],
				desc = L["Draw line desc"],
				order = 70,
				width = "full"
			},
			spokes = {
				type = "range",
				name = L["Spokes"],
				order = 80,
				width = "full",
				min = 4, max=20, step=2.0
			},
			useTexture = {
				type = "toggle",
				name = L["Use texture"],
				desc = L["Use texture desc marker"],
				order = 85,
				width = "full"
			},
			classColor = {
				type = "toggle",
				name = L["Class color"],
				order = 90,
				width = "full"
			},			
			color = {
				get = 	function(info)
							return self.color[1],self.color[2],self.color[3],self.color[4]
						end,
				set =	function(info,r,g,b,a)
							self:SetColor(r,g,b,a)
						end,
				type = "color",
				name = L["Color"],
				hasAlpha = true,
				order = 100
			},
			sharing=original.args.sharing,
			id=original.args.id,
			from=original.args.from,
		}
	}
	ret.args.sharing.order=110
	ret.args.id.order=120
	ret.args.from.order=130
	return ret
end

local markers={}
for i=1,40 do insert(markers,'') end
--- Override normal DrawScene.
function AVRRangeWarningScene:DrawScene()
	local px,py
	local sx,sy=self.threed:GetUnitPosition("player")
	local dx,dy
	local numMarkers=0 
	-- Iterate through raid/party members and add anyone that needs to be marked in markers array.
	local numRaidMembers=GetNumRaidMembers()
	if numRaidMembers>0 then
		for i=1,numRaidMembers do
			if not UnitIsUnit(raidID[i],"player") then 
				px,py=self.threed:GetUnitPosition(raidID[i])
				if px~=0 or py~=0 then
					dx,dy=sx-px,sy-py
					if dx*dx+dy*dy<=self.rangeSq then
						if not UnitIsDead(raidID[i]) then
							numMarkers=numMarkers+1
							markers[numMarkers]=raidID[i]
						end
					end
				end
			end
		end
	else
		for i=1,4 do
			px,py=self.threed:GetUnitPosition(partyID[i])
			if px~=0 or py~=0 then
				dx,dy=sx-px,sy-py
				if dx*dx+dy*dy<=self.rangeSq then
					if not UnitIsDead(partyID[i]) then
						numMarkers=numMarkers+1
						markers[numMarkers]=partyID[i]
					end
				end
			end
		end
	end
	
	-- Create new marker meshes if needed
	while #self.markerMeshes<numMarkers do 
		local m=self:AddMesh(AVRMarkerMesh:New(self.radius,self.spokes),false,false)
		m.followPlayer=false
		m.followRotation=false
		m.classColor=self.classColor
		m.line=self.line
		m:SetColor(self.color[1],self.color[2],self.color[3],self.color[4])
		m:SetUseTexture(self.useTexture)
		insert(self.markerMeshes,m)
	end
	-- Set follow unit on marker meshes and then draw them. Note that the scene may contain
	-- more marker meshes than needed but they won't be drawn.
	for i=1,numMarkers do
		self.markerMeshes[i].followUnit=markers[i]
		self.markerMeshes[i]:OnUpdate(self.threed)
		self.threed:DrawMesh(self.markerMeshes[i])
	end
	-- Draw range circle if it's enabled
	if self.circleMesh then
		self.circleMesh:OnUpdate(self.threed)
		self.threed:DrawMesh(self.circleMesh)
	end
	-- No call to original DrawScene implementation, we handled drawing already
end

function AVRRangeWarningScene:Pack()
	self:ClearScene()
	local s=AVRScene.Pack(self)
	s.radius=self.radius
	s.range=self.range
	s.spokes=self.spokes
	s.circle=self.circle
	s.line=self.line
	s.classColor=self.classColor
	s.useTexture=self.useTexture
	s.color={self.color[1],self.color[2],self.color[3],self.color[4]}
	return s
end

function AVRRangeWarningScene:Unpack(s)
	AVRScene.Unpack(self,s)
	self.range=s.range or 10
	self.rangeSq=self.range*self.range
	self.radius=s.radius or 1
	self.spokes=s.spokes or 6
	if s.circle==nil then self.circle=true 
	else self.circle=s.circle end
	if s.line==nil then self.line=false
	else self.line=s.line end
	if s.classColor==nil then self.classColor=false
	else self.classColor=s.classColor end
	if s.color then self.color={s.color[1],s.color[2],s.color[3],s.color[4]}
	else self.color={1.0,1.0,1.0,0.5} end
	if s.useTexture then self.useTexture=s.useTexture
	else self.useTexture=false end
	
	self:SetCircle(self.circle,true)
	self:SetRange(self.range)
	self:ClearMarkerMeshes()
end

-- Register the scene
AVR:RegisterSceneClass(AVRRangeWarningScene)
