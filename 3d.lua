local _G = _G
local pairs = pairs
local ipairs = ipairs
local remove = table.remove
local insert = table.insert
local max = math.max
local min = math.min
local abs = math.abs
local atan = math.atan
local atan2 = math.atan2
local sqrt = math.sqrt
local sin = math.sin
local cos = math.cos
local tan = math.tan
local type = type
local select = select
local next = next
local GetTime = GetTime
local deg2rad = math.pi/180.0
local pi = math.pi
local pi2 = math.pi*2

local Core=AVR

AVR3D = {Embed = Core.Embed}
local T=AVR3D

local function setCoords(t, A, B, C, D, E, F)
	local det = A*E - B*D;
	local ULx, ULy, LLx, LLy, URx, URy, LRx, LRy;
	
	ULx, ULy = ( B*F - C*E ) / det, ( -(A*F) + C*D ) / det;
	LLx, LLy = ( -B + B*F - C*E ) / det, ( A - A*F + C*D ) / det;
	URx, URy = ( E + B*F - C*E ) / det, ( -D - A*F + C*D ) / det;
	LRx, LRy = ( E - B + B*F - C*E ) / det, ( -D + A -(A*F) + C*D ) / det;
	
	local mi=min(ULx,ULy,LLx,LLy,URx,URy,LRx,LRy)
	local ma=max(ULx,ULy,LLx,LLy,URx,URy,LRx,LRy)
--	if mi<-1000 then print("min="..mi) end
--	if ma>1000 then print("max="..ma) end
	
	t:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy);
end

local function matrixMultiply(a,b)
	return {a[1]*b[1]+a[2]*b[4]+a[3]*b[7],  a[1]*b[2]+a[2]*b[5]+a[3]*b[8], a[1]*b[3]+a[2]*b[6]+a[3]*b[9],
	        a[4]*b[1]+a[5]*b[4]+a[6]*b[7],  a[4]*b[2]+a[5]*b[5]+a[6]*b[8], a[4]*b[3]+a[5]*b[6]+a[6]*b[9],
			a[7]*b[1]+a[8]*b[4]+a[9]*b[7],  a[7]*b[2]+a[8]*b[5]+a[9]*b[8], a[7]*b[3]+a[8]*b[6]+a[9]*b[9]}
end

local raceHeights={
	{},
	{ -- male
		Human=1.83,
		Gnome=0.88,
		NightElf=2.3,
		Draenei=2.38,
		Dwarf=1.42, 
		Tauren=1.83,
		Orc=1.86,
		Scourge=1.70,
		Troll=1.86,
		BloodElf=1.87,
	},
	{ -- female
		Human=1.76,
		Gnome=0.84,
		NightElf=2.10,
		Draenei=2.25,
		Dwarf=1.36, 
		Tauren=1.93,
		Orc=1.88,
		Scourge=1.68,
		Troll=2.28,
		BloodElf=1.85,
	}
}

local formHeights={
	DRUID={
		0.84, -- bear
		1.0, -- aquatic 
		0.98, -- cat
		0.98, -- travel
		1.85, -- tree	
		1.85, -- moonkin (guess)
		1.0, -- flight
	},
	SHAMAN={
		1.13, -- ghost wolf
	}
}


function T:New(frame,addon)
	if self ~= T then return end
	local s={}
	
	T:Embed(s)
	
	local gender=UnitSex("player")
	local _,race=UnitRace("player")
	local _,class=UnitClass("player")
	s.playerRaceHeight=raceHeights[gender][race] or raceHeigts[2]["Human"]
	s.playerHeight=s.playerRaceHeight
	s.playerClass=class
	
	s.zoneData=addon.zoneData
	s.frameF=768
	s.cameraDistF=1.0
	s.projDist=0.98
	
	s.frame=frame
	
	s.lineTexCache={}
	s.lineCount=0
	s.lastLineCount=0
	
	s.triangleTexCache={}
	s.triangleCount=0
	s.lastTriangleCount=0
	
	s.spriteTexCache={}
	s.spriteCount=0
	s.lastSpriteCount=0
	
	-- these four set properly in MakeCameraMatrix
	s.screenWidth2=1/2 -- width/2, most of the time needed like that
	s.screenHeight2=1/2
	s.clipLeftNormalX,s.clipLeftNormalY=1,0 -- normals for screen clipping planes
	s.clipBottomNormalZ,s.clipBottomNormalY=1,0
	
	s.playerDirection=0
	s.cameraPitch=0
	s.cameraDistance=50
	s.cameraYaw=0
	s.playerPosX=0
	s.playerPosY=0
	
	s.leftDown=0
	s.rightDown=0
	
	s.drawStart=nil
	
	s.cm={1,0,0,0,1,0,0,0,1} -- camera matrix
	s.icm={nil,nil,nil,nil,nil,nil,nil,nil,nil} -- inverse camera matrix
	
	addon:HookScript(WorldFrame,"OnMouseDown",function(widget,button) s:WorldFrameButton(button,1) end)
	addon:HookScript(WorldFrame,"OnMouseUp",function(widget,button) s:WorldFrameButton(button,0) end)
	
	return s
end

function T:WorldFrameButton(button,state)
	if button=="LeftButton" then self.leftDown=state
	elseif button=="RightButton" then self.rightDown=state end
end

function T:GetCameraHeight()
	return sin(self.cameraPitch)*self.cameraDistance+self.playerHeight
end


function T:InverseProject(screenX,screenY,planeZ)
	local h,sy,sx,sa,a,d,d2,psy,psz,psx,icm
	screenX=(screenX-self.frame:GetLeft())-self.screenWidth2
	screenY=(screenY-self.frame:GetBottom())-self.screenHeight2
	planeZ=planeZ or -self.playerHeight
	
	h=sin(self.cameraPitch)*self.cameraDistance-planeZ
	sy=screenY/self.frameF
	sx=screenX/self.frameF
	sa=atan2(sy,self.projDist)
	a=pi/2.0-self.cameraPitch+sa
	d=h/cos(a)
	if d<0 or d>10000.0 then return nil,nil,nil end
	d2=math.sqrt(self.projDist*self.projDist+sy*sy)
	
	psy=d/d2*self.projDist
	psz=sy/self.projDist*psy
	psx=sx/d2*d
	
	psy=psy-self.cameraDistance
	
	icm=self.icm
	return 	psx*icm[1]+psy*icm[2]+psz*icm[3]+self.playerPosX,
			psx*icm[4]+psy*icm[5]+psz*icm[6]+self.playerPosY,
			psx*icm[7]+psy*icm[8]+psz*icm[9]+self.playerPosZ+self.playerHeight
end

function T:InvertCameraMatrix()
	if self.icm[1]~=nil then return end
	local a,b,c,d,e,f,g,h,i=self.cm[1],self.cm[2],self.cm[3],self.cm[4],self.cm[5],self.cm[6],self.cm[7],self.cm[8],self.cm[9]
	local det = -c*e*g+b*f*g+c*d*h-a*f*h-b*d*i+a*e*i
	
	self.icm[1]=(e*i-f*h)/det
	self.icm[2]=(c*h-b*i)/det
	self.icm[3]=(b*f-c*e)/det
	self.icm[4]=(f*g-d*i)/det
	self.icm[5]=(a*i-c*g)/det
	self.icm[6]=(c*d-a*f)/det
	self.icm[7]=(d*h-e*g)/det
	self.icm[8]=(b*g-a*h)/det
	self.icm[9]=(a*e-b*d)/det
end

function T:GetUnitPosition(unit)	
	local tx,ty,s
	tx,ty=GetPlayerMapPosition(unit)
	if tx==0 and ty==0 then return 0,0 end
	s=self.zoneData:GetCurrentZoneScale()
	if s==nil then return tx*1500,(1-ty)*1000 end
	return tx*s[1],(1-ty)*s[2]
end

function T:MapCoordinatesToYards(x,y)
	s=self.zoneData:GetCurrentZoneScale()
	if s==nil then return nil end
	return x*s[1],(1-y)*s[2]
end

--[[
-- simulating a raid environment
local allClasses={"WARRIOR","ROGUE","PRIEST","SHAMAN","DEATHKNIGHT","HUNTER","PALADIN","MAGE","WARLOCK","DRUID"}
local function makeSimMember()
	return {
		x=450+30*math.random(),
		y=90+30*math.random(),
		class=allClasses[math.floor(math.random()*10)+1],
		mx=math.random()*4,
		my=math.random()*4,
		msx=math.random()*2,
		mox=math.random()*10,
		msy=math.random()*2,
		moy=math.random()*10
	}
end
	
local simParty={}
for i=1,4 do
	simParty[i]=makeSimMember()
	simParty[i].name="party"..i
	simParty["party"..i]=simParty[i]
end
for i=1,24 do
	simParty[i]=makeSimMember()
	simParty[i].name="raid"..i
	simParty[i].subGroup=math.floor((i-1)/5)+1
	simParty["raid"..i]=simParty[i]
end

local OriginalUnitClass=UnitClass
function UnitClass(unit)
	if unit=="raid25" then return OriginalUnitClass("player")
	elseif simParty[unit] then return simParty[unit].class,simParty[unit].class
	else return OriginalUnitClass(unit) end
end

local OriginalUnitIsUnit=UnitIsUnit
function UnitIsUnit(u1,u2)
	if (u1=="raid25" and u2=="player") or (u1=="player" and u2=="raid25") then return true
	else return OriginalUnitIsUnit(u1,u2) end
end

function GetNumRaidMembers()
	return 25
end

function IsRaidLeader()
	return true
end

function GetRaidRosterInfo(unit)
	if unit==25 then
		local _,cls=UnitClass("player")
		return UnitName("player"),2,5,80,cls,cls,"",true,false,nil,nil
	elseif simParty[unit] then
		return simParty[unit].name,0,simParty[unit].subGroup,80,simParty[unit].class,simParty[unit].class,"",true,false,nil,nil
	else return nil end
end

local oldUnitPosition=T.GetUnitPosition
function T:GetUnitPosition(unit)
	if simParty then
		if unit=="raid25" then return self:GetUnitPosition("player")
		elseif simParty[unit] then
			local s=simParty[unit]
			return s.x+s.mx*math.sin(GetTime()*s.msx+s.mox), s.y+s.my*math.sin(GetTime()*s.msy+s.moy)
		end
	end
	return oldUnitPosition(self,unit)
end
--]] 

function T:UpdatePlayerHeight()
	if self.playerClass=="DRUID" then
		local _,_,_,_,hasTree=GetTalentInfo(3,23)
		local _,_,_,_,hasMoonkin=GetTalentInfo(1,18)
		local form=GetShapeshiftForm(nil) 
		-- meaning of GetShapeshiftForm depends on whether player has tree/moonkin talents
		if form>=5 then
			if not hasTree and not hasMoonkin then form=7
			elseif hasTree then
				if form>5 then form=7 end
			else -- hasMoonkin
				if form>5 then form=7
				else form=6 end
			end
		end
		if form==0 then self.playerHeight=self.playerRaceHeight
		else self.playerHeight=formHeights.DRUID[form] end
	elseif self.playerClass=="SHAMAN" then
		local form=GetShapeshiftForm(nil)
		if form==0 then self.playerHeight=self.playerRaceHeight
		else self.playerHeight=formHeights.SHAMAN[form] end
	end
end

function T:MakeCameraMatrix()
	local adjust,rotZ,rotX,cz,sz,cx,sx
	
	if self.screenWidth2~=self.frame:GetWidth()/2 or self.screenHeight2~=self.frame:GetHeight()/2 then
		self.screenWidth2=self.frame:GetWidth()/2
		self.screenHeight2=self.frame:GetHeight()/2
		
		local fovX=atan(self.screenWidth2/self.frameF/self.projDist)
		local fovY=atan(self.screenHeight2/self.frameF/self.projDist)
		
		self.clipLeftX=cos(fovX)
		self.clipLeftY=sin(fovX)
		self.clipBottomZ=cos(fovY)
		self.clipBottomY=sin(fovY)
	end
	
	SaveView(5);
	self.cameraPitch=GetCVar("cameraPitchD")*deg2rad
	self.cameraDistance=GetCVar("cameraDistanceD")*self.cameraDistF
	self.cameraYaw=tonumber(GetCVar("cameraYawD"))*deg2rad
	self.playerDirection=GetPlayerFacing()
	self.frameF=self.screenHeight2*2.0
	self.playerPosX,self.playerPosY=self:GetUnitPosition("player")
	self.playerPosZ=0
	--if IsMounted() then self.playerPosZ=self.playerPosZ+0.9 end
		
	adjust=0.0
	if IsMouselooking() or self.leftDown==1 then
		adjust=-self.playerDirection
	end
	
	--print(GetCVar("cameraYawE").." "..(GetPlayerFacing()/deg2rad))
	
	rotZ=-self.playerDirection-adjust-self.cameraYaw
	rotX=self.cameraPitch
		
	cz=cos(rotZ)
	sz=sin(rotZ)
	cx=cos(rotX)
	sx=sin(rotX)

	self.cm[1]=cz
	self.cm[2]=-sz
	self.cm[3]=0
	
	self.cm[4]=cx*sz
	self.cm[5]=cx*cz
	self.cm[6]=-sx

	self.cm[7]=sx*sz
	self.cm[8]=sx*cz
	self.cm[9]=cx
	
	self.icm[1]=nil

end

function T:ProjectMesh(mesh)
	local vs=mesh.vertices
	local v,px,py,pz
	local cm=self.cm
	local cm1,cm2,cm3,cm4,cm5,cm6,cm7,cm8,cm9=cm[1],cm[2],cm[3],cm[4],cm[5],cm[6],cm[7],cm[8],cm[9]
	local cd,pd,ff=self.cameraDistance,self.projDist,self.frameF
	local tx,ty,tz=mesh.translateX-self.playerPosX,
					mesh.translateY-self.playerPosY,
					mesh.translateZ-self.playerPosZ-self.playerHeight
	if mesh.rotateZ~=0.0 or mesh.scaleX~=1.0 or mesh.scaleY~=1.0 or mesh.scaleZ~=1.0 then
		local ca=cos(mesh.rotateZ)
		local sa=sin(mesh.rotateZ)
		local preA,preB,preC,preD=ca*mesh.scaleX,-sa*mesh.scaleX,
							sa*mesh.scaleY, ca*mesh.scaleY
		for i=1,#vs do
			v=vs[i]
			px,py,pz=v[1],v[2],v[3]
			px,py,pz=preA*px+preB*py+tx,	preC*px+preD*py+ty,		mesh.scaleZ*pz+tz
			px,py,pz= px*cm1+py*cm2+pz*cm3,
						px*cm4+py*cm5+pz*cm6+cd, --self.cameraDistance,
						px*cm7+py*cm8+pz*cm9
			-- rotated and translated coordinates
			v[4],v[5],v[6],v[7],v[8]=px,py,pz,
			-- screen coordinates
				px/py*pd*ff,pz/py*pd*ff
		end
							
	else 
		for i=1,#vs do
			v=vs[i]
			px,py,pz=v[1]+tx,v[2]+ty,v[3]+tz
			px,py,pz= px*cm1+py*cm2+pz*cm3,
						px*cm4+py*cm5+pz*cm6+cd, --self.cameraDistance,
						px*cm7+py*cm8+pz*cm9
			-- rotated and translated coordinates
			v[4],v[5],v[6],v[7],v[8]=px,py,pz,
			-- screen coordinates
				px/py*pd*ff,pz/py*pd*ff
		end
		
	end
end

function T:DrawMesh(mesh)
	if not mesh.visible then return end
	local t,l
	local vs=mesh.vertices
	local ts=mesh.triangles
	local ls=mesh.lines
	local texs=mesh.textures
	local r,g,b,a=mesh.r,mesh.g,mesh.b,mesh.a
	
	if mesh.clipToScreen then
		self:ProjectMesh(mesh)
		for i=1,#ts do		
			t=ts[i]
			if t.visible then
				self:Draw3DTriangleClipScreen(vs[t.v1],vs[t.v2],vs[t.v3],
								t.a or a,t.r or r,t.g or g,t.b or b)
			end
		end
		for i=1,#ls do
			l=ls[i]
			if l.visible then
				self:Draw3DLineClipScreen(vs[l.v1],vs[l.v2],
								l.width,l.a or a,l.r or r,l.g or g,l.b or b)
			end
		end
	else
		self:ProjectMesh(mesh)
		for i=1,#ts do		
			t=ts[i]
			if t.visible then
				self:Draw3DTriangle(vs[t.v1],vs[t.v2],vs[t.v3],
								t.a or a,t.r or r,t.g or g,t.b or b)
			end
		end
		for i=1,#ls do
			l=ls[i]
			if l.visible then
				self:Draw3DLine(vs[l.v1],vs[l.v2],
								l.width,l.a or a,l.r or r,l.g or g,l.b or b)
			end
		end
	end
	for i=1,#texs do
		t=texs[i]
		if t.visible then
			self:Draw3DTexture(vs[t.v1],vs[t.v2],vs[t.v3],vs[t.v4],vs[t.v5],t.rotateTexture,
				t.texture,t.a or a,t.r or r,t.g or g,t.b or b)
		end
	end
end

do
	local SetPoint
	local Hide
	local SetTexture
	local SetTexCoord
	local SetVertexColor
	local Show
	
	function T:DrawTriangle(x1,y1,x2,y2,x3,y3,alpha,red,green,blue,alphaend)
		local minx=min(x1,x2,x3)
		local miny=min(y1,y2,y3)
		local maxx=max(x1,x2,x3)
		local maxy=max(y1,y2,y3)
		
		if maxx<-self.screenWidth2 then return
		elseif minx>self.screenWidth2 then return
		elseif maxy<-self.screenHeight2 then return
		elseif miny>self.screenHeight2 then return
		end
		
		local dx=maxx-minx
		local dy=maxy-miny
		if dx==0 or dy==0 then return end
		
		local tx3,ty1,ty2,ty3
		if x1==minx then
			if x2==maxx then
				tx3,ty1,ty2,ty3=(x3-minx)/dx,(maxy-y1),(maxy-y2),(maxy-y3)
			else
				tx3,ty1,ty2,ty3=(x2-minx)/dx,(maxy-y1),(maxy-y3),(maxy-y2)
			end
		elseif x2==minx then
			if x1==maxx then
				tx3,ty1,ty2,ty3=(x3-minx)/dx,(maxy-y2),(maxy-y1),(maxy-y3) 
			else
				tx3,ty1,ty2,ty3=(x1-minx)/dx,(maxy-y2),(maxy-y3),(maxy-y1) 
			end
		else -- x3==minx
			if x2==maxx then
				tx3,ty1,ty2,ty3=(x1-minx)/dx,(maxy-y3),(maxy-y2),(maxy-y1) 
			else
				tx3,ty1,ty2,ty3=(x2-minx)/dx,(maxy-y3),(maxy-y1),(maxy-y2) 
			end
		end
		
		local t1=-0.99609375/(ty3-tx3*ty2+(tx3-1)*ty1) -- 0.99609375==510/512
		local t2=dy*t1
		x1=0.001953125-t1*tx3*ty1 -- 0.001953125=1/512
		x2=0.001953125+t1*ty1
		x3=t2*tx3+x1
		y1=t1*(ty2-ty1)
		y2=t1*(ty1-ty3)
		y3=-t2+x2
		
		if abs(t2)>=9000 then return end
		
		self.triangleCount=self.triangleCount+1
		local tex=self.triangleTexCache[self.triangleCount]
		if not tex then
			tex=self.frame:CreateTexture("AVR_TRIANGLE_"..self.triangleCount,"ARTWORK")
			tex:SetTexture("Interface\\AddOns\\AVR\\Textures\\triangle")
			insert(self.triangleTexCache,tex)
			if not SetPoint then
				SetPoint=tex.SetPoint
				Hide=tex.Hide
				SetTexture=tex.SetTexture
				SetTexCoord=tex.SetTexCoord
				SetVertexColor=tex.SetVertexColor
				Show=tex.Show
			end
		end
		Hide(tex)
			
		SetPoint(tex,"BOTTOMLEFT",self.frame,"CENTER",minx,miny)
		SetPoint(tex,"TOPRIGHT",self.frame,"CENTER",maxx,maxy)

		SetTexCoord(tex,x1,x2,x3,y3,x1+y2,x2+y1,y2+x3,y1+y3)

		SetVertexColor(tex,red,green,blue,alpha)
		Show(tex)
	end

	function T:Draw3DTexture(v1,v2,v3,v4,v5,rotate,texture,alpha,red,green,blue)
		local maxx=max(v1[7],v2[7],v3[7],v4[7],v5[7])
		local minx=min(v1[7],v2[7],v3[7],v4[7],v5[7])
		local maxy=max(v1[8],v2[8],v3[8],v4[8],v5[8])
		local miny=min(v1[8],v2[8],v3[8],v4[8],v5[8])
		if v1[5]<self.projDist or v2[5]<self.projDist or v3[5]<self.projDist or 
			v4[5]<self.projDist or v5[5]<self.projDist then return end

		if maxx<-self.screenWidth2 then return
		elseif minx>self.screenWidth2 then return
		elseif maxy<-self.screenHeight2 then return
		elseif miny>self.screenHeight2 then return
		end
		
		local p0x,p0y,p1x,p1y,p2x,p2y,p3x,p3y,p4x,p4y=
			v1[7],v1[8],
			v2[7],v2[8],
			v3[7],v3[8],
			v4[7],v4[8],
			v5[7],v5[8]

		local l0x,l0y,l0z=p0y-p1y,p1x-p0x,p0x*p1y-p0y*p1x
		local l1x,l1y,l1z=p1y-p2y,p2x-p1x,p1x*p2y-p1y*p2x
		local l2x,l2y,l2z=p2y-p3y,p3x-p2x,p2x*p3y-p2y*p3x
		local l3x,l3y,l3z=p3y-p4y,p4x-p3x,p3x*p4y-p3y*p4x
		local qx,qy,qz=l0y*l3z-l0z*l3y, l0z*l3x-l0x*l3z, l0x*l3y-l0y*l3x
		
		local A,B,C=qx,qy,qz
		local a1,b1,c1=l1x,l1y,l1z
		local a2,b2,c2=l2x,l2y,l2z
		local x0,y0,w0=p0x,p0y,1
		local x4,y4,w4=p4x,p4y,1
		
		local y4w0 = y4*w0
		local w4y0 = w4*y0
		local w4w0 = w4*w0
		local y4y0 = y4*y0
		local x4w0 = x4*w0
		local w4x0 = w4*x0
		local x4x0 = x4*x0
		local y4x0 = y4*x0
		local x4y0 = x4*y0
		local a1a2 = a1*a2
		local a1b2 = a1*b2
		local a1c2 = a1*c2
		local b1a2 = b1*a2
		local b1b2 = b1*b2
		local b1c2 = b1*c2
		local c1a2 = c1*a2
		local c1b2 = c1*b2
		local c1c2 = c1*c2
		
		local t1,t2,t3,t4
		
		local a = 
			-A*a1a2*y4w0+A*a1a2*w4y0-B*b1a2*y4w0-B*c1a2*w4w0+B*a1b2*w4y0+
			B*a1c2*w4w0+C*b1a2*y4y0+C*c1a2*w4y0-C*a1b2*y4y0-C*a1c2*y4w0

		local c =  
			A*c1b2*w4w0+A*a1b2*x4w0-A*b1c2*w4w0-A*b1a2*w4x0+B*b1b2*x4w0
			-B*b1b2*w4x0+C*b1c2*x4w0+C*b1a2*x4x0-C*c1b2*w4x0-C*a1b2*x4x0

		local f =
			A*c1a2*y4x0+A*c1b2*y4y0-A*a1c2*x4y0-A*b1c2*y4y0-B*c1a2*x4x0-
			B*c1b2*x4y0+B*a1c2*x4x0+B*b1c2*y4x0-C*c1c2*x4y0+C*c1c2*y4x0

		local b =
			A*c1a2*w4w0+A*a1a2*x4w0-A*a1b2*y4w0-A*a1c2*w4w0-A*a1a2*w4x0
			+A*b1a2*w4y0+B*b1a2*x4w0-B*b1b2*y4w0-B*c1b2*w4w0-B*a1b2*w4x0
			+B*b1b2*w4y0+B*b1c2*w4w0-C*b1c2*y4w0-C*b1a2*x4y0-C*b1a2*y4x0
			-C*c1a2*w4x0+C*c1b2*w4y0+C*a1b2*x4y0+C*a1b2*y4x0+C*a1c2*x4w0

		local d =
			-A*c1a2*y4w0+A*a1a2*y4x0+A*a1b2*y4y0+A*a1c2*w4y0-A*a1a2*x4y0
			-A*b1a2*y4y0+B*b1a2*y4x0+B*c1a2*w4x0+B*c1a2*x4w0+B*c1b2*w4y0
			-B*a1b2*x4y0-B*a1c2*w4x0-B*a1c2*x4w0-B*b1c2*y4w0+C*b1c2*y4y0
			+C*c1c2*w4y0-C*c1a2*x4y0-C*c1b2*y4y0-C*c1c2*y4w0+C*a1c2*y4x0

		local e =
			-A*c1a2*w4x0-A*c1b2*y4w0-A*c1b2*w4y0-A*a1b2*x4y0+A*a1c2*x4w0
			+A*b1c2*y4w0+A*b1c2*w4y0+A*b1a2*y4x0-B*b1a2*x4x0-B*b1b2*x4y0
			+B*c1b2*x4w0+B*a1b2*x4x0+B*b1b2*y4x0-B*b1c2*w4x0-C*b1c2*x4y0
			+C*c1c2*x4w0+C*c1a2*x4x0+C*c1b2*y4x0-C*c1c2*w4x0-C*a1c2*x4x0
		
		if a~= 0.0 then
			b = b/a; c = c/a; d = d/a; e = e/a; f = f/a; a = 1.0;
		elseif b ~= 0.0 then
			c = c/b; d = d/b; e = e/b; f = f/b; b = 1.0;
		elseif c ~= 0.0 then
			d = d/c; e = e/c; f = f/c; c = 1.0;
		elseif d ~= 0.0 then
			e = e/d; f = f/d; d = 1.0;
		elseif e ~= 0.0 then
			f = f/e; e = 1.0;
		else
			return
		end
		b=b/2
		d=d/2
		e=e/2
		
		t1=(b*b-a*c)
		local x0=(c*d-b*e)/t1
		local y0=(a*e-b*d)/t1
		
		t2=2*(a*e*e+c*d*d+f*b*b-2*b*d*e-a*c*f)
		t3=sqrt((a-c)*(a-c)+4*b*b)
		local w1=sqrt( t2/( t1*(t3-(a+c)) ) )
		local w2=sqrt( t2/( t1*(-t3-(a+c)) ) )
		
		local p
		if b==0 then
			if a<c then p=0
			else p=0.5*pi end
		else
			if a<c then 
				if b<0 then
					p=0.5*(0.5*pi-atan((a-c)/(2*b)))
				else
					p=0.5*(-0.5*pi-atan((a-c)/(2*b)))
				end
			else 
				if b<0 then
					p=0.5*(pi-0.5*pi-atan((a-c)/(2*b)))
				else
					p=0.5*(pi+0.5*pi-atan((a-c)/(2*b)))
				end
			end
		end
		
		self.spriteCount=self.spriteCount+1
		tex=self.spriteTexCache[self.spriteCount]
		if not tex then
			tex=self.frame:CreateTexture("AVR_SPRITE_"..self.spriteCount,"ARTWORK")
			insert(self.spriteTexCache,tex)
			if not SetPoint then
				SetPoint=tex.SetPoint
				Hide=tex.Hide
				SetTexture=tex.SetTexture
				SetTexCoord=tex.SetTexCoord
				SetVertexColor=tex.SetVertexColor
				Show=tex.Show
			end
		end
		Hide(tex)
		
		local w=max(w1,w2)	
		
		w1=w1*2
		w2=w2*2
		
		SetPoint(tex,"TOPLEFT",self.frame,"CENTER",x0-w,y0+w)
		SetPoint(tex,"BOTTOMRIGHT",self.frame,"CENTER",x0+w,y0-w)	
		SetTexture(tex,texture)	

		local cp=cos(-p)
		local sp=sin(-p)
		w=w*2

		w1=w1/w
		w2=w2/w

		if rotate then
			local tx=(p0x-x0)/w
			local ty=(p0y-y0)/w

			t1=sqrt(cp*cp*w1*w1+sp*sp*w2*w2-4*tx*tx)
			t2=sqrt(cp*cp*w2*w2+sp*sp*w1*w1-4*ty*ty)
			
			local q=(2*atan((cp*w1-t1)/(sp*w2+2*tx)))%pi2
			
			local q3=(2*atan((-sp*w1-t2)/(cp*w2-2*ty))+pi)%pi2
			local q4=(2*atan((-sp*w1+t2)/(cp*w2-2*ty))+pi)%pi2

			if abs(q-q3)<0.0000001 then 
			elseif abs(q-q4)<0.0000001 then
			else 
				q=(2*atan((cp*w1+t1)/(sp*w2+2*tx)))%pi2
			end

			local cq=cos(q)
			local sq=sin(q)
			
			t1=cp*cq*w1-sp*sq*w2
			t2=-cq*sp*w2-cp*sq*w1
			t3=cp*sq*w2+cq*sp*w1
			t4=cp*cq*w2-sp*sq*w1
		else
			t1=cp*w1
			t2=-sp*w2
			t3=sp*w1
			t4=cp*w2
		end
		
--		setCoords(tex,  t1, t2, 0.5*(-t1-t2+1),
--						t3, t4, 0.5*(-t3-t4+1) )

		local det = w1*w2*2 -- == (t1*t4 - t2*t3)*2;
		if det<0.0003 or det~=det then return end -- det~=det evalutase to true if det is NaN
--[[
		ULx = ( 0.5+( t2-t4)/det )
		ULy = ( 0.5+(-t1+t3)/det )
		LLx = ( 0.5+(-t2-t4)/det )
		LLy = ( 0.5+( t1+t3)/det )
		URx = ( 0.5+( t4+t2)/det )
		URy = ( 0.5+(-t3-t1)/det )
		LRx = ( 0.5+( t4-t2)/det )
		LRy = ( 0.5+(-t3+t1)/det )
--]]
		SetTexCoord(tex,
			0.5+( t2-t4)/det,
			0.5+(-t1+t3)/det,
			0.5+(-t2-t4)/det,
			0.5+( t1+t3)/det,
			0.5+( t4+t2)/det,
			0.5+(-t3-t1)/det,
			0.5+( t4-t2)/det,
			0.5+(-t3+t1)/det
		)
			
		SetVertexColor(tex,red,green,blue,alpha)
		Show(tex)
	end

end

function T:DrawLine(sx,sy,ex,ey,lineW,lineAlpha,r,g,b)
	if sx==ex and sy==ey then return nil end
	local dx,dy=ex-sx,ey-sy
	local w,h=abs(dx),abs(dy)
	local d,tex

	if w>h then d=w
	else d=h end

	local tx=(sx+ex-d)/2.0
	local ty=(sy+ey-d)/2.0
	local a=atan2(dy,dx)
	
	if lineW==0.0 then
		lineW=1.0
	else
		if lineW<1.0 then
			lineAlpha=lineAlpha*lineW
			lineW=1.0
		end
	end
	local s=lineW*16/d	
	if abs(s)<0.0001 then return end
--	local ca=cos(a)*s -- multiply with s already, the transform matrix needs it
--	local sa=sin(a)*s
	local ca=cos(a)/s -- divide by s already so we can ignore determinant in the matrix later
	local sa=sin(a)/s
		
	self.lineCount=self.lineCount+1
	if self.lineCount<=#self.lineTexCache then
		tex=self.lineTexCache[self.lineCount]
	else
		tex=self.frame:CreateTexture("AVR_LINE_"..self.lineCount,"ARTWORK")
		tex:SetTexture("Interface\\AddOns\\AVR\\Textures\\line")
		insert(self.lineTexCache,tex)
	end
	tex:Hide()
		
	tex:SetPoint("BOTTOMLEFT",self.frame,"CENTER",tx,ty)
	tex:SetPoint("TOPRIGHT",self.frame,"CENTER",tx+d,ty+d)
--	setCoords(tex, ca,sa,-ca/2.0-sa/2.0+0.5,
--	              -sa,ca, sa/2.0-ca/2.0+0.5)

--	local A,B,C,D,E,F=	 ca,sa,-ca/2.0-sa/2.0+0.5,
--						-sa,ca,sa/2.0-ca/2.0+0.5
--	local det = s*s -- A*E - B*D;

--[[
	B*F-C*E
	=sa*(sa/2.0-ca/2.0+0.5)-(-ca/2.0-sa/2.0+0.5)*ca
	=sa*sa/2.0+sa*0.5+ca*ca/2.0-ca*0.5
	=(s*s+sa-ca)/2.0
	
	-(A*F)+C*D
	=-(ca*(sa/2.0-ca/2.0+0.5))+(-ca/2.0-sa/2.0+0.5)*(-sa)
	=ca*ca/2.0-ca*0.5+sa*sa/2.0-sa*0.5
	=(s*s-sa-ca)/2.0
]]
--[[[
	local ULx, ULy, LLx, LLy, URx, URy, LRx, LRy;
	ULx, ULy = ( B*F - C*E ) / det, ( -(A*F) + C*D ) / det;
	LLx, LLy = ( -B + B*F - C*E ) / det, ( A - A*F + C*D ) / det;
	URx, URy = ( E + B*F - C*E ) / det, ( -D - A*F + C*D ) / det;
	LRx, LRy = ( E - B + B*F - C*E ) / det, ( -D + A -(A*F) + C*D ) / det;
--	local mi=min(ULx,ULy,LLx,LLy,URx,URy,LRx,LRy)
--	local ma=max(ULx,ULy,LLx,LLy,URx,URy,LRx,LRy)
--	if mi<-1000 then print("min="..mi) end
--	if ma>1000 then print("max="..ma) end
	tex:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy);
]]
	local C1,C2=(1+sa-ca)/2.0, (1-sa-ca)/2.0
	tex:SetTexCoord( 	C1, 		C2,
						-sa+C1, 	ca+C2,
						ca+C1, 		sa+C2,
						ca-sa+C1, 	ca+sa+C2)

	tex:SetVertexColor(r,g,b,lineAlpha)
	
	tex:Show()
	return tex
end

do
	local function clipLineToPlane(x1,y1,z1,x2,y2,z2,nx,ny,nz,dist)
		local d1=x1*nx+y1*ny+z1*nz
		local d2=x2*nx+y2*ny+z2*nz
		local s
		if d1<0 then
			if d2< 0 then
				return nil
			else
				s=d1/(d1-d2)
				return x1+s*(x2-x1),y1+s*(y2-y1),z1+s*(z2-z1),x2,y2,z2
			end
		else
			if d2< 0 then
				s=d1/(d1-d2)
				return x1,y1,z1,x1+s*(x2-x1),y1+s*(y2-y1),z1+s*(z2-z1)
			else
				return x1,y1,z1,x2,y2,z2
			end
		end
	end

	function T:Draw3DLineClipScreen(v1,v2,width,a,r,g,b)
		local p,p2
		local sx1,sy1,sx2,sy2
		local pd=self.projDist
		local ff=self.frameF
		
		local x1,y1,z1,x2,y2,z2=v1[4],v1[5],v1[6],v2[4],v2[5],v2[6]

		x1,y1,z1,x2,y2,z2=clipLineToPlane(x1,y1,z1,x2,y2,z2,self.clipLeftX,self.clipLeftY,0,0)
		if x1==nil then return end
		x1,y1,z1,x2,y2,z2=clipLineToPlane(x1,y1,z1,x2,y2,z2,-self.clipLeftX,self.clipLeftY,0,0)
		if x1==nil then return end
		x1,y1,z1,x2,y2,z2=clipLineToPlane(x1,y1,z1,x2,y2,z2,0,self.clipBottomY,self.clipBottomZ,0)
		if x1==nil then return end
		x1,y1,z1,x2,y2,z2=clipLineToPlane(x1,y1,z1,x2,y2,z2,0,self.clipBottomY,-self.clipBottomZ,0)
		if x1==nil then return end
		x1,y1,z1,x2,y2,z2=clipLineToPlane(x1,y1,z1,x2,y2,z2,0,1,0,self.projDist)
		if x1==nil then return end
		
		sx1,sy1=x1/y1*pd*ff, z1/y1*pd*ff
		sx2,sy2=x2/y2*pd*ff, z2/y2*pd*ff
		width=width/((y1+y2)/2)*self.projDist
		self:DrawLine(sx1,sy1,sx2,sy2,width,a,r,g,b)
	end
end

function T:Draw3DLine(v1,v2,width,a,r,g,b)
	-- clip to projection plane if needed
	if v1[5]<self.projDist then
		if v2[5]<self.projDist then return end
		local sx,sy,py=self:ClipToProj(v1,v2)
		--width=width/((py+v2[5])/2)*self.projDist
		width=width/min(py+v2[5])*self.projDist
		self:DrawLine(sx,sy,v2[7],v2[8],width,a,r,g,b)		
	elseif v2[5]<self.projDist then
		local sx,sy,py=self:ClipToProj(v2,v1)
--		width=width/((py+v1[5])/2)*self.projDist
		width=width/min(py+v1[5])*self.projDist
		self:DrawLine(v1[7],v1[8],sx,sy,width,a,r,g,b)		
	else
--		width=width/((v1[5]+v2[5])/2)*self.projDist
		width=width/min(v1[5]+v2[5])*self.projDist
		self:DrawLine(v1[7],v1[8],v2[7],v2[8],width,a,r,g,b)
	end
end

local function alphaFallOff(dist)
	if dist<=20 then return 1.0 end
	return 0.7/((dist-20)/5+1)+0.3
end

do
	-- temp point coordinates used for clipping
	-- first three are vertex coordinates
	local ps={ {0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0} }
	local psc=0 -- counter how many are used
	-- results for next step get put in these
	local ps2={ {0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0} }
	local psc2=0

	local function clipToPlane(nx,ny,nz,dist) -- normal of the plane and distance from origin
		local p,p2,p3,s
		for i=1,psc do
			p=ps[i]
			p[4]=p[1]*nx+p[2]*ny+p[3]*nz-dist -- distance from clipping plane, sign indicates side
		end
		psc2=0
		for i=1,psc do
			p=ps[i]
			p2=ps[(i%psc)+1]
			if p[4]<0 then
				if p2[4]<0 then
					-- both on the wrong side, do nothing
				else
					-- p wrong, p2 right
					s=p[4]/(p[4]-p2[4])
					p3=ps2[psc2+1]
					p3[1],p3[2],p3[3]=
						p[1]+s*(p2[1]-p[1]),
						p[2]+s*(p2[2]-p[2]),
						p[3]+s*(p2[3]-p[3])
					p3=ps2[psc2+2]
					p3[1],p3[2],p3[3]=p2[1],p2[2],p2[3]
					psc2=psc2+2
				end
			else
				if p2[4]<0 then
					-- p right, p2 wrong
					s=p[4]/(p[4]-p2[4])
					p3=ps2[psc2+1]
					p3[1],p3[2],p3[3]=
						p[1]+s*(p2[1]-p[1]),
						p[2]+s*(p2[2]-p[2]),
						p[3]+s*(p2[3]-p[3])
					psc2=psc2+1
				else
					-- both on the right side
					p3=ps2[psc2+1]
					p3[1],p3[2],p3[3]=p2[1],p2[2],p2[3]
					psc2=psc2+1
				end
			end
		end
		-- swap tables so the results are in ps,psc
		ps,ps2=ps2,ps
		psc,psc2=psc2,psc
	end

	function T:Draw3DTriangleClipScreen(v1,v2,v3,a,r,g,b)
		local p,p2,p3
		local sx1,sy1,sx2,sy2,sx3,sy3
		local pd=self.projDist
		local ff=self.frameF

		psc=3
		ps[1][1],ps[1][2],ps[1][3],ps[2][1],ps[2][2],ps[2][3],ps[3][1],ps[3][2],ps[3][3]=v1[4],v1[5],v1[6],v2[4],v2[5],v2[6],v3[4],v3[5],v3[6]
		
		clipToPlane(self.clipLeftX,self.clipLeftY,0,0)
		if psc==0 then return end
		clipToPlane(-self.clipLeftX,self.clipLeftY,0,0)
		if psc==0 then return end
		clipToPlane(0,self.clipBottomY,self.clipBottomZ,0)
		if psc==0 then return end
		clipToPlane(0,self.clipBottomY,-self.clipBottomZ,0)
		if psc==0 then return end
		clipToPlane(0,1,0,self.projDist)
		if psc==0 then return end
		
--		local z1,z2,z3
		p=ps[1]
--		z1=p[2]
		p2=ps[2]
--		z2=p2[2]
		sx1,sy1=p[1]/p[2]*pd*ff, p[3]/p[2]*pd*ff
		sx2,sy2=p2[1]/p2[2]*pd*ff, p2[3]/p2[2]*pd*ff
		for i=2,psc-1 do
			p3=ps[i+1]
--			z3=p3[2]
			sx3,sy3=p3[1]/p3[2]*pd*ff, p3[3]/p3[2]*pd*ff
			
--			self:DrawTriangle(sx1,sy1,sx2,sy2,sx3,sy3,a*alphaFallOff(min(z1,z2,z3)),r,g,b,a*alphaFallOff(max(z1,z2,z3)))
			self:DrawTriangle(sx1,sy1,sx2,sy2,sx3,sy3,a,r,g,b)
--			sx2,sy2,z2=sx3,sy3,z3
			sx2,sy2=sx3,sy3
		end
	end
end


function T:ClipToProj(v1,v2) -- v1[5]<self.projDist<=v2[5]
	local s=(v2[5]-self.projDist)/(v2[5]-v1[5])
	return (v2[4]+(v1[4]-v2[4])*s)*self.frameF,
			(v2[6]+(v1[6]-v2[6])*s)*self.frameF,
			self.projDist
end

function T:Draw3DTriangle(v1,v2,v3,a,r,g,b)
	local z1,z2,z3=v1[5],v2[5],v3[5]
	local d=self.projDist

	
---[[	
	-- clip to projection plane if needed
	if z1<d then
		if z2<d then
			if z3<d then -- all behind
				return 
			else -- 1 and 2 behind
				local sx1,sy1,_=self:ClipToProj(v1,v3)
				local sx2,sy2,_=self:ClipToProj(v2,v3)
				self:DrawTriangle(v3[7],v3[8],sx1,sy1,sx2,sy2,a,r,g,b)
			end
		elseif z3<d then -- 1 and 3 behind
			local sx1,sy1,_=self:ClipToProj(v1,v2)
			local sx2,sy2,_=self:ClipToProj(v3,v2)
			self:DrawTriangle(v2[7],v2[8],sx1,sy1,sx2,sy2,a,r,g,b)
		else -- 1 behind
			local sx1,sy1,_=self:ClipToProj(v1,v2)
			local sx2,sy2,_=self:ClipToProj(v1,v3)
			self:DrawTriangle(sx1,sy1,v2[7],v2[8],v3[7],v3[8],a,r,g,b)
			self:DrawTriangle(sx1,sy1,v3[7],v3[8],sx2,sy2,a,r,g,b)
		end
	elseif z2<d then
		if z3<d then -- 2 and 3 behind
			local sx1,sy1,_=self:ClipToProj(v2,v1)
			local sx2,sy2,_=self:ClipToProj(v3,v1)
			self:DrawTriangle(v1[7],v1[8],sx1,sy1,sx2,sy2,a,r,g,b)
		else -- 2 behind
			local sx1,sy1,_=self:ClipToProj(v2,v1)
			local sx2,sy2,_=self:ClipToProj(v2,v3)
			self:DrawTriangle(sx1,sy1,v1[7],v1[8],v3[7],v3[8],a,r,g,b)
			self:DrawTriangle(sx1,sy1,v3[7],v3[8],sx2,sy2,a,r,g,b)
		end
	elseif z3<d then -- 3 behind
		local sx1,sy1,_=self:ClipToProj(v3,v1)
		local sx2,sy2,_=self:ClipToProj(v3,v2)
		self:DrawTriangle(sx1,sy1,v1[7],v1[8],v2[7],v2[8],a,r,g,b)
		self:DrawTriangle(sx1,sy1,v2[7],v2[8],sx2,sy2,a,r,g,b)	
	else -- all in front
		self:DrawTriangle(v1[7],v1[8],v2[7],v2[8],v3[7],v3[8],a,r,g,b)
	end
--]] 
--[[
	if z1<d then
		if z2<d then
			if z3<d then -- all behind
				return 
			else -- 1 and 2 behind
				local sx1,sy1,_=self:ClipToProj(v1,v3)
				local sx2,sy2,_=self:ClipToProj(v2,v3)
				self:DrawTriangle(v3[7],v3[8],sx1,sy1,sx2,sy2,a,r,g,b,a*alphaFallOff(z3))
			end
		elseif z3<d then -- 1 and 3 behind
			local sx1,sy1,_=self:ClipToProj(v1,v2)
			local sx2,sy2,_=self:ClipToProj(v3,v2)
			self:DrawTriangle(v2[7],v2[8],sx1,sy1,sx2,sy2,a,r,g,b,a*alphaFallOff(z2))
		else -- 1 behind
			local sx1,sy1,_=self:ClipToProj(v1,v2)
			local sx2,sy2,_=self:ClipToProj(v1,v3)
			self:DrawTriangle(sx1,sy1,v2[7],v2[8],v3[7],v3[8],a,r,g,b,a*alphaFallOff(max(z2,z3)))
			self:DrawTriangle(sx1,sy1,v3[7],v3[8],sx2,sy2,a,r,g,b,a*alphaFallOff(z3))
		end
	elseif z2<d then
		if z3<d then -- 2 and 3 behind
			local sx1,sy1,_=self:ClipToProj(v2,v1)
			local sx2,sy2,_=self:ClipToProj(v3,v1)
			self:DrawTriangle(v1[7],v1[8],sx1,sy1,sx2,sy2,a,r,g,b,a*alphaFallOff(z1))
		else -- 2 behind
			local sx1,sy1,_=self:ClipToProj(v2,v1)
			local sx2,sy2,_=self:ClipToProj(v2,v3)
			self:DrawTriangle(sx1,sy1,v1[7],v1[8],v3[7],v3[8],a,r,g,b,a*alphaFallOff(max(z1,z3)))
			self:DrawTriangle(sx1,sy1,v3[7],v3[8],sx2,sy2,a,r,g,b,a*alphaFallOff(z3))
		end
	elseif z3<d then -- 3 behind
		local sx1,sy1,_=self:ClipToProj(v3,v1)
		local sx2,sy2,_=self:ClipToProj(v3,v2)
		self:DrawTriangle(sx1,sy1,v1[7],v1[8],v2[7],v2[8],a,r,g,b,a*alphaFallOff(max(z1,z2)))
		self:DrawTriangle(sx1,sy1,v2[7],v2[8],sx2,sy2,a,r,g,b,a*alphaFallOff(z2))	
	else -- all in front
		self:DrawTriangle(v1[7],v1[8],v2[7],v2[8],v3[7],v3[8],a*alphaFallOff(min(z1,z2,z3)),r,g,b,a*alphaFallOff(max(z1,z2,z3)))
	end
--]]
	
end

function T:ClearAllTriangles()
	local tex
	for i=1,#self.triangleTexCache do
		self.triangleTexCache[i]:Hide()
	end
	self.triangleCount=0
	self.lastTriangleCount=0
end

function T:ClearAllLines()
	local tex
	for i=1,#self.lineTexCache do
		self.lineTexCache[i]:Hide()
	end
	self.lineCount=0
	self.lastLineCount=0
end

function T:ClearAllSprites()
	local tex
	for i=1,#self.spriteTexCache do
		self.spriteTexCache[i]:Hide()
	end
	self.spriteCount=0
	self.lastSpriteCount=0
end

function T:StartRender()
	self:UpdatePlayerHeight()
	self:MakeCameraMatrix()
	self.lastLineCount=self.lineCount
	self.lastTriangleCount=self.triangleCount
	self.lastSpriteCount=self.spriteCount
	self.lineCount=0
	self.triangleCount=0
	self.spriteCount=0
end
function T:EndRender()
	local tex
	for i=self.lineCount+1,self.lastLineCount do
		self.lineTexCache[i]:Hide()
	end
	for i=self.triangleCount+1,self.lastTriangleCount do
		self.triangleTexCache[i]:Hide()
	end
	for i=self.spriteCount+1,self.lastSpriteCount do
		self.spriteTexCache[i]:Hide()
	end
end
