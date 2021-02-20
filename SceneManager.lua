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

local Core=AVR

AVRSceneManager = {Embed = Core.Embed}
local T=AVRSceneManager

--- Constructs a new scene manager.
-- AVR automatically creates the scene manager and there should be
-- no need to create another.
function T:New(threed)
	if self ~= T then return end
	local s={}
	
	T:Embed(s)

	s.threed=threed			-- The 3d engine
	s.scenes={}				-- All scenes associated with this scene manager
	s.sceneid=0				-- Scene id counter 
	s.selection=0			-- Index of the currently selected scene
	
	s.scenesLoaded=false	-- A flag indicating if scenes were successfully loaded, see SaveScenes
	
	return s
end

--- Loads scenes from profile database, i.e. saved variables.
function T:LoadScenes()
	self.scenes={}
	if not Core.db.profile.scenes then 
		self.sceneid=1
		self.scenesLoaded=true
		return
	end
	self.sceneid=Core.db.profile.sceneid or 1
	for i,scene in ipairs(Core.db.profile.scenes) do
		local s=self:UnpackScene(scene,false)
		self.scenes[i]=s
		s:SetSceneManager(self)
	end
	for i,scene in ipairs(self.scenes) do
		if scene.from==nil and self.sceneid<=scene.id then
			self.sceneid=scene.id+1
		end
	end
	
	local ids={}
	for i,scene in ipairs(self.scenes) do
		if scene.from==nil then
			if not scene.id or scene.id==0 or ids[scene.id] then
				Core:Print(L["Loaded scene had invalid scene id, reassigning"])
				scene.id=self:GetNewSceneID()
			end
		end
	end
	self.selection=Core.db.profile.selectedScene
	if not self.selection then self.selection=0 end
	
	self.scenesLoaded=true
	Core:OptionsChanged()
end

--- Returns the selected scene or nil if nothing is selected.
-- @return The selected scene or nil if nothing is selected.
function T:GetSelectedScene()
	if self.selection<=0 or self.selection>#self.scenes then return nil
	else return self.scenes[self.selection] end
end

--- Returns the selected mesh of the selected scene or nil
-- if no scene is selected or the selected scene doesn't have any
-- mesh selected.
-- @return The selected mesh or nil.
function T:GetSelectedMesh()
	local scene=self:GetSelectedScene()
	if not scene then return nil end
	return scene:GetSelectedMesh()
end

--- Sets the currently selected scene.
-- @param scene Scene to select.
function T:SetSelectedScene(scene)
	if scene~=nil then
		if self.selection>0 and self.scenes[self.selection]==scene then return true end
		for i,s in ipairs(self.scenes) do
			if s==scene then
				self.selection=i
				Core:OptionsChanged()
				return true
			end
		end
	end
	self.selection=0
	Core:OptionsChanged()
	return false
end

--- Notification that the scene manager is about to be
-- removed from AVR.
function T:OnRemove()
	for i,scene in ipairs(self.scenes) do
		scene:OnRemove()
	end
end

--- Saves scenes to profile database, i.e. saved variables.
-- Will not save anything if self.scenesLoaded is false. This is to
-- prevent overwriting everything in saved variables if the loading
-- failed in some way.
function T:SaveScenes()
	-- don't save if we didn't load anything, otherwise we'll clear all scenes
	-- whenever there's a bug somewhere in loading
	if not self.scenesLoaded then return end
	
	Core.db.profile.scenes={}
	Core.db.profile.sceneid=self.sceneid
	Core.db.profile.selectedScene=self.selection
	local counter=1
	for i,scene in ipairs(self.scenes) do
		if scene.save then
			Core.db.profile.scenes[counter]=scene:Pack()
			counter=counter+1
		end
	end
end

--- Draws all visible scenes.
-- AVR calls this automatically every OnUpdate.
function T:DrawScenes()
	local scene
	local currentZone=Core.zoneData:GetCurrentZone()
	for i=1,#self.scenes do
		scene=self.scenes[i]
		if scene.visible and (scene.zone==nil or scene.zone==currentZone) then 
			self.scenes[i]:DrawScene()
		end
	end
end

--- Gets a new unused scene id.
-- There should be no need to call this, when you add a scene to
-- the scene manager, a new unused id is automatically assigned.
function T:GetNewSceneID()
	local id=self.sceneid
	self.sceneid=self.sceneid+1
	return id
end

--- Unpacks a scene and returns it.
-- Does not add the scene to this scene manager.
-- @param scene The packed scene table
-- @param commReceive A flag indicating whether this scene was received from the comm channel.
-- @return The unpacked scene or nil if it could not be unpacked.
function T:UnpackScene(scene,commReceive)
	local class=scene.class
	if not class then class="AVRScene" end
	if AVR.sceneClasses[class] then
		if not commReceive or AVR.receiveSceneClasses[class] then
			local s=AVR.sceneClasses[class]:New(self.threed)
			s:Unpack(scene)
			return s
		else
			Core:Print(format(L["Received scene with class %s but that class is not receivable"],class))
		end
	else
		Core:Print(format(L["Trying to unpack scene, unknown class %s"],class))
		if not commReceive then
			local s=AVRUnknownScene:New(self.threed)
			s:Unpack(scene)
			return s
		end
	end
	return nil
end

--- Adds a scene received from addon channel possibly overwriting a previous
-- scene. If an old scene from same user with same id is found, it is
-- overwritten. Otherwise a new scene is added.
-- @param scene The scene to add.
function T:ReceiveScene(scene)
	scene:SetSceneManager(self)
	for i=1,#self.scenes do
		local s=self.scenes[i]
		if s.from==scene.from and s.id==scene.id then
			self.scenes[i]=scene
			return
		end
	end
	insert(self.scenes,scene)
	
	Core:OptionsChanged()
end

--- Adds a scene in this scene manager.
-- Automatically assigns a scene id for the scene and sets its scene manager.
-- @param scene The scene to add.
function T:AddScene(scene,select)
	scene.from=nil
	scene.id=self:GetNewSceneID()
	scene:SetSceneManager(self)
	insert(self.scenes,scene)
	
	if scene.guiVisible then
		if select==nil or select then
			self.selection=#self.scenes
		end
		Core:OptionsChanged()	
	end
end

--- Removes a scene from this scene manager.
-- @param scene The scene to remove.
function T:RemoveScene(scene)
	for i=1,#self.scenes do
		local s=self.scenes[i]
		if s==scene then
			remove(self.scenes,i)
			scene:OnRemove()
			if self.selection==i then
				self.selection=0
			end
			break
		end
	end
	
	if scene.guiVisible then
		Core:OptionsChanged()
	end
end
