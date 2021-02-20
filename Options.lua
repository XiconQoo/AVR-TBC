local ADDON_NAME="AVR"
local Core=AVR
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, true)

local function strsplit(str)
	local tbl = {}
	for v in string.gmatch(str, "[^ ]+") do
	  tinsert(tbl, v)
	end
	return tbl
end

local function getScenesArgs() 
	if not Core.sceneManager then return {} end
	
	local ss=Core.sceneManager.scenes
	local ret={
		newScene={
			type = "group",
			name = L["New scene"],
			order = -1,
			args = {},
		}
	}
	local i=1
	for s,n in pairs(AVR.guiSceneClasses) do
		s=AVR.sceneClasses[s]
		ret.newScene.args[n] = {
			type = "execute",
			width = "full",
			name = format(L["New %s"],n),
			order = i,
			func =	function()
						local ns=s:New(Core.threed)
						if ns then
							if ns.class==AVRScene.sceneInfo.class then
								ns:SetZone(Core.zoneData:GetCurrentZone())
							end
							Core.sceneManager:AddScene(ns)
						end
					end
		}
		i=i+1
	end
	ret.newScene.args.importScene={
		type = "execute",
		width = "full",
		name = L["Import scene"],
		desc = L["Import scene desc"],
		order = i,
		func =	function()
					Core:ImportScene()
				end
	}
	
	i=1
	for _,scene in ipairs(ss) do
		if scene.guiVisible then
			local options=scene:GetOptions()
			if options then
				local key=""..scene.id
				if scene.from then key=scene.from..key end
				ret[key]=options
				i=i+1
			end
		end
	end
	return ret
end

local function setOptionParam(info,value,folder)
	local varName = nil
	if type(info) == "string" then
		varName = info
	else
		varName = info[#info]
	end
	if not folder then folder=Core.db.profile end
	folder[varName] = value
end
local function getOptionParam(info,folder)
	local varName = nil
	if type(info) == "string" then
		varName = info
	else
		varName = info[#info]
	end
	if not folder then folder=Core.db.profile end
	return folder[varName]
end

Core.options = {
    name = ADDON_NAME,
    handler = Core,
    type = 'group',
	get = getOptionParam,
	set = setOptionParam,
}
local profileOptions
Core.rootArgs=nil
setmetatable(Core.options,{
	__index=function(table,key)
		if key~="args" then return nil end
		if Core.rootArgs~=nil then return Core.rootArgs end
		if profileOptions==nil then
			profileOptions=LibStub("AceDBOptions-3.0"):GetOptionsTable(Core.db)
		end
		Core.rootArgs={
			menu = {
				type="execute",
				name=L["Menu"],
				guiHidden=true,
				func = function() Core.AceConfigDialog:Open(ADDON_NAME) end
			},
			edit = {
				type="execute",
				name=L["Open scene editor"],
				guiHidden=true,
				func = function()
							Core.AceConfigDialog:Close(ADDON_NAME)															
							Core.edit:EnableEdit()
						end
			},
			general = {
				type="group",
				name= L["General"],
				order = 10,
				args={
					enable = {
						type = "toggle",
						name = L["Enable"],
						desc = L["Enable desc"],
						width = "full",
						order = 0,
						set = function(info, v)
							setOptionParam(info,v)
							if v then
								Core:DoEnable()
							else
								Core:DoDisable()
							end
						end,
					},
					hideAll = {
						type = "toggle",
						name = L["Hide all"],
						desc = L["Hide all desc"],
						width = "full",
						order = 1,
						set = 	function(info,v)
									Core.db.profile.hideAll=v
									Core:Clear3D()
								end
					},
					openEditor = {
						type = "execute",
						name = L["Open scene editor"],
						desc = L["Open scene editor desc"],
						width = "full",
						order = 2,
						func = 	function()
									Core.AceConfigDialog:Close(ADDON_NAME)															
									Core.edit:EnableEdit()
								end
					},
					versionCheck = {
						type = "execute",
						name = L["Version check"],
						width = "full",
						order=3,
						func = 	function()
									Core:VersionCheck()
								end
					}
				},
			},
			sharing = {
				type = "group",
				name = L["Sharing"],
				order = 20,
				args = {
					acceptFrom = {
						type = "group",
						inline = true,
						name = L["Accept incoming scenes from"],
						args = {
							acceptScenesFromRaidLeader = {
								type="toggle",
								name=L["Raid leader"],
							},
							acceptScenesFromRaidAssist = {
								type="toggle",
								name=L["Raid assist"],
							},
							acceptScenesFromRaid = {
								type="toggle",
								name=L["Raid others"],
							},
							acceptScenesFromPartyLeader = {
								type="toggle",
								name=L["Party leader"],
							},
							acceptScenesFromParty = {
								type="toggle",
								name=L["Party others"],
							},
							acceptScenesFromBG = {
								type="toggle",
								name=L["Battleground"],
							},
							acceptScenesFromGuild = {
								type="toggle",
								name=L["Guild"],
							},
							acceptScenesFromWhisper = {
								type="toggle",
								name=L["Whisper"],
							}
						},
						order=10,
					},
					blackList ={
						type="group",
						inline=true,
						name="Blacklist",
						order=20,
						args={
							blacklistSelected = {
								type="select",
								name=L["Blacklist"],
								desc=L["Blacklist desc"],
								order=10,
								values = 	function()
												return Core.db.profile.sharingBlacklist
											end
							},
							blacklistRemove={
								type="execute",
								name=L["Remove"],
								order=20,
								func = 	function()
											if Core.db.profile.blacklistSelected then
												Core.db.profile.sharingBlacklist[Core.db.profile.blacklistSelected]=nil
												Core.db.profile.blacklistSelected=nil
											end
										end
							},
							blacklistAdd={
								type="input",
								name=L["Add"],
								order=30,
								get=function() return "" end,
								set=	function(_,val) 
											val=string.gsub(string.gsub(val,"^%s*",""),"%s*$","")
											val=string.lower(val)
											if strlen(val)==0 then return end
											Core.db.profile.sharingBlacklist[val]=val
										end
							}
						}
					},
					receiveOwnScenes = {
						type="select",
						name=L["Receive own scenes"],
						desc=L["Receive own scenes desc"],
						values = {yes=L["Yes"],no=L["No"],hidden=L["As hidden"]},
						order=30,
					},
				}
			},
			profile = profileOptions,
			-- scenes
			-- scene
			-- mesh
			about = {
				name = L["About"],
				order = 900,
				type = "group",
				args = {
					version = {
						type = "description",
						order = 10,
						name = L["Version"]
					},
					copyright = {
						type = "description",
						order = 20,
						name = L["Copyright"]
					},
					license = {
						type = "description",
						order = 30,
						name = L["License"]
					},
					header1={
						type = "header",
						order = 31,
						name = ""
					},
					pluginsLicense = {
						type = "description",
						order = 35,
						name = L["PluginsLicense"]
					},
					header2={
						type = "header",
						order = 36,
						name = ""
					},
					libcompresslicense = {
						type = "description",
						order = 40,
						name = L["LibCompressLicense"]
					},
					header3={
						type = "header",
						order = 41,
						name = ""
					},
					libbase64license = {
						type = "description",
						order = 50,
						name = L["LibBase64License"]
					},
					header4={
						type = "header",
						order = 51,
						name = "",
					},
					acelicense = {
						type = "description",
						order = 60,
						name = L["AceLicense"]
					},
				}
			}
		}
		if Core.sceneManager then
			Core.rootArgs.scenes={
				type = "group",
				name = L["Scenes"],
				order = 20,
				args = getScenesArgs()
			}
			
			local scene=Core.sceneManager:GetSelectedScene()
			if scene and scene.guiVisible then
				Core.rootArgs.scene=scene:GetOptions()
				Core.rootArgs.scene.guiHidden=true
				Core.rootArgs.scene.order=30
				local mesh=scene:GetSelectedMesh()
				if mesh then
					Core.rootArgs.mesh=mesh:GetOptions()
					Core.rootArgs.mesh.guiHidden=true
					Core.rootArgs.mesh.order=40
				end
			end
		end
		
		if Core.meshEdit then
			Core.rootArgs.meshEdit=Core.meshEdit:GetOptions()
			Core.rootArgs.meshEdit.order=50
		end
		return Core.rootArgs
	end
})

function Core:GetNewMeshArgs(scene)
	local ret={}
	for name,template in pairs(self.guiMeshTemplates) do
		ret[name]=template:GetOptions()
		ret[name].name=name
		ret[name].args.add={
			name=L["Add"],
			order=1,
			width="full",
			type="execute",
			func= 	function()
						local n=template:Duplicate()
						local mesh=scene:AddMesh(n)
						if not mesh.followPlayer and (mesh.followUnit==nil or mesh.followUnit=="") then
							mesh.followPlayer=true
							mesh:Detach()
						end
					end
		}
		if ret[name].args.follow then
			ret[name].args.follow.args.header1=nil
			ret[name].args.follow.args.attach=nil
			ret[name].args.follow.args.attachRotation=nil
			ret[name].args.follow.args.detach=nil
			ret[name].args.follow.args.detachRotation=nil
		end
		ret[name].args.remove=nil
	end
	return ret
end

Core.defaultOptions = {
	profile = {
		enable = true,
		hideAll = false,
		scenes = {},
		sceneid = 1,
		selectedScene = 0,
		noPackDoubles = false,
		receiveOwnScenes = "hidden",
		acceptScenesFromRaidLeader = true,
		acceptScenesFromRaidAssist = true,
		acceptScenesFromRaid = false,
		acceptScenesFromPartyLeader = false,
		acceptScenesFromParty = false,
		acceptScenesFromBG = false,
		acceptScenesFromGuild = false,
		acceptScenesFromWhisper = false,
		sharingBlacklist = {},
		blacklistSelected = nil,
	}
}

function Core:OpenLDBMenu()
end
