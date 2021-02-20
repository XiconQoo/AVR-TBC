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
local format = string.format

local Core=AVR

AVRScene = {Embed = Core.Embed}
AVRScene.sceneInfo={
	class="AVRScene",
	guiName=L["Normal scene"],
	guiCreateNew=true,
	receivable=true
}

--- Constructs a new AVR scene.
-- Overriding classes must have similar constructor.
-- @param threed The 3d engine.
function AVRScene:New(threed)
	if self ~= AVRScene then return end
	local s={}
	
	AVRScene:Embed(s)

	s.threed=threed 	-- the 3d engine
	s.meshes={} 		-- all meshes in this scene
	s.selection=0 		-- index of the currently selected mesh or 0 for no selection
	s.class=AVRScene.sceneInfo.class -- scene class identifier
	
	s.guiVisible=true 	-- is this scene visible in options
	s.save=true 		-- should this scene be saved to saved variables
	
	s.visible=true 		-- is this scene drawn
	s.name=L["Scene"] 	-- name of the scene
	s.from=nil 			-- who is this scene from if it was received through addon channel
	s.id=0 				-- id for the scene, mostly needed to decide which scene to overwrite when receiving same scene again through addon channel
	s.zone=nil			-- where this scene is active or nil for everywhere
	s.shareChannel="Raid" -- channel this scene is shared with when user clicks the send button
	s.shareTarget=""	-- share target if channel is whisper
	
	s.autoFireOptionChanges=true -- fire option changed events automatically, some subclasses may want to turn this off
	s.sceneManager=nil	-- the scene manager
	s.removed=false		-- flag set when the scene has been removed
	
	s.deferRemove=false -- this is true when iterating meshes
	s.deferredRemove={}	-- deferred remove operations are stored here for later processing
	
	return s
end

--- Packs the scene for saved variables or for to be sent through the addon channel.
-- Should return a table with all the relevant data to reconstruct the scene
-- afterwards. Default implementation puts all basic options and packs all contained
-- meshes.
--
-- Subclasses should override this but still call the default implementation and then
-- add their own data in the table. In some cases you might not want the meshes to be
-- packed. You can simply overwrite the meshes value in the table or you can
-- assign an empty table in self.meshes and then restore it afterwards.
--
-- @return A table containing enough data to reconstruct this scene.
function AVRScene:Pack()
	local s={
		name=self.name,
		class=self.class,
		visible=self.visible,
		from=self.from,
		id=self.id,
		selection=self.selection,
		zone=self.zone,
		shareChannel=self.shareChannel,
		shareTarget=self.shareTarget,
		meshes={}
	}
	for i=1,#self.meshes do
		local packed=self.meshes[i]:Pack()
		if packed then insert(s.meshes,packed) end
	end
	return s
end

--- Unpacks the scene from saved variables or a message received through the
-- addon channel.
-- @param s The packed table as returned by Pack.
-- @param commReceive A boolean flag indicating if this scene was received
--                    from the addon channel. In such a you might not want to
--                    blindly trust everything in the table.
function AVRScene:Unpack(s,commReceive)
	self.name=s.name or L["Scene"]
	self.visible=s.visible
	if self.visible==nil then self.visible=true end
	self.from=s.from
	self.id=s.id or 0
	self.selection=s.selection or 0
	self.zone=s.zone
	self.shareChannel=s.shareChannel or "RAID"
	self.shareTarget=s.shareTarget or ""
	self.meshes={}
	for i=1,#s.meshes do
		local class=s.meshes[i].c
		local m
		
		if AVR.meshGeneratorClasses[class] then
			if not commReceive or AVR.receiveMeshClasses[class] then
				m=AVR.meshGeneratorClasses[class]:New()
				m:Unpack(s.meshes[i])
				insert(self.meshes,m)
				m:SetScene(self)
			else
				Core:Print(format(L["Received mesh with class %s but that class is not receivable"],class))
			end
		else
			Core:Print(format(L["Trying to unpack mesh, unknown class %s"],class))
			if not commReceive then
				m=AVRUnknownMesh:New()
				m:Unpack(s.meshes[i])
				insert(self.meshes,m)
				m:SetScene(self)
			end
		end
	end
	
	if self.autoFireOptionChanges then Core:OptionsChanged() end
end


function AVRScene:GetToolSettings(info)
	if type(info)=="string" then
		info={info}
	end
	for i=1,#info do
		if self.toolSettings[info[i]] then
			local t=self.toolSettings
			for j=i,#info do
				t=t[info[j]]
				if t==nil then return nil end
			end
			return t
		end
	end
	return nil
end

function AVRScene:SetToolSettings(info,val)
	if type(info)=="string" then
		info={info}
	end
	for i=1,#info do
		if self.toolSettings[info[i]] then
			local t=self.toolSettings
			for j=i,#info-1 do
				t=t[info[j]]
				if t==nil then return end
			end
			t[info[#info]]=val
		end
	end
	return nil
end
--- Sets the scene manager managing this scene.
-- @param The scene manager.
function AVRScene:SetSceneManager(m)
	self.sceneManager=m
end

--- Selects this scene.
function AVRScene:SelectScene()
	if not self.sceneManager then return end
	self.sceneManager:SetSelectedScene(self)
end

--- Draws this scene.
-- Default implementation iterates through self.meshes,
-- calls OnUpdate on each and then draws each.
-- Subclasses may override this and perform other preparations
-- before drawing. They may then use the default implementation
-- to draw all contained meshes or may handle the drawing
-- themselves and draw only some of them.
function AVRScene:DrawScene()
	self.deferRemove=true
	for i=1,#self.meshes do
		self.meshes[i]:OnUpdate(self.threed)
		self.threed:DrawMesh(self.meshes[i])
	end
	self.deferRemove=false
	while #self.deferredRemove>0 do
		local m=remove(self.deferredRemove)
		self:RemoveMesh(m)
	end
end

function AVRScene:SetName(name)
	self.name=name
	if self.autoFireOptionChanges then Core:OptionsChanged() end
end

--- Sets the zone where this scene is enabled.
-- The zone should be zone name as returned by GetMapInfo() and 
-- zone level, if greater than 0, as returned by GetCurrentMapDungeonLevel().
-- For example "IcecrownCitadel4". nil value indicates that the
-- scene should be enabled everywhere
function AVRScene:SetZone(zone)
	self.zone=zone
	if self.autoFireOptionChanges then Core:OptionsChanged() end
end

function AVRScene:GetZone()
	return self.zone
end

--- Adds a mesh to this scene.
-- @param select If the new mesh should be selected automatically, defaults to true.
-- @param selectScene If this scene should be selected automaticall, defaults to true.
function AVRScene:AddMesh(mesh,select,selectScene)
	mesh:SetScene(self)
	insert(self.meshes,mesh)
	if select==nil or select then
		self.selection=#self.meshes
	end
	if self.guiVisible and (selectScene==nil or selectScene) then
		self:SelectScene()
	end
	
	if self.autoFireOptionChanges then Core:OptionsChanged() end
	return mesh
end

--- Removes a mesh from this scene.
-- Also notifies the mesh by calling its OnRemove
-- @param the mesh to remove.
function AVRScene:RemoveMesh(mesh)
	if self.deferRemove then
		insert(self.deferredRemove,mesh)
		return
	end
	local sel=self:GetSelectedMesh()
	for i=1,#self.meshes do
		if self.meshes[i]==mesh then
			table.remove(self.meshes,i)
			mesh:OnRemove()
			break
		end
	end
	if sel then self:SetSelectedMesh(sel) end
	
	if self.autoFireOptionChanges then Core:OptionsChanged() end
end

--- Returns the last mesh added to this scene.
-- @return The last mesh added to this scene.
function AVRScene:GetLastMesh()
	if #self.meshes==0 then return nil end
	return self.meshes[#self.meshes]
end

--- Selects a mesh by its index.
-- @param num The index of the mesh to be selected or nil to select nothing.
function AVRScene:SetSelectedMeshNum(num)
	if num==nil or num<0 or num>#self.meshes then num=0 end
	self.selection=num
end

--- Selects a mesh.
-- @param mesh The mesh to be selected.
function AVRScene:SetSelectedMesh(mesh)
	if mesh~=nil then
		for i=1,#self.meshes do
			if self.meshes[i]==mesh then
				self.selection=i
				if self.autoFireOptionChanges then Core:OptionsChanged() end
				return
			end
		end
	end
	self.selection=0
	if self.autoFireOptionChanges then Core:OptionsChanged() end
end

--- Gets the currently selected mesh.
-- @return Currently selected mesh or nil if nothing is selected.
function AVRScene:GetSelectedMesh()
	if self.selection<=0 then return nil
	else return self.meshes[self.selection] end
end

--- Duplicates this scene clearing the from field in the process.
-- Clearing the from field essentially changes the owner to the player.
-- This is useful if you want to make a permanent copy of a scene you have received from
-- someone else.
function AVRScene:MakeOwnCopy()
	local p=self:Pack()
	local scene=AVRScene:New(self.threed)
	scene:Unpack(p)
	self.sceneManager:AddScene(scene)
end

--- Clears the scene by removing all meshes.
function AVRScene:ClearScene()
	self.selection=0
	for i=1,#self.meshes do
		self.meshes[i]:OnRemove()
	end
	self.meshes={}
	
	if self.autoFireOptionChanges then Core:OptionsChanged() end
end

--- Notification that this scene is about to be removed from the scene manager.
function AVRScene:OnRemove()
	self.removed=true
end

--- Removes this mesh from the scene manager.
function AVRScene:Remove()
	self.sceneManager:RemoveScene(self)
end

--- Returns the args part for an option table group which
-- contains options of all included meshes.
-- If subclasses override GetOptions then this method might never be called.
-- @return The args part of an option table group.
-- @see GetOptions
function AVRScene:GetMeshesOptionsArgs()
	local ret={}
	local i,m
	for i,m in ipairs(self.meshes) do
		ret[""..i]=m:GetOptions()
	end
	return ret
end

--- Gets an options table for this scene.
-- Subclasses may add their own settings in the default options table or
-- they may create a completely new options table without any of the default
-- options. It is a good idea to include some very basic options like the
-- name, visibility and a way to remove the scene. If you make sure that 
-- self.guiVisible is always false then the options table should never
-- be needed.
-- @return The scene options table.
function AVRScene:GetOptions()
	if not self.toolSettings then
		self.toolSettings={
			paint = {
				followPlayer = false,
				followRotation = false,
				detail = 0.5
			}
		}
	end

	local r={
		name = (self.from and (self.from..": "..self.name) or self.name),
		type = "group",
		get = function(info) 
			if type(info)~="string" then info=info[#info] end
			return self[info]
		end,
		set = function(info,val)
			if type(info)~="string" then info=info[#info] end
			self[info]=val
		end,
		args={
			name = {
				type = "input",
				name = L["Name"],
				order = 10,
				width = "full",
				set = 	function(_,val)
							self.name=val
							Core:OptionsChanged()
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
							if Core.sceneManager:GetSelectedScene()==self then return true
							else return false end
						end,
				set =	function(_,val)
							if val then Core.sceneManager:SetSelectedScene(self)
							else Core.sceneManager:SetSelectedScene(nil) end
						end
			},
			clear = {
				type = "execute",
				name = L["Clear scene"],
				desc = L["Clear scene desc"],
				order = 25,
				width = "full",
				confirm = true,
				func = function() self:ClearScene() end
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
			zone = {
				name = L["Zone"],
				desc = L["Zone desc"],
				type = "input",
				order = 40,
				set = 	function(_,val)
							val=string.gsub(string.gsub(val,"^%s*",""),"%s*$","")
							if string.len(val)==0 then val=nil end
							self:SetZone(val)
						end
				
			},
			currentZone = {
				name = L["Current zone"],
				desc = L["Current zone desc"],
				type = "execute",
				order = 50,
				func = function() self:SetZone(Core.zoneData:GetCurrentZone()) end
			},
			sharing = {
				type = "group",
				name = L["Share"],
				order = 60,
				inline = true,
				args = {
					shareChannel = {
						name = L["Channel"],
						desc = L["Channel desc"],
						type = "select",
						order = 10,
						values = {RAID="Raid",PARTY="Party",GUILD="Guild",BATTLEGROUND="Battleground",WHISPER="Whisper"},
						set = 	function(_,val)
									if val~="WHISPER" then self.shareTarget="" end
									self.shareChannel=val
								end
					},
					shareTarget = {
						name = L["Whisper target"],
						desc = L["Whisper target desc"],
						type = "input",
						order = 20,
						set = 	function(_,val)
									if self.shareChannel=="WHISPER" then self.shareTarget=val end
								end
					},
					send = {
						name = L["Send"],
						type = "execute",
						order = 30,
						width = "full",
						func =	function()
									Core:SendScene(self,self.shareChannel,self.shareTarget)
								end
					},
					export = {
						name = L["Export to clipboard"],
						type = "execute",
						order = 40,
						width = "full",
						func =	function()
									Core.AceConfigDialog:Close(ADDON_NAME)						
									Core:ExportScene(self)
								end
					}
				}
			},
			id = {
				name = L["Scene id"],
				type = "input",
				disabled = true,
				order = 70,
				set = function() end,
				get = function() return ''..self.id end
			},
			from = {
				name = L["Owner"],
				type = "input",
				disabled = true,
				order = 80,
				set = function() end,
			},
			ownCopy = {
				name = L["Make own copy"],
				desc = L["Make own copy desc"],
				type = "execute",
				order = 90,
				disabled = (self.from==nil),
				func = function() self:MakeOwnCopy() end
			},
			paint = {
				type = "group",
				name = L["Paint"],
				order = 140,
				get = function(info) return self:GetToolSettings(info) end,
				set = function(info,val) self:SetToolSettings(info,val) end,
				args = {
					followPlayer = { name=L["Follow player"], type = "toggle" },
					followRotation = { name=L["Follow rotation"], type = "toggle" },
					detail = { 
						name = L["Detail level"],
						type = "range",
						min = 0.1,
						max = 5.0,
						bigStep = 0.1,
					},
					start = { 
						type = "execute",
						name = L["Start"],
						func = function()
							Core.mousePaint:EnableDraw(true,self.toolSettings.paint.followPlayer,self.toolSettings.paint.followRotation,self)
							Core.mousePaint:SetDetailLevel(self.toolSettings.paint.detail)
						end
					}
				}
			},
			meshes = {
				type = "group",
				name = L["Meshes"],
				desc = L["Meshes desc"],
				order = 150,
				args = self:GetMeshesOptionsArgs(self)
			},
			newMesh = {
				type = "group",
				name = L["Add new mesh"],
				order = 160,
				args = AVR:GetNewMeshArgs(self)
			},
		}
	}
	if not AVR.receiveSceneClasses[self.class] then r.args.sharing=nil end
	return r
end


AVR:RegisterSceneClass(AVRScene)


-------------------------------------------------------------------------
------     Wrapper to hold unknown scenes     ---------------------------
-------------------------------------------------------------------------

AVRUnknownScene = {Embed = Core.Embed}
AVRUnknownScene.sceneInfo={
	class="AVRUnknownScene",
	guiName=nil,
	guiCreateNew=false,
	receivable=false
}
--- Constructs a scene that can be used to hold packed data of an unknown scene type.
function AVRUnknownScene:New(threed)
	if self ~= AVRUnknownScene then return end
	local s=AVRScene:New(threed)
	AVRUnknownScene:Embed(s)
	s.packed={}
	return s
end

function AVRUnknownScene:Pack()
	return self.packed
end

function AVRUnknownScene:Unpack(s,commReceive)
	AVRScene.Unpack(self,s)
	self.packed=s
end

function AVRUnknownScene:DrawScene()
end

function AVRUnknownScene:GetOptions()
	return {
		type = "group",
		name = self.name,	
		args = {
			name = {
				type = "description",
				name = L["Name"],
				order = 10,
				width = "full",
			},
			desc = {
				type = "description",
				name = format(L["UNKNOWN SCENE"],self.packed.class),
				order = 20
			},
			remove = {
				type = "execute",
				name = L["Remove scene"],
				order = 30,
				width = "full",
				confirm = true,
				func = function() self:Remove() end
			},			
		}
	}
end

AVR:RegisterSceneClass(AVRUnknownScene)
