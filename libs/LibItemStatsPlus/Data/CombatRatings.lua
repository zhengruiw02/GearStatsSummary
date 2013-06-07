local _, ns = ...
ns.CombatRatingsFromIndexToName = {
	[1] = "ITEM_MOD_DODGE_RATING_SHORT",
	[2] = "ITEM_MOD_PARRY_RATING_SHORT",
	[3] = "ITEM_MOD_BLOCK_RATING_SHORT", --?
	[4] = "ITEM_MOD_HIT_RATING_SHORT",
	[5] = "ITEM_MOD_CRIT_RATING_SHORT",
	[6] = "ITEM_MOD_RESILIENCE_RATING_SHORT",
	[7] = "ITEM_MOD_HASTE_RATING_SHORT",
	[8] = "ITEM_MOD_EXPERTISE_RATING_SHORT",
	[9] = "ITEM_MOD_MASTERY_RATING_SHORT",
	[10] = "ITEM_MOD_PVP_POWER_SHORT",
}
ns.CombatRatingsFromNameToIndex = {
	["ITEM_MOD_DODGE_RATING_SHORT"] = 1,
	["ITEM_MOD_PARRY_RATING_SHORT"] = 2,
	["ITEM_MOD_BLOCK_RATING_SHORT"] = 3, --?
	["ITEM_MOD_HIT_RATING_SHORT"] = 4,
	["ITEM_MOD_CRIT_RATING_SHORT"] = 5,
	["ITEM_MOD_RESILIENCE_RATING_SHORT"] = 6,
	["ITEM_MOD_HASTE_RATING_SHORT"] = 7,
	["ITEM_MOD_EXPERTISE_RATING_SHORT"] = 8,
	["ITEM_MOD_MASTERY_RATING_SHORT"] = 9,
	["ITEM_MOD_PVP_POWER_SHORT"] = 10,
}

ns.CombatRatingsFromRatingIDToIndex = {
	["CR_WEAPON_SKILL"] = 0,
	["CR_DEFENSE_SKILL"] = 0,
	["CR_DODGE"] = 1,
	["CR_PARRY"] = 2,
	["CR_BLOCK"] = 3,
	["CR_HIT_MELEE"] = 4,
	["CR_HIT_RANGED"] = 4,
	["CR_HIT_SPELL"] = 4,
	["CR_CRIT_MELEE"] = 5,
	["CR_CRIT_RANGED"] = 5,
	["CR_CRIT_SPELL"] = 5,
	["CR_HIT_TAKEN_MELEE"] = 0,
	["CR_HIT_TAKEN_RANGED"] = 0,
	["CR_HIT_TAKEN_SPELL"] = 0,
	["COMBAT_RATING_RESILIENCE_CRIT_TAKEN"] = 0,
	["COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN"] = 6,
	["CR_CRIT_TAKEN_SPELL"] = 0,
	["CR_HASTE_MELEE"] = 7,
	["CR_HASTE_RANGED"] = 7,
	["CR_HASTE_SPELL"] = 7,
	["CR_WEAPON_SKILL_MAINHAND"] = 0,
	["CR_WEAPON_SKILL_OFFHAND"] = 0,
	["CR_WEAPON_SKILL_RANGED"] = 0,
	["CR_EXPERTISE"] = 8,
	["CR_ARMOR_PENETRATION"] = 0,
	["CR_MASTERY"] = 9,
	["CR_PVP_POWER"] = 10,
}

ns.CombatRating10 = {
	0.796153128,
	0.796153128,
	0.265384376,
	0.307691991,
	0.538461983,
	0.30631423,
	0.384615004,
	0.307691991,
	0.538461983,
	0.30631423,
}

ns.CombatRating60 = {
	[1] = {0.3981, 0.7962},
	[2] = {0.3981, 0.7962},
	[3] = {0.1327, 0.2654},
	[4] = {0.1538, 0.3077},
	[5] = {0.2692, 0.5385},
	[6] = {0.1532, 0.3063},
	[7] = {0.1923, 0.3846},
	[8] = {0.1538, 0.3077},
	[9] = {0.2692, 0.5385},
	[10] = {0.1532, 0.3063},
}
--CR_DODGE CR_PARRY CR_BLOCK CR_HIT_MELEE CR_CRIT_MELEE COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN CR_HASTE_MELEE CR_EXPERTISE CR_MASTERY CR_PVP_POWER
--gtCombatRatings.dbc
ns.CombatRatings = {
	[1] = {0.796153188,0.796153188,0.265384346,0.307691991,0.538461983,0.3063142,0.384615004,0.307691991,0.538461983,0.3063142},
	[2] = {0.796153069,0.796153069,0.265384316,0.307691991,0.538461983,0.30631417,0.384615004,0.307691991,0.538461983,0.30631417},
	[3] = {0.796153069,0.796153069,0.265384316,0.307691991,0.538461983,0.30631423,0.384615004,0.307691991,0.538461983,0.30631423},
	[4] = {0.796153069,0.796153069,0.265384346,0.307691991,0.538461983,0.3063142,0.384615004,0.307691991,0.538461983,0.3063142},
	[5] = {0.796152949,0.796152949,0.265384316,0.307691991,0.538461983,0.30631417,0.384615004,0.307691991,0.538461983,0.30631417},
	[6] = {0.796153128,0.796153128,0.265384346,0.307691991,0.538461983,0.30631426,0.384615004,0.307691991,0.538461983,0.30631426},
	[7] = {0.796153069,0.796153069,0.265384376,0.307691991,0.538461983,0.30631423,0.384615004,0.307691991,0.538461983,0.30631423},
	[8] = {0.796153009,0.796153009,0.265384346,0.307691991,0.538461983,0.3063142,0.384615004,0.307691991,0.538461983,0.3063142},
	[9] = {0.796153009,0.796153009,0.265384376,0.307691991,0.538461983,0.30631417,0.384615004,0.307691991,0.538461983,0.30631417},
	[10] = {0.796153128,0.796153128,0.265384376,0.307691991,0.538461983,0.30631423,0.384615004,0.307691991,0.538461983,0.30631423},
	[11] = {1.194230556,1.194230556,0.398076862,0.461537987,0.807691991,0.459471703,0.576923013,0.461537987,0.807691991,0.459471703},
	[12] = {1.592308164,1.592308164,0.530769408,0.615384996,1.076923013,0.612629235,0.769231021,0.615384996,1.076923013,0.612629235},
	[13] = {1.990383744,1.990383744,0.663461208,0.769231021,1.346153975,0.765785873,0.961538017,0.769231021,1.346153975,0.765785873},
	[14] = {2.388461113,2.388461113,0.796153724,0.923076987,1.615385056,0.918943524,1.153846025,0.923076987,1.615385056,0.918943524},
	[15] = {2.786539078,2.786539078,0.928846478,1.076923013,1.884614944,1.072101116,1.346153975,1.076923013,1.884614944,1.072101116},
	[16] = {3.184616804,3.184616804,1.061538696,1.230769038,2.153846025,1.225258589,1.538462043,1.230769038,2.153846025,1.225258589},
	[17] = {3.582691908,3.582691908,1.194230676,1.384614944,2.423077106,1.378415346,1.730769038,1.384614944,2.423077106,1.378415346},
	[18] = {3.980769873,3.980769873,1.326923013,1.538462043,2.692307949,1.5315727,1.923076987,1.538462043,2.692307949,1.5315727},
	[19] = {4.378847599,4.378847599,1.459615827,1.692307949,2.961538076,1.684730411,2.115385056,1.692307949,2.961538076,1.684730411},
	[20] = {4.776922703,4.776922703,1.592307568,1.846153975,3.230768919,1.83788693,2.307692051,1.846153975,3.230768919,1.83788693},
	[21] = {5.175000191,5.175000191,1.724999905,2,3.5,1.991044402,2.5,2,3.5,1.991044402},
	[22] = {5.573077679,5.573077679,1.857692242,2.153846025,3.769231081,2.144201756,2.692307949,2.153846025,3.769231081,2.144201756},
	[23] = {5.971153259,5.971153259,1.99038446,2.307692051,4.038462162,2.297358751,2.884614944,2.307692051,4.038462162,2.297358751},
	[24] = {6.369230747,6.369230747,2.123076916,2.46153903,4.307692051,2.450515985,3.076922894,2.46153903,4.307692051,2.450515985},
	[25] = {6.767308712,6.767308712,2.255769253,2.615385056,4.576922894,2.603673697,3.269231081,2.615385056,4.576922894,2.603673697},
	[26] = {7.165383339,7.165383339,2.388461113,2.769231081,4.846154213,2.756830215,3.461538076,2.769231081,4.846154213,2.756830215},
	[27] = {7.563461781,7.563461781,2.521154165,2.923077106,5.115385056,2.909987688,3.653846025,2.923077106,5.115385056,2.909987688},
	[28] = {7.961538792,7.961538792,2.653846025,3.076922894,5.384614944,3.063145399,3.846153975,3.076922894,5.384614944,3.063145399},
	[29] = {8.359617233,8.359617233,2.786538839,3.230768919,5.653845787,3.216302872,4.038462162,3.230768919,5.653845787,3.216302872},
	[30] = {8.757692337,8.757692337,2.919230461,3.384614944,5.923077106,3.369459391,4.230769157,3.384614944,5.923077106,3.369459391},
	[31] = {9.155768394,9.155768394,3.051922798,3.538461924,6.192306995,3.522616863,4.423077106,3.538461924,6.192306995,3.522616863},
	[32] = {9.553846359,9.553846359,3.184615374,3.692307949,6.461537838,3.675774336,4.615385056,3.692307949,6.461537838,3.675774336},
	[33] = {9.951925278,9.951925278,3.317308426,3.846153975,6.730769157,3.828932524,4.807693005,3.846153975,6.730769157,3.828932524},
	[34] = {10.35000134,10.35000134,3.450000048,4,7,3.982088566,5,4,7,3.982088566},
	[35] = {10.74807739,10.74807739,3.582691908,4.153845787,7.269230843,4.1352458,5.192307949,4.153845787,7.269230843,4.1352458},
	[36] = {11.14615345,11.14615345,3.715384007,4.307692051,7.538462162,4.288403511,5.384614944,4.307692051,7.538462162,4.288403511},
	[37] = {11.54423141,11.54423141,3.848077059,4.461537838,7.807693005,4.441560268,5.576922894,4.461537838,7.807693005,4.441560268},
	[38] = {11.94230747,11.94230747,3.980768919,4.615385056,8.07692337,4.594717503,5.769230843,4.615385056,8.07692337,4.594717503},
	[39] = {12.34038353,12.34038353,4.113461018,4.769230843,8.346154213,4.747875214,5.961537838,4.769230843,8.346154213,4.747875214},
	[40] = {12.73846245,12.73846245,4.246153831,4.923077106,8.615384102,4.901032448,6.153845787,4.923077106,8.615384102,4.901032448},
	[41] = {13.13653755,13.13653755,4.378846169,5.076922894,8.884614944,5.054189205,6.346154213,5.076922894,8.884614944,5.054189205},
	[42] = {13.53461647,13.53461647,4.511538982,5.230769157,9.153845787,5.207346439,6.538462162,5.230769157,9.153845787,5.207346439},
	[43] = {13.93269253,13.93269253,4.644230843,5.384614944,9.42307663,5.36050415,6.730769157,5.384614944,9.42307663,5.36050415},
	[44] = {14.33076859,14.33076859,4.77692318,5.538462162,9.692307472,5.513661385,6.923077106,5.538462162,9.692307472,5.513661385},
	[45] = {14.72884655,14.72884655,4.909615994,5.692306995,9.961538315,5.666818619,7.115385056,5.692306995,9.961538315,5.666818619},
	[46] = {15.12692547,15.12692547,5.042307854,5.846154213,10.23077011,5.819975853,7.307693005,5.846154213,10.23077011,5.819975853},
	[47] = {15.52499962,15.52499962,5.175000191,6,10.5,5.973133564,7.5,6,10.5,5.973133564},
	[48] = {15.92307758,15.92307758,5.307693005,6.153845787,10.7692318,6.126290798,7.692306995,6.153845787,10.7692318,6.126290798},
	[49] = {16.32115555,16.32115555,5.440383911,6.307693005,11.03846169,6.279448032,7.884614944,6.307693005,11.03846169,6.279448032},
	[50] = {16.71923065,16.71923065,5.573077202,6.461537838,11.30769253,6.432605743,8.07692337,6.461537838,11.30769253,6.432605743},
	[51] = {17.11730957,17.11730957,5.705769062,6.615385056,11.57692337,6.585762501,8.269230843,6.615385056,11.57692337,6.585762501},
	[52] = {17.51538658,17.51538658,5.838461876,6.769230843,11.84615517,6.738920212,8.461538315,6.769230843,11.84615517,6.738920212},
	[53] = {17.91346169,17.91346169,5.971154213,6.923077106,12.11538506,6.892076492,8.653845787,6.923077106,12.11538506,6.892076492},
	[54] = {18.3115387,18.3115387,6.103846073,7.076922894,12.38461685,7.045234203,8.846154213,7.076922894,12.38461685,7.045234203},
	[55] = {18.70961761,18.70961761,6.236537933,7.230769157,12.65384674,7.198391438,9.038461685,7.230769157,12.65384674,7.198391438},
	[56] = {19.10769272,19.10769272,6.369231224,7.384614944,12.92307854,7.351549149,9.230769157,7.384614944,12.92307854,7.351549149},
	[57] = {19.50576973,19.50576973,6.501923084,7.538462162,13.19230843,7.504705429,9.42307663,7.538462162,13.19230843,7.504705429},
	[58] = {19.90384865,19.90384865,6.634614944,7.692306995,13.46153927,7.657863617,9.615385056,7.692306995,13.46153927,7.657863617},
	[59] = {20.30192375,20.30192375,6.767308235,7.846154213,13.73077011,7.811020374,9.807692528,7.846154213,13.73077011,7.811020374},
	[60] = {20.70000076,20.70000076,6.900001049,8,14,7.964177132,10,8,14,7.964177132},
	[61] = {21.48607636,21.48607636,7.162024975,8.303797722,14.53164673,8.266614914,10.37974739,8.303797722,14.53164673,8.266614914},
	[62] = {22.33421326,22.33421326,7.444736958,8.631579399,15.10526466,8.592928886,10.78947353,8.631579399,15.10526466,8.592928886},
	[63] = {23.25205612,23.25205612,7.750685215,8.986301422,15.7260294,8.946062088,11.23287678,8.986301422,15.7260294,8.946062088},
	[64] = {24.2485714,24.2485714,8.082857132,9.371427536,16.39999962,9.329465866,11.7142868,9.371427536,16.39999962,9.329465866},
	[65] = {25.33432961,25.33432961,8.444775581,9.791045189,17.13432884,9.747202873,12.23880672,9.791045189,17.13432884,9.747202873},
	[66] = {26.52187729,26.52187729,8.840625763,10.25,17.9375,10.20410347,12.8125,10.25,17.9375,10.20410347},
	[67] = {27.826231,27.826231,9.275409698,10.75409889,18.81967354,10.70594406,13.44262409,10.75409889,18.81967354,10.70594406},
	[68] = {29.26551819,29.26551819,9.755171776,11.31034565,19.79310417,11.25969982,14.13793087,11.31034565,19.79310417,11.25969982},
	[69] = {30.86182022,30.86182022,10.28727341,11.92727375,20.87272835,11.87386513,14.909091,11.92727375,20.87272835,11.87386513},
	[70] = {32.64230728,32.64230728,10.88076973,12.61538506,22.07692337,12.55889606,15.76923275,12.61538506,22.07692337,12.55889606},
	[71] = {35.12157059,35.12157059,11.70719147,13.57355499,23.75372124,13.51277542,16.96694183,13.57355499,23.75372124,13.51277542},
	[72] = {37.78913879,37.78913879,12.59638023,14.60449982,25.55787468,14.53910255,18.25562477,14.60449982,25.55787468,14.53910255},
	[73] = {40.65932083,40.65932083,13.55310726,15.71374798,27.49905586,15.64338303,19.6421833,15.71374798,27.49905586,15.64338303},
	[74] = {43.74749374,43.74749374,14.5824976,16.90724373,29.587677,16.83153725,21.13405418,16.90724373,29.587677,16.83153725},
	[75] = {47.07022095,47.07022095,15.69007397,18.19139099,31.83493423,18.10993195,22.73923683,18.19139099,31.83493423,18.10993195},
	[76] = {50.64532089,50.64532089,16.881773,19.57307053,34.25287247,19.48542595,24.46633911,19.57307053,34.25287247,19.48542595},
	[77] = {54.49195862,54.49195862,18.16398621,21.05969429,36.85446548,20.96539116,26.32461739,21.05969429,36.85446548,20.96539116},
	[78] = {58.63075638,58.63075638,19.54358482,22.65922737,39.65364838,22.55776405,28.32403564,22.65922737,39.65364838,22.55776405},
	[79] = {63.08390427,63.08390427,21.02796745,24.38025284,42.66543961,24.27108192,30.47531509,24.38025284,42.66543961,24.27108192},
	[80] = {67.87528229,67.87528229,22.62509346,26.23199272,45.90598679,26.11453056,32.78998947,26.23199272,45.90598679,26.11453056},
	[81] = {89.12595367,89.12595367,29.70865059,34.44481277,60.27842331,32.59654999,43.05601501,34.44481277,60.27842331,32.59654999},
	[82] = {117.0372772,117.0372772,39.01242828,45.23180008,79.15564728,40.68750763,56.53974915,45.23180008,79.15564728,40.68750763},
	[83] = {153.7501984,153.7501984,51.25006485,59.42036819,103.9856415,50.78675842,74.27545166,59.42036819,103.9856415,50.78675842},
	[84] = {201.8813782,201.8813782,67.29379272,78.02178955,136.5381317,63.39279938,97.52723694,78.02178955,136.5381317,63.39279938},
	[85] = {265.0783386,265.0783386,88.35944366,102.4457397,179.2800446,79.12784576,128.0571594,102.4457397,179.2800446,79.12784576},
	[86] = {335,335,112,130,228,100,162,130,228,100},
	[87] = {430,430,143,166,290,128,208,166,290,128},
	[88] = {545,545,182,211,370,163,264,211,370,163},
	[89] = {700,700,233,269,470,208,336,269,470,208},
	[90] = {885,885,295,340,600,265,425,340,600,265},
}
