local lib = LibStub:GetLibrary("LibItemStatsPlus")
lib.APPerStr = {
	2, --WARRIOR
	2, --PALADIN
	1, --HUNTER
	1, --ROGUE
	2, --PRIEST
	2, --DEATHKNIGHT
	1, --SHAMAN
	2, --MAGE
	2, --WARLOCK
	1, --MONK   TODO: 20120811: Figure out Monk's Attack Power per Strength. (Does AP/Str even vary by class anymore?)
	1, --DRUID
}

lib.RAPPerAgi = {
	1,	--Warrior
	0,	--Paladin
	2,	--Hunter
	1,	--Rogue
	0,	--Priest
	0,	--Death Knight
	0,	--Shaman
	0,	--Mage
	0,	--Warlock
	0,	--Monk
	0,	--Druid
}

lib.APPerAgi = {
	0, --WARRIOR
	0, --PALADIN
	1, --HUNTER
	2, --ROGUE
	0, --PRIEST
	0, --DEATHKNIGHT
	2, --SHAMAN
	0, --MAGE
	0, --WARLOCK
	2, --MONK  20121108: "I did some informal testing on my monk (lvl90), and it does appear that 1 agil = 2 attack pwr, at least for WindWalker." 20121107: "likely be changed to 2 to fall in like with other classes"  20120811: Figure out Monk's AP per AGI (do they even have any? Does AP/Agi ever vary by class anymore?)
	0, --DRUID
}

lib.SPPerInt = {
	0, --WARRIOR
	0, --PALADIN
	0, --HUNTER
	0, --ROGUE
	1, --PRIEST
	0, --DEATHKNIGHT
	1, --SHAMAN
	1, --MAGE
	1, --WARLOCK
	1, --MONK  20121108: "I did some informal testing on my monk (lvl90), and it does appear that 1 agil = 2 attack pwr, at least for WindWalker." 20121107: "likely be changed to 2 to fall in like with other classes"  20120811: Figure out Monk's AP per AGI (do they even have any? Does AP/Agi ever vary by class anymore?)
	1, --DRUID
}