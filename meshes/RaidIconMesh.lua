local ADDON_NAME="AVR"
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, true)

local _G = _G
local sin = math.sin
local cos = math.cos
local pi = math.pi

AVRRaidIconMesh={Embed=AVR.Embed}
AVRRaidIconMesh.meshInfo={
	class="AVRRaidIconMesh",
	derived=false,
	guiCreateNew=true,
	guiName=L["Raid icon"],
	receivable=true
}
function AVRRaidIconMesh:New(icon,size)
	if self ~= AVRRaidIconMesh then return end
	local s=AVRMesh:New()
	AVRRaidIconMesh:Embed(s)
	s.class=AVRRaidIconMesh.meshInfo.class
	s.icon=icon or 1
	s.size=size or 10
	s.defaultColor=true
	s.vertices=nil
	s.a=0.25
	s:ApplyDefaultColor()
	s.name=L["Raid icon"]
	return s
end

function AVRRaidIconMesh:SetSize(size)
	self.size=size
	self.vertices=nil
end

function AVRRaidIconMesh:GetSize()
	return self.size
end

function AVRRaidIconMesh:SetIcon(icon)
	self.icon=icon
	self.vertices=nil
	if self.defaultColor then self:ApplyDefaultColor() end
end
function AVRRaidIconMesh:GetIcon()
	return self.icon
end

function AVRRaidIconMesh:SetColor(r,g,b,a)
	if self.defaultColor then
		if a~=nil then self.a=a end
		return self
	else
		return AVRMesh.SetColor(self,r,g,b,a)
	end
end

function AVRRaidIconMesh:SetDefaultColor(value)
	self.defaultColor=value
	if self.defaultColor then self:ApplyDefaultColor() end
end

function AVRRaidIconMesh:GetDefaultColor()
	return self.defaultColor
end

function AVRRaidIconMesh:ApplyDefaultColor()
	if self.icon==1 then
		self.r,self.g,self.b=1.0,1.0,0.0
	elseif self.icon==2 then
		self.r,self.g,self.b=1.0,0.6,0.0
	elseif self.icon==3 then
		self.r,self.g,self.b=1.0,0.0,1.0
	elseif self.icon==4 then
		self.r,self.g,self.b=0.0,1.0,0.0
	elseif self.icon==5 then
		self.r,self.g,self.b=0.0,1.0,1.0
	elseif self.icon==6 then
		self.r,self.g,self.b=0.0,0.0,1.0
	elseif self.icon==7 then
		self.r,self.g,self.b=1.0,0.0,0.0
	else
		self.r,self.g,self.b=1.0,1.0,1.0
	end
end

function AVRRaidIconMesh:GetOptions()
	local o=AVRMesh.GetOptions(self)
	o.args.circle = {
		type = "group",
		name = L["Raid icon properties"],
		inline = true,
		order = 80,
		args = {
			icon = {
				type = "select",
				name = L["Raid icon"],
				order = 10,
				width = "full",
				values = {[1]=L["Star"], [2]=L["Circle"], [3]=L["Diamond"], [4]=L["Triangle"],
							[5]=L["Moon"], [6]=L["Square"], [7]=L["Cross"], [8]=L["Skull"]},
			},			
			size = {
				type = "range",
				name = L["Size"],
				order = 20,
				width = "full",
				min = 0.0, max=500, bigStep=1.0
			},		
			defaultColor = {
				type = "toggle",
				name = L["Use default color"],
				order = 30,
				width = "full",
			},
		}
	}
	return o
end

function AVRRaidIconMesh:GenerateMesh()
	if self.icon==1 then
		self:AddTriangleData({
			{	-0.3,0.3,0.0,	0.0,1.0,0.0,	0.3,0.3,0.0	},
			{	0.3,0.3,0.0,	1.0,0.0,0.0,	0.3,-0.3,0.0	},
			{	0.3,-0.3,0.0,	0.0,-1.0,0.0,	-0.3,-0.3,0.0	},
			{	-0.3,-0.3,0.0,	-1.0,0.0,0.0,	-0.3,0.3,0.0	},
			{	-0.3,0.3,0.0,	0.3,0.3,0.0,	-0.3,-0.3,0.0	},
			{	0.3,0.3,0.0,	0.3,-0.3,0.0,	-0.3,-0.3,0.0	}
		},self.size)
	elseif self.icon==2 then
		local segments=20
		local ox=self.size
		local oy=0
		for i=1,segments do
			a=pi*2/segments*i
			
			x=cos(a)*self.size
			y=sin(a)*self.size
			
			self:AddTriangle(0,0,0,ox,oy,0,x,y,0)
			
			ox,oy=x,y
		end	
	elseif self.icon==3 then
		self:AddTriangleData({
			{	-0.7,0.0,0.0,	0.0,1.0,0.0,	0.7,0.0,0.0	},
			{	-0.7,0.0,0.0,	0.7,0.0,0.0,	0.0,-1.0,0.0	}
		},self.size)		
	elseif self.icon==4 then
		self:AddTriangleData({
			{	-1.0,0.866,0.0,	1.0,0.866,0.0,	0.0,-0.866,0.0	}
		},self.size)		
	elseif self.icon==5 then
		self:AddTriangleData({
			{	0.33,0.95,0.0,	0.62,0.79,0.0,	0.50,0.70,0.0	},
			{	0.62,0.79,0.0,	0.58,0.50,0.0,	0.50,0.70,0.0	},
			{	0.62,0.79,0.0,	0.87,0.50,0.0,	0.58,0.50,0.0	},
			{	0.58,0.50,0.0,	0.87,0.50,0.0,	0.94,0.32,0.0	},
			{	0.58,0.50,0.0,	0.94,0.32,0.0,	0.60,0.20,0.0	},
			{	0.94,0.32,0.0,	1.0,0.0,0.0,	0.60,0.20,0.0	},
			{	0.60,0.20,0.0,	1.0,0.0,0.0,	0.55,0.0,0.0	},
			{	0.55,0.0,0.0,	1.0,0.0,0.0,	0.93,-0.33,0.0	},
			{	0.55,0.0,0.0,	0.93,-0.33,0.0,	0.45,-0.2,0.0	},
			{	0.45,-0.2,0.0,	0.93,-0.33,0.0,	0.70,-0.70,0.0	},
			{	0.45,-0.2,0.0,	0.70,-0.70,0.0,	0.33,-0.33,0.0	},
	
			{	-0.95,-0.33,0.0,	-0.79,-0.62,0.0,	-0.70,-0.50,0.0	},
			{	-0.79,-0.62,0.0,	-0.50,-0.58,0.0,	-0.70,-0.50,0.0	},
			{	-0.79,-0.62,0.0,	-0.50,-0.87,0.0,	-0.50,-0.58,0.0	},
			{	-0.50,-0.58,0.0,	-0.50,-0.87,0.0,	-0.32,-0.94,0.0	},
			{	-0.50,-0.58,0.0,	-0.32,-0.94,0.0,	-0.20,-0.60,0.0	},
			{	-0.32,-0.94,0.0,	0.0,-1.0,0.0,		-0.20,-0.60,0.0	},
			{	-0.20,-0.60,0.0,	0.0,-1.0,0.0,		0.0,-0.55,0.0	},
			{	0.0,-0.55,0.0,		0.0,-1.0,0.0,		0.33,-0.93,0.0	},
			{	0.0,-0.55,0.0,		0.33,-0.93,0.0,		0.2,-0.45,0.0	},
			{	0.2,-0.45,0.0,		0.33,-0.93,0.0,		0.70,-0.70,0.0	},
			{	0.2,-0.45,0.0,		0.70,-0.70,0.0,		0.33,-0.33,0.0	}
		},self.size)				
	elseif self.icon==6 then
		self:AddTriangleData({
			{	-1,1,0.0,	1,1,0.0,	1,-1,0.0	},
			{	-1,1,0.0,	1,-1,0.0,	-1,-1,0.0	}
		},self.size)		
	elseif self.icon==7 then
		self:AddTriangleData({
			{	-0.7,1.0,0.0,	1.0,-0.7,0.0,	-1.0,0.7,0.0	},
			{	-1.0,0.7,0.0,	1.0,-0.7,0.0,	0.7,-1.0,0.0	},
			{	0.7,1.0,0.0,	1.0,0.7,0.0,	0.0,0.3,0.0		},
			{	1.0,0.7,0.0,	0.3,0.0,0.0,	0.0,0.3,0.0		},
			{	-0.3,0.0,0.0,	0.0,-0.3,0.0,	-0.7,-1.0,0.0	},
			{	-0.3,0.0,0.0,	-0.7,-1.0,0.0,	-1.0,-0.7,0.0	}
		},self.size)		
	else
		self:AddTriangleData({
			{	0.0,0.0,0.0,	0.0,1.0,0.0,	0.4,0.93,0.0	},
			{	0.0,0.0,0.0,	0.4,0.93,0.0,	0.7,0.78,0.0	},
			{	0.0,0.0,0.0,	0.7,0.78,0.0,	0.92,0.5,0.0	},
			{	0.0,0.0,0.0,	0.92,0.5,0.0,	1.0,0.2,0.0	},
			{	0.0,0.0,0.0,	1.0,0.2,0.0,	0.92,-0.1,0.0	},
			{	0.0,0.0,0.0,	0.92,-0.1,0.0,	0.7,-0.38,0.0	},
			{	0.0,0.0,0.0,	0.7,-0.38,0.0,	0.5,-0.5,0.0	},
			
			{	0.0,0.0,0.0,	0.5,-0.5,0.0,	-0.5,-0.5,0.0	},
			
			{	0.0,0.0,0.0,	0.0,1.0,0.0,	-0.4,0.93,0.0	},
			{	0.0,0.0,0.0,	-0.4,0.93,0.0,	-0.7,0.78,0.0	},
			{	0.0,0.0,0.0,	-0.7,0.78,0.0,	-0.92,0.5,0.0	},
			{	0.0,0.0,0.0,	-0.92,0.5,0.0,	-1.0,0.2,0.0	},
			{	0.0,0.0,0.0,	-1.0,0.2,0.0,	-0.92,-0.1,0.0	},
			{	0.0,0.0,0.0,	-0.92,-0.1,0.0,	-0.7,-0.38,0.0	},
			{	0.0,0.0,0.0,	-0.7,-0.38,0.0,	-0.5,-0.5,0.0	},
			
			{	0.5,-0.5,0.0,	0.7,-1.0,0.0,	-0.7,-1.0,0.0	},
			{	-0.5,-0.5,0.0,	0.5,-0.5,0.0,	-0.7,-1.0,0.0	}
		},self.size)		
	end

	AVRMesh.GenerateMesh(self)
end

function AVRRaidIconMesh:Pack()
	local s=AVRMesh.Pack(self)
	s.ico=self.icon
	s.defcol=self.defaultColor
	s.siz=self.size
	return s
end

function AVRRaidIconMesh:Unpack(s)
	AVRMesh.Unpack(self,s)
	self.icon=s.ico or 1
	self.size=s.siz or 10
	if s.defcol~=nil then self.defaultColor=s.defcol
	else self.defaultColor=true end
	
	if self.defaultColor then self:ApplyDefaultColor() end
	
	self.vertices=nil
end

AVR:RegisterMeshClass(AVRRaidIconMesh)