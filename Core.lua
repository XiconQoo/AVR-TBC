local ADDON_NAME="AVR"

local _G = _G
local pairs = pairs
local ipairs = ipairs
local remove = table.remove
local insert = table.insert
local type = type
local select = select
local next = next
local format = string.format

AVR = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceEvent-3.0", "AceConsole-3.0", "AceHook-3.0", "AceSerializer-3.0", "AceComm-3.0", "AceTimer-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, true)


local Core=AVR

Core.meshGeneratorClasses={}
Core.receiveMeshClasses={}
Core.guiMeshTemplates={}
Core.sceneClasses={}
Core.receiveSceneClasses={}
Core.guiSceneClasses={}

local function tableFind(table,value)
	for i,v in ipairs(table) do
		if v==value then return i end
	end
	return nil
end

local function capitalize(s)
	return (s:sub(1,1):upper())..(s:sub(2):lower())
end

function Core:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New(ADDON_NAME.."_DB",Core.defaultOptions)
	
	Core.options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	Core.AceConfig=LibStub("AceConfig-3.0")
	Core.AceConfig:RegisterOptionsTable(ADDON_NAME, Core.options, {ADDON_NAME:lower()})
	Core.AceConfigRegistry=LibStub("AceConfigRegistry-3.0")
	Core.AceConfigDialog=LibStub("AceConfigDialog-3.0")
	Core.AceConfigDialog:AddToBlizOptions(ADDON_NAME, ADDON_NAME)

	Core.Compress=LibStub("LibCompress")
	Core.AddonEncodeTable=Core.Compress:GetAddonEncodeTable()

	self.db.RegisterCallback(self,"OnProfileShutdown","OnProfileShutdown")
	self.db.RegisterCallback(self,"OnDatabaseShutdown","OnProfileShutdown")
	self.db.RegisterCallback(self,"OnProfileChanged","OnProfileChanged")
	self.db.RegisterCallback(self,"OnProfileCopied","OnProfileChanged")
	self.db.RegisterCallback(self,"OnProfileReset","OnProfileChanged")
	
	self:RegisterComm(ADDON_NAME,"OnCommReceived")
end

function Core:OnCommReceived(prefix,message,distribution,sender)
	if not self.db.profile.enable then return end
	if strlen(message)<4 then return end
	
	local type=message:sub(1,4)
	local content=message:sub(5)
	
	if type=="VERC" then
	elseif type=="VERI" then
	elseif type=="SCEN" then
	else
		-- message without header from old version
		type="SCEN"
		content=message
	end
	
	if type=="SCEN" then	
		if self.db.profile.receiveOwnScenes=="no" and sender==GetUnitName("player") then return end
		if self.db.profile.sharingBlacklist[string.lower(sender)] then return end
		
		if distribution=="RAID" then
			if not self.db.profile.acceptScenesFromRaid and not self.db.profile.acceptScenesFromRaidLeader and
				not self.db.profile.acceptScenesFromRaidAssist then return end
			local rank=0
			for i=1,40 do
				local raidName,raidRank=GetRaidRosterInfo(i)
				if raidName==sender then
					rank=raidRank
					break
				end
			end
			if rank==0 and not self.db.profile.acceptScenesFromRaid then return end
			if rank==1 and not self.db.profile.acceptScenesFromRaidAssist then return end
			if rank==2 and not self.db.profile.acceptScenesFromRaidLeader then return end
		elseif distribution=="PARTY" then
			if not self.db.profile.acceptScenesFromParty and not self.db.profile.acceptScenesFromPartyLeader then 
				return end
			local rank=0
			local leaderIndex=GetPartyLeaderIndex()
			if leaderIndex~=0 then
				for i=1,4 do
					local partyName=UnitName("party"..i)
					if partyName==sender then
						if leaderIndex==i then rank=2 end
						break
					end
				end
			elseif sender==GetUnitName("player") then rank=2
			end
			if rank==0 and not self.db.profile.acceptScenesFromParty then return end
			if rank==2 and not self.db.profile.acceptScenesFromPartyLeader then return end
		elseif distribution=="BATTLEGROUND" and not self.db.profile.acceptScenesFromBG then return 
		elseif distribution=="GUILD" and not self.db.profile.acceptScenesFromGuild then return 
		elseif distribution=="WHISPER" and not self.db.profile.acceptScenesFromWhisper then return
		end

		self:Print(format(L["Received AVR scene from %s"],sender))
		content=self.AddonEncodeTable:Decode(content)
		content=self.Compress:Decompress(content)
		local ok,msg=self:Deserialize(content)
		if not ok then 
			self:Print(format(L["Couldn't deserialized AVR addon message from %s %s"],sender,msg))
			return
		end
		self:HandleSceneAddonMessage(msg,sender)
	elseif type=="VERC" then
		local msg={
			version=GetAddOnMetadata("AVR","Version")
		}
		msg=self:Serialize(msg)
		self:SendCommMessage(ADDON_NAME,"VERI"..msg,"WHISPER",sender)
	elseif type=="VERI" then
		if self.versionInfo then
			local ok,msg=self:Deserialize(content)
			if ok then
				self.versionInfo[sender]=msg
			end
		end
	end
end

function Core:HandleSceneAddonMessage(msg,sender)
	if msg.type=="scene" then
		local scene=self.sceneManager:UnpackScene(msg.content)
		scene.from=sender
		if sender==GetUnitName("player") and self.db.profile.receiveOwnScenes=="hidden" then
			scene.visible=false
		end
		if not scene.id then scene.id=1 end
		self.sceneManager:ReceiveScene(scene)
	elseif msg.type=="sceneexport" then
		local scene=self.sceneManager:UnpackScene(msg.content)
		self.sceneManager:AddScene(scene)
	end
end

function Core:VersionCheck()
	if GetNumRaidMembers()<=0 then
		self:Print(L["Version check available only in raids"])
		return
	end
	if not self.versionInfo then
		self.versionInfo={}
		self:ScheduleTimer("FinishVersionCheck",5)
		self:SendCommMessage(ADDON_NAME,"VERC","RAID")
		self:Print(L["Sending version check"])
	end
end

function Core:FinishVersionCheck()
	if not self.versionInfo then return end
	local replies=0
	for k,v in pairs(self.versionInfo) do
		if v.version then
			replies=replies+1
		end
	end
	self:Print(string.format(L["Version check finished. Got %s replies."],replies))
	for k,v in pairs(self.versionInfo) do
		if v.version then
			self:Print(string.format("%s %s",k,v.version))
		end
	end	
	self.versionInfo=nil
end

function Core:Clear3D()
	if self.threed then
		self.threed:ClearAllLines()
		self.threed:ClearAllTriangles()
		self.threed:ClearAllSprites()
	end	
end

function Core:OnProfileShutdown()
	if self.sceneManager then self.sceneManager:SaveScenes() end
end
function Core:OnProfileChanged()
	if self.sceneManager then self.sceneManager:LoadScenes() end
	self:Clear3D()
	if self.db.profile.enable then self:DoEnable()
	else self:DoDisable() end
end

function Core.Embed(self, other)
	local k,v
	if _G.getmetatable(other) then
		for k, v in pairs(self) do
			other[k] = v
		end
	else
		_G.setmetatable(other, {__index = self})
	end
	return other
end

function Core:EnableDraw()
	self.rootFrame:EnableMouse(true)
end

function Core:DisableDraw()
	self.rootFrame:EnableMouse(false)
end

--local times={}
--for i=1,40 do times[i]=0 end
--local timeptr=1
function Core:OnUpdate()
	if not self.db.profile.hideAll then
		self.zoneData:OnUpdate()	
		--local t1=GetTime()
		self.threed:StartRender()
		self.mousePaint:UpdatePaint()
		if self.edit then self.edit:OnUpdatePreRender() end
		if self.meshEdit then self.meshEdit:OnUpdatePreRender() end
	
		self.sceneManager:DrawScenes()

		self.threed:EndRender()
		
		--[[
		local t2=GetTime()
		times[timeptr]=t2-t1
		timeptr=(timeptr%(#times))+1
		local sum=0
		for i=1,#times do sum=sum+times[i] end
		print(sum/#times)
		--]]
		
		if self.edit then self.edit:OnUpdate() end
		if self.meshEdit then self.meshEdit:OnUpdate() end
	end
end

function Core:OnEnable()
	self:DoEnable()
end
function Core:DoEnable()
	if not self.db.profile.enable then return end
	if not self.rootFrame then
		self.rootFrame=CreateFrame("FRAME",ADDON_NAME.."_RootFrame",WorldFrame)
		self.rootFrame:SetPoint("BOTTOMLEFT",WorldFrame,"BOTTOMLEFT",0,0)
		self.rootFrame:SetPoint("TOPRIGHT",WorldFrame,"TOPRIGHT",0,0)
	end
	if not self.zoneData then
		self.zoneData=AVRZoneData:New()
	end
	self.zoneData:Enable()
	if not self.threed then
		self.threed=AVR3D:New(self.rootFrame,self)
	end
	if not self.meshEdit and AVRMeshEdit then
		self.meshEdit=AVRMeshEdit:New(self.threed)
	end
	if not self.edit and AVREdit then
		self.edit=AVREdit:New(self.threed)
	end
	if not self.sceneManager then
		self.sceneManager=AVRSceneManager:New(self.threed)
	end
	self.sceneManager:LoadScenes()
	if not self.mousePaint then
		self.mousePaint=AVRMousePaint:New(self.threed)
	end
	self.rootFrame:SetScript("OnUpdate",function() self:OnUpdate() end )
	
	self:OptionsChanged()
end


function Core:OnDisable()
	self:DoDisable()
end
function Core:DoDisable()

	self.rootFrame:SetScript("OnUpdate",nil )
	if self.mousePaint then
		self.mousePaint:DisableDraw()
		self.mousePaint:DisableDrag()
	end
	if self.meshEdit then
		self.meshEdit:DisableEdit()
		self.meshEdit:ClearAllHandles()
	end
	if self.edit then
		self.edit:DisableEdit()
	end
	self:Clear3D()
	if self.zoneData then
		self.zoneData:Disable()
	end
	if self.sceneManager then
		self.sceneManager:SaveScenes()
		self.sceneManager:OnRemove()
		self.sceneManager=nil
	end
	self:UnregisterAllEvents()
	self:OptionsChanged()
end

function Core:GetTargetPlatePos()
	local cs={WorldFrame:GetChildren()}
	local c,r
	local t=nil
	for i=1,#cs do
		c=cs[i]
		r=c:GetRegions()
		if r and r:GetObjectType() == "Texture" and r:GetTexture() == "Interface\\TargetingFrame\\UI-TargetingFrame-Flash" then
			if c:GetAlpha()==1 then
				if t~=nil then 
					return nil
				else
					t=r
				end
			end
		end
	end
	if t==nil then
		return nil
	end
	return (t:GetLeft()+t:GetRight())/2,t:GetTop()
end

function Core:Benchmark(num,type,clip)
	local x,y
	if type==nil then type=1 end
	if clip==nil then clip=false end
	scene=self.sceneManager:GetSelectedScene()
	num=num or 5
	for x=-num,num do 
		for y=-num,num do
			if type==1 then
				scene:AddMesh(AVRFilledCircleMesh:New(0.5,20):TranslateMesh(x,y))
			elseif type==2 then
				scene:AddMesh(AVRCircleMesh:New(0.5,20):TranslateMesh(x,y))
			elseif type==3 then
				scene:AddMesh(AVRMarkerMesh:New(0.5):TranslateMesh(x,y))
			elseif type==4 then
				scene:AddMesh(AVRRaidIconMesh:New(4,0.5):TranslateMesh(x,y))
			end
			scene:GetLastMesh():SetFollowPlayer(true):Detach()
			scene:GetLastMesh().clipToScreen=clip
		end
	end
end

function Core:GetSelectedMesh()
	if not self.sceneManager then return nil end
	local scene=self.sceneManager:GetSelectedScene()
	if not scene then return nil end
	return scene:GetSelectedMesh()
end

function Core:AddMesh(mesh)
	if not self.sceneManager then return nil end
	local scene=self.sceneManager:GetSelectedScene()
	if not scene then return nil end
	return scene:AddMesh(mesh)
end

function Core:FindTargetPlateHeight()
	local px,py=self.threed:GetUnitPosition("player")
	local x,y=self:GetTargetPlatePos()
	if x==nil then
		return nil
	end
	
	self.threed:InvertCameraMatrix()
	local px1,py1,pz1=self.threed:InverseProject(x,y,20)
	local px2,py2,pz2=self.threed:InverseProject(x,y,10)
	local dx1,dy1=px2-px1,py2-py1
	local dx2,dy2=px-px1,py-py1
	local d=(dx1*dx2+dy1*dy2)/(dx1*dx1+dy1*dy1)
	local h=pz1+(pz2-pz1)*d+self.threed.playerHeight
	return h
end
