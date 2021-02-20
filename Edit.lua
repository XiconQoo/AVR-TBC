local ADDON_NAME="AVR"
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, true)

local _G = _G
local pairs = pairs
local ipairs = ipairs
local remove = table.remove
local insert = table.insert
local sort = table.sort
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

AVREdit = {Embed = Core.Embed}
local T=AVREdit

local function tableFind(t,v)
	for i,u in ipairs(t) do
		if u==v then return i end
	end
	return -1
end

function T:New(threed)
	if self ~= T then return end
	local s={}

	T:Embed(s)
	
	s.frameCache={}
	s.visibleFrames={}
	s.threed=threed
	s.frame=s.threed.frame
	
	s.enabled=false
	
	s.draggingMesh=nil
	s.dragMouseStart=nil
	s.dragMeshStart=nil
	s.dragFrame=nil
	
	s.optionsFrame=nil
	s.options=nil
				
	return s
end

function T:GetOptionsParam(info)
end

function T:SetOptionsParam(info,value)
end

function T:GetSelectedScene()
	if not Core.sceneManager then return nil end
	return Core.sceneManager:GetSelectedScene()
end

function T:GetSelectedMesh()
	if not Core.sceneManager then return nil end
	local s=Core.sceneManager:GetSelectedScene()
	if not s then return nil end
	return s:GetSelectedMesh()
end

function T:OptionsChanged()
	if self.optionsFrame and self.optionsFrame:IsVisible() then
		self:ShowOptionsFrame()
	end
end

function T:RefreshOptionsFrame()
	if not self.options then
		self.options = {
			name = ADDON_NAME,
			handler = self,
			type = 'group',
			get = function(info) self.GetOptionsParam(info) end,
			set = function(info,value) self.SetOptionsParam(info,value) end,
			args = {
				scene = {
					name = L["Scene"],
					desc = L["Select scene desc"],
					type = "select",
					width = "full",
					values=nil,
					get = 	function(info) 
								local s=self:GetSelectedScene()
								if not s then return nil end
								return tableFind(Core.sceneManager.scenes,s)
							end,
					set = 	function(info,value)
								if not Core.sceneManager then return end
								if value==65535 then
									local s=AVRScene:New(self.threed)
									s:SetZone(Core.zoneData:GetCurrentZone())
									Core.sceneManager:AddScene(s)
								else
									local s=Core.sceneManager.scenes[value]
									s:SelectScene()
								end
							end,
					style = "dropdown",
					order = 10,
				},
				sceneName = {
					name = "",
					desc = L["Scene name desc"],
					type = "input",
					width = "full",
					order = 12,
					get = 	function(info)
								local s=self:GetSelectedScene()
								if not s then return nil end
								return s.name
							end,
					set =	function(info,value)
								local s=self:GetSelectedScene()
								if not s then return end
								s:SetName(value)
							end
				},
				removeScene = {
					type = "execute",
					name = L["Remove scene"],
					desc = L["Remove scene desc"],
					order = 15,
					width = "full",
					confirm = true,
					func = function() 
						local s=self:GetSelectedScene()
						if not s then return end
						s:Remove()
					end
				},
				sceneVisible = {
					name = L["Visible"],
					type = "toggle",
					width = "full",
					get =	function(info)
								local s=self:GetSelectedScene()
								if not s then return nil end
								return s.visible
							end,
					set =	function(info,value)
								local s=self:GetSelectedScene()
								if not s then return end
								s.visible=value
							end,
					order = 20,
				},
				zone = {
					name = L["Zone"],
					desc = L["Zone desc"],
					type = "input",
					order = 23,
					get =	function(info)
								local s=self:GetSelectedScene()
								if not s then return nil end
								return s:GetZone()
							end,
					set = 	function(_,val)
								local s=self:GetSelectedScene()
								if not s then return nil end
								val=string.gsub(string.gsub(val,"^%s*",""),"%s*$","")
								if string.len(val)==0 then val=nil end
								s:SetZone(val)
							end
					
				},
				currentZone = {
					name = L["Current zone"],
					desc = L["Current zone desc"],
					type = "execute",
					order = 25,
					func =	function() 
								local s=self:GetSelectedScene()
								if not s then return end
								s:SetZone(Core.zoneData:GetCurrentZone())
							end
				},
				mesh = {
					name = L["Mesh"],
					desc = L["Select mesh desc"],
					type = "select",
					width = "full",
					values=nil,
					get =	function(info)
								local s=self:GetSelectedScene()
								local m=self:GetSelectedMesh()
								if not m then return nil end
								return tableFind(s.meshes,m)
							end,
					set =	function(info,value)
								local s=self:GetSelectedScene()
								if s then
									local m=s.meshes[value]
									m:SelectMesh()
								end
							end,
					style = "dropdown",
					order = 30,
				},
				deleteMesh = {
					name = L["Remove mesh"],
					desc = L["Remove mesh desc"],
					type = "execute",
					width = "full",
					func = 	function()
								local m=self:GetSelectedMesh()
								if not m then return nil end
								m:Remove() 
							end,
					order = 40,
				},
				editGroup = {
					name = L["Edit mesh"],
					type = "group",
					inline = true,
					order = 50,
					args = {
						meshName = {
							name = "",
							desc = L["Mesh name desc"],
							type = "input",
							width = "full",
							order = 10,
							get = 	function(info)
										local m=self:GetSelectedMesh()
										if not m then return nil end
										return m.name
									end,
							set =	function(info,value)
										local m=self:GetSelectedMesh()
										if not m then return end
										m:SetName(value)
									end
						},
						color = {
							name = L["Color"],
							get = 	function(info)
										local m=self:GetSelectedMesh()
										if not m then return nil end
										return m.r,m.g,m.b,m.a
									end,
							set =	function(info,r,g,b,a)
										local m=self:GetSelectedMesh()
										if not m then return end
										m:SetColor(r,g,b,a)
									end,
							type = "color",
							hasAlpha = true,
							order = 60,
						},
						rotate = {
							name = L["Rotate"],
							type = "range",
							order = 200,
							width = "full",
							min = -360, max = 360, bigStep = 0.1,
							get = 	function(info) 
										local m=self:GetSelectedMesh()
										if not m then return 0 end
										return m.meshRotateZ*180/pi
									end,
							set = 	function(info,value)
										local m=self:GetSelectedMesh()
										if not m then return end
										m:SetMeshRotation(value*pi/180)
									end,
						},
						scaleX = {
							name = L["Scale X"],
							type = "range",
							order = 210,
							width = "full",
							min = -10, max = 10, bigStep = 0.1,
							get = 	function(info) 
										local m=self:GetSelectedMesh()
										if not m then return 0 end
										return m.meshScaleX
									end,
							set = 	function(info,value)
										local m=self:GetSelectedMesh()
										if not m then return end
										m:SetMeshScale(value,m.meshScaleY,m.meshScaleZ)
									end,
						},
					},
				},
				addGroup = {
					name = L["Add mesh"],
					type = "group",
					inline = true,
					order = 60,
					args = {
						filledCircle = {
							name = "",
							type = "execute",
							image = "Interface\\AddOns\\AVR\\Icons\\filledcircle",
							width = "half",
							order = 10,
							func =	function() 
										local s=self:GetSelectedScene()
										if not s then return end
										local m=AVRFilledCircleMesh:New()
										s:AddMesh(m)
										self:NewMeshDrag(m)
									end
						},
						circle = {
							name = "",
							type = "execute",
							image = "Interface\\AddOns\\AVR\\Icons\\circle",
							width = "half",
							order = 20,
							func = 	function()
										local s=self:GetSelectedScene()
										if not s then return end
										local m=AVRCircleMesh:New()
										s:AddMesh(m)
										self:NewMeshDrag(m)
									end
						},
						icon = {
							name = "",
							type = "execute",
							image = "Interface\\AddOns\\AVR\\Icons\\star",
							width = "half",
							order = 30,
							func = 	function()
										local s=self:GetSelectedScene()
										if not s then return end
										local m=AVRRaidIconMesh:New()
										s:AddMesh(m)
										self:NewMeshDrag(m)
									end
						},
						arrow = {
							name = "",
							type = "execute",
							image = "Interface\\AddOns\\AVR\\Icons\\arrow",
							width = "half",
							order = 40,
							func = 	function()
										local s=self:GetSelectedScene()
										if not s then return end
										local m=AVRArrowMesh:New()
										s:AddMesh(m)
										self:NewMeshDrag(m)
									end
						},
						draw = {
							name = "",
							type = "execute",
							image = "Interface\\AddOns\\AVR\\Icons\\pen",
							width = "half",
							order = 50,
							func = 	function()
										local s=self:GetSelectedScene()
										if not s then return end
										if Core.mousePaint.paintEnabled then
											Core.mousePaint:DisableDraw()
										else
											Core.mousePaint:EnableDraw(true,false,false,s)
											Core.mousePaint:SetDetailLevel(0.5)
										end
									end
						},
					}
				},
				shareGroup={
					name = L["Sharing"],
					type = "group",
					inline = true,
					order = 70,
					args = {
						shareChannel = {
							name = L["Channel"],
							desc = L["Channel desc"],
							type = "select",
							order = 10,
							values = {RAID="Raid",PARTY="Party",GUILD="Guild",BATTLEGROUND="Battleground",WHISPER="Whisper"},
							set = 	function(_,val)
										local s=self:GetSelectedScene()
										if not s then return end
										if val~="WHISPER" then s.shareTarget="" end
										s.shareChannel=val
									end,
							get =	function (_,val)
										local s=self:GetSelectedScene()
										if not s then return nil end
										return s.shareChannel
									end
						},
						shareTarget = {
							name = L["Whisper target"],
							desc = L["Whisper target desc"],
							type = "input",
							order = 20,
							set = 	function(_,val)
										local s=self:GetSelectedScene()
										if not s then return end
										if s.shareChannel=="WHISPER" then 
											s.shareTarget=val
										end
									end,
							get =	function (_,val)
										local s=self:GetSelectedScene()
										if not s then return nil end
										return s.shareTarget
									end
						},
						send = {
							name = L["Send"],
							type = "execute",
							order = 30,
							func =	function()
										local s=self:GetSelectedScene()
										if not s then return nil end
										Core:SendScene(s,s.shareChannel,s.shareTarget)
									end
						}
					}
				},
				menu = {
					name = L["Main menu"],
					type = "execute",
					width = "full",
					func = function() 
						Core:ScheduleTimer(function()
							self:DisableEdit()
							Core.AceConfigDialog:Open(ADDON_NAME)						
						end, 0.01)
					end,
					order = 200,
				}
			}
		}
		Core.AceConfig:RegisterOptionsTable(ADDON_NAME.."EDIT", self.options)
	end
	
	local sceneValues={}
	local meshValues={}
	if Core.sceneManager then
		local ss=Core.sceneManager.scenes
		for i,scene in ipairs(ss) do
			if scene.class==AVRScene.sceneInfo.class and scene.guiVisible then
				if scene.from then sceneValues[i]=scene.from..": "..scene.name
				else sceneValues[i]=scene.name end
			end
		end
	
		local s=Core.sceneManager:GetSelectedScene()
		if s then
			local ms=s.meshes
			for i,mesh in ipairs(ms) do
				meshValues[i]=mesh.name
			end
		end
		sceneValues[65535]="Create new"
	end
	
	self.options.args.scene.values=sceneValues
	self.options.args.mesh.values=meshValues
	
	local m=self:GetSelectedMesh()
	local edit=self.options.args.editGroup.args
	local optionals={'radius','size','icon','length','headSize','width', 'lineWidth'}
	for _,v in ipairs(optionals) do
		edit[v]=nil
	end
	if m then
		if m.class==AVRCircleMesh.meshInfo.class or m.class==AVRFilledCircleMesh.meshInfo.class then
			edit.radius={
				name = L["Radius"],
				type = "range",
				order = 100,
				width = "full",
				min = 0, max = 100, bigStep = 1.0,
				get = 	function(info) 
							local m=self:GetSelectedMesh()
							if not m then return 0 end
							return m.radius
						end,
				set = 	function(info,value)
							local m=self:GetSelectedMesh()
							if not m then return end
							m:SetRadius(value)
						end,
			}
			if m.class==AVRCircleMesh.meshInfo.class then
				edit.lineWidth = {
					name = L["Line Width"],
					type = "range",
					order = 101,
					width = "full",
					min = 1, max = 200, bigStep = 1,
					get = 	function(info)
						local m=self:GetSelectedMesh()
						if not m then return 0 end
						return m.lineWidth
					end,
					set = 	function(info,value)
						local m=self:GetSelectedMesh()
						if not m then return end
						m:SetLineWidth(value)
					end,
				}
			end
		elseif m.class==AVRRaidIconMesh.meshInfo.class then
			edit.size={
				name = L["Size"],
				type = "range",
				order = 100,
				width = "full",
				min = 0, max = 100, bigStep = 1.0,
				get = 	function(info) 
							local m=self:GetSelectedMesh()
							if not m then return 0 end
							return m.size
						end,
				set = 	function(info,value)
							local m=self:GetSelectedMesh()
							if not m then return end
							m:SetSize(value)
						end,
			}
			edit.icon={
				name = L["Raid icon"],
				type = "select",
				order = 110,
				width = "full",
				values = {[1]=L["Star"], [2]=L["Circle"], [3]=L["Diamond"], [4]=L["Triangle"],
							[5]=L["Moon"], [6]=L["Square"], [7]=L["Cross"], [8]=L["Skull"]},
				get = 	function(info) 
							local m=self:GetSelectedMesh()
							if not m then return 0 end
							return m.icon
						end,
				set = 	function(info,value)
							local m=self:GetSelectedMesh()
							if not m then return end
							m:SetIcon(value)
						end,
			}
		elseif m.class==AVRArrowMesh.meshInfo.class then
			edit.length={
				name = L["Length"],
				type = "range",
				order = 120,
				width = "full",
				min = 0, max = 100, bigStep = 0.5,
				get = 	function(info) 
							local m=self:GetSelectedMesh()
							if not m then return 0 end
							return m.length
						end,
				set = 	function(info,value)
							local m=self:GetSelectedMesh()
							if not m then return end
							m:SetLength(value)
						end,
			}
			edit.width={
				name = L["Width"],
				type = "range",
				order = 130,
				width = "full",
				min = 0, max = 100, bigStep = 0.5,
				get = 	function(info) 
							local m=self:GetSelectedMesh()
							if not m then return 0 end
							return m.width
						end,
				set = 	function(info,value)
							local m=self:GetSelectedMesh()
							if not m then return end
							m:SetWidth(value)
						end,
			}
			edit.headSize={
				name = L["Head size"],
				type = "range",
				order = 140,
				width = "full",
				min = 0, max = 100, bigStep = 0.5,
				get = 	function(info) 
							local m=self:GetSelectedMesh()
							if not m then return 0 end
							return m.headSize
						end,
				set = 	function(info,value)
							local m=self:GetSelectedMesh()
							if not m then return end
							m:SetHeadSize(value)
						end,
			}
		elseif m.class==AVRDataMesh.meshInfo.class then
			edit.width={
				name = L["Width"],
				type = "range",
				order = 110,
				width = "full",
				min = 0, max = 255, step=1.0, bigStep = 1.0,
				get = 	function(info) 
							local m=self:GetSelectedMesh()
							if not m then return 0 end
							return m.lineWidth
						end,
				set = 	function(info,value)
							local m=self:GetSelectedMesh()
							if not m then return end
							m:SetLineWidth(value)
						end,
			}
		end
	end
end

function T:ShowOptionsFrame()
	self:RefreshOptionsFrame()
	
	if not self.optionsFrame then
		local AceGUI = LibStub("AceGUI-3.0")
		self.optionsFrame=AceGUI:Create("Frame")
		self.optionsFrame:SetCallback("OnClose",function() self:DisableEdit() end)
		self.optionsFrame.frame:SetMinResize(250,200)
		Core.AceConfigDialog:SetDefaultSize(ADDON_NAME.."EDIT",250,500)
		local st=Core.AceConfigDialog:GetStatusTable(ADDON_NAME.."EDIT")
		st.top=780
		st.left=30
	end
	Core.AceConfigDialog:Open(ADDON_NAME.."EDIT",self.optionsFrame)

end

function T:HideOptionsFrame()
	if self.optionsFrame then
		self.optionsFrame:Hide()
	end
end

function T:OnUpdatePreRender()
	if self.draggingMesh then
		local m=self.draggingMesh
		
		self.threed:InvertCameraMatrix()
		local mx,my=GetCursorPosition()
		local sx,sy,sz=self.threed:InverseProject(mx,my)
		if sx==nil then return end
		
		local dx,dy,dz=sx-self.dragMouseStart[1],sy-self.dragMouseStart[2],sz-self.dragMouseStart[3]
		m:SetMeshTranslate(self.dragMeshStart[1]+dx,self.dragMeshStart[2]+dy,self.dragMeshStart[3]+dz)
	end
end

function T:OnUpdate()
	if not self.enabled then return end
	if not Core.sceneManager then return end

	self:ClearFrames()
	
	if self.draggingMesh~=nil then return end	
	
	if Core.mousePaint.paintEnabled then return end

	local scene=Core.sceneManager:GetSelectedScene()
	if not scene then return end
	if not scene.class==AVRScene.sceneInfo.class then return end
	if not scene.visible then return end
	
	local w2,h2=self.threed.screenWidth2,self.threed.screenHeight2
	
	local minx,maxx,miny,maxy
	local f,t,area
	local sortedMeshes={}
	
	for _,m in ipairs(scene.meshes) do
		if m.vertices then 
			minx,maxx,miny,maxy=w2,-w2,h2,-h2
			
			for _,v in ipairs(m.vertices) do
				if v[5]>0 then
					minx=min(minx,v[7])
					maxx=max(maxx,v[7])
					miny=min(miny,v[8])
					maxy=max(maxy,v[8])
				end
			end
			
			if maxx>-w2 and minx<w2 and maxy>-h2 and miny<h2 then 
				t={}
				insert(sortedMeshes,t)
				
				maxx=min(maxx,w2)
				minx=max(minx,-w2)
				maxy=min(maxy,h2)
				miny=max(miny,-h2)
				
				area=(maxx-minx)*(maxy-miny)
				
				t[1],t[2],t[3],t[4],t[5],t[6]=maxx,minx,maxy,miny,area,m
				
			end
		end
	end
	
	sort(sortedMeshes,function(a,b) return a[5]<b[5] end)
	
	for _,t in ipairs(sortedMeshes) do
		f=self:GetFrame()
		insert(self.visibleFrames,f)
		f.mesh=t[6]
		
		f:SetPoint("TOPLEFT",self.frame,"CENTER",t[2],t[3])
		f:SetPoint("BOTTOMRIGHT",self.frame,"CENTER",t[1],t[4])
		
		f:Show()
	end
	
end

function T:EnableEdit(value)
	if value==nil then value=true end
	if value then
		self:ShowOptionsFrame()
		self.enabled=true
	else
		self:HideOptionsFrame()
		self.enabled=false
		self:ClearFrames()
	end
end

function T:DisableEdit()
	self:EnableEdit(false)
end

function T:ClearFrames()
	local f
	while #self.visibleFrames>0 do
		f=remove(self.visibleFrames)
		self:ReleaseFrame(f)
	end
end

function T:NewMeshDrag(mesh)
	local frame=self:GetFrame()
	frame.mesh=mesh
	self:FrameMouseDown(frame,"LeftButton")
	mesh:SetMeshTranslate(self.dragMouseStart[1],self.dragMouseStart[3],self.dragMouseStart[3])
	self.dragMeshStart=self.dragMouseStart
end

function T:FrameMouseDown(frame,button)
	if button~="LeftButton" then return end
	
	local m=frame.mesh
	if not m then return end
	
	m:SelectMesh()
	
	self.threed:InvertCameraMatrix()
	local mx,my=GetCursorPosition()
	local sx,sy,sz=self.threed:InverseProject(mx,my)
	if sx==nil then return end
	
	self.draggingMesh=m
	self.dragMouseStart={sx,sy,sz}
	self.dragMeshStart={m.meshTranslateX,m.meshTranslateY,m.meshTranslateZ}
	
	self.dragFrame=frame
	for i,f in ipairs(self.visibleFrames) do
		if f==frame then
			remove(self.visibleFrames,i)
			break
		end
	end
	self.dragFrame:SetPoint("TOPLEFT",self.frame,"TOPLEFT",0,0)
	self.dragFrame:SetPoint("BOTTOMRIGHT",self.frame,"BOTTOMRIGHT",0,0)	
	self.dragFrame:Show()
end

function T:FrameMouseUp(frame,button)
	self.draggingMesh=nil
	self.dragFrame:Hide()
	self:ReleaseFrame(self.dragFrame)
end

function T:GetFrame()
	local f=remove(self.frameCache)
	if not f then
		f=CreateFrame("Frame",nil,self.frame)
		f:Hide()
		--f:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",edgeFile=nil,tile=true,tileSize=32,edgeSize=0,insets={left=0,right=0,top=0,bottom=0}})
		--f:SetBackdropColor(1.0,1.0,1.0,0.5)
		f:SetScript("OnMouseDown",function(frame,button) self:FrameMouseDown(frame,button) end)
		f:SetScript("OnMouseUp",function(frame,button) self:FrameMouseUp(frame,button) end)
		f:EnableMouse()
	end
	return f
end

function T:ReleaseFrame(f)
	f:Hide()
	insert(self.frameCache,f)
end
