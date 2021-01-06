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

--- Gets or makes a temporary scene.
-- The returned scene is temporary in the sense that it will not be saved
-- in saved variables. It also isn't visible in the default options dialog.
-- Each temporary scene has an id, if an existing temporary scene with the
-- specified id is found then that is returned. Otherwise a new scene is 
-- created. You are free to use any string as id.
-- @param id The id of the scene.
-- @return A scene object.
function Core:GetTempScene(id)
	if not self.sceneManager or not self.threed then return nil end
	if not self.tempScenes then self.tempScenes={} end
	if self.tempScenes[id] then 
		if not self.tempScenes[id].removed then
			return self.tempScenes[id]
		end
	end
	local s=AVRScene:New(self.threed)
	s.save=false
	s.guiVisible=false
	s.name=id
	self.sceneManager:AddScene(s,false)
	self.tempScenes[id]=s
	return s
end

--- Adds a circle warning under everyone in raid.
-- See Add circleWarning for details. This calls that method for everyone in the raid.
-- Segments defaults to a low value because of the large number of circles that this
-- method can potentially add.
-- @param scene The scene where the circles are added.
-- @param follow Boolean indicating whether the circles should follow their units.
-- @param duration The duration in seconds the circles will remain.
-- @param r The red color component for the circles.
-- @param g The green color component for the circles.
-- @param b The blue color component for the circles.
-- @param a The alpha color component for the circles.
-- @param segments The number of segments to use in the circle.
-- @see AddCircleWarning
function Core:AddCircleWarningEveryone(scene,follow,radius,duration,r,g,b,a,segments)
	segments=segments or 8
	local raidSize=GetNumRaidMembers()
	for i=1,raidSize do
		local _,_,subGroup,_,_,_,_,_,dead=GetRaidRosterInfo(i)
		if subGroup and subGroup<=5 and not dead then
			self:AddCircleWarning(scene,"raid"..i,follow,radius,duration,r,g,b,a,segments)
		end
	end
end

--- Adds a circle warning in the given scene.
-- The circle is placed on the specified unit and can be made to either follow
-- the unit or remain where it was initially placed. A timer is added that will
-- remove the circle after spefied amount of seconds. A color for the circle 
-- can be also given, otherwise transparent red is used. Amount of segments to use
-- in the circle can also be provided. Unless there is a spefic reason, this should
-- be left nil. A specific reason is for example to use a low amount of segments
-- in a situation where you are placing many circles.
--
-- @param scene The scene where the circle is added.
-- @param unit The unit on which the circle is placed.
-- @param follow Boolean indicating whether the circle should follow the specified unit.
-- @param duration The duration in seconds the circle will remain. If nil then the mesh
--					won't be automatically removed
-- @param r The red color component for the circle.
-- @param g The green color component for the circle.
-- @param b The blue color component for the circle.
-- @param a The alpha color component for the circle.
-- @param segments The number of segments to use in the circle.
-- @param timer Should the mesh have a visual circular timer.
-- @return The mesh and remove timer handle
function Core:AddCircleWarning(scene,unit,follow,radius,duration,r,g,b,a,segments,timer)
	if not scene then
		scene=Core.sceneManager:GetSelectedScene()
		if not scene then return end
	end
	if follow==nil then follow=true end
	if timer==nil then timer=false end
	radius=radius or 5.0
	r=r or 1.0
	g=g or 0.0
	b=b or 0.0
	a=a or 0.25
	
	local px,py
	if not follow then
		px,py=self.threed:GetUnitPosition(unit)
		if px==0 and py==0 then return end
	end
	local m
	if timer then
		m=AVRTimerCircleMesh:New(radius,segments)
		m:SetColor2(r/2,g/2,b/2,a)
		if duration~=nil then m:SetTimer(duration) end
	else
		m=AVRFilledCircleMesh:New(radius,segments)
	end
	m:SetColor(r,g,b,a)
	if follow then
		m.followUnit=unit
	else
		m:TranslateMesh(px,py)
	end
	scene:AddMesh(m,false,false)
	local timerHandle=nil
	if duration~=nil then
		timerHandle=self:ScheduleTimer(function()
			m:Remove()
		end,duration)
	end
	return m,timerHandle
end
