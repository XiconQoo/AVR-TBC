local ADDON_NAME="AVR"
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, true)

local _G = _G
local pairs = pairs
local ipairs = ipairs
local remove = table.remove
local insert = table.insert
local type = type
local select = select
local next = next
local format = string.format

local Core=AVR

--- Sends a scene to other players through the addon channel
-- @param scene Scene to send.
-- @param distribution Distribution of addon message, passed as type to SendAddonMessage. Defaults to "RAID".
-- @param prio Addon message priority passed to AceComm. Defaults to "BULK".
function Core:SendScene(scene,distribution,target,prio)
	if scene.from~=nil then
		self:Print(L["Can't send a scene from someone else. Make own copy first."])
		return
	end

	distribution=distribution or "RAID"
	prio=prio or "BULK"
	local msg={
		type="scene",
		content=scene:Pack()
	}
	if not msg.content then return end
	msg=self:Serialize(msg)
	msg=self.Compress:CompressHuffman(msg)
	msg=self.AddonEncodeTable:Encode(msg)
	self:Print(format(L["Sending scene to %s"],distribution=="WHISPER" and target or L[distribution:lower()]))
--	self:SendCommMessage(ADDON_NAME,"SCEN"..msg,distribution,target,prio)
	self:SendCommMessage(ADDON_NAME,msg,distribution,target,prio)
end

--- Opens a new frame with a text export of the given scene.
-- @param scene Exported scene
function Core:ExportScene(scene)
	local msg={
		type="sceneexport",
		content=scene:Pack()
	}
	msg=self:Serialize(msg)
	msg=self.Compress:CompressHuffman(msg)
	local Base64=LibStub("LibBase64-1.0")
	msg=Base64.Encode(msg,80)
	
	AceGUI=LibStub("AceGUI-3.0")
	local frame=AceGUI:Create("Frame")
	frame:SetTitle(L["Export scene"])
	frame:SetLayout("Fill")

	local edit= AceGUI:Create("MultiLineEditBox")
	edit:SetText(msg)
	edit.editbox:HighlightText()
	edit.editbox:SetAutoFocus(true)
	edit:SetLabel(L["Copy this to clipboard"])
	frame:AddChild(edit)
	
	frame:SetCallback("OnClose", function(widget) 
		edit.editbox:SetAutoFocus(false)
		AceGUI:Release(widget) 
	end)	
	frame:Show()
	
end

-- Opens a new frame with a text box where user can paste a
-- previously exported scene. This scene is then
-- added to scene manager.
function Core:ImportScene()
	AceGUI=LibStub("AceGUI-3.0")
	local frame=AceGUI:Create("Frame")
	frame:SetTitle(L["Import scene"])
	frame:SetLayout("Fill")

	local edit= AceGUI:Create("MultiLineEditBox")
	edit:SetLabel(L["Paste exported scene here"])
	edit:SetText("")
	frame:AddChild(edit)
	
	frame:SetCallback("OnClose", function(widget) 
		local text=edit:GetText()
		text=text:gsub("^%s*",""):gsub("%s*$","")
		if strlen(text)>0 then
		
			local Base64=LibStub("LibBase64-1.0")
			local msg=Base64.Decode(text)
			msg=Core.Compress:Decompress(msg)
			local ok,msg=self:Deserialize(msg)
			if not ok then 
				Core:Print(L["Couldn't deserialized imported scene"])
			else
				if msg.type=="sceneexport" then
					Core:HandleSceneAddonMessage(msg)
				end
			end
		end
		AceGUI:Release(widget) 
	end)	
	frame:Show()

end


--- Registers a mesh class.
-- The given class should be a subclass of AVRMesh or implement a similar interface. In addition
-- to this, meshClass.meshInfo must contain a table with information about how to
-- handle this class. See Mesh documentation for information about the table.
-- @param meshClass The class to register.
function AVR:RegisterMeshClass(meshClass)
	local template=nil
	local info=meshClass.meshInfo
	if not info.derived then self.meshGeneratorClasses[info.class]=meshClass end
	if info.receivable then self.receiveMeshClasses[info.class]=meshClass end
	if info.guiCreateNew then
		if meshClass['NewTemplate'] then template=meshClass:NewTemplate()
		else template=meshClass:New() end
		self.guiMeshTemplates[info.guiName]=template
	end
end

--- Registers a scene class.
-- The given class should be a subclass of AVRScene or implement a similar interface. In addition
-- to this, sceneClass.sceneInfo must contain a table with information about how to
-- handle this class. See Scene documentanion for information about the table.
-- @param sceneClass the class to register.
function AVR:RegisterSceneClass(sceneClass)
	local info=sceneClass.sceneInfo
	self.sceneClasses[info.class]=sceneClass
	if info.receivable then self.receiveSceneClasses[info.class]=sceneClass end
	if info.guiCreateNew then self.guiSceneClasses[info.class]=info.guiName end
end

--- Checks if AVR is currently enabled.
-- @return false or true.
function AVR:IsEnabled()
	return self.db.profile.enable
end

--- Gets the AVR scene manager.
-- The scene manager can be used to add new scenes or access existing scenes.
-- @return The scene manager object.
function AVR:GetSceneManager()
	return self.sceneManager
end

--- Gets the AVR 3d engine.
-- @return The AVR 3d engine.
function AVR:Get3D()
	return self.threed
end

--- Notification that options table should be refreshed. 
-- You should call this whenever the options table needs to be recreated.
-- For standard options it should be called automatically.
function Core:OptionsChanged()
	self.rootArgs=nil
	self.AceConfigRegistry:NotifyChange(ADDON_NAME)
	if self.edit then self.edit:OptionsChanged() end
end
