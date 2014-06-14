local lib = LibStub:GetLibrary("LibItemStatsPlus")
lib.GetClassIDFromClassName = {
	["WARRIOR"] = 1,
	["PALADIN"] = 2,
	["HUNTER"] = 3,
	["ROGUE"] = 4,
	["PRIEST"] = 5,
	["DEATHKNIGHT"] = 6,
	["SHAMAN"] = 7,
	["MAGE"] = 8,
	["WARLOCK"] = 9,
	["MONK"] = 10,
	["DRUID"] = 11,
}

lib.MasteryCoefficients = {
	[1] = {2.3, 1.4, 2.2},
	[2] = {1.5, 1, 0,0,0,2.1},
	[3] = {2, 2, 1},
	[4] = {3.5, 2, 3},
	[5] = {2.5, 1.25, 1.8},
	[6] = {6.25, 2, 2.5},
	[7] = {2, 2, 3},
	[8] = {2, 1.5, 2},
	[9] = {3.1, 1, 3},
	[10] = {0.5, 1.2, 1.4},
	[11] = {1.875, 3.13, 1.25, 1.25},
}

lib.SpecIDToSpecIndex = {
70, 64, 252, 258, 255, 249, 261, 61, 264, 267, 101,
}