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
local tostring,tonumber=tostring,tonumber
local strlen=string.len

local Core=AVR


local function packDouble(d)
	if d==nil then return d end
	if Core.db.profile.noPackDoubles then return d end
	local s=tostring(d)
	if tonumber(s)==d and strlen(s)<8 then return d end
	local bs=AVRByteStream:New()
	bs:WriteDouble(d)
	bs:FlushBuffer()
	return bs.data[1]
end
local function unpackDouble(p)
	if p==nil then return p end
	if type(p)=="number" then return p end
	local bs=AVRByteStream:New({data={p}})
	return bs:ReadDouble()
end
AVRUnpackDouble=unpackDouble
AVRPackDouble=packDouble

AVRMesh = {Embed=Core.Embed}

-- A table describing how to use this mesh class.
AVRMesh.meshInfo={
	-- A string used to identify the class when saving to saved variables or sending the mesh
	-- to others through addon channel.
	class="AVRMesh",
	
	-- A boolean flag indicating whether this class is derived from some other primary class.
	-- For example, AVRBlink is really just an AVRCircleMesh with the circle moved to correct
	-- position.
	derived=false,
	
	-- Is there an option in the default options to create new meshes of this type.
	guiCreateNew=false,
	
	-- A user visible name used for this class. Should be localized. Can be null if guiCreateNew is false.
	guiName=nil,
	
	-- Should it be possible to receive meshes of this type from others.
	receivable=false
}

--- Creates a new mesh.
-- If it is possible for the mesh to be unpacked from saved variables or an addon message or
-- it is possible to create new meshes of this type from the default options (guiCreateNew flag
-- in meshInfo) then the constructor must be callable without any parameters.
function AVRMesh:New()
	if self ~= AVRMesh then return end
	local s={}
	
	AVRMesh:Embed(s)
	
	s.name=""			-- name of the mesh
	s.class=AVRMesh.meshInfo.class	-- class identifier
	s.vertices={}		-- model vertex data used for rendering
						-- each vertex is an array of 8, first three are mesh coordinates, next three are
						-- coordinates after camera rotation, last two projected screen coordinates
	s.lines={}			-- model line data used for rendering, list of AVRLine objects
	s.triangles={}		-- model triangle data used for rendering, list of AVRTriangle objects
	s.textures={}		-- model texture data used for rendering, list of AVRTexture objects
	
	-- There are two types of deformations. First is done in GenerateMesh whes self.vertices is generated.
	-- Other is done in OnUpdate or rather in threed.ProjectMesh during the actual rendering. Generally
	-- modifying the first type is more costly as a single operation since it requires regenerating the
	-- model vertex data. But after it's done it's faster to render. Thus something that changes every or
	-- close to every frame should use the second type of deformations and more static deformations should
	-- use the first type.
	s.meshTranslateX=0	-- translation of mesh data done in GenerateMesh
	s.meshTranslateY=0
	s.meshTranslateZ=0
	s.meshRotateZ=0		-- rotation of mesh data done in GenerateMesh
	s.meshScaleX=1.0	-- scaling of mesh data done in GenerateMesh
	s.meshScaleY=1.0
	s.meshScaleZ=1.0
	s.translateX=0		-- translation of mesh done when rendering
	s.translateY=0
	s.translateZ=0
	s.rotateZ=0			-- rotation of mesh done when rendering
	s.scaleX=1.0		-- scaling of mesh done when rendering
	s.scaleY=1.0
	s.scaleZ=1.0
	s.visible=true		-- is this mesh visible
	s.clipToScreen=false	-- Should mesh be clipped to screen before drawing.
							-- Use this if you have very big meshes.
	
	-- all lines and triangles may override the default mesh color,
	-- these values are used if line/triangle color is nil
	s.r=1.0				-- red color component
	s.g=1.0				-- green color component
	s.b=1.0				-- blue color component
	s.a=1.0				-- alpha color component
	
	s.followUnit=nil		-- unit id to follow or nil for none
	s.followPlayer=false	-- should the mesh follow player
	s.followRotation=false	-- should the mesh follow player rotation
	
	s.removed=false			-- flag set when the mesh has been removed

	return s
end

--- A separate constructor used to create a template for the new mesh menu.
-- If guiCreateNew flag in meshInfo is false then this constructor is never used.
-- Default implementiation calls the normal New constructor and in most cases
-- shouldn't have to be overridden.
--
-- Basically the object created with this constructor should have all options working
-- but it doesn't need to be renderable.
function AVRMesh:NewTemplate()
	return self:New()
end

--- An options table for this mesh.
-- If you make sure that the mesh can never have a visible options table then you can
-- return nil. In other words, if meshInfo.guiCreateNew is false and you add meshes
-- of this type only to scenes which don't expose the meshes to the user through
-- options.
function AVRMesh:GetOptions()
	return {
		name = self.name,
		type = "group",
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
				width = "full"
			},
			select = {
				type = "toggle",
				name = L["Select"],
				width = "full",
				disabled = (self.scene==nil),
				order = 20,
				get =	function(_)
							if not self.scene then return false end
							if self.scene:GetSelectedMesh()==self then return true
							else return false end
						end,
				set =	function(_,val)
							if not self.scene then return end
							if val then self.scene:SetSelectedMesh(self)
							else self.scene:SetSelectedMesh(nil) end
						end
			},
			remove = {
				type = "execute",
				name = L["Remove"],
				width = "full",
				order = 30,
				func = function() self:Remove() end
			},
			color = {
				get = 	function(info)
							return self.r,self.g,self.b,self.a
						end,
				set =	function(info,r,g,b,a)
							self:SetColor(r,g,b,a)
						end,
				type = "color",
				name = L["Color"],
				hasAlpha = true,
				order = 40
			},
			follow = {
				type = "group",
				name = L["Follow behavior"],
				inline = true,
				order = 50,
				args = {
					followPlayer = {
						type = "toggle",
						name = L["Follow player"],
						desc = L["Follow player desc"],
						order = 10,
					},
					followRotation = {
						type = "toggle",
						name = L["Follow rotation"],
						desc = L["Follow rotation desc"],
						order = 20,
					},
					followUnit = {
						type = "input",
						name = L["Follow unit"],
						desc = L["Follow unit desc"],
						order = 30,
						set = 	function(info,val)
									val=string.gsub(string.gsub(val,"^%s*",""),"%s*$","")
									if string.len(val)==0 then val=nil end
									self.followUnit=val
								end
					},
					header1 = {
						type = "header",
						name = "",
						order = 40,
					},
					attach = {
						type = "execute",
						name = L["Attach"],
						desc = L["Attach desc"],
						order = 50,
						func = function() self:Attach() end
					},
					detach = {
						type = "execute",
						name = L["Detach"],
						desc = L["Detach desc"],
						order = 60,
						func = function() self:Detach() end
					},
--[[
					attachRotation = {
						type = "execute",
						name = L["Attach rotation"],
						order = 70,
						func = function() self:AttachRotation() end
					},
					detachRotation = {
						type = "execute",
						name = L["Detach rotation"],
						order = 80,
						func = function() self:DetachRotation() end
					},
--]]
				}
			},
			meshDeform = {
				type = "group",
				name = L["Mesh deform"],
				inline = true,
				order = 100,
				args = {
					drag = {
						type = "execute",
						name = L["Drag"],
						desc = L["Drag desc"],
						order = 10,
						width = "full",
						func = function() Core.mousePaint:EnableDrag(true,self) end
					},					
					meshTranslateX = {
						type = "range",
						name = L["X Position"],
						order = 20,
						width = "full",
						min = -500, max = 500, bigStep = 0.5,
						set = function(_,val) self.meshTranslateX=val ; self.vertices=nil end
					},
					meshTranslateY = {
						type = "range",
						name = L["Y Position"],
						order = 30,
						width = "full",
						min = -500, max = 500, bigStep = 0.5,
						set = function(_,val) self.meshTranslateY=val ; self.vertices=nil end
					},
					meshTranslateZ = {
						type = "range",
						name = L["Z Position"],
						order = 40,
						width = "full",
						min = -500, max = 500, bigStep = 0.5,
						set = function(_,val) self.meshTranslateZ=val ; self.vertices=nil end
					},
					meshScaleX = {
						type = "range",
						name = L["X Scale"],
						order = 50,
						width = "full",
						min = -100, max = 100, bigStep = 0.1,
						set = function(_,val) self.meshScaleX=val ; self.vertices=nil end
					},
					meshScaleY = {
						type = "range",
						name = L["Y Scale"],
						order = 60,
						width = "full",
						min = -100, max = 100, bigStep = 0.1,
						set = function(_,val) self.meshScaleY=val ; self.vertices=nil end
					},
					meshScaleZ = {
						type = "range",
						name = L["Z Scale"],
						order = 70,
						width = "full",
						min = -100, max = 100, bigStep = 0.1,
						set = function(_,val) self.meshScaleZ=val ; self.vertices=nil end
					},
					meshRotateZ = {
						type = "range",
						name = L["Z Rotate"],
						order = 80,
						width = "full",
						min = -360, max = 360, bigStep = 0.1,
						set = function(_,val) self.meshRotateZ=val*pi/180 ; self.vertices=nil end,
						get = function(_) return self.meshRotateZ*180/pi end
					}
				}
			},
		}
	}
end

--- Generates the vertices, lines and triangles that make up the mesh.
-- Meshes in AVR are generally defined by a small amount of options.
-- This method should generate the actual 3d data based on these options.
-- The options can be changed and 3d data needs to be remade even after
-- the mesh has been made visible. This method is called automatically
-- if self.vertices, self.triangles or self.lines is nil.
--
-- The default implementation translates, scales and rotates the mesh
-- according to meshTranslate, meshScale and meshRotate options.
-- Overriding classes should generally first create the mesh and then
-- call AVRMesh.GenerateMesh(self) to apply the deformations.
function AVRMesh:GenerateMesh()
	ca=cos(self.meshRotateZ)
	sa=sin(self.meshRotateZ)
	local preA,preB,preC,preD=ca*self.meshScaleX,-sa*self.meshScaleY,
								sa*self.meshScaleX, ca*self.meshScaleY
	local v
	for i=1,#self.vertices do
		v=self.vertices[i]
		v[1],v[2],v[3]=	preA*v[1]+preB*v[2]+self.meshTranslateX,
						preC*v[1]+preD*v[2]+self.meshTranslateY,
						self.meshScaleZ*v[3]+self.meshTranslateZ
	end
end

--- Duplicates this mesh.
-- Default implementation does this by packing and unpacking the mesh.
-- @return A new mesh that will be identical to this.
function AVRMesh:Duplicate()
	local packed=self:Pack()
	local ret=AVR.meshGeneratorClasses[self.class]:New()
	ret:Unpack(packed)
	return ret
end

--- Packs the mesh for saved variables or to be sent through the addon channel.
-- Should return a table with all the relevant options. To reduce the size
-- of the table, it should not contain the actual 3d model data, only the
-- options needed to regenerate it. In some cases the 3d model can't be
-- describe by just a few options and the actual model data has to be
-- included. AVRDataMesh can be used to do this.
-- @return A table containing enough data to reconstruct this mesh.
function AVRMesh:Pack()
	local s={
		n=self.name,
		c=self.class,
		tx=packDouble(self.meshTranslateX),
		ty=packDouble(self.meshTranslateY),
		tz=packDouble(self.meshTranslateZ),
		rz=packDouble(self.meshRotateZ),
		sx=packDouble(self.meshScaleX),
		sy=packDouble(self.meshScaleY),
		sz=packDouble(self.meshScaleZ),
		v=self.visible,
		cs=self.clipToScreen,
		r=packDouble(self.r),
		g=packDouble(self.g),
		b=packDouble(self.b),
		a=packDouble(self.a),
		fu=self.followUnit,
		fp=self.followPlayer,
		fr=self.followRotation
	}
	return s
end

--- Unpacks the mesh from saved variables or a message received through
-- the addon channel. This methoud should try to be lenient about missing
-- options and use reasonable default values for those. Backward compatibility
-- with older versions is also strongle recommended.
-- @param s The packed table as returned by Pack.
function AVRMesh:Unpack(s)
	self.name=s.n or L["unnamed"]
	self.meshTranslateX=unpackDouble(s.tx) or 0.0
	self.meshTranslateY=unpackDouble(s.ty) or 0.0
	self.meshTranslateZ=unpackDouble(s.tz) or 0.0
	self.meshRotateZ=unpackDouble(s.rz) or 0.0
	self.meshScaleX=unpackDouble(s.sx) or 1.0
	self.meshScaleY=unpackDouble(s.sy) or 1.0
	self.meshScaleZ=unpackDouble(s.sz) or 1.0
	if s.v==nil then self.visible=true
	else self.visible=s.v end
	self.clipToScreen=s.cs or false
	self.r=unpackDouble(s.r) or 1.0
	self.g=unpackDouble(s.g) or 1.0
	self.b=unpackDouble(s.b) or 1.0
	self.a=unpackDouble(s.a) or 1.0
	self.followUnit=s.fu
	self.followPlayer=s.fp or false
	self.followRotation=s.fr or false
	self.vertices={}
	self.lines={}
	self.triangles={}
end

--- Sets the scene where this mesh belongs to.
-- This method must be called before trying to render this mesh.
function AVRMesh:SetScene(scene)
	self.scene=scene
	self.removed=false
	if self.scene then self.threed=self.scene.threed
	else self.threed=nil end
end

--- Notification that this mesh has been removed from the scene where it was.
function AVRMesh:OnRemove()
	self.removed=true
end

--- Remove this mesh from the scene where it is currently.
function AVRMesh:Remove()
	if self.scene then self.scene:RemoveMesh(self) end
end

--- Makes this mesh the selected mesh in its scene.
function AVRMesh:SelectMesh()
	if self.scene then self.scene:SetSelectedMesh(self) end
end

--- Sets the color of the mesh.
-- Any of the parameters can be nil in which case the current
-- value of that will not be changed. All values are in the range 0<=value<=1.
-- @param r The red component
-- @param g The green component
-- @param b The blue component
-- @param a The alpha component
function AVRMesh:SetColor(r,g,b,a)
	if r~=nil then self.r=r end
	if g~=nil then self.g=g end
	if b~=nil then self.b=b end
	if a~=nil then self.a=a end
	return self
end

--- Translates the mesh.
-- Any of the parameters can be nil in which case the mesh is not
-- translated in that direction. This adds to the existing translation.
-- Use SetMeshTranslate to set absolute translation values.
--
-- @param x Translation in X direction.
-- @param y Translation in Y direction.
-- @param z Translation in Z direction.
-- @see SetMeshTranslate
function AVRMesh:TranslateMesh(x,y,z)
	if x~=nil then self.meshTranslateX=self.meshTranslateX+x end
	if y~=nil then self.meshTranslateY=self.meshTranslateY+y end
	if z~=nil then self.meshTranslateZ=self.meshTranslateZ+z end
	self.vertices=nil
	return self
end

--- Sets the translation parameters.
-- Unlike TranslateMesh, this sets absolute values instead of adding
-- to existing translation values.
-- @param x Translation in X direction.
-- @param y Translation in Y direction.
-- @param z Translation in Z direction.
function AVRMesh:SetMeshTranslate(x,y,z)
	self.meshTranslateX=x
	self.meshTranslateY=y
	self.meshTranslateZ=z
	self.vertices=nil
	return self
end

--- Rotates the mesh around Z axis.
-- This adds to existing rotation. Use SetMeshRotation to set
-- absolute values.
-- @param z Amount to rotate in radians.
-- @see SetMeshRotation
function AVRMesh:RotateMesh(z)
	if z~=nil then self.meshRotateZ=self.meshRotateZ+z end
	self.vertices=nil
	return self
end

--- Sets the mesh rotation around Z axis
-- Unlike RotateMesh, this sets the absolute value
-- @param z Amount to rotate in radians.
-- @see RotateMesh
function AVRMesh:SetMeshRotation(z)
	self.meshRotateZ=z
	self.vertices=nil
	return self
end

--- Scales the mesh.
-- If only one parameter is provided then then uniform scaling
-- is performed. If only two parameters are provided then z is
-- assumed to be 1.0, i.e. not scaled. This multiplies current
-- scale values. Use SetMeshScale to set absolute values.
-- @param x The scale factor for X-axis or uniform scale factor if y and z parameters are nil.
-- @param y The scale factor for Y-axis.
-- @param z The scale factor for Z-axis, assumed 1.0 if not given.
-- @see SetMeshScale
function AVRMesh:ScaleMesh(x,y,z)
	if y==nil then
		y=x
		z=x
	elseif z==nil then
		z=1.0
	end
	self.meshScaleX=self.meshScaleX*x
	self.meshScaleY=self.meshScaleY*y
	self.meshScaleZ=self.meshScaleZ*z
	self.vertices=nil
end

--- Scales the mesh.
-- Unlike ScaleMesh, this sets absolute values.
-- @param x The scale factor for X-axis or uniform scale factor if y and z parameters are nil.
-- @param y The scale factor for Y-axis.
-- @param z The scale factor for Z-axis, assumed 1.0 if not given.
-- @see ScaleMesh
function AVRMesh:SetMeshScale(x,y,z)
	self.meshScaleX=x
	self.meshScaleY=y
	self.meshScaleZ=z
	self.vertices=nil
end

--- Sets the name of this mesh.
function AVRMesh:SetName(name)
	self.name=name
	Core:OptionsChanged()
	return self
end

--- Sets this mesh to follow or not follow the player.
-- @param value Whether this mesh should follow the player.
-- @see Attach, Detach
function AVRMesh:SetFollowPlayer(value)
	if value==nil then value=true end
	self.followPlayer=value
	return self
end

--- Sets this mesh to follow any unit id for which map coordinates are available.
-- Note that follow player takes precedence over this option.
-- @param value The unit id to follow or nil to stop following a unit.
function AVRMesh:SetFollowUnit(value)
	if value==nil then value=true end
	if self.followPlayer then
		self:SetFollowPlayer(false)
	end
	self.followUnit=value
	return self
end

--- Makes this mesh to follow or not follow the player rotation.
-- Note that usually following rotation will be useless unless
-- the player position is also followed.
-- @param value Whether this mesh should follow the player rotation.
-- @see AttachRotation, DetachRotation
function AVRMesh:SetFollowRotation(value)
	if value==nil then value=true end
	self.followRotation=value
	return self
end

--- Sets the mesh to follow player and translates it so that it retains
-- its current relative position to player.
-- If you have a mesh under your feet that currently isn't following the
-- player and you call SetFollowPlayer(true) then the mesh will most
-- likely end up somewhere very far from the player. This is because 
-- for player following meshes the origin is at player position and for
-- others it's at the corner of the map. In addition to setting the
-- follow flag, this method also translates the mesh so that it keeps
-- it's current position relative to player.
-- @param threed Threed object used to get zone coordinates. If this mesh
--				 has already been added to a scene you can pass nil.
-- @see Detach
function AVRMesh:Attach(threed)
	if self.followUnit~=nil then
		self.followUnit=nil
		self.followPlayer=true
	elseif not self.followPlayer then
		threed=threed or self.threed
		self.followPlayer=true
		self.meshTranslateX,self.meshTranslateY,self.meshTranslateZ=
			self.meshTranslateX-threed.playerPosX,
			self.meshTranslateY-threed.playerPosY,
			self.meshTranslateZ-threed.playerPosZ
		self.vertices=nil
	end
	return self
end

--- Sets the mesh to not follow player and translates it so that it
-- retains its current relative position to player.
-- @param threed The 3d object used to get zone coordinates. If this mesh
--				 has already been added to a scene you can pass nil.
-- @see Attach
function AVRMesh:Detach(threed)
	if self.followPlayer then
		threed=threed or self.threed
		self.followPlayer=false
		self.meshTranslateX,self.meshTranslateY,self.meshTranslateZ=
			self.meshTranslateX+threed.playerPosX,
			self.meshTranslateY+threed.playerPosY,
			self.meshTranslateZ+threed.playerPosZ		
		self.vertices=nil
	end
	return self
end

function AVRMesh:AttachRotation(threed)
	if not self.followRotation then
		threed=threed or self.threed
		self.followRotation=true
		self.meshRotateZ=self.meshRotateZ-threed.playerDirection
		self.vertices=nil
	end
	return self
end
function AVRMesh:DetachRotation(threed)
	if self.followRotation then
		threed=threed or self.threed
		self.followRotation=false
		self.meshRotateZ=self.meshRotateZ+threed.playerDirection
		self.vertices=nil
	end
	return self
end

--- Notifies mesh that it is about to be rendered.
-- This method should do all necessary preparations so that
-- self.vertices, self.lines, and self.triangles contain the
-- 3d model data that can be rendered.
-- 
-- Default implementation generetes the mesh using GenerateMesh
-- if needed and applies translations if the mesh is following any unit.
--
-- Overriding classes may or may not want to call the default implementation.
-- If not, then they must make sure themselves that the 3d model data is ready.
-- If this mesh should not be rendered then self.visible can be set to false.
--
-- @param threed The 3d engine.
function AVRMesh:OnUpdate(threed)
	if self.vertices==nil or self.lines==nil or self.triangles==nil or self.textures==nil then
		self.vertices={}
		self.lines={}
		self.triangles={}
		self.textures={}
		self:GenerateMesh()
	end

	if self.followRotation then
		self.rotateZ=threed.playerDirection
	else
		self.rotateZ=0.0
	end
	
	local ux,uy
	if self.followPlayer then
		self.translateX,self.translateY,self.translateZ=threed.playerPosX,threed.playerPosY,threed.playerPosZ
	elseif self.followUnit~=nil then
		self.visible=true
		ux,uy=threed:GetUnitPosition(self.followUnit)
		if ux==0.0 then
			self.visible=false
		else
			self.translateX,self.translateY,self.translateZ=ux,uy,threed.playerPosZ
		end
	else
		self.translateX,self.translateY,self.translateZ=0.0,0.0,0.0
	end
	self.scaleX,self.scaleY,self.scaleZ=1.0,1.0,1.0
end

--- Adds a vertex in self.vertices table.
-- @param x X coordinate of the vertex.
-- @param y Y coordinate of the vertex.
-- @param z Z coordinate of the vertex.
-- @return The index of the created vertex.
function AVRMesh:AddVertex(x,y,z)
	insert(self.vertices,{x,y,z,0,0,0,0,0})
	return #self.vertices
end

--- Finds the index of a previously created vertex in self.vertices table.
-- @param x X coordinate of the vertex.
-- @param y Y coordinate of the vertex.
-- @param z Z coordinate of the vertex.
-- @return The index the vertex or nil if not found.
function AVRMesh:FindVertex(x,y,z)
	for i,v in ipairs(self.vertices) do
		if v[1]==x and v[2]==y and v[3]==z then return i end
	end
	return nil
end

--- Creates a new vertex or uses an existing one in self.vertices table.
-- @param x X coordinate of the vertex.
-- @param y Y coordinate of the vertex.
-- @param z Z coordinate of the vertex.
-- @return The index of the found or created vertex.
function AVRMesh:AddOrFindVertex(x,y,z)
	return self:FindVertex(x,y,z) or self:AddVertex(x,y,z)
end

--- Adds a line in self.lines table.
-- Can either be given line end point coordinates in which case the
-- vertices are created as needed or can be called with a single
-- parameter containing an AVRLine object.
-- @param line Either the first x coordinate or a premade AVRLine object.
-- @param y1 The first y coordinate.
-- @param z1 The first z coordinate.
-- @param x2 The second x coordinate.
-- @param y2 The second y coordinate.
-- @param z2 The second z coordinate.
-- @param width Line width or nil for default.
-- @param a The alpha color component or nil to use default mesh color.
-- @param r The red color component or nil to use default mesh color.
-- @param g The green color component or nil to use default mesh color.
-- @param b The blue color component or nil to use default mesh color.
function AVRMesh:AddLine(line,y1,z1,x2,y2,z2,width,a,r,g,b)
	if y1~=nil then
		local v1=self:AddOrFindVertex(line,y1,z1)
		local v2=self:AddOrFindVertex(x2,y2,z2)
		local l=AVRLine:New(v1,v2,width,a,r,g,b)
		insert(self.lines,l)
		return l
	else
		insert(self.lines,line)
	end
end

--- Adds a triangle in self.triangles table.
-- Can either be given triangle corner coordinates in which case the
-- vertices are created as needed or can be called with a single
-- parameter containing an AVRTriangle object.
-- @param triangle Either the first x coordinate or a premade AVRTriangle object.
-- @param y1 The first y coordinate.
-- @param z1 The first z coordinate.
-- @param x2 The second x coordinate.
-- @param y2 The second y coordinate.
-- @param z2 The second z coordinate.
-- @param x3 The third x coordinate.
-- @param y3 The third y coordinate.
-- @param z3 The third z coordinate.
-- @param a The alpha color component or nil to use default mesh color.
-- @param r The red color component or nil to use default mesh color.
-- @param g The green color component or nil to use default mesh color.
-- @param b The blue color component or nil to use default mesh color.
function AVRMesh:AddTriangle(triangle,y1,z1,x2,y2,z2,x3,y3,z3,a,r,g,b)
	if y1~=nil then
		local v1=self:AddOrFindVertex(triangle,y1,z1)
		local v2=self:AddOrFindVertex(x2,y2,z2)
		local v3=self:AddOrFindVertex(x3,y3,z3)
		local t=AVRTriangle:New(v1,v2,v3,a,r,g,b)
		insert(self.triangles,t)
		return t
	else
		insert(self.triangles,triangle)
	end
end

function AVRMesh:AddTexture(tex,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4,x5,y5,z5,texture,a,r,g,b)
	if y1~=nil then
		local v1=self:AddOrFindVertex(tex,y1,z1)
		local v2=self:AddOrFindVertex(x2,y2,z2)
		local v3=self:AddOrFindVertex(x3,y3,z3)
		local v4=self:AddOrFindVertex(x4,y4,z4)
		local v5=self:AddOrFindVertex(x5,y5,z5)
		local t=AVRTexture:New(v1,v2,v3,v4,v5,texture,a,r,g,b)
		insert(self.textures,t)
		return t
	else
		insert(self.textures,tex)
	end
end


--- Adds several lines from a table of data.
-- Each element in the table should be another table containing
-- parameters for AddLine method. Can also optionally be given
-- a scaling factor. The coordinates are scaled with this.
-- @param data A table containing the line data.
-- @param scale A scaling factor to scale the coordinates with or nil if no scaling is desired.
function AVRMesh:AddLineData(data,scale)
	scale=scale or 1.0
	for i=1,#data do
		self:AddLine(data[i][1]*scale,data[i][2]*scale,data[i][3]*scale,
					 data[i][4]*scale,data[i][5]*scale,data[i][6]*scale,
					 data[i][7],data[i][8],data[i][9],data[i][10],data[i][11])
	end
end

--- Adds several triangles from a table of data.
-- Each element in the table should be another table containing
-- parameters for AddTriangle method. Can also optionally be given
-- a scaling factor. The coordinates are scaled with this.
-- @param data A table containing the triangle data.
-- @param scale A scaling factor to scale the coordinates with or nil if no scaling is desired.
function AVRMesh:AddTriangleData(data,scale)
	scale=scale or 1.0
	for i=1,#data do
		self:AddTriangle(	data[i][1]*scale,data[i][2]*scale,data[i][3]*scale,
							data[i][4]*scale,data[i][5]*scale,data[i][6]*scale,
							data[i][7]*scale,data[i][8]*scale,data[i][9]*scale,
							
							data[i][10],data[i][11],data[i][12],data[i][13])
	end
end


AVRLine = {Embed = Core.Embed}
--- Constructs a new line object.
-- @param v1 Vertex index for the first end point.
-- @param v2 Vertex index for the second end point.
-- @width Line width or nil for default. 
-- @param a The alpha color component or nil to use default mesh color.
-- @param r The red color component or nil to use default mesh color.
-- @param g The green color component or nil to use default mesh color.
-- @param b The blue color component or nil to use default mesh color.
function AVRLine:New(v1,v2,width,a,r,g,b)
	if self ~= AVRLine then return end
	local s={}
		
	AVRLine:Embed(s)
	
	s.r=r
	s.g=g
	s.b=b
	s.a=a
	s.v1=v1
	s.v2=v2
	s.width=(width==nil and 32 or width)
	s.visible=true

	return s
end

--- Packs the line in a byte stream.
function AVRLine:Pack(bs)
	bs:WriteByte((self.r~=nil and 1 or 0)+(self.g~=nil and 2 or 0)+(self.b~=nil and 4 or 0)+(self.a~=nil and 8 or 0)+
				 (self.visible and 16 or 0))
	if self.r~=nil then bs:WriteByte(math.floor(self.r*255)) end
	if self.g~=nil then bs:WriteByte(math.floor(self.g*255)) end
	if self.b~=nil then bs:WriteByte(math.floor(self.b*255)) end
	if self.a~=nil then bs:WriteByte(math.floor(self.a*255)) end
	bs:WriteVariableBytes(self.v1)
	bs:WriteVariableBytes(self.v2)
	bs:WriteVariableBytes(math.floor(self.width))
end

--- Unpacks the line from a byte stream.
function AVRLine:Unpack(bs)
	local mask=bs:ReadByte()
	if bit.band(mask,1)~=0 then self.r=bs:ReadByte()/255
	else self.r=nil end
	if bit.band(mask,2)~=0 then self.g=bs:ReadByte()/255
	else self.g=nil end
	if bit.band(mask,4)~=0 then self.b=bs:ReadByte()/255
	else self.b=nil end
	if bit.band(mask,8)~=0 then self.a=bs:ReadByte()/255
	else self.a=nil end
	if bit.band(mask,16)~=0 then self.visible=true
	else self.visible=false end
	self.v1=bs:ReadVariableBytes()
	self.v2=bs:ReadVariableBytes()
	self.width=bs:ReadVariableBytes()
end

AVRTriangle = {Embed = Core.Embed}
--- Constructs a new triangle object.
-- @param v1 Vertex index for the first corner.
-- @param v2 Vertex index for the second corner.
-- @param v3 Vertex index for the third corner.
-- @param a The alpha color component or nil to use default mesh color.
-- @param r The red color component or nil to use default mesh color.
-- @param g The green color component or nil to use default mesh color.
-- @param b The blue color component or nil to use default mesh color.
function AVRTriangle:New(v1,v2,v3,a,r,g,b)
	if self ~= AVRTriangle then return end
	local s={}
		
	AVRTriangle:Embed(s)
	
	s.r=r
	s.g=g
	s.b=b
	s.a=a
	s.v1=v1
	s.v2=v2
	s.v3=v3
	s.visible=true

	return s
end

--- Packs the triangle in a byte stream.
function AVRTriangle:Pack(bs)
	bs:WriteByte((self.r~=nil and 1 or 0)+(self.g~=nil and 2 or 0)+(self.b~=nil and 4 or 0)+(self.a~=nil and 8 or 0)+
				 (self.visible and 16 or 0))
	if self.r~=nil then bs:WriteByte(math.floor(self.r*255)) end
	if self.g~=nil then bs:WriteByte(math.floor(self.g*255)) end
	if self.b~=nil then bs:WriteByte(math.floor(self.b*255)) end
	if self.a~=nil then bs:WriteByte(math.floor(self.a*255)) end
	bs:WriteVariableBytes(self.v1)
	bs:WriteVariableBytes(self.v2)
	bs:WriteVariableBytes(self.v3)
end

--- Unpacks the triangle from a byte stream.
function AVRTriangle:Unpack(bs)
	local mask=bs:ReadByte()
	if bit.band(mask,1)~=0 then self.r=bs:ReadByte()/255
	else self.r=nil end
	if bit.band(mask,2)~=0 then self.g=bs:ReadByte()/255
	else self.g=nil end
	if bit.band(mask,4)~=0 then self.b=bs:ReadByte()/255
	else self.b=nil end
	if bit.band(mask,8)~=0 then self.a=bs:ReadByte()/255
	else self.a=nil end
	if bit.band(mask,16)~=0 then self.visible=true 
	else self.visible=false end
	self.v1=bs:ReadVariableBytes()
	self.v2=bs:ReadVariableBytes()
	self.v3=bs:ReadVariableBytes()
end


AVRTextures={
	filledcircle="Interface\\AddOns\\AVR\\Textures\\filledcircle",
	marker="Interface\\AddOns\\AVR\\Textures\\marker",
--	raidcircle="Interface\\AddOns\\AVR\\Textures\\raid_circle",
--	raidcross="Interface\\AddOns\\AVR\\Textures\\raid_cross",
}
AVRTexturesInv={}
for k,v in pairs(AVRTextures) do AVRTexturesInv[v]=k end

AVRTexture = {Embed = Core.Embed}
function AVRTexture:New(v1,v2,v3,v4,v5,texture,a,r,g,b)
	if self ~= AVRTexture then return end
	local s={}
		
	AVRTexture:Embed(s)
	
	s.v1=v1
	s.v2=v2
	s.v3=v3
	s.v4=v4
	s.v5=v5
	s.texture=AVRTextures[texture]
	s.r=r
	s.g=g
	s.b=b
	s.a=a
	s.visible=true
	s.rotateTexture=true

	return s
end

--- Packs the texture in a byte stream.
function AVRTexture:Pack(bs)
	bs:WriteByte((self.r~=nil and 1 or 0)+(self.g~=nil and 2 or 0)+(self.b~=nil and 4 or 0)+(self.a~=nil and 8 or 0)+
				 (self.visible and 16 or 0))
	if self.r~=nil then bs:WriteByte(math.floor(self.r*255)) end
	if self.g~=nil then bs:WriteByte(math.floor(self.g*255)) end
	if self.b~=nil then bs:WriteByte(math.floor(self.b*255)) end
	if self.a~=nil then bs:WriteByte(math.floor(self.a*255)) end
	bs:WriteVariableBytes(self.v1)
	bs:WriteVariableBytes(self.v2)
	bs:WriteVariableBytes(self.v3)
	bs:WriteVariableBytes(self.v4)
	bs:WriteVariableBytes(self.v5)
	bs:WriteString(AVRTexturesInv[self.texture])
end

--- Unpacks the sprite from a byte stream.
function AVRTexture:Unpack(bs)
	local mask=bs:ReadByte()
	if bit.band(mask,1)~=0 then self.r=bs:ReadByte()/255
	else self.r=nil end
	if bit.band(mask,2)~=0 then self.g=bs:ReadByte()/255
	else self.g=nil end
	if bit.band(mask,4)~=0 then self.b=bs:ReadByte()/255
	else self.b=nil end
	if bit.band(mask,8)~=0 then self.a=bs:ReadByte()/255
	else self.a=nil end
	if bit.band(mask,16)~=0 then self.visible=true
	else self.visible=false end
	self.v1=bs:ReadVariableBytes()
	self.v2=bs:ReadVariableBytes()
	self.v3=bs:ReadVariableBytes()
	self.v4=bs:ReadVariableBytes()
	self.v5=bs:ReadVariableBytes()
	local tex=bs:ReadString()
	self.texture=AVRTextures[tex]
end

-------------------------------------------------------------------------
------     Wrapper to hold unknown meshes     ---------------------------
-------------------------------------------------------------------------


AVRUnknownMesh={Embed=Core.Embed}
AVRUnknownMesh.class="AVRUnknownMesh"
--- Constructs a mesh that can be used to hold packed data of an unknown mesh type.
function AVRUnknownMesh:New()
	if self ~= AVRUnknownMesh then return end
	local s=AVRMesh:New()
	AVRUnknownMesh:Embed(s)
	s.packed={}
	return s
end

function AVRUnknownMesh:Pack()
	return self.packed
end

function AVRUnknownMesh:Unpack(s)
	AVRMesh.Unpack(self,s)
	self.packed=s
end

function AVRUnknownMesh:GetOptions()
	return {
		name = self.name,
		type = "group",
		args = {
			name = {
				type = "description",
				name = L["Name"],
				order = 10,
				width = "full"
			},
			desc = {
				type = "description",
				name = format(L["UNKNOWN MESH"],self.packed.c),
				order = 20
			},
			remove = {
				type = "execute",
				name = L["Remove"],
				width = "full",
				order = 30,
				func = function() self:Remove() end
			},
		}
	}	
end


-------------------------------------------------------------------------
------     Effects     --------------------------------------------------
-------------------------------------------------------------------------

--[[
function AVRBreath(mesh,amount,speed)
	amount=amount or 0.1
	speed=speed or 2.0
	local original=mesh.OnUpdate
	mesh.OnUpdate=function(self,threed)
		original(self,threed)
		local s=1.0+sin(GetTime()*speed)*amount
		self.scaleX,self.scaleY,self.scaleZ=self.scaleX*s,self.scaleY*s,self.scaleZ*s
	end
	mesh.RemoveBreath=function(self)
		self.OnUpdate=original
		self.RemoveBreath=nil
	end
end

function AVRPulse(mesh,r,g,b,speed)
	r=r or 1.0
	g=g or 0.0
	b=b or 0.0
	local ro,go,bo=mesh.r,mesh.g,mesh.b
	speed=speed or 2.0
	local original=mesh.OnUpdate
	mesh.OnUpdate=function(self,threed)
		original(self,threed)
		local s=sin(GetTime()*speed)*0.5+0.5
		local t=1-s
		self.r,self.g,self.b=s*r+t*ro,s*g+t*go,s*b+t*bo
	end
	mesh.RemovePulse=function(self)
		self.r,self.g,self.b=ro,go,bo
		self.OnUpdate=original
		self.RemovePulse=nil
	end	
end
]]