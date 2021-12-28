tiles = {
	["wall"] = {
		["solid"] = true,
		["deathly"] = false
	},
	["floor"] = {
		["solid"] = false,
		["deathly"] = false
	},
	["spike_ball"] = {
		["solid"] = false,
		["deathly"] = true
	},
	["troll"] = {
		["solid"] = false,
		["deathly"] = true,
		["gfxoverride"] = {
			"wall"
		}
	},
	["dirt"] = {
		["solid"] = true,
		["deathly"] = false
	},
	["dirtbg"] = {
		["solid"] = false,
		["deathly"] = false
	},
	["grass"] = {
		["solid"] = false,
		["deathly"] = false,
		["soft"] = true --Tile property that should make tiles like one-way upward platforms that can be ducked down through. And without the "ghost floor" nonsense like in Jumper 2 Editor where all objects stop colliding with it if you're beneath it. -Titku
	},
	["sky"] = {
		["solid"] = false,
		["deathly"] = false
	},
	["cloud"] = {
		["solid"] = false,
		["deathly"] = false
	},
	["invisible"] = {
		["solid"] = true,
		["deathly"] = false,
		["invisible"] = true
	},
	["black"] = {
		["solid"] = true,
		["deathly"] = false
	},
	["fakeblack"] = {
		["solid"] = false,
		["deathly"] = false,
		["gfxoverride"] = {
			"black"
		}
	},
	["fakewall"] = {
		["solid"] = false,
		["deathly"] = false,
		["gfxoffsets"] = {0, 0},
		["gfxoverride"] = {
			"wall"
		},
		["gfxoverrideoffsets"] = {
			{0, 0}
		}
	},
	["tallwall"] = {
		["solid"] = true,
		["deathly"] = false,
		["gfxoffsets"] = {0, -3}
	},
	["drippywall"] = {
		["solid"] = true,
		["deathly"] = false
	},
	["slab"] = {
		["solid"] = true,
		["deathly"] = false,
		["automask"] = true
	},
	["sideslab"] = {
		["solid"] = true,
		["deathly"] = false,
		["automask"] = true
	},
	["rubber"] = {
		["solid"] = true,
		["deathly"] = false,
		["ontoucheffects"] = {"bounce"}
	},
	["levelborder"] = { --this tile was created as a kludge for collision. you can place it, in which case it acts like a tile you can't walljump off of, but i can't see why you'd want to place it. whatever
		["solid"] = true,
		["deathly"] = false,
		["walljumpable"] = false,
		["gfxoverride"] = {
			"black"
		}
	},
	["shortspikes"] = {
		["deathly"] = true,
		["automask"] = true
	},
	["slopeNW"] = {
		["solid"] = true,
		["automask"] = true
	},
	["slopeNE"] = {
		["solid"] = true,
		["automask"] = true
	},
	["slopeSE"] = {
		["solid"] = true,
		["automask"] = true
	},
	["slopeSW"] = {
		["solid"] = true,
		["automask"] = true
	}
}