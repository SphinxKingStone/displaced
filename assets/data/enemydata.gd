extends Node


var predeterminatedgroups = {
	forestboss = {weight = 0.1, group = {5 : 'bigtreant'}, code = 'forestboss', music = 'boss'},
	caveboss = {weight = 0.1, group = {2 : 'earthgolemboss'}, code = 'caveboss', music = 'boss'},
	
	
	
}

var randomgroups = {
	foresteasy = {units = {elvenrat = [1,2]}, weight = 1, code = 'foresteasy', reqs = [{type = "party_level", operant = "lte", value = 3}]},
	foresteasymed = {units = {elvenrat = [2,4]}, weight = 1, code = 'foresteasymed', reqs = []},
	forestmedium = {units = {elvenrat = [1,3], treant = [0,1]}, weight = 1, code = 'forestmedium',reqs = [{type = "party_level", operant = "gte", value = 2}]},
	forestmedium2 = {units = {elvenrat = [1,2], treant = [1,2]}, weight = 1, code = 'forestmedium2',reqs = [{type = "party_level", operant = "gte", value = 2}]},
	foresthard = {units = {treant = [2,3], elvenrat = [1,2]}, weight = 1, code = 'foresthard',reqs = [{type = "party_level", operant = "gte", value = 5}]},
	foresthard2 = {units = {spider = [1,2], treant = [1,2]}, weight = 1, code = 'foresthard2',reqs = [{type = "party_level", operant = "gte", value = 4}]},
	foresthard3 = {units = {fairies = [1,1], treant = [1,2]}, weight = 1, code = 'foresthard3',reqs = [{type = "party_level", operant = "gte", value = 4}]},
	forestextraboss = {units = {bigtreant = [1,1], treant = [1,2]}, weight = 0.2, code = 'forestextraboss',reqs = [{type = "party_level", operant = "gte", value = 8}]},
	
	#caves
	
	caveeasy = {units = {spider = [1,2]}, weight = 1, code = 'caveeasy',reqs = [{type = "party_level", operant = "lte", value = 4}]},
	cavemedium = {units = {spider = [1,2], earthgolem = [1,2]}, weight = 1, code = 'cavemedium',reqs = [{type = "party_level", operant = "gte", value = 4}]},
	cavemedium2 = {units = {earthgolem = [1,2], angrydwarf = [1,1]}, weight = 1, code = 'cavemedium2',reqs = [{type = "party_level", operant = "gte", value = 4}]},
	cavemedium3 = {units = {angrydwarf = [2,2]}, weight = 1, code = 'cavemedium3',reqs = [{type = "party_level", operant = "gte", value = 5}]},
	
}

var enemylist = {
	elvenrat = {
		code = 'elvenrat',
		name = '',
		flavor = '',
		race = 'animal',
		skills = ['attack'],
		basehp = 130,
		damage = 25,
		resists = {slash = -50, bludgeon = 50, earth = 50, water = -100, light = -100, dark = 50},
		xpreward = 10,
		bodyhitsound = 'flesh',
		base_dmg_type = 'pierce',
		traits = [],
		combaticon = 'enemies/ElvenratCombatIcon',
		bodyimage = null,
		aiposition = 'melee',
		loottable = 'elvenratloot',
		weaponsound = 'elvenrat at',
		animations = {
			idle = "Fight/Fight_spritesFHD_0000s_0000s_0002_Rat_idle",
			hit = "Fight/Fight_spritesFHD_0000s_0000s_0001_Rat_hit",
			attack = "Fight/Fight_spritesFHD_0000s_0000s_0000_Rat_at",
#			idle_1 = "res://assets/images/Fight/Fight_spritesFHD_0000s_0000s_0002_Rat_idle.png"
		},
	},
	mole = { #copied from rat fully!!!
		code = 'mole',
		name = '',
		flavor = '',
		race = 'animal',
		skills = ['attack'],
		basehp = 130,
		damage = 30,
		resists = {slash = -50, bludgeon = 50, earth = 50, water = -100, light = -100, dark = 50},
		xpreward = 10,
		bodyhitsound = 'flesh',
		base_dmg_type = 'pierce',
		traits = [],
		combaticon = 'enemies/MoleCombatIcon',
		bodyimage = null,
		aiposition = 'melee',
		loottable = 'moleloot',
		weaponsound = 'mole at',
		animations = {
			idle = "Fight/Fight_spritesFHD_0007s_0000_mole_idle",
			hit = "Fight/Fight_spritesFHD_0007s_0002_mole_hit",
			attack = "Fight/Fight_spritesFHD_0007s_0001_mole_at",
#			idle_1 = "res://assets/images/Fight/Fight_spritesFHD_0000s_0000s_0002_Rat_idle.png"
		},
	},
	vulture = { #copied from rat fully!!!
		code = 'vulture',
		name = '',
		flavor = '',
		race = 'animal',
		skills = ['attack'],
		basehp = 124,
		damage = 56,
		resists = {slash = -50, bludgeon = 50, earth = 50, water = -100, light = -100, dark = 50},
		xpreward = 10,
		bodyhitsound = 'flesh',
		base_dmg_type = 'pierce',
		traits = [],
		combaticon = 'enemies/VultureCombatIcon',
		bodyimage = null,
		aiposition = 'melee',
		loottable = 'vultureloot',
		weaponsound = 'vulture at',
		animations = {
			idle = "Fight/Fight_spritesFHD_0005s_0000_vulture_idle",
			hit = "Fight/Fight_spritesFHD_0005s_0000_vulture_hit",
			attack = "Fight/Fight_spritesFHD_0005s_0000_vulture_at",
#			idle_1 = "res://assets/images/Fight/Fight_spritesFHD_0000s_0000s_0002_Rat_idle.png"
		},
	},
	treant = {
		code = 'treant',
		name = '',
		flavor = '',
		race = 'plant',
		skills = ['attack', 'earth_attack'],
		basehp = 111,
		damage = 27,
		resists = {slash = 50, pierce = 50, fire = -100, earth = 50, water = 150, air = -100, light = 50},
		xpreward = 10,
		bodyhitsound = 'flesh',
		base_dmg_type = 'bludgeon',
		traits = [],
		combaticon = 'enemies/TreantCombatIcon',
		bodyimage = null,
		aiposition = 'melee',
		loottable = 'treantloot',
		weaponsound = 'treant at',
		animations = {
			idle = "Fight/Fight_spritesFHD_0000s_0003s_0002_Treant_idle",
			hit = "Fight/Fight_spritesFHD_0000s_0003s_0001_Treant_hit",
			attack = "Fight/Fight_spritesFHD_0000s_0003s_0000_Treant_at",
		},
	},
	faery = {
		code = 'faery',
		name = '',
		flavor = '',
		race = 'humanoid',
		skills = ['attack', 'fire_attack_small', 'f_heal'],
		basehp = 86,
		damage = 35,
		resists = {pierce = -100, bludgeon = 50, earth = 50, water = -100, light = -100},
		xpreward = 10,
		bodyhitsound = 'flesh',
		base_dmg_type = 'air',
		traits = [],
		combaticon = 'enemies/FaeryCombatIcon',
		bodyimage = null,
		aiposition = 'melee',
		loottable = 'faeryloot',
		weaponsound = 'fairy at',
		animations = {
			idle = "Fight/Fight_spritesFHD_0001s_0002_Fairy_idle",
			hit = "Fight/Fight_spritesFHD_0001s_0001_Fairy_hit",
			attack = "Fight/Fight_spritesFHD_0001s_0000_Fairy_at",
		},
	},
	faery_2 = {
		code = 'faery_2',
		name = '',
		flavor = '',
		race = 'humanoid',
		skills = ['attack', 'fire_attack_small'],
		basehp = 55,
		damage = 61,
		resists = {pierce = -100, bludgeon = 50, earth = 50, water = -100, light = -100},
		xpreward = 10,
		bodyhitsound = 'flesh',
		base_dmg_type = 'air',
		traits = [],
		combaticon = '',
		bodyimage = null,
		aiposition = 'melee',
		loottable = 'faeryloot_2',
		weaponsound = 'fairy at',
		animations = {
			idle = "Fight/Fight_spritesFHD_0002s_0002_fairyalt_idle",
			hit = "Fight/Fight_spritesFHD_0002s_0001_fairyalt_hit",
			attack = "Fight/Fight_spritesFHD_0002s_0000_fairyalt_at",
		},
	},
	spider = {
		code = 'spider',
		name = '',
		flavor = "",
		race = 'insect',
		skills = ['attack', 'poison_spit'],
		basehp = 90,
		damage = 45,
		resists = {slash = -50, pierce = 50, fire = -100, air = -50, dark = 50},
		xpreward = 10,
		bodyhitsound = 'flesh',
		base_dmg_type = 'pierce',
		traits = [],
		combaticon = 'enemies/SpiderCombatIcon',
		bodyimage = null,
		aiposition = 'melee',
		loottable = 'spiderloot',
		weaponsound = 'spider at',
		animations = {
			idle = "Fight/Fight_spritesFHD_0000s_0002s_0002_Spider_idle",
			hit = "Fight/Fight_spritesFHD_0000s_0002s_0000_Spider_hit",
			attack = "Fight/Fight_spritesFHD_0000s_0002s_0001_Spider_at",
		},
	},
	spider_2 = {
		code = 'spider_2',
		name = '',
		flavor = "",
		race = 'insect',
		skills = ['attack', 'poison_spit'],
		basehp = 75,
		damage = 55,
		resists = {slash = -50, pierce = 50, fire = -100, air = -50, dark = 50},
		xpreward = 10,
		bodyhitsound = 'flesh',
		base_dmg_type = 'pierce',
		traits = [],
		combaticon = 'enemies/Spider_2CombatIcon',
		bodyimage = null,
		aiposition = 'melee',
		loottable = 'spiderloot_2',
		weaponsound = 'spider at',
		animations = {
			idle = "Fight/Fight_spritesFHD_0001s_0002_spideralt_idle",
			hit = "Fight/Fight_spritesFHD_0001s_0000_spideralt_hit",
			attack = "Fight/Fight_spritesFHD_0001s_0001_spideralt_at",
		},
	},
	
	earthgolem = {
		code = 'earthgolem',
		name = "",
		flavor = "",
		race = 'rock',
		skills = ['attack', 'earth_aoe'],
		basehp = 160,
		damage = 37,
		resists = {slash = 50, pierce = 50, bludgeon = -50, earth = 150, water = -100, air = 50, light = 50, dark = 50},
		xpreward = 10,
		bodyhitsound = 'flesh',
		base_dmg_type = 'earth',
		traits = [],
		combaticon = 'enemies/EarthgolemCombatIcon',
		bodyimage = null,
		aiposition = 'melee',
		loottable = 'earthgolemloot',
		weaponsound = 'golem at',
		animations = {
			idle = "Fight/Fight_spritesFHD_0000s_0001s_0002_Golem_idle",
			hit = "Fight/Fight_spritesFHD_0000s_0001s_0001_Golem_hit",
			attack = "Fight/Fight_spritesFHD_0000s_0001s_0000_Golem_at",
		},
	},
	angrydwarf = {
		code = 'angrydwarf',
		name = "",
		flavor = "",
		race = 'humanoid',
		skills = ['attack', 'earth_attack'],
		basehp = 152,
		damage = 51,
		resists = {slash = -50, bludgeon = 50, fire = -100, earth = 50, water = -100, dark = -100},
		xpreward = 10,
		bodyhitsound = 'flesh',
		base_dmg_type = 'slash',
		traits = ['dw_enrage'],
		combaticon = 'enemies/AngrydwarfCombatIcon',
		bodyimage = null,
		aiposition = 'melee',
		loottable = 'angrydwarfloot',
		weaponsound = 'dwarf at',
		animations = {
			idle = "Fight/Fight_spritesFHD_0003s_0002_Dwarf2_idle",
			hit = "Fight/Fight_spritesFHD_0003s_0000_Dwarf2_hit",
			attack = "Fight/Fight_spritesFHD_0003s_0001_Dwarf2_at",
		},
	},
	dwarfwarrior = {
		code = 'dwarfwarrior',
		name = "",
		flavor = "",
		race = 'humanoid',
		skills = ['attack', 'earth_attack'],
		basehp = 184,
		damage = 37,
		resists = {slash = 100, pierce = 50, bludgeon = -50, earth = 100, water = -50, air = -100, light = -100},
		xpreward = 10,
		bodyhitsound = 'flesh',
		base_dmg_type = 'slash',
		traits = ['dw_enrage'],
		combaticon = 'enemies/DwarfwarriorCombatIcon',
		bodyimage = null,
		aiposition = 'melee',
		loottable = 'dwarfwarriorloot',
		weaponsound = 'dwarf attack armor',
		animations = {
			idle = "Fight/Fight_spritesFHD_0004s_0002_Dwarf1_idle",
			hit = "Fight/Fight_spritesFHD_0004s_0000_Dwarf1_hit",
			attack ="Fight/Fight_spritesFHD_0004s_0001_Dwarf1_at" ,
		},
	},
	zombie = {
		code = 'zombie',
		name = "",
		flavor = "",
		race = 'undead',
		skills = ['attack', 'poison_breath'],
		basehp = 142,
		damage = 40,
		resists = {slash = -50, pierce = 50, bludgeon = 100, fire = -100, earth = 50, water = 100, light = -100},
		xpreward = 10,
		bodyhitsound = 'flesh',
		base_dmg_type = 'bludgeon',
		traits = [],
		combaticon = 'enemies/ZombieCombatIcon',
		bodyimage = null,
		aiposition = 'melee',
		loottable = 'zombieloot',
		weaponsound = 'zombie at',
		animations = {
			idle ="Fight/Fight_spritesFHD_0002s_0002_Zombieidle" ,
			hit = "Fight/Fight_spritesFHD_0002s_0000_Zombie_hit",
			attack = "Fight/Fight_spritesFHD_0002s_0001_Zombie_at",
		},
	},
	skeleton_warrior = {
		code = 'skeleton_warrior',
		name = "",
		flavor = "",
		race = 'undead',
		skills = ['attack', 'air_attack', 'dark_attack'],
		basehp = 132,
		damage = 45,
		resists = {pierce = 100, bludgeon = -100, fire = 50, earth = -100, water = -100, air = -100, light = -100},
		xpreward = 10,
		bodyhitsound = 'flesh',
		base_dmg_type = 'slash',
		traits = ['wounds'],
		combaticon = 'enemies/Skeleton_warriorCombatIcon',
		bodyimage = null,
		aiposition = 'melee',
		loottable = 'skeletonwarriorloot',
		weaponsound = 'skeleton warrior at',
		animations = {
			idle = "Fight/Fight_spritesFHD_0000s_0002_Skelet_warrior_idle",
			hit = "Fight/Fight_spritesFHD_0000s_0000_Skelet_warrior_hit",
			attack = "Fight/Fight_spritesFHD_0000s_0001_Skelet_warrior_at",
		},
	},
	skeleton_archer = {
		code = 'skeleton_archer',
		name = "",
		flavor = "",
		race = 'undead',
		skills = ['attack', 'fire_attack', 'dark_attack'],
		basehp = 117,
		damage = 62,
		resists = {pierce = 100, bludgeon = -100, fire = 50, earth = -100, water = -100, air = -100, light = -100},
		xpreward = 10,
		bodyhitsound = 'flesh',
		base_dmg_type = 'pierce',
		base_dmg_range = 'any',
		traits = [],
		combaticon = 'enemies/Skeleton_archerCombatIcon',
		bodyimage = null,
		aiposition = 'ranged',
		loottable = 'skeletonarcherloot',
		weaponsound = 'arrow_shot',
		animations = {
			idle = "Fight/Fight_spritesFHD_0005s_0002_Archer_idle",
			hit = "Fight/Fight_spritesFHD_0005s_0000_Archer_hit",
			attack = "Fight/Fight_spritesFHD_0005s_0001_Archer_at",
		},
	},
	wraith = { #animations copied
		code = 'wraith',
		name = "",
		flavor = "",
		race = 'undead',
		skills = ['attack', 'air_attack'],
		basehp = 98,
		damage = 65,
		resists = {slash = 100, pierce = 100, bludgeon = 100, fire = -100, earth = 100, water = -100, air = -100, light = -100, dark = 100},
		xpreward = 10,
		bodyhitsound = 'flesh',
		base_dmg_type = 'dark',
		traits = [],
		combaticon = 'enemies/WraithCombatIcon',
		bodyimage = null,
		aiposition = 'melee',
		loottable = 'wraithloot',
		weaponsound = 'wraith at',
		animations = {
			idle = "Fight/Fight_spritesFHD_0006s_0000_wraith_idle",
			hit = "Fight/Fight_spritesFHD_0006s_0000_wraith_hit",
			attack ="Fight/Fight_spritesFHD_0006s_0000_wraith_at" ,
		},
	},
	cult_soldier = { #sprites copied
		code = 'cult_soldier',
		name = "",
		flavor = "",
		race = 'humanoid',
		skills = ['attack', 'light_attack', 'pierce_attack', 'guard'],
		basehp = 106,
		damage = 58,
		resists = {slash = 50, pierce = -50, fire = 50, earth = -100, light = -100, dark = 50},
		xpreward = 10,
		bodyhitsound = 'flesh',
		base_dmg_type = 'slash',
		traits = [],
		combaticon = 'enemies/Cult_soldierCombatIcon',
		bodyimage = null,
		aiposition = 'melee',
		loottable = 'cultsoldierloot',
		weaponsound = 'slash',
		animations = {
			idle = "Fight/Fight_spritesFHD_0008s_0000_cultsoldier_idle",
			hit = "Fight/Fight_spritesFHD_0008s_0000_cultsoldier_hit",
			attack = "Fight/Fight_spritesFHD_0008s_0000_cultsoldier_at",
		},
	},
	cult_mage = { #sprites copied
		code = 'cult_mage',
		name = "",
		flavor = "",
		race = 'humanoid',
		skills = ['attack', 'fire_attack_cast', 'c_heal'],
		basehp = 90,
		damage = 65,
		resists = {slash = -100, bludgeon = 50, fire = 50, earth = -50, water = 50, air = -50, light = 100, dark = -100},
		xpreward = 10,
		bodyhitsound = 'flesh',
		base_dmg_type = 'air',
		base_dmg_range = 'any',
		traits = [],
		combaticon = 'enemies/Cult_mageCombatIcon',
		bodyimage = null,
		aiposition = 'ranged',
		loottable = 'cultmageloot',
		animations = {
			idle = "Fight/Fight_spritesFHD_0003s_0000_culthealer_idle",
			hit = "Fight/Fight_spritesFHD_0003s_0000_culthealer_hit",
			attack ="Fight/Fight_spritesFHD_0003s_0000_culthealer_at" ,
			cast ="Fight/Fight_spritesFHD_0003s_0000_culthealer_cast" ,
		},
	},
	cult_archer = { #sprites copied
		code = 'cult_archer',
		name = "",
		flavor = "",
		race = 'humanoid',
		skills = ['attack', 'fire_attack', 'c_heal_archer'],
		basehp = 112,
		damage = 51,
		resists = {slash = -100, pierce = 50, fire = -100, earth = 50, water = 100, air = -100, light = -100},
		xpreward = 10,
		bodyhitsound = 'flesh',
		base_dmg_type = 'pierce',
		base_dmg_range = 'any',
		traits = [],
		combaticon = 'enemies/Cult_archerCombatIcon',
		bodyimage = null,
		aiposition = 'ranged',
		loottable = 'cultarcherloot',
		weaponsound = 'arrow_shot',
		animations = {
			idle = "Fight/Fight_spritesFHD_0004s_0000_cultarcher_idle",
			hit = "Fight/Fight_spritesFHD_0004s_0000_cultarcher_hit",
			attack = "Fight/Fight_spritesFHD_0004s_0000_cultarcher_at",
		},
	},
	hatchling = {
		code = 'hatchling',
		name = "",
		flavor = "",
		race = 'dragon',
		skills = ['attack', 'fire_breath'],
		basehp = 120,
		damage = 45,
		resists = {slash = -100, bludgeon = 50, fire = 100, earth = -100, water = -100, air = 50, light = -100, dark = 50},
		xpreward = 10,
		bodyhitsound = 'flesh',
		base_dmg_type = 'fire',
		traits = [],
		combaticon = 'enemies/HatchlingCombatIcon',
		bodyimage = null,
		aiposition = 'melee',
		loottable = 'hatchlingloot',
		weaponsound = 'hatchling at',
		animations = {
			idle = "Fight/Fight_spritesFHD_0000s_0004s_0002_Dragon_idle",
			hit ="Fight/Fight_spritesFHD_0000s_0004s_0000_Dragon_hit" ,
			attack = "Fight/Fight_spritesFHD_0000s_0004s_0001_Dragon_at",
		},
	},
	wyvern = {
		code = 'wyvern',
		name = "",
		flavor = "",
		race = 'dragon',
		skills = ['attack', 'fire_breath', 'tail_swipe'],
		basehp = 150,
		damage = 55,
		resists = {slash = 50, pierce = -100, bludgeon = 50, fire = 50, earth = 50, water = -100, air = -100, light = 50, dark = -100},
		xpreward = 10,
		bodyhitsound = 'flesh',
		base_dmg_type = 'pierce',
		traits = [],
		combaticon = 'enemies/WyvernCombatIcon',
		bodyimage = null,
		aiposition = 'melee',
		loottable = 'wyvernloot',
		weaponsound = 'wyvern at',
		animations = {
			idle = "Fight/Fight_spritesFHD_0000s_0007s_0002_Wyvern_idle",
			hit = "Fight/Fight_spritesFHD_0000s_0007s_0000_Wyvern_hit",
			attack = "Fight/Fight_spritesFHD_0000s_0007s_0001_Wyvern_at",
		},
	},
	armored_beast = {
		code = 'armored_beast',
		name = "",
		flavor = "",
		race = 'animal',
		skills = ['attack', 'earth_attack', 'roar'],
		basehp = 180,
		damage = 44,
		resists = {slash = 100, bludgeon = -100, fire = -100, earth = 100, water = -100, air = 100, light = -100, dark = 50},
		xpreward = 10,
		bodyhitsound = 'flesh',
		base_dmg_type = 'bludgeon',
		traits = [],
		combaticon = 'enemies/Armored_beastCombatIcon',
		bodyimage = null,
		aiposition = 'melee',
		loottable = 'armoredbeastloot',
		weaponsound = 'tortle at',
		animations = {
			idle = "Fight/Fight_spritesFHD_0000s_0005s_0002_Tortle_idle",
			hit = "Fight/Fight_spritesFHD_0000s_0005s_0001_Tortle_hit",
			attack = "Fight/Fight_spritesFHD_0000s_0005s_0000_Tortle_at",
		},
	},
	giant_toad = {
		code = 'giant_toad',
		name = "",
		flavor = "",
		race = 'animal',
		skills = ['attack', 'poison_spit', 'waterspray'],
		basehp = 130,
		damage = 52,
		resists = {pierce = 50, bludgeon = -100, fire = 50, earth = -100, water = 100, air = -100, light = 50, dark = -100},
		xpreward = 10,
		bodyhitsound = 'flesh',
		base_dmg_type = 'water',
		traits = [],
		combaticon = 'enemies/Giant_toadCombatIcon',
		bodyimage = null,
		aiposition = 'melee',
		loottable = 'gianttoadloot',#or not - not used
		weaponsound = 'toad at',
		animations = {
			idle = "Fight/Fight_spritesFHD_0000s_0006s_0002_Toad_idle",
			hit = "Fight/Fight_spritesFHD_0000s_0006s_0001_Toad_hit",
			attack = "Fight/Fight_spritesFHD_0000s_0006s_0000_Toad_at",
		},
	},
	demon1 = {
		code = 'demon1',
		name = "",
		flavor = "",
		race = 'demon',
		skills = ['attack', 'heavystrike'],
		basehp = 150,
		damage = 66,
		resists = {slash = 50, pierce = -100, bludgeon = 50, fire = 0, earth = 50, water = 50, air = -100, light = -100, dark = 50},
		xpreward = 10,
		bodyhitsound = 'flesh',
		base_dmg_type = 'slash',
		traits = [],
		combaticon = '',
		bodyimage = null,
		aiposition = 'melee',
		loottable = 'demon1loot',
		weaponsound = 'demon at',
		animations = {
			idle = "Fight/Demon_idle",
			hit = "Fight/Demon_hit",
			attack = "Fight/Demon_at",
		},
	},
	demon2 = {
		code = 'demon2',
		name = "",
		flavor = "",
		race = 'demon',
		skills = ['attack', 'fire_attack', 'impale'],
		basehp = 190,
		damage = 48,
		resists = {slash = -100, pierce = 100, bludgeon = -100, fire = 50, earth = -100, water = -100, air = 50, light = -100, dark = 100},
		xpreward = 10,
		bodyhitsound = 'flesh',
		base_dmg_type = 'dark',
		traits = [],
		combaticon = '',
		bodyimage = null,
		aiposition = 'melee',
		loottable = 'demon2loot',
		weaponsound = 'demon at',
		animations = {
			idle = "Fight/Fight_spritesFHD_0000s_0002_Demonalt_idle",
			hit = "Fight/Fight_spritesFHD_0000s_0000_Demonalt_hit",
			attack = "Fight/Fight_spritesFHD_0000s_0001_Demonalt_at",}
	},
	soldier = {
		code = 'soldier',
		name = "",
		flavor = "",
		race = 'humanoid',
		skills = ['attack', 'light_attack'],
		basehp = 180,
		damage = 70,
		resists = {slash = -100, pierce = 50, bludgeon = -50, fire = 50, earth = -100, water = 100, air = 50, light = 50, dark = -50},
		xpreward = 10,
		bodyhitsound = 'flesh',
		base_dmg_type = 'pierce',
		traits = [],
		combaticon = 'enemies/SoldierCombatIcon',
		bodyimage = null,
		aiposition = 'melee',
		loottable = 'soldierloot',
		weaponsound = 'soldier at',
		animations = {
			idle = "Fight/Fight_spritesFHD_0004s_0002_Specnaz_idle (1)",
			hit = "Fight/Fight_spritesFHD_0004s_0000_Specnaz_hit (1)",
			attack = "Fight/Fight_spritesFHD_0004s_0001_Specnaz_at (1)",
		},
	},
	
	drone = {
		code = 'drone',
		name = "",
		flavor = "",
		race = 'humanoid',
		skills = ['attack', 'light_attack'],
		basehp = 210,
		damage = 60,
		resists = {slash = -50, pierce = 50, bludgeon = 100, fire = -100, earth = 100, water = -50, air = -100, light = 50, dark = 50},
		xpreward = 10,
		bodyhitsound = 'flesh',
		base_dmg_type = 'pierce',
		traits = [],
		combaticon = 'enemies/DroneCombatIcon',
		bodyimage = null,
		aiposition = 'melee',
		loottable = 'droneloot',
		weaponsound = 'drone at',
		animations = {
			idle = "Fight/Fight_spritesFHD_0002s_0002_Dron_idle (1)",
			hit = "Fight/Fight_spritesFHD_0002s_0000_Dron_hit (1)",
			attack = "Fight/Fight_spritesFHD_0002s_0001_Dron_at (1)",
		},
	},
	
	bomber = {
		code = 'bomber',
		name = tr("MONSTERELVENRAT"),
		flavor = tr("MONSTERELVENRATFLAVOR"),
		race = 'animal',
		skills = ['attack'],
		passives = [],
		basehp = 50,
		basemana = 0,
		armor = 0,
		armorpenetration = 0,
		mdef = 0,
		evasion = 0,
		hitrate = 80,
		damage = 15,
		speed = 50,
		resists = {},
		xpreward = 10,
		
		bodyhitsound = 'flesh',
		traits = ['unstable'],
		combaticon = 'enemies/BomberCombatIcon',
		bodyimage = null,
		aiposition = 'melee',
		loottable = '',
		animations = {
			idle = "Fight/Bosses/Zombie/Fight_spritesFHD_0001s_0002_Zombie_boom_idle",
			hit = "Fight/Bosses/Zombie/Fight_spritesFHD_0001s_0001_Zombie_boom_hit",
			attack = "Fight/Bosses/Zombie/Fight_spritesFHD_0001s_0000_Zombie_boom_at",
#			dead = load("res://assets/images/Fight/Bosses/Zombie/Zombie_boom_sq/Zombie_explode.tres")
		},
	},
	#bosses
	bigtreant = {
		code = 'bigtreant',
		name = "",
		flavor = "",
		race = 'plant',
		skills = ['attack', 'treant_summon'],
		passives = [],
		basehp = 720,
		basemana = 100,
		armor = 0,
		armorpenetration = 0,
		mdef = 0,
		evasion = 0,
		hitrate = 70,
		damage = 73,
		speed = 20,
		resists = {},
		xpreward = 50,
		ai = load('res://files/ai_classes/big_treant.gd'),
		bodyhitsound = 'wood',
		
		combaticon = 'enemies/BigtreantCombatIcon',
		bodyimage = null,
		aiposition = 'ranged',
		loottable = 'bigtreantloot',
		weaponsound = 'ent at boss',
		animations = {
			idle = load("res://assets/images/Fight/Bosses/Ent_boss_sqq/Ent.tres"),
			hit = "Fight/Bosses/Ent_hit",
			attack = "Fight/Bosses/Ent_at",
		},
		traits = ['summoner']
	},
	earthgolemboss = { #animations copied from regulal version!!!
		code = 'earthgolemboss',
		name = "",
		flavor = "",
		race = 'rock',
		skills = ['attack'], #'golemattack'], stop giving nonexistant skills!
		passives = [],
		traits = [],
		basehp = 470,
		basemana = 0,
		armor = 35,
		armorpenetration = 0,
		mdef = 15,
		evasion = 0,
		hitrate = 95,
		damage = 100,
		speed = 30,
		resists = {earth = 50, air = 25},
		xpreward = 50,
		
		bodyhitsound = 'stone',
		
		combaticon = 'enemies/EarthgolemCombatIcon',
		bodyimage = null,
		aiposition = 'melee',
		loottable = 'earthgolembossloot',
		animations = {
			idle = "Fight/Fight_spritesFHD_0000s_0001s_0002_Golem_idle",
			hit = "Fight/Fight_spritesFHD_0000s_0001s_0001_Golem_hit",
			attack = "Fight/Fight_spritesFHD_0000s_0001s_0000_Golem_at",
		}
	},
	dwarvenking = { #stats copied from above!!! animation copied from regular warrior!!!! passives not set up
		code = 'dwarvenking',
		name = "",
		flavor = "",
		race = 'rock',
		skills = [],
		passives = [],
		traits = [],
		basehp = 430,
		basemana = 0,
		armor = 35,
		armorpenetration = 0,
		mdef = 15,
		evasion = 0,
		hitrate = 95,
		damage = 74,
		speed = 30,
		resists = {earth = 50, air = 25},
		xpreward = 50,
		ai = load('res://files/ai_classes/dk.gd'),
		bodyhitsound = 'stone',
		
		combaticon = 'enemies/DwarvenkingCombatIcon',
		bodyimage = null,
		aiposition = 'melee',
		loottable = 'dwarvenkingloot',
		animations = {
			idle = "Fight/Fight_spritesFHD_0004s_0002_Dwarf1_idle",
			hit = "Fight/Fight_spritesFHD_0004s_0000_Dwarf1_hit",
			attack ="Fight/Fight_spritesFHD_0004s_0001_Dwarf1_at" ,
		},
	},
	fearyqueen = { #stats copied from above!!!  
		code = 'fearyqueen',
		name = "",
		flavor = "",
		race = 'rock',
		skills = [],
		passives = [],
		traits = ['fq_armor', 'summoner'],
		basehp = 1000,
		basemana = 0,
		armor = 35,
		armorpenetration = 0,
		mdef = 15,
		evasion = 0,
		hitrate = 95,
		damage = 90,
		speed = 30,
		resists = {earth = 50, air = 25},
		xpreward = 50,
		ai = load('res://files/ai_classes/faery_queen.gd'),
		bodyhitsound = 'stone',

		combaticon = 'enemies/FearyqueenCombatIcon',
		bodyimage = null,
		aiposition = 'melee',
		loottable = 'fearyqueenloot',
		animations = {
			idle = load("res://assets/images/Fight/Bosses/Fairy_sq/FairyQueen.tres"),
			hit = "Fight/Bosses/Queen_fairy_hit",
			attack ="Fight/Bosses/Queen_fairy_cast" ,
		},
	},
	dragon_boss = { #stats copied from above!!!  skills copied from wyvern
		code = 'dragon_boss',
		name = "",
		flavor = "",
		race = 'dragon',
		skills = ['attack', 'fire_breath_drag_boss', 'tail_swipe'],
		passives = [],
		traits = [],
		basehp = 1300,
		basemana = 0,
		armor = 35,
		armorpenetration = 0,
		mdef = 15,
		evasion = 0,
		hitrate = 95,
		damage = 70,
		speed = 30,
		resists = {earth = 50, air = 25},
		xpreward = 50,
		bodyhitsound = 'stone',

		combaticon = 'enemies/Dragon_bossCombatIcon',
		bodyimage = null,
		aiposition = 'melee',
		loottable = 'dragonbossloot',
		weaponsound = 'dragon at boss',
		animations = {
			idle = load("res://assets/images/Fight/Bosses/Dragon_idle_sq/Dragon.tres"),
			hit = "Fight/Bosses/Dragon_hit",
			attack ="Fight/Bosses/Dragon_at" ,
			cast ="Fight/Bosses/Dragon_cast" ,
		},
	},
	viktor_boss = { #stats copied from above!!!
		code = 'dragon_boss',
		name = "",
		flavor = "",
		race = 'humanoid',
		skills = [],
		passives = [],
		traits = [],
		basehp = 450,
		basemana = 0,
		armor = 35,
		armorpenetration = 0,
		mdef = 15,
		evasion = 0,
		hitrate = 95,
		damage = 100,
		speed = 30,
		resists = {earth = 50, air = 25},
		xpreward = 50,
		bodyhitsound = 'stone',
		ai = load('res://files/ai_classes/viktor.gd'),
		combaticon = 'enemies/Viktor_bossCombatIcon',
		bodyimage = null,
		aiposition = 'melee',
		loottable = 'viktorbossloot',
		weaponsound = 'viktor at',
		animations = {
			idle = load("res://assets/images/Fight/Bosses/Viktor_sq_idle/Viktor.tres"),
			hit = "Fight/Bosses/Viktor_hit",
			attack ="Fight/Bosses/Viktor_at" ,
			special ="Fight/Bosses/Viktor_sp_at" ,
		},
	},
	annet = { #stats copied from above!!!
		code = 'annet',
		name = "",
		flavor = "",
		race = 'humanoid',
		skills = ['an_attack', 'an_charm', 'an_summon', 'an_poison_mist', 'an_light_2_rand'],
		passives = [],
		traits = [],
		basehp = 1200,
		basemana = 0,
		armor = 35,
		armorpenetration = 0,
		mdef = 15,
		evasion = 0,
		hitrate = 95,
		damage = 110,
		speed = 30,
		resists = {earth = 50, air = 25},
		xpreward = 50,
		bodyhitsound = 'stone',
		ai = load('res://files/ai_classes/annet.gd'),
		combaticon = 'enemies/AnnetCombatIcon',
		bodyimage = null,
		aiposition = 'melee',
		loottable = 'annetloot',
		weaponsound = 'sukkub at',
		animations = {
			idle = load("res://assets/images/Fight/Bosses/Sukkub_sq_anim/Succubus.tres"),
			hit = "Fight/Bosses/Sukkub_hit",
			attack ="Fight/Bosses/Sukkub_at" ,
			special ="Fight/Bosses/Sukkub_cast" ,
		},
	},
	scientist_boss = {
		code = 'scientist_boss',
		name = tr("MONSTERELVENRAT"),
		flavor = tr("MONSTERELVENRATFLAVOR"),
		race = 'animal',
		skills = [], # got them from ai
		passives = [],
		basehp = 500,
		basemana = 0,
		armor = 0,
		armorpenetration = 0,
		mdef = 0,
		evasion = 0,
		hitrate = 80,
		damage = 15,
		speed = 50,
		resists = {},
		xpreward = 10,
		ai = load('res://files/ai_classes/scientist.gd'),
		
		bodyhitsound = 'flesh',
		traits = ['summoner'],
		combaticon = 'enemies/Scientist_bossCombatIcon',
		bodyimage = null,
		aiposition = 'melee',
		loottable = '',
		weaponsound = 'doc at',
		animations = {
			idle = load("res://assets/images/Fight/Bosses/Doctor_idle_sq/doc_idle.tres"),
			hit = "Fight/Bosses/Fight_spritesFHD_0000s_0001_Doc_hit",
			attack ="Fight/Bosses/Fight_spritesFHD_0000s_0000_Doc_at" ,
		},
	},
	caliban = { #stats copied from above!!!
		code = 'caliban',
		name = tr("MONSTERELVENRAT"),
		flavor = tr("MONSTERELVENRATFLAVOR"),
		race = 'animal',
		skills = ['attack'],#there are no skills for him in docs
		passives = [],
		basehp = 500,
		basemana = 0,
		armor = 0,
		armorpenetration = 0,
		mdef = 0,
		evasion = 0,
		hitrate = 80,
		damage = 15,
		speed = 50,
		resists = {},
		xpreward = 10,
		
		bodyhitsound = 'flesh',
		traits = [],
		combaticon = 'enemies/CalibanCombatIcon',
		bodyimage = null,
		aiposition = 'melee',
		loottable = '',
		weaponsound = 'caliban at',
		animations = {
			idle = load("res://assets/images/Fight/Bosses/Monster_idle_sq/monster.tres"),
			hit = "Fight/Bosses/Fight_spritesFHD_0001s_0001_Mnstr_hit",
			attack ="Fight/Bosses/Fight_spritesFHD_0001s_0000_Mnstr_at" ,
		},
	},
	demitrius1 = { #stats copied from above!!!
		code = 'demitrius1',
		name = "",
		flavor = "",
		race = 'humanoid',
		skills = ['dm_storm', 'dm_fire', 'dm_poison_spike', 'dm_bomb'],
		passives = [],
		traits = [],
		basehp = 2200,
		basemana = 0,
		armor = 35,
		armorpenetration = 0,
		mdef = 15,
		evasion = 0,
		hitrate = 95,
		damage = 95,
		speed = 30,
		resists = {earth = 50, air = 25},
		xpreward = 50,
		bodyhitsound = 'stone',

		combaticon = 'enemies/Demitrius1CombatIcon',
		bodyimage = null,
		aiposition = 'melee',
		loottable = 'demitrius1loot',
		weaponsound = 'demitrius at',
		animations = {
			idle = load("res://assets/images/Fight/Bosses/Demitrius_idle_sq/Demitrius.tres"),
			hit = "Fight/Bosses/Demitrius_hit",
			attack ="Fight/Bosses/Demitrius_at" ,
			special ="Fight/Bosses/Demitrius_cast" ,
		},
		
	},
	demitrius2 = { #stats copied from above!!!
		code = 'demitrius2',
		name = "",
		flavor = "",
		race = 'humanoid',
		skills = ['dm_storm', 'dm_nova', 'dm_form'],
		passives = [],
		traits = ['dem_rules'],
		basehp = 450,
		basemana = 0,
		armor = 35,
		armorpenetration = 0,
		mdef = 15,
		evasion = 0,
		hitrate = 95,
		damage = 100,
		speed = 30,
		resists = {earth = 50, air = 25},
		xpreward = 50,
		bodyhitsound = 'stone',
		ai = load('res://files/ai_classes/dimitrius_2.gd'),
		combaticon = 'enemies/Demitrius2CombatIcon',
		bodyimage = null,
		aiposition = 'melee',
		loottable = 'demitrius2loot',
		weaponsound = 'demitrius at',
		animations = {
			idle = load("res://assets/images/Fight/Bosses/Demitrius_idle_sq/Demitrius.tres"),
			hit = "Fight/Bosses/Demitrius_hit",
			attack ="Fight/Bosses/Demitrius_at" ,
			special ="Fight/Bosses/Demitrius_cast" ,
		},
		
	},
}







var loottables = { # no need to separate materials from usables now
	# added option to put xpreward into lootable
	elvenratloot = {
		items = [
			{code = 'item_heal_2', chance = 30},
			{code = 'stone', chance = 60}
		],
		gold = [1, 5]
	},
	moleloot = {
		items = [
			{code = 'item_heal_1', chance = 50},
			{code = 'stone', chance = 60}
		],
		gold = [10, 20]
	},
	vultureloot = {
		items = [
			{code = 'item_barrier_1', chance = 30},
			{code = 'item_barrier_2', chance = 5},
			{code = 'stone', chance = 60}
		],
		gold = [50, 60]
	},
	treantloot = {
		items = [
			{code = 'item_heal_1', chance = 30},
			{code = 'item_dispel_1', chance = 10},
			{code = 'wood', chance = 70}
		],
		gold = [1, 20]
	},
	faeryloot = {
		items = [
			{code = 'item_heal_aoe_1', chance = 30},
			{code = 'item_dispel_1', chance = 30},
			{code = 'wood', chance = 70}
		],
		gold = [20, 40]
	},
	faeryloot_2 = {
		items = [
			{code = 'item_heal_aoe_1', chance = 30},
			{code = 'item_heal_aoe_2', chance = 10},
			{code = 'item_dispel_2', chance = 20},
			{code = 'wood', chance = 70}
		],
		gold = [50, 70]
	},
	spiderloot = {
		items = [
			{code = 'chitine', chance = 45},
			{code = 'item_heal_aoe_2', chance = 10}
		],
		gold = [10, 20]
	},
	spiderloot_2 = {
		items = [
			{code = 'chitine', chance = 70},
			{code = 'item_heal_aoe_3', chance = 10}
		],
		gold = [10, 40]
	},
	earthgolemloot = {
		items = [
			{code = 'metal', chance = 45},
			{code = 'stone', chance = 45},
			{code = 'item_heal_aoe_1', chance = 10},
			{code = 'item_res_3', chance = 5}
		],
		gold = [30, 50]
	},
	angrydwarfloot = {
		items = [
			{code = 'metal', chance = 80},
			{code = 'item_heal_2', chance = 20},
			{code = 'item_barrier_2', chance = 5},
			{code = 'item_damage_1', chance = 10}
		],
		gold = [50, 70]
	},
	dwarfwarriorloot = {
		items = [
			{code = 'metal', chance = 100},
			{code = 'item_heal_2', chance = 50},
			{code = 'item_heal_3', chance = 5},
			{code = 'item_barrier_2', chance = 10},
			{code = 'item_barrier_3', chance = 5},
			{code = 'item_damage_1', chance = 20},
			{code = 'item_buff_atk', chance = 5}
		],
		gold = [80, 120]
	},
	zombieloot = {
		items = [
			{code = 'leather', chance = 50},
			{code = 'item_res_1', chance = 10},
		],
		gold = [50, 100]
	},
	skeletonwarriorloot = {
		items = [
			{code = 'leather', chance = 50},
			{code = 'item_res_1', chance = 10},
			{code = 'item_res_2', chance = 5},
		],
		gold = [50, 100]
	},
	skeletonarcherloot = {
		items = [
			{code = 'leather', chance = 50},
			{code = 'item_res_2', chance = 10},
			{code = 'item_res_3', chance = 5},
		],
		gold = [50, 100]
	},
	wraithloot = {
		items = [
			{code = 'leather', chance = 50},
			{code = 'item_res_3', chance = 10},
			{code = 'item_res_4', chance = 5},
			{code = 'item_barrier_2', chance = 10}
		],
		gold = [70, 120]
	},
	hatchlingloot = {
		items = [
			{code = 'scales', chance = 50},
			{code = 'item_heal_2', chance = 20},
			{code = 'item_heal_aoe_2', chance = 20},
			{code = 'item_barrier_1', chance = 10}
		],
		gold = [50, 100]
	},
	wyvernloot = {
		items = [
			{code = 'scales', chance = 80},
			{code = 'item_heal_2', chance = 20},
			{code = 'item_heal_aoe_3', chance = 20},
			{code = 'item_barrier_2', chance = 10}
		],
		gold = [70, 120]
	},
	armoredbeastloot = {
		items = [
			{code = 'scales', chance = 80},
			{code = 'item_heal_2', chance = 50},
			{code = 'item_heal_aoe_3', chance = 10},
			{code = 'item_barrier_2', chance = 10},
			{code = 'item_barrier_3', chance = 50}
		],
		gold = [70, 120]
	},
	gianttoadloot = {
		items = [
			{code = 'scales', chance = 50},
			{code = 'item_heal_2', chance = 50},
			{code = 'item_heal_3', chance = 5},
			{code = 'item_heal_aoe_2', chance = 10},
			{code = 'item_barrier_2', chance = 5},
		],
		gold = [70, 120]
	},
	cultsoldierloot = {
		items = [
			{code = 'otherworld', chance = 20},
			{code = 'item_heal_2', chance = 30},
			{code = 'item_heal_aoe_1', chance = 30},
			{code = 'item_dispel_1', chance = 30},
		],
		gold = [50, 100]
	},
	cultarcherloot = {
		items = [
			{code = 'otherworld', chance = 80},
			{code = 'item_heal_2', chance = 30},
			{code = 'item_heal_aoe_2', chance = 10},
			{code = 'item_barrier_2', chance = 10},
		],
		gold = [50, 100]
	},
	cultmageloot = {
		items = [
			{code = 'otherworld', chance = 100},
			{code = 'item_heal_2', chance = 30},
			{code = 'item_heal_aoe_2', chance = 30},
			{code = 'item_heal_aoe_3', chance = 5},
			{code = 'item_dispel_1', chance = 30},
			{code = 'item_dispel_2', chance = 5},
			{code = 'item_barrier_3', chance = 5},
			{code = 'item_res_1', chance = 5},
			{code = 'item_buff_atk', chance = 10},
			{code = 'item_buff_def', chance = 10}
		],
		gold = [100, 150]
	},
	demon1loot = {
		items = [
			{code = 'demonic', chance = 25},
			{code = 'item_dispel_1', chance = 20},
			{code = 'item_res_3', chance = 5},
			{code = 'item_barrier_1', chance = 10},
			{code = 'item_damage_1', chance = 10},
		],
		gold = [150, 200]
	},
	demon2loot = {
		items = [
			{code = 'demonic', chance = 50},
			{code = 'item_dispel_1', chance = 20},
			{code = 'item_res_4', chance = 5},
			{code = 'item_barrier_2', chance = 10},
			{code = 'item_damage_1', chance = 10},
		],
		gold = [150, 200]
	},
	soldierloot = {
		items = [
			{code = 'demonic', chance = 50},
			{code = 'item_heal_1', chance = 20},
			{code = 'item_heal_2', chance = 20},
			{code = 'item_damage_1', chance = 10},
			{code = 'item_damage_2', chance = 5},
		],
		gold = [150, 200]
	},
	droneloot = {
		items = [
			{code = 'demonic', chance = 50},
			{code = 'item_damage_1', chance = 10},
			{code = 'item_damage_2', chance = 5},
		],
		gold = [150, 200]
	},
	
	#bosses
	bigtreantloot = {
		items = [
			{code = 'item_heal_1', chance = 100, min = 1, max = 3},
			{code = 'item_dispel_2', chance = 100},
			{code = 'item_res_3', chance = 10},
			{code = 'item_buff_def', chance = 10},
			{code = 'wood', chance = 100, min = 1, max = 5}
		],
		gold = [100, 200]
	},
	fearyqueenloot = {
		items = [
			{code = 'item_heal_aoe_1', chance = 100},
			{code = 'item_heal_aoe_2', chance = 30},
			{code = 'item_heal_aoe_3', chance = 5},
			{code = 'item_dispel_1', chance = 70},
			{code = 'item_dispel_2', chance = 50},
			{code = 'item_res_2', chance = 80},
			{code = 'item_res_3', chance = 50},
			{code = 'wood', chance = 100, min = 1, max = 3}
		],
		gold = [100, 190]
	},
	earthgolembossloot = {
		items = [
			{code = 'metal', chance = 100, min = 1, max = 5},
			{code = 'stone', chance = 100, min = 3, max = 7},
			{code = 'item_heal_aoe_1', chance = 30},
			{code = 'item_res_3', chance = 20},
			{code = 'item_res_4', chance = 5},
			{code = 'item_barrier_1', chance = 30}
		],
		gold = [120, 200]
	},
	dwarvenkingloot = {
		items = [
			{code = 'metal', chance = 100, min = 1, max = 5},
			{code = 'item_heal_2', chance = 50},
			{code = 'item_heal_3', chance = 30},
			{code = 'item_barrier_2', chance = 30},
			{code = 'item_barrier_3', chance = 15},
			{code = 'item_damage_1', chance = 30},
			{code = 'item_damage_2', chance = 5},
			{code = 'item_buff_atk', chance = 50}
		],
		gold = [150, 220]
	},
	dragonbossloot = {
		items = [
			{code = 'scales', chance = 100, min = 1, max = 5},
			{code = 'item_heal_aoe_3', chance = 100},
			{code = 'item_barrier_2', chance = 70},
			{code = 'item_barrier_3', chance = 20},
			{code = 'item_dispel_1', chance = 100},
			{code = 'item_res_2', chance = 50},
			{code = 'item_buff_atk', chance = 5},
			{code = 'item_buff_def', chance = 5},
		],
		gold = [200, 300]
	},
	viktorbossloot = {
		items = [
			{code = 'otherworld', chance = 100, min = 1, max = 5},
			{code = 'item_heal_2', chance = 50},
			{code = 'item_heal_3', chance = 30},
			{code = 'item_heal_aoe_3', chance = 40},
			{code = 'item_dispel_1', chance = 30},
			{code = 'item_barrier_2', chance = 80},
			{code = 'item_buff_atk', chance = 10},
			{code = 'item_buff_def', chance = 10}
		],
		gold = [250, 300]
	},
	annetloot = {
		items = [
			{code = 'demonic', chance = 100, min = 1, max = 5},
			{code = 'item_dispel_1', chance = 100},
			{code = 'item_dispel_2', chance = 50},
			{code = 'item_res_3', chance = 80},
			{code = 'item_res_4', chance = 50},
			{code = 'item_barrier_2', chance = 80},
			{code = 'item_barrier_3', chance = 40}
		],
		gold = [300, 400]
	},
	demitrius1loot = {
		items = [
			{code = 'demonic', chance = 100, min = 5, max = 10},
			{code = 'item_heal_aoe_2', chance = 100},
			{code = 'item_heal_aoe_3', chance = 50},
			{code = 'item_res_1', chance = 100},
			{code = 'item_res_2', chance = 100},
			{code = 'item_res_3', chance = 50},
			{code = 'item_res_4', chance = 50},
			{code = 'item_barrier_2', chance = 100},
			{code = 'item_barrier_3', chance = 100},
			{code = 'item_buff_atk', chance = 100},
			{code = 'item_buff_def', chance = 100}
		],
		gold = [400, 500]
	},
	demitrius2loot = {
		items = [
			{code = 'demonic', chance = 100, min = 5, max = 10},
			{code = 'item_heal_aoe_3', chance = 100},
			{code = 'item_res_2', chance = 100},
			{code = 'item_res_4', chance = 100},
			{code = 'item_barrier_3', chance = 100},
			{code = 'item_buff_atk', chance = 100},
			{code = 'item_buff_def', chance = 100}
		],
		gold = [700, 1000]
	},
}


func _ready():
	for i in enemylist.values():
#		e.basehp = 1
		i.name = "MONSTER" + i.code.to_upper()
		i.flavor = "MONSTER" + i.code.to_upper() + "FLAVOR"
	yield(preload_icons(), 'completed')
	print("Enemies icons preloaded")


func preload_icons():
	for ch in enemylist.values():
#		if b.icon.begins_with("res:"): continue
		if ch.combaticon != null:
			resources.preload_res(ch.combaticon)
		if ch.bodyimage != null:
			resources.preload_res(ch.bodyimage)
		for an in ch.animations.values():
			if an is AnimatedTexAutofill:
				an.fill_frames()
			else:
				resources.preload_res(an)
		if ch.has('weaponsound'):
			resources.preload_res('sound/%s' % ch.weaponsound)
	if resources.is_busy(): yield(resources, "done_work")
