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
		["gfxoverride"] = {
			"wall"
		}
	}
}