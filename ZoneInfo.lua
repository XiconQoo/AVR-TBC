local ADDON_NAME="AVR"
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, true)

AVRZoneData = LibStub("AceAddon-3.0"):NewAddon("AVRZoneInfo", "AceEvent-3.0")
local T=AVRZoneData
local Core=AVR
AVRZoneData.Embed=Core.Embed

function T:New()
	if self ~= T then return end
	local s={}
	
	T:Embed(s)
	
	s.currentScale=nil
	s.currentZone=nil
	s.hasLevels=false
	
	s.oldZoneText=""
	
	return s
end

function T:Disable()
	self:UnregisterEvent("ZONE_CHANGED")
	self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
	self:UnregisterEvent("ZONE_CHANGED_INDOORS")
	self:UnregisterEvent("PLAYER_ENTERING_WORLD","ZoneChanged")
end

function T:Enable()
	self:RegisterEvent("ZONE_CHANGED","ZoneChanged")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA","ZoneChanged")
	self:RegisterEvent("ZONE_CHANGED_INDOORS","ZoneChanged")
	self:RegisterEvent("PLAYER_ENTERING_WORLD","ZoneChanged")
	self:ZoneChanged("Enable")
end

function T:OnUpdate()
	local zoneText=GetMinimapZoneText()
	local force=T.forceZones[zoneText]
	if force then
		if self.currentZone~=force then
			self:ZoneChanged("ZoneText")
		end
	end
end

function T:ZoneChanged(event)
	if event=="ZONE_CHANGED" and not self.hasLevels then return end
	
	self.oldZoneText=GetMinimapZoneText()
	SetMapToCurrentZone()
	local tex,_,_=GetMapInfo()
	local level=0
	self.hasLevels=(level>0)
	if tex=="Ulduar" then level=level-1 end -- Why????
	if level>0 then
		tex=tex..level
	end
	self.currentScale=T.zoneData[tex]
	self.currentZone=tex
	--print("Zone changed "..event)
end

function T:GetCurrentZone()
	return self.currentZone
end

function T:GetCurrentZoneScale()
	return self.currentScale
end

-- some zones have trouble triggering events at proper times
T.forceZones={
	[L["The Frozen Throne"]]="IcecrownCitadel7", -- Teleporter to Lich King's platform in Icecrown raid is a bit troublesome.
}

T.zoneData={
	Arathi = { 3599.99987792969, 2399.99992370605, 1},
	Ogrimmar = { 1402.6044921875, 935.416625976563, 2},
	Undercity = { 959.375030517578, 640.104125976563, 4},
	Barrens = { 10133.3330078125, 6756.24987792969, 5},
	Darnassis = { 1058.33325195313, 705.7294921875, 6},
	AzuremystIsle = { 4070.8330078125, 2714.5830078125, 7},
	UngoroCrater = { 3699.99981689453, 2466.66650390625, 8},
	BurningSteppes = { 2929.16659545898, 1952.08349609375, 9},
	Wetlands = { 4135.41668701172, 2756.25, 10},
	Winterspring = { 7099.99984741211, 4733.33325195313, 11},
	Dustwallow = { 5250.00006103516, 3499.99975585938, 12},
	Darkshore = { 6549.99975585938, 4366.66650390625, 13},
	LochModan = { 2758.33312988281, 1839.5830078125, 14},
	BladesEdgeMountains = { 5424.99975585938, 3616.66638183594, 15},
	Durotar = { 5287.49963378906, 3524.99987792969, 16},
	Silithus = { 3483.333984375, 2322.916015625, 17},
	ShattrathCity = { 1306.25, 870.833374023438, 18},
	Ashenvale = { 5766.66638183594, 3843.74987792969, 19},
	Azeroth = { 40741.181640625, 27149.6875, 20},
	Nagrand = { 5525.0, 3683.33316802979, 21},
	TerokkarForest = { 5399.99975585938, 3600.00006103516, 22},
	EversongWoods = { 4925.0, 3283.3330078125, 23},
	SilvermoonCity = { 1211.45849609375, 806.7705078125, 24},
	Tanaris = { 6899.99952697754, 4600.0, 25},
	Stormwind = { 1737.499958992, 1158.3330078125, 26},
	SwampOfSorrows = { 2293.75, 1529.1669921875, 27},
	EasternPlaguelands = { 4031.25, 2687.49987792969, 28},
	BlastedLands = { 3349.99987792969, 2233.333984375, 29},
	Elwynn = { 3470.83325195313, 2314.5830078125, 30},
	DeadwindPass = { 2499.99993896484, 1666.6669921875, 31},
	DunMorogh = { 4924.99975585938, 3283.33325195313, 32},
	TheExodar = { 1056.7705078125, 704.687744140625, 33},
	Felwood = { 5749.99963378906, 3833.33325195313, 34},
	Silverpine = { 4199.99975585938, 2799.99987792969, 35},
	ThunderBluff = { 1043.74993896484, 695.833312988281, 36},
	Hinterlands = { 3850.0, 2566.66662597656, 37},
	StonetalonMountains = { 4883.33312988281, 3256.24981689453, 38},
	Mulgore = { 5137.49987792969, 3424.99984741211, 39},
	Hellfire = { 5164.5830078125, 3443.74987792969, 40},
	Ironforge = { 790.625061035156, 527.6044921875, 41},
	ThousandNeedles = { 4399.99969482422, 2933.3330078125, 42},
	Stranglethorn = { 6381.24975585938, 4254.166015625, 43},
	Badlands = { 2487.5, 1658.33349609375, 44},
	Teldrassil = { 5091.66650390625, 3393.75, 45},
	Moonglade = { 2308.33325195313, 1539.5830078125, 46},
	ShadowmoonValley = { 5500.0, 3666.66638183594, 47},
	Tirisfal = { 4518.74987792969, 3012.49981689453, 48},
	Aszhara = { 5070.83276367188, 3381.24987792969, 49},
	Redridge = { 2170.83325195313, 1447.916015625, 50},
	BloodmystIsle = { 3262.4990234375, 2174.99993896484, 51},
	WesternPlaguelands = { 4299.99990844727, 2866.66653442383, 52},
	Alterac = { 2799.99993896484, 1866.66665649414, 53},
	Westfall = { 3499.99981689453, 2333.3330078125, 54},
	Duskwood = { 2699.99993896484, 1800.0, 55},
	Netherstorm = { 5574.99967193604, 3716.66674804688, 56},
	Ghostlands = { 3300.0, 2199.99951171875, 57},
	Zangarmarsh = { 5027.08349609375, 3352.08325195313, 58},
	Desolace = { 4495.8330078125, 2997.91656494141, 59},
	Kalimdor = { 36799.810546875, 24533.2001953125, 60},
	SearingGorge = { 2231.24984741211, 1487.49951171875, 61},
	Expansion01 = { 17464.078125, 11642.71875, 62},
	Feralas = { 6949.99975585938, 4633.3330078125, 63},
	Hilsbrad = { 3199.99987792969, 2133.33325195313, 64},
	Sunwell = { 3327.0830078125, 2218.7490234375, 65},
	Northrend = { 17751.3984375, 11834.2650146484, 66},
	BoreanTundra = { 5764.5830078125, 3843.74987792969, 67},
	Dragonblight = { 5608.33312988281, 3739.58337402344, 68},
	GrizzlyHills = { 5249.99987792969, 3499.99987792969, 69},
	HowlingFjord = { 6045.83288574219, 4031.24981689453, 70},
	IcecrownGlacier = { 6270.83331298828, 4181.25, 71},
	SholazarBasin = { 4356.25, 2904.16650390625, 72},
	TheStormPeaks = { 7112.49963378906, 4741.666015625, 73},
	ZulDrak = { 4993.75, 3329.16650390625, 74},
	ScarletEnclave = { 3162.5, 2108.33337402344, 76},
	CrystalsongForest = { 2722.91662597656, 1814.5830078125, 77},
	LakeWintergrasp = { 2974.99987792969, 1983.33325195313, 78},
	StrandoftheAncients = { 1743.74993896484, 1162.49993896484, 79},
	Dalaran = { 0.0, 0.0, 80},
	Naxxramas = { 1856.24975585938, 1237.5, 81},
	Naxxramas1 = { 1093.830078125, 729.219970703125, 82},
	Naxxramas2 = { 1093.830078125, 729.219970703125, 83},
	Naxxramas3 = { 1200.0, 800.0, 84},
	Naxxramas4 = { 1200.330078125, 800.219970703125, 85},
	Naxxramas5 = { 2069.80981445313, 1379.8798828125, 86},
	Naxxramas6 = { 655.93994140625, 437.2900390625, 87},
	TheForgeofSouls = { 11399.9995117188, 7599.99975585938, 88},
	TheForgeofSouls1 = { 1448.09985351563, 965.400390625, 89},
	AlteracValley = { 4237.49987792969, 2824.99987792969, 90},
	WarsongGulch = { 1145.83331298828, 764.583312988281, 91},
	IsleofConquest = { 2650.0, 1766.66658401489, 92},
	TheArgentColiseum = { 2599.99996948242, 1733.33334350586, 93},
	TheArgentColiseum1 = { 369.986186981201, 246.657989501953, 94},
	TheArgentColiseum1 = { 369.986186981201, 246.657989501953, 95},
	TheArgentColiseum2 = { 739.996017456055, 493.330017089844, 96},
	HrothgarsLanding = { 3677.08312988281, 2452.083984375, 97},
	AzjolNerub = { 1072.91664505005, 714.583297729492, 98},
	AzjolNerub1 = { 752.973999023438, 501.983001708984, 99},
	AzjolNerub2 = { 292.973999023438, 195.315979003906, 100},
	AzjolNerub3 = { 367.5, 245.0, 101},
	Ulduar77 = { 3399.99981689453, 2266.66666412354, 102},
	Ulduar771 = { 920.196014404297, 613.466064453125, 103},
	DrakTharonKeep = { 627.083312988281, 418.75, 104},
	DrakTharonKeep1 = { 619.941009521484, 413.293991088867, 105},
	DrakTharonKeep2 = { 619.941009521484, 413.293991088867, 106},
	HallsofReflection = { 12999.9995117188, 8666.66650390625, 107},
	HallsofReflection1 = { 879.02001953125, 586.01953125, 108},
	TheObsidianSanctum = { 1162.49991798401, 775.0, 109},
	HallsofLightning = { 3399.99993896484, 2266.66666412354, 110},
	HallsofLightning1 = { 566.235015869141, 377.489990234375, 111},
	HallsofLightning2 = { 708.237014770508, 472.160034179688, 112},
	IcecrownCitadel = { 12199.9995117188, 8133.3330078125, 113},
	IcecrownCitadel1 = { 1355.47009277344, 903.647033691406, 114},
	IcecrownCitadel2 = { 1067.0, 711.333690643311, 115},
	IcecrownCitadel3 = { 195.469970703125, 130.315002441406, 116},
	IcecrownCitadel4 = { 773.710083007813, 515.810302734375, 117},
	IcecrownCitadel5 = { 1148.73999023438, 765.820068359375, 118},
	IcecrownCitadel6 = { 373.7099609375, 249.1298828125, 119},
	IcecrownCitadel7 = { 293.260009765625, 195.507019042969, 120},
	IcecrownCitadel8 = { 247.929931640625, 165.287994384766, 121},
	VioletHold = { 383.333312988281, 256.25, 122},
	VioletHold1 = { 256.22900390625, 170.820068359375, 123},
	NetherstormArena = { 2270.83319091797, 1514.58337402344, 124},
	CoTStratholme = { 1824.99993896484, 1216.66650390625, 125},
	CoTStratholme1 = { 1125.29998779297, 750.199951171875, 126},
	TheEyeofEternity = { 3399.99981689453, 2266.66666412354, 127},
	TheEyeofEternity1 = { 430.070068359375, 286.713012695313, 128},
	Nexus80 = { 2600.0, 1733.33322143555, 129},
	Nexus801 = { 514.706970214844, 343.138977050781, 130},
	Nexus802 = { 664.706970214844, 443.138977050781, 131},
	Nexus803 = { 514.706970214844, 343.138977050781, 132},
	Nexus804 = { 294.700988769531, 196.463989257813, 133},
	VaultofArchavon = { 2599.99987792969, 1733.33325195313, 134},
	VaultofArchavon1 = { 1398.25500488281, 932.170013427734, 135},
	Ulduar = { 3287.49987792969, 2191.66662597656, 136},
	Ulduar1 = { 669.450988769531, 446.300048828125, 137},
	Ulduar2 = { 1328.46099853516, 885.639892578125, 138},
	Ulduar3 = { 910.5, 607.0, 139},
	Ulduar4 = { 1569.4599609375, 1046.30004882813, 140},
	Ulduar5 = { 619.468994140625, 412.97998046875, 141},
	Dalaran1 = { 830.015014648438, 553.33984375, 142},
	Dalaran2 = { 563.223999023438, 375.48974609375, 143},
	Gundrak = { 1143.74996948242, 762.499877929688, 144},
	Gundrak1 = { 905.033050537109, 603.35009765625, 145},
	TheNexus = { 0.0, 0.0, 146},
	TheNexus1 = { 1101.2809753418, 734.1875, 147},
	PitofSaron = { 1533.33331298828, 1022.91667175293, 148},
	Ahnkahet = { 972.91667175293, 647.916610717773, 149},
	Ahnkahet1 = { 972.41796875, 648.279022216797, 150},
	ArathiBasin = { 1756.24992370605, 1170.83325195313, 151},
	UtgardePinnacle = { 6549.99951171875, 4366.66650390625, 152},
	UtgardePinnacle1 = { 548.936019897461, 365.957015991211, 153},
	UtgardePinnacle2 = { 756.179943084717, 504.119003295898, 154},
	UtgardeKeep = { 0.0, 0.0, 155},
	UtgardeKeep1 = { 734.580993652344, 489.721500396729, 156},
	UtgardeKeep2 = { 481.081008911133, 320.720293045044, 157},
	UtgardeKeep3 = { 736.581008911133, 491.054512023926, 158},
}


