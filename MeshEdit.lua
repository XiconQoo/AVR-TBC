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

AVRMeshEdit = {Embed = Core.Embed}
local T=AVRMeshEdit

function tablefind(table,element)
	for i,v in ipairs(table) do
		if element==v then return i end
	end
	return -1
end

function T:New(threed)
	if self ~= T then return end
	local s={}

	T:Embed(s)
	
	s.editMesh=nil
	s.handleCache={}
	s.visibleHandles={}
	s.handleCount=0
	s.threed=threed
	s.frame=s.threed.frame
	s.selected={}

	s.mode="" -- "", "edit", "addvertex", "addtriangle", "drag"
	s.dragging=false
	s.mouseStart=nil
	s.selectionStart=nil
		
	return s
end

function T:OnUpdatePreRender()
	if self.editMesh and self.editMesh.removed then
		self:DisableEdit()
	end
	
	if not self.dragging and self.mouseStart~=nil then
		local mx,my=GetCursorPosition()
		local dx=self.mouseStart[1]-mx
		local dy=self.mouseStart[2]-my
		if dx*dx+dy*dy>=9 and #self.selected>0 then
			self.threed:InvertCameraMatrix()
			local sx,sy,sz=self.threed:InverseProject(mx,my)
			if sx~=nil then
				self.mouseStart[3]=sx
				self.mouseStart[4]=sy
				self.mouseStart[5]=sz
				self.dragging=true
				self.selectionStart={self:GetSelectionCoords()}
			end
		end
	end
	
	if self.dragging then
		self.threed:InvertCameraMatrix()
		local mx,my=GetCursorPosition()
		if IsShiftKeyDown() then
			local dy=my-self.mouseStart[2]
			self:SetSelectionCoords(nil,nil,self.selectionStart[3]+dy*0.05)
		else
			local sx,sy,sz=self.threed:InverseProject(mx,my)
			if sx~=nil then
				local dx=sx-self.mouseStart[3]
				local dy=sy-self.mouseStart[4]
				self:SetSelectionCoords(self.selectionStart[1]+dx,self.selectionStart[2]+dy,nil)
			end
		end
	end
end

function T:OnUpdate()
	self:ClearAllHandles()
	if self.editMesh~=nil then
		local vs=self.editMesh.vertices
		local v,tex
		for i=1,#vs do
			v=vs[i]
			tex=self:GetHandleFrame()
			insert(self.visibleHandles,tex)
			tex.vertex=i
			tex:Show()
			if tablefind(self.selected,i)~=-1 then
				tex:SetVertexColor(1.0,0.0,0.0,0.5)
			else
				tex:SetVertexColor(1.0,1.0,1.0,0.5)
			end
			tex:SetPoint("BOTTOMLEFT",self.frame,"CENTER",v[7]-3,v[8]-3)
			tex:SetPoint("TOPRIGHT",self.frame,"CENTER",v[7]+3,v[8]+3)
		end
	end
end

function T:EnableFrameMouse(e)
	self.frame:EnableMouse(e)
	if e then
		self.frame:SetScript("OnMouseDown",function(widget,button) self:DrawFrameButton(button,1) end)
		self.frame:SetScript("OnMouseUp",function(widget,button) self:DrawFrameButton(button,0) end)
	else
		self.frame:SetScript("OnMouseDown",nil)
		self.frame:SetScript("OnMouseUp",nil)
	end
end

function T:EnableEdit(mesh)
	self.editMesh=mesh
	if mesh~=nil then
		self:EnableFrameMouse(true)
		self.mode="edit"
		self.dragging=false
		self.mouseStart=nil
	else
		self:EnableFrameMouse(false)
		self.mode=""
		self.dragging=false
		self.mouseStart=nil
	end
end
function T:DisableEdit()
	self:EnableEdit(nil)
end

function T:ClearAllHandles()
	local tex
	while #self.visibleHandles>0 do
		tex=remove(self.visibleHandles)
		self:ReleaseHandleFrame(tex)
	end
end

function T:GetVertexAt(x,y)
	if not self.editMesh then return nil end
	for i=1,#self.visibleHandles do
		local h=self.visibleHandles[i]
		if x>=h:GetLeft() and x<=h:GetRight() and y>=h:GetBottom() and y<=h:GetTop() then
			return h.vertex
		end
	end
	return -1
end

function T:DrawFrameButton(button,state)
	if self.mode=="" then return end
	
	if self.mode=="edit" then
		local mx,my=GetCursorPosition()
		if button=="LeftButton" and state==1 and self.mouseStart==nil then
			self.mouseStart={mx,my}
		end
		
		if not self.dragging and button=="LeftButton" and state==0 then
			if not IsShiftKeyDown() then
				self.selected={}
			end
			local v=self:GetVertexAt(mx,my)
			if v~=-1 then
				local ind=tablefind(self.selected,v)
				if ind~=-1 then
					remove(self.selected,ind)
				else
					insert(self.selected,v)
				end
			end
		end
		
		if state==0 then
			self.dragging=false
			self.mouseStart=nil
		end
		
	elseif self.mode=="addvertex" then
		if button=="RightButton" then
			self.mode="edit"
		else
			if state==0 then
				self.threed:InvertCameraMatrix()
				local mx,my=GetCursorPosition()
				local sx,sy,sz=self.threed:InverseProject(mx,my)
				if sx==nil then return end
				self.editMesh:AddDataVertex(sx,sy,sz)
			end
		end
	end
end

function T:GetSelectionCoords()
	if not self.editMesh then return nil end
	if #self.selected==0 then return 0,0,0 end
	local x,y,z=0,0,0
	for i=1,#self.selected do
		local v=self.editMesh.vertexData[self.selected[i]]
		x=x+v[1]
		y=y+v[2]
		z=z+v[3]
	end
	return x/#self.selected,y/#self.selected,z/#self.selected
end

function T:SetSelectionCoords(nx,ny,nz)
	if not self.editMesh then return nil end
	local x,y,z=self:GetSelectionCoords()
	if x==nil then return end
	if nx==nil then nx=x end
	if ny==nil then ny=y end
	if nz==nil then nz=z end
	
	local dx,dy,dz=nx-x,ny-y,nz-z
	
	for i=1,#self.selected do
		local v=self.editMesh.vertexData[self.selected[i]]
		v[1]=v[1]+dx
		v[2]=v[2]+dy
		v[3]=v[3]+dz
	end
	self.editMesh.vertices=nil
end

function T:AddTriangle()
	if not self.editMesh then return end
	if #self.selected~=3 then return end
	
	local t=AVRTriangle:New(self.selected[1],self.selected[2],self.selected[3])
	self.editMesh:AddDataTriangle(t)
end

function T:DeleteTriangle()
	if not self.editMesh then return end
	if #self.selected~=3 then return end
	for i=1,#self.editMesh.triangleData do
		local t=#self.editMesh.triangleData[i]
		if tablefind(self.selected,t.v1)~=-1 and tablefind(self.selected,t.v2)~=-1 and tablefind(self.selected,t.v3)~=-1 then
			self.editMesh:DeleteDataTriangle(t)
			break
		end
	end
end

function T:DeleteSelectedVertices()
	if not self.editMesh then return end
	if not self.selected or #self.selected==0 then return end
	table.sort(self.selected)
	for i=#self.selected,1,-1 do
		self.editMesh:DeleteDataVertex(self.selected[i])
	end
	self.selected={}
end

function T:GetHandleFrame()
	local tex=remove(self.handleCache)
	if not tex then
		tex=self.frame:CreateTexture("AVR_EDITHANDLE_"..self.handleCount,"ARTWORK")
		self.handleCount=self.handleCount+1
		tex:SetTexture("Interface\\AddOns\\AVR\\Textures\\square")
	end
	return tex
end
function T:ReleaseHandleFrame(tex)
	tex:Hide()
	insert(self.handleCache,tex)
end

function T:GetOptions()
	return {
		type = "group",
		name = L["Mesh edit"],
		args = {
			startedit = {
				order = 10,
				type = "execute",
				name = L["Start edit"],
				disabled = (Core.sceneManager:GetSelectedMesh()==nil) ,
				func = function() 
					local m=Core.sceneManager:GetSelectedMesh()
					if m.class~="AVRDataMesh" then
						Core:Print("Can only edit AVRDataMeshes")
					else
						self:EnableEdit(m)
						Core:OptionsChanged()
					end
				end
			},
			stopedit = {
				order = 20,
				type = "execute",
				name = L["Stop edit"],
				disabled = (self.editMesh==nil),
				func = function()
					self:DisableEdit()
					Core:OptionsChanged()
				end
			},
			addvertex = {
				order = 30,
				type = "execute",
				name = L["Add vertices"],
				disabled = (self.editMesh==nil),
				func = function() 
					self.mode="addvertex"
				end
			},
			deletevertex = {
				order = 40,
				type = "execute",
				name = L["Delete vertices"],
				disabled = (self.editMesh==nil),
				func = 	function() 
							self:DeleteSelectedVertices()
						end
			},
			addtriangle = {
				order = 50,
				type = "execute",
				name = L["Add triangle"],
				disabled = (self.editMesh==nil),
				func = 	function() 
							self:AddTriangle()
						end
			},
			removetriangle = {
				order = 60,
				type = "execute",
				name = L["Remove triangle"],
				disabled = (self.editMesh==nil),
				func = 	function()
							self:DeleteTriangle()
						end
			},
			newMesh = {
				order = 70,
				type = "execute",
				name = L["New mesh"],
				disabled = (Core.sceneManager:GetSelectedScene()==nil),
				func = 	function()
							local m=AVRDataMesh:New()
							m.name="Data mesh"
							m.followPlayer=false
							m.followRotation=false
							m.highres=true
							Core.sceneManager:GetSelectedScene():AddMesh(m)
						end
			}
		}
	}
end




