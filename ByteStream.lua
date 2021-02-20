local _G = _G
local pairs = pairs
local ipairs = ipairs
local remove = table.remove
local max = math.max
local type = type
local select = select
local next = next
local GetTime = GetTime
local char=string.char
local byte=string.byte
local Core=AVR

AVRByteStream={Embed = Core.Embed}
local T=AVRByteStream

--T.LibBase64=LibStub("LibBase64-1.0")

function T:New(store)
	if self ~= T then return end
	local s={}
	store=store or {}
	
	T:Embed(s)
	
--	s.maxBufferSize=384 -- preferably multiple of 3 for base64 encoding
	s.maxBufferSize=1024
	s.store=store
	if not s.store.data then s.store.data={} end
	if not s.store.buffer then s.store.buffer={} end
	s.data=s.store.data
	s.buffer=s.store.buffer
	
	s.readDataPosition=1
	s.readBufferPosition=1
	s.readBufer=nil
	
	return s
end

function T:IsEOS()
	while self.readBuffer==nil or self.readBufferPosition>#self.readBuffer do
		if self.readDataPosition>#self.data then return true end
--		self.readBuffer=T.LibBase64.Decode(self.data[self.readDataPosition])
		self.readBuffer=self.data[self.readDataPosition]
		self.readDataPosition=self.readDataPosition+1
		self.readBufferPosition=1
	end
	return false
end

function T:ReadByte()
	-- IsEOS also fills buffer if needed
	if self:IsEOS() then return -1 end
	local c=byte(self.readBuffer,self.readBufferPosition)
	self.readBufferPosition=self.readBufferPosition+1
	return c;
end

function T:FlushBuffer()
--	self.data[#self.data+1]=T.LibBase64.Encode(table.concat(self.buffer),4096)
	self.data[#self.data+1]=table.concat(self.buffer)
	self.store.buffer={}
	self.buffer=self.store.buffer
end

-- Writes one byte. Value should be integer in [0,255]
function T:WriteByte(value)
	self.buffer[#self.buffer+1]=char(value)
	--self.buffer[#self.buffer+1]=format("%x",bit.band(value,255)) -- debugging
	if #self.buffer>=self.maxBufferSize then
		self:FlushBuffer()
	end
end

-- Writes the value in specified amount of bytes. Most significant bits are written first.
-- If signed is true, sign bit is written before anything else.
function T:WriteBytes(value,size,signed)
	while size > 0 do
		if signed then
			signed=false
			local sign=0
			if value<0 then
				value=-value
				sign=128
			end
--			self:WriteByte(bit.band(bit.rshift(value,(size-1)*8),127)+sign)
			self:WriteByte(bit.band(value/math.pow(256,size-1),127)+sign)
		else
--			self:WriteByte(bit.band(bit.rshift(value,(size-1)*8),255))
			self:WriteByte(bit.band(value/math.pow(256,size-1),255))
		end
		size=size-1
	end
end

function T:ReadBytes(size,signed)
	local value=0
	local sign=1
	while size > 0 do
		local b=self:ReadByte()
		if signed then
			signed=false
			if b>=128 then
				value=b-128
				sign=-1
			else
				value=b
			end
		else
			value=value*256+b
		end
		size=size-1
	end
	return sign*value
end

-- Writes the value in an amount of bytes suitable for the value. The amount of consecutive
-- 1 bits in high end of first byte tells how many more bytes follow. After the first 0
-- rest of the bits in the first byte are the most significant bits of the actual value.
-- If signed is true then a sign bit is written before everything else, including the length
-- marker bits. The size parameter can be used to set a minimum number of bytes to be written.
function T:WriteVariableBytes(value,size,signed)
	size=size or 1
	local signBits=signed and 1 or 0
	local signBit=0
	
	if signed and value<0 then
		value=-value
		signBit=128
	end

	local extras=0	
	while math.pow(2,(size-1+extras)*8+7-extras-signBits) <= value do
		extras=extras+1
		if(extras==7-signBits) then
			extras=8-signBits
			break
		end
	end
	local fullBytes=size-1+extras
	local header=signBit
	for i=0,extras-1,1 do
		header=bit.bor(header,bit.lshift(1,7-i-signBits))
	end
	
	if extras<8 then
--		header=bit.bor(header,bit.rshift(value,fullBytes*8))
		header=bit.bor(header,bit.band(value/math.pow(256,fullBytes),255))
	end

	self:WriteByte(bit.band(header,255))
	if fullBytes>0 then self:WriteBytes(value,fullBytes) end
	return 1+fullBytes
end

function T:ReadVariableBytes(size,signed)
	size=size or 1
	signBits=signed and 1 or 0
	sign=1
	local value=0
	local b=self:ReadByte()
	if signed and b>=128 then
		sign=-1
	end
	local extras=0
	while bit.band(bit.rshift(b,7-signBits-extras),1)==1 do
		extras=extras+1
		if extras==7-signBits then
			extras=8-signBits
			break
		end
	end
	if extras<7-signBits then
		value=bit.band(b,math.pow(2,7-extras-signBits)-1)*math.pow(256,size-1+extras)
	end
	
	value=sign*(value+self:ReadBytes(size-1+extras))
	return value
end

local m,e
function T:WriteDouble(value)
-- ieee 754 binary64
-- 66665555 55555544 44444444 33333333 33222222 22221111 111111
-- 32109876 54321098 76543210 98765432 10987654 32109876 54321098 76543210
-- seeeeeee eeeemmmm mmmmmmmm mmmmmmmm mmmmmmmm mmmmmmmm mmmmmmmm mmmmmmmm
	if value==0.0 then
		self:WriteBytes(0,8)
		return
	end


	signBit=0
	if value<0 then
		signBit=128 -- shifted left to appropriate position 
		value=-value
	end
	
	m,e=math.frexp(value) 
	m=m*2-1 -- m in [0.5,1.0), multiply by 2 will get it to [1.0,2.0) giving the implicit first bit in mantissa, -1 to get rid of that
	e=e-1+1023 -- adjust for the *2 on previous line and 1023 is the exponent zero offset
	
	-- sign and 7 bits of exponent
	self:WriteByte(bit.bor(signBit,bit.band(bit.rshift(e,4),127)))
	
	-- first 4 bits of mantissa
	m=m*16
	-- write last 4 bits of exponent and first 4 of mantissa
	self:WriteByte(bit.bor(bit.band(bit.lshift(e,4),255),bit.band(m,15)))
	-- get rid of written bits and shift for next 8
	m=(m-math.floor(m))*256
	self:WriteByte(bit.band(m,255))
	-- repeat for rest of mantissa
	m=(m-math.floor(m))*256
	self:WriteByte(bit.band(m,255))

	m=(m-math.floor(m))*256
	self:WriteByte(bit.band(m,255))

	m=(m-math.floor(m))*256
	self:WriteByte(bit.band(m,255))

	m=(m-math.floor(m))*256
	self:WriteByte(bit.band(m,255))
	
	m=(m-math.floor(m))*256
	self:WriteByte(bit.band(m,255))
	
end

function T:ReadDouble()
	local b=self:ReadByte()
	local sign=1
	if b>=128 then 
		sign=-1
		b=b-128
	end
	local exponent=b*16
	b=self:ReadByte()
	exponent=exponent+bit.band(bit.rshift(b,4),15)-1023
	local mantissa=bit.band(b,15)/16
	
	b=self:ReadByte()
	mantissa=mantissa+b/16/256
	b=self:ReadByte()
	mantissa=mantissa+b/16/65536
	b=self:ReadByte()
	mantissa=mantissa+b/16/65536/256
	b=self:ReadByte()
	mantissa=mantissa+b/16/65536/65536
	b=self:ReadByte()
	mantissa=mantissa+b/16/65536/65536/256
	b=self:ReadByte()
	mantissa=mantissa+b/16/65536/65536/65536
	if mantissa==0.0 and exponent==-1023 then return 0.0
	else return (mantissa+1.0)*math.pow(2,exponent)*sign end
end

function T:WriteFloat(value)
-- ieee 754 binary32
-- 33222222 22221111 111111
-- 10987654 32109876 54321098 76543210
-- seeeeeee emmmmmmm mmmmmmmm mmmmmmmm
	if value==0.0 then
		self:WriteBytes(0,4)
		return
	end

	signBit=0
	if value<0 then
		signBit=128 -- shifted left to appropriate position 
		value=-value
	end
	
	m,e=math.frexp(value) 
	m=m*2-1
	e=e-1+127
	e=min(max(0,e),255)
	
	-- sign and 7 bits of exponent
	self:WriteByte(bit.bor(signBit,bit.band(bit.rshift(e,1),127)))
	
	-- first 7 bits of mantissa
	m=m*128
	-- write last bit of exponent and first 7 of mantissa
	self:WriteByte(bit.bor(bit.band(bit.lshift(e,7),255),bit.band(m,127)))
	-- get rid of written bits and shift for next 8
	m=(m-math.floor(m))*256
	self:WriteByte(bit.band(m,255))
	
	m=(m-math.floor(m))*256
	self:WriteByte(bit.band(m,255))	
end

function T:ReadFloat()
	local b=self:ReadByte()
	local sign=1
	if b>=128 then 
		sign=-1
		b=b-128
	end
	local exponent=b*2
	b=self:ReadByte()
	exponent=exponent+bit.band(bit.rshift(b,7),1)-127
	local mantissa=bit.band(b,127)/128
	
	b=self:ReadByte()
	mantissa=mantissa+b/128/256
	b=self:ReadByte()
	mantissa=mantissa+b/128/65536
	if mantissa==0.0 and exponent==-127 then return 0.0
	else return (mantissa+1.0)*math.pow(2,exponent)*sign end
end

function T:WriteHalf(value)
-- ieee 754 binary16
-- 111111
-- 54321098 76543210
-- seeeeemm mmmmmmmm
	if value==0.0 then
		self:WriteBytes(0,2)
		return
	end

	signBit=0
	if value<0 then
		signBit=128 -- shifted left to appropriate position 
		value=-value
	end
	
	m,e=math.frexp(value) 
	m=m*2-1
	e=e-1+15
	e=min(max(0,e),31)
	
	m=m*4
	-- sign, 5 bits of exponent, 2 bits of mantissa
	self:WriteByte(bit.bor(signBit,bit.band(e,31)*4,bit.band(m,3)))
	
	-- get rid of written bits and shift for next 8
	m=(m-math.floor(m))*256
	self:WriteByte(bit.band(m,255))	
end

function T:ReadHalf()
	local b=self:ReadByte()
	local sign=1
	if b>=128 then 
		sign=-1
		b=b-128
	end
	local exponent=bit.rshift(b,2)-15
	local mantissa=bit.band(b,3)/4
	
	b=self:ReadByte()
	mantissa=mantissa+b/4/256
	if mantissa==0.0 and exponent==-15 then return 0.0
	else return (mantissa+1.0)*math.pow(2,exponent)*sign end
end


function T:WriteString(value)
	self:WriteVariableBytes(#value)
	for i=1,#value,1 do
		self:WriteByte(string.byte(value,i))
	end
end

function T:ReadString()
	local length=self:ReadVariableBytes()
	local chars={}
	local b
	for i=1,length do
		b=self:ReadByte()
		chars:insert(string.char(b))
	end
	return chars:concat()
end
