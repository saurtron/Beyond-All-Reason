return {
	corcs = {
		builddistance = 200,
		builder = true,
		buildpic = "CORCS.DDS",
		buildtime = 3700,
		canmove = true,
		collisionvolumeoffsets = "0 -1 1",
		collisionvolumescales = "30 26 47",
		collisionvolumetype = "Box",
		corpse = "DEAD",
		energycost = 2000,
		energymake = 7,
		energystorage = 50,
		explodeas = "mediumexplosiongeneric-builder",
		floater = true,
		footprintx = 3,
		footprintz = 3,
		health = 1080,
		idleautoheal = 5,
		idletime = 1800,
		maxacc = 0.03567,
		maxdec = 0.03567,
		metalcost = 200,
		minwaterdepth = 15,
		movementclass = "BOAT3",
		objectname = "Units/CORCS.s3o",
		script = "Units/CORCS.cob",
		seismicsignature = 0,
		selfdestructas = "mediumexplosiongenericSelfd-builder",
		sightdistance = 400,
		speed = 60,
		terraformspeed = 1250,
		turninplace = true,
		turninplaceanglelimit = 90,
		turnrate = 391.5,
		waterline = 0,
		workertime = 125,
		buildoptions = {
			[1] = "cormex",
			[2] = "corvp",
			[3] = "corap",
			[4] = "corlab",
			[5] = "coreyes",
			[6] = "cordl",
			[7] = "cordrag",
			[8] = "cormaw",
			[9] = "corpun",
			[10] = "cortide",
			[11] = "corgeo",
			[12] = "coruwgeo",
			[13] = "corfmkr",
			[14] = "coruwms",
			[15] = "coruwes",
			[16] = "corsy",
			[17] = "corasy",
			[18] = "cornanotcplat",
			[19] = "corfhp",
			[20] = "coramsub",
			[21] = "corplat",
			[22] = "corfrad",
			[23] = "corfdrag",
			[24] = "cortl",
			[25] = "corfrt",
			[26] = "corfhlt",
		},
		customparams = {
			model_author = "Mr Bob",
			normaltex = "unittextures/cor_normal.dds",
			subfolder = "CorShips",
			unitgroup = "builder",
		},
		featuredefs = {
			dead = {
				blocking = false,
				category = "corpses",
				collisionvolumeoffsets = "0.0 0.0 0.0374984741211",
				collisionvolumescales = "45.9999694824 17.25 80.0749969482",
				collisionvolumetype = "Box",
				damage = 1380,
				featuredead = "HEAP",
				footprintx = 5,
				footprintz = 5,
				height = 4,
				metal = 100,
				object = "Units/corcs_dead.s3o",
				reclaimable = true,
			},
			heap = {
				blocking = false,
				category = "heaps",
				damage = 4032,
				footprintx = 2,
				footprintz = 2,
				height = 4,
				metal = 50,
				object = "Units/cor5X5C.s3o",
				reclaimable = true,
				resurrectable = 0,
			},
		},
		sfxtypes = {
			explosiongenerators = {
				[1] = "custom:waterwake-small",
			},
			pieceexplosiongenerators = {
				[1] = "deathceg2-builder",
				[2] = "deathceg3-builder",
				[3] = "deathceg4-builder",
			},
		},
		sounds = {
			build = "nanlath2",
			canceldestruct = "cancel2",
			repair = "repair2",
			underattack = "warning1",
			working = "reclaim1",
			cant = {
				[1] = "cantdo4",
			},
			count = {
				[1] = "count6",
				[2] = "count5",
				[3] = "count4",
				[4] = "count3",
				[5] = "count2",
				[6] = "count1",
			},
			ok = {
				[1] = "shcormov",
			},
			select = {
				[1] = "shcorsel",
			},
		},
	},
}
