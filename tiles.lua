tiles = {
	--basictiles
	["wall"] = {
		["graphics"] = {{["referencename"] = "basictiles", ["quad"] = {0, 0}}},
		["solid"] = true,
		["deathly"] = false
	},
	["backwall"] = {
		["graphics"] = {{["referencename"] = "basictiles", ["quad"] = {0, 16}}},
		["solid"] = false,
		["deathly"] = false
	},
	["black"] = {
		["graphics"] = {{["referencename"] = "basictiles", ["quad"] = {64, 0}}},
		["solid"] = true,
		["deathly"] = false
	},
	["slabS"] = {
		["graphics"] = {{["referencename"] = "basictiles", ["quad"] = {16, 0}}},
		["solid"] = true,
		["deathly"] = false,
		["hitboxheight"] = tilesize / 2,
		["hitboxYoffset"] = tilesize / 2,
	},
	["slabE"] = {
		["graphics"] = {{["referencename"] = "basictiles", ["quad"] = {16, 16}}},
		["solid"] = true,
		["deathly"] = false,
		["hitboxwidth"] = tilesize / 2,
		["hitboxXoffset"] = tilesize / 2,
	},
	["slabN"] = {
		["graphics"] = {{["referencename"] = "basictiles", ["quad"] = {16, 0}, ["ingameoffset"] = {0, -8}}},
		["solid"] = true,
		["deathly"] = false,
		["hitboxheight"] = tilesize / 2,
		["hitboxYoffset"] = 0,
	},
	["slabW"] = {
		["graphics"] = {{["referencename"] = "basictiles", ["quad"] = {16, 16}, ["ingameoffset"] = {-8, 0}}},
		["solid"] = true,
		["deathly"] = false,
		["hitboxwidth"] = tilesize / 2,
		["hitboxXoffset"] = 0,
	},
	["slopeNW"] = {
		["graphics"] = {{["referencename"] = "basictiles", ["quad"] = {48, 16}}},
		["solid"] = true,
		["automask"] = true
	},
	["slopeNE"] = {
		["graphics"] = {{["referencename"] = "basictiles", ["quad"] = {32, 16}}},
		["solid"] = true,
		["automask"] = true
	},
	["slopeSE"] = {
		["graphics"] = {{["referencename"] = "basictiles", ["quad"] = {32, 0}}},
		["solid"] = true,
		["automask"] = true
	},
	["slopeSW"] = {
		["graphics"] = {{["referencename"] = "basictiles", ["quad"] = {48, 0}}},
		["solid"] = true,
		["automask"] = true
	},
	
	--spikes
	["spike_ball"] = {
		["graphics"] = {{["referencename"] = "spikes", ["quad"] = {64, 0}}},
		["solid"] = false,
		["deathly"] = true
	},
	["spikesS"] = {
		["graphics"] = {{["referencename"] = "spikes", ["quad"] = {0, 0}}},
		["solid"] = false,
		["deathly"] = true,
		["automask"] = true
	},
	["spikesE"] = {
		["graphics"] = {{["referencename"] = "spikes", ["quad"] = {16, 0}}},
		["solid"] = false,
		["deathly"] = true,
		["automask"] = true
	},
	["spikesN"] = {
		["graphics"] = {{["referencename"] = "spikes", ["quad"] = {32, 0}}},
		["solid"] = false,
		["deathly"] = true,
		["automask"] = true
	},
	["spikesW"] = {
		["graphics"] = {{["referencename"] = "spikes", ["quad"] = {48, 0}}},
		["solid"] = false,
		["deathly"] = true,
		["automask"] = true
	},
	["shortspikesS"] = {
		["graphics"] = {{["referencename"] = "spikes", ["quad"] = {0, 16}}},
		["solid"] = false,
		["deathly"] = true,
		["automask"] = true
	},
	["shortspikesE"] = {
		["graphics"] = {{["referencename"] = "spikes", ["quad"] = {16, 16}}},
		["solid"] = false,
		["deathly"] = true,
		["automask"] = true
	},
	["shortspikesN"] = {
		["graphics"] = {{["referencename"] = "spikes", ["quad"] = {32, 16}}},
		["solid"] = false,
		["deathly"] = true,
		["makemask"] = function()
			local maskstring = [[
################
.######..######.
..####....####..
................
................
................
................
................
................
................
................
................
................
................
................
................]]
			return makemaskwithmultistring(maskstring, ".", "#")
		end
	},
	["shortspikesW"] = {
		["graphics"] = {{["referencename"] = "spikes", ["quad"] = {48, 16}}},
		["solid"] = false,
		["deathly"] = true,
		["automask"] = true
	},
	
	
	--outside
	["dirt"] = {
		["graphics"] = {{["referencename"] = "outsidetiles", ["quad"] = {0, 0}}},
		["solid"] = true,
		["deathly"] = false
	},
	["dirtbg"] = {
		["graphics"] = {{["referencename"] = "outsidetiles", ["quad"] = {0, 16}}},
		["solid"] = false,
		["deathly"] = false
	},
	["grass"] = {
		["graphics"] = {{["referencename"] = "outsidetiles", ["quad"] = {16, 0}}},
		["solid"] = false,
		["deathly"] = false,
		["soft"] = true --Tile property that should make tiles like one-way upward platforms that can be ducked down through. And without the "ghost floor" nonsense like in Jumper 2 Editor where all objects stop colliding with it if you're beneath it. -Titku
	},
	["snow"] = {
		["graphics"] = {{["referencename"] = "outsidetiles", ["quad"] = {32, 0}}},
		["solid"] = false,
		["deathly"] = false,
		["soft"] = true
	},
	["cloud"] = {
		["graphics"] = {{["referencename"] = "outsidetiles", ["quad"] = {16, 16}}},
		["solid"] = false,
		["deathly"] = false
	},
	
	
	["invisible"] = {
		["solid"] = true,
		["deathly"] = false,
		["invisible"] = true
	},
	["fakeblack"] = {
		["graphics"] = {{["referencename"] = "basictiles", ["quad"] = {64, 0}}},
		["solid"] = true,
		["deathly"] = false
	},
	["fakewall"] = {
		["graphics"] = {{["referencename"] = "basictiles", ["quad"] = {0, 0}}},
		["solid"] = true,
		["deathly"] = false
	},
	["rubber"] = {
		["solid"] = true,
		["deathly"] = false,
		["bounce"] = true
	},
	["levelborder"] = { --this tile was created as a kludge for collision and normally is never drawn, but if you do create a levelsymbol for it and place it for whatever reason, it just acts like black but not walljumpable. also, the level border will always be solid, but notwalljumpable being true here is why you can't walljump from it
		["graphics"] = {{["referencename"] = "basictiles", ["quad"] = {64, 0}}},
		["solid"] = true,
		["deathly"] = false,
		["notwalljumpable"] = true,
	},
	["dev_wall"] = {
		["graphics"] = {
			{
				["referencename"] = "devtiles",
				["quad"] = {16, 0}
			}
		},
		["solid"] = true
	},
	["dev_backwall"] = {
		["graphics"] = {
			{
				["referencename"] = "devtiles",
				["quad"] = {0, 0}
			}
		},
		["solid"] = false
	},
	["dev_death"] = {
		["graphics"] = {
			{
				["referencename"] = "devtiles",
				["quad"] = {32, 0}
			}
		},
		["solid"] = false,
		["deathly"] = true,
	}
}