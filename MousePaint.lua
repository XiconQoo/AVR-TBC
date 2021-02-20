local _G = _G
local pairs = pairs
local ipairs = ipairs
local remove = table.remove
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

AVRMousePaint = {Embed = Core.Embed}
local T=AVRMousePaint

function T:New(threed)
	if self ~= T then return end
	local s={}
	
	T:Embed(s)

	s.scene=nil
	s.threed=threed
	s.frame=s.threed.frame
	
	s.paintEnabled=false
	s.dragEnabled=false
	
	s.drawStart=nil
	s.lastPos=nil
	s.mesh=nil
	
	s.followRotate=false
	s.followPlayer=false
	s.drawWidth=32
	
	s.detail=0.5
	
	return s
end

function T:SetDrawMode(followPlayer,followRotate)
	if followPlayer~=nil then self.followPlayer=followPlayer else self.followPlayer=false end
	if followRotate~=nil then self.followRotate=followRotate else self.followRotate=false end
end

function T:SetDetailLevel(level)
	self.detail=level or 0.5
end

function T:SetDrawWidth(width)
	self.drawWidth=width
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

function T:EnableDrag(e,mesh)
	if e==nil then e=true end
	if self.paintEnabled then return end
	
	self:EnableFrameMouse(e)
	self.dragEnabled=e
	if e then
		self.mesh=mesh
		self.scene=self.mesh.scene
	end
end

function T:DisableDrag()
	self:EnableDrag(false)
end


function T:EnableDraw(e,followPlayer,followRotate,scene)
	if e==nil then e=true end
	if self.dragEnabled then return end
	
	self.scene=scene
	self:SetDrawMode(followPlayer,followRotate)
	
	self:EnableFrameMouse(e)
	self.paintEnabled=e
	if not e then
		self.drawStart=nil
		self.mesh=nil
	end
end
function T:DisableDraw()
	self:EnableDraw(false)
end

function T:Translate(x,y,z)
	if self.followPlayer then
		x,y,z=x-self.threed.playerPosX,y-self.threed.playerPosY,z
		if self.followRotate then
			local s=sin(-self.threed.playerDirection)
			local c=cos(-self.threed.playerDirection)
			return c*x-s*y,s*x+c*y,z
		end
	end
	return x,y,z
end

function T:DrawFrameButton(button,state)
	if button=="LeftButton" then
		if state==1 then
			if self.drawStart==nil then
				self.threed:InvertCameraMatrix()
				local cx,cy=GetCursorPosition()
				local sx,sy,sz=self.threed:InverseProject(cx,cy)
				if sx==nil then return end
				sx,sy,sz=self:Translate(sx,sy,sz)
				self.drawStart={sx,sy,sz}
				self.lastPos=nil
			end		
			if self.mesh==nil or self.mesh.removed then
				self.mesh=AVRDataMesh:New()
				self.mesh.name="Paint mesh"
				self.mesh.followRotation=self.followRotate
				self.mesh.followPlayer=self.followPlayer
				if not self.followPlayer then
					self.mesh.meshTranslateX=self.threed.playerPosX
					self.mesh.meshTranslateY=self.threed.playerPosY
				end
				self.scene:AddMesh(self.mesh)
			end
		else
			self.drawStart=nil
		end
	elseif button=="RightButton" and state==1 then
		if self.paintEnabled then self:DisableDraw()
		elseif self.dragEnabled then self:DisableDrag() end
	end
end

function T:UpdatePaint()
	if self.mesh~=nil and self.drawStart~=nil then
		self.threed:InvertCameraMatrix()
		local cx,cy=GetCursorPosition()
		local ex,ey,ez=self.threed:InverseProject(cx,cy)
		if ex==nil then return end
		ex,ey,ez=self:Translate(ex,ey,ez)
		
		local dx,dy,dz
		dx=ex-self.drawStart[1]
		dy=ey-self.drawStart[2]
		dz=ez-self.drawStart[3]

		if self.paintEnabled then
			if dx*dx+dy*dy+dz*dz > self.detail*self.detail then
				self.mesh:AddDataLine(self.drawStart[1]-self.mesh.meshTranslateX,self.drawStart[2]-self.mesh.meshTranslateY,self.drawStart[3],
										ex-self.mesh.meshTranslateX,ey-self.mesh.meshTranslateY,ez,drawWidth)
				self.drawStart={ex,ey,ez}
			end
		elseif self.dragEnabled then
			if self.lastPos~=nil then
				self.mesh:TranslateMesh(-self.lastPos[1],-self.lastPos[2])
			end
			
			if self.mesh.followRotate then
				local s=sin(-self.threed.playerDirection)
				local c=cos(-self.threed.playerDirection)
				dx,dy=c*dx-s*dy,s*dx+c*dy
			end
			
			self.mesh:TranslateMesh(dx,dy)
			self.lastPos={dx,dy}
		end
	end
	
end
