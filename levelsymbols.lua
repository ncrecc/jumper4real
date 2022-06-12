levelsymbols = {
	["  "] = {
		name = "Nothing",
		categories = {"invisible"},
		order = 1,
		tiles = {},
		objects = {},
		tooltip = "Pure, undiluted nothingness. Use with caution. (Or as an eraser.)" --Ku
	},
	["t "] = {
		name = "Wall",
		categories = {"tiles"},
		order = 2,
		tiles = {"wall"},
		objects = {},
		tooltip = "Just a plain wall. Standard for blocking Ogmos and Ogmoey creatures." --ku
	},
	["t!"] = {
		name = "Backwall",
		categories = {"tiles"},
		order = 3,
		tiles = {"backwall"},
		objects = {},
		tooltip = "Painting walls light-gray makes them further away on average, studies show." --ku
	},
	["x "] = {
		name = "Spikeball",
		categories = {"deadly"},
		order = 4,
		tiles = {"spike_ball"},
		objects = {},
		tooltip = "A spike so spiky it collapsed into a spherical shape." --ku
	},
	["M "] = {
		name = "Ogmo",
		hasogmo = true,
		categories = {"mobs"},
		order = 5,
		tiles = {},
		objects = {"ogmo"},
		tooltip = "The man. The myth. The legend. Well, maybe not a man, but Ogmo regardless." --ku
	},
	["M\""] = {
		name = "Gost's Block",
		categories = {"mobs"},
		order = 6,
		tiles = {},
		objects = {"ogmo|gost"},
		tooltip = "It copies your movements, and you die if it dies." --ku
	},
	["M!"] = {
		name = "Ashley",
		categories = {"mobs"},
		order = 7,
		tiles = {},
		objects = {"ashley"},
		tooltip = "You can move her in four directions, ignoring gravity." --ashley
	},
	--[[
	       = {
		tiles = {},
		objects = {"ashley;red|fast"},
		tooltip = "evil ashley be like" --diane
	},
	]]
	["O "] = {
		name = "Choice Block A",
		categories = {"objects"},
		order = 8,
		rotations = {"O!", "O!"},
		tiles = {},
		objects = {"choiceblock"},
		tooltip = "The solidity of this block is the player's choice! It's solid only if Choice is ON." --ku
	},
	["O!"] = {
		name = "Choice Block B",
		categories = {"objects"},
		order = 9,
		rotations = {"O ", "O "},
		tiles = {},
		objects = {"choiceblock|inverse"},
		tooltip = "The solidity of this block is the player's choice! It's solid only if Choice is OFF." --ku
	},
	[" !"] = {
		name = "Win",
		categories = {"invisible"},
		order = 10,
		tiles = {},
		objects = {"win"},
		tooltip = "Win tile! Takes you to another level. You can specify which with Magic Numbers." --ku
	},
	[" \""] = {
		name = "Invisible",
		categories = {"invisible"},
		order = 11,
		tiles = {"invisible"},
		objects = {},
		tooltip = "It looks exactly like nothing is here, and yet: an invisible block!" --ku
	},
	--[[
		[" "] = {
			tiles = {"sky"},
			objects = {},
			tooltip = "This is the sky. You've seen it before, hopefully." --ku
				you know that actually makes me think of the implications of living in a world in which people play jumper 4 real but have never seen the sky. would we be some shitty love2d game megacorp or something -buster
		},
	]]
	["t\""] = {
		name = "Cloud",
		categories = {"decor"},
		order = 12,
		tiles = {"cloud"},
		objects = {},
		tooltip = "A cloud. Completely decorative. Tends to make more sense outside." --ku
	},
	["t#"] = {
		name = "Dirt",
		categories = {"tiles"},
		order = 13,
		tiles = {"dirt"},
		objects = {},
		tooltip = "It's a big ol' clump of dirt!" --ku
	},
	["t$"] = {
		name = "Backdirt",
		categories = {"tiles"},
		order = 14,
		tiles = {"dirtbg"},
		objects = {},
		tooltip = "A clump of dirt, much further away." --ku
	},
	["t%"] = {
		name = "Grass",
		categories = {"tiles"},
		order = 15,
		tiles = {"dirt", "grass"},
		objects = {},
		tooltip = "A grassy floor, now with 80% less ticks!" --ku
	},
	[" 0"] = {
		name = "Magic Number (0)",
		categories = {"invisible"},
		rotations = {" 9", " 1"},
		order = 16.0,
		tiles = {"magic0"},
		magicvalue = 0,
		objects = {},
		tooltip = "This can modify the tile or object on the layer below it." --ku
	},
	[" 1"] = {
		name = "Magic Number (1)",
		categories = {"invisible"},
		rotations = {" 0", " 2"},
		order = 16.1,
		tiles = {"magic1"},
		magicvalue = 1,
		objects = {},
		tooltip = "This can modify the tile or object on the layer below it." --ku
	},
	[" 2"] = {
		name = "Magic Number (2)",
		categories = {"invisible"},
		rotations = {" 1", " 3"},
		order = 16.2,
		tiles = {"magic2"},
		magicvalue = 2,
		objects = {},
		tooltip = "This can modify the tile or object on the layer below it." --ku
	},
	[" 3"] = {
		name = "Magic Number (3)",
		categories = {"invisible"},
		rotations = {" 2", " 4"},
		order = 16.3,
		tiles = {"magic3"},
		magicvalue = 3,
		objects = {},
		tooltip = "This can modify the tile or object on the layer below it." --ku
	},
	[" 4"] = {
		name = "Magic Number (4)",
		categories = {"invisible"},
		rotations = {" 3", " 5"},
		order = 16.4,
		tiles = {"magic4"},
		magicvalue = 4,
		objects = {},
		tooltip = "This can modify the tile or object on the layer below it." --ku
	},
	[" 5"] = {
		name = "Magic Number (5)",
		categories = {"invisible"},
		rotations = {" 4", " 6"},
		order = 16.5,
		tiles = {"magic5"},
		magicvalue = 5,
		objects = {},
		tooltip = "This can modify the tile or object on the layer below it." --ku
	},
	[" 6"] = {
		name = "Magic Number (6)",
		categories = {"invisible"},
		rotations = {" 5", " 7"},
		order = 16.6,
		tiles = {"magic6"},
		magicvalue = 6,
		objects = {},
		tooltip = "This can modify the tile or object on the layer below it." --ku
	},
	[" 7"] = {
		name = "Magic Number (7)",
		categories = {"invisible"},
		rotations = {" 6", " 8"},
		order = 16.7,
		tiles = {"magic7"},
		magicvalue = 7,
		objects = {},
		tooltip = "This can modify the tile or object on the layer below it." --ku
	},
	[" 8"] = {
		name = "Magic Number (8)",
		categories = {"invisible"},
		rotations = {" 7", " 9"},
		order = 16.8,
		tiles = {"magic8"},
		magicvalue = 8,
		objects = {},
		tooltip = "This can modify the tile or object on the layer below it." --ku
	},
	[" 9"] = {
		name = "Magic Number (9)",
		categories = {"invisible"},
		rotations = {" 8", " 0"},
		order = 16.9,
		tiles = {"magic9"},
		magicvalue = 9,
		objects = {},
		tooltip = "This can modify the tile or object on the layer below it." --ku
	},
	["t&"] = {
		name = "Black",
		categories = {"tiles"},
		order = 17,
		tiles = {"black"},
		objects = {},
		tooltip = "Blackness lies beyond the walls of the facility." --ku
	},
	["t'"] = {
		name = "reserved",
		order = 9026,
		tooltip = "shouldn't be seeable",
		nevershow = true
	},
	["t("] = {
		name = "reserved",
		order = 9026,
		tooltip = "shouldn't be seeable",
		nevershow = true
	},
	["t)"] = {
		name = "Slab (Down)",
		categories = {"tiles"},
		rotations = {"t,", "t*"},
		order = 20,
		tiles = {"slabS"},
		objects = {},
		tooltip = "When you said these were \"half off\", I didn't know that's what you meant..." --ku
		--lol
	},
	["t*"] = {
		name = "Slab (Right)",
		categories = {"tiles"},
		rotations = {"t)", "t+"},
		order = 21,
		tiles = {"slabE"},
		objects = {},
		tooltip = "When you said these were \"half off\", I didn't know that's what you meant..." --ku
	},
	["t+"] = {
		name = "Slab (Up)",
		categories = {"tiles"},
		rotations = {"t*", "t,"},
		order = 22,
		tiles = {"slabN"},
		objects = {},
		tooltip = "When you said these were \"half off\", I didn't know that's what you meant..." --ku
		--lol
	},
	["t,"] = {
		name = "Slab (Left)",
		categories = {"tiles"},
		rotations = {"t+", "t)"},
		order = 23,
		tiles = {"slabW"},
		objects = {},
		tooltip = "When you said these were \"half off\", I didn't know that's what you meant..." --ku
	},
	["t-"] = {
		name = "Rubber",
		categories = {"tiles"},
		order = 24,
		tiles = {"rubber"},
		objects = {},
		tooltip = "It's a block made of rubber. You bounce off of it, rather than being erased. That's good." --bert
	},
	["t."] = {
		name = "reserved",
		order = 9026,
		tooltip = "shouldn't be seeable",
		nevershow = true
	},
	["t/"] = {
		name = "reserved",
		order = 9026,
		tooltip = "shouldn't be seeable",
		nevershow = true
	},
	["t0"] = {
		name = "reserved",
		order = 9026,
		tooltip = "shouldn't be seeable",
		nevershow = true
	},
	["t1"] = {
		name = "reserved",
		order = 9026,
		tooltip = "shouldn't be seeable",
		nevershow = true
	},
	["t2"] = {
		name = "Slope (Down-Right)",
		categories = {"tiles"},
		rotations = {"t3", "t5"},
		order = 29,
		tiles = {"slopeSE"},
		objects = {},
		tooltip = "Spice things up with a 45-degree angle! Ogmo can't walk up it, sadly." --Ku
	},
	["t3"] = {
		name = "Slope (Down-Left)",
		categories = {"tiles"},
		rotations = {"t4", "t2"},
		order = 30,
		tiles = {"slopeSW"},
		objects = {},
		tooltip = "Spice things up with a 45-degree angle! Ogmo can't walk up it, sadly."
	},
	["t4"] = {
		name = "Slope (Up-Left)",
		categories = {"tiles"},
		rotations = {"t5", "t3"},
		order = 31,
		tiles = {"slopeNW"},
		objects = {},
		tooltip = "Spice things up with a 45-degree angle!"
	},
	["t5"] = {
		name = "Slope (Up-Right)",
		categories = {"tiles"},
		rotations = {"t2", "t4"},
		order = 32,
		tiles = {"slopeNE"},
		objects = {},
		tooltip = "Spice things up with a 45-degree angle!"
	},
	["O\""] = {
		name = "Jump Arrow",
		categories = {"objects"},
		order = 33,
		tiles = {},
		objects = {"jumparrow"},
		tooltip = "Restores your double jump if you've used it. Takes a while to regenerate." --bert
	},
	["t6"] = {
		name = "Dev Wall",
		categories = {"tiles"},
		order = 34,
		tiles = {"dev_wall"},
		objects = {},
		tooltip = "A relic of a simpler era. (An era that lasted 1 month.)" --Ku
	},
	["t7"] = {
		name = "Dev Backwall",
		categories = {"tiles"},
		order = 35,
		tiles = {"dev_backwall"},
		objects = {},
		tooltip = "A relic of a simpler era. (An era that lasted 1 month.)"
	},
	["x!"] = {
		name = "Dev Death",
		categories = {"tiles"},
		order = 36,
		tiles = {"dev_death"},
		objects = {},
		tooltip = "A relic of a simpler era. (An era that lasted 1 month.)"
	},
	["x\""] = {
		name = "Spikes (Down)",
		categories = {"tiles"},
		rotations = {"x%", "x#"},
		order = 37,
		tiles = {"spikesS"},
		objects = {},
		tooltip = "Just pointy enough to menace Ogmo without raising a safety hazard." --Ku
	},
	["x#"] = {
		name = "Spikes (Right)",
		categories = {"tiles"},
		rotations = {"x\"", "x$"},
		order = 38,
		tiles = {"spikesE"},
		objects = {},
		tooltip = "Just pointy enough to menace Ogmo without raising a safety hazard."
	},
	["x$"] = {
		name = "Spikes (Up)",
		categories = {"tiles"},
		rotations = {"x#", "x%"},
		order = 39,
		tiles = {"spikesN"},
		objects = {},
		tooltip = "Just pointy enough to menace Ogmo without raising a safety hazard."
	},
	["x%"] = {
		name = "Spikes (Left)",
		categories = {"tiles"},
		rotations = {"x$", "x\""},
		order = 40,
		tiles = {"spikesW"},
		objects = {},
		tooltip = "Just pointy enough to menace Ogmo without raising a safety hazard."
	},
	["x&"] = {
		name = "Short Spikes (Down)",
		categories = {"tiles"},
		rotations = {"x)", "x'"},
		order = 41,
		tiles = {"shortspikesS"},
		objects = {},
		tooltip = "Shorter, perhaps, but no less pointy and dangerous." --Ku
	},
	["x'"] = {
		name = "Short Spikes (Right)",
		categories = {"tiles"},
		rotations = {"x&", "x("},
		order = 42,
		tiles = {"shortspikesE"},
		objects = {},
		tooltip = "Shorter, perhaps, but no less pointy and dangerous."
	},
	["x("] = {
		name = "Short Spikes (Up)",
		categories = {"tiles"},
		rotations = {"x'", "x)"},
		order = 43,
		tiles = {"shortspikesN"},
		objects = {},
		tooltip = "Shorter, perhaps, but no less pointy and dangerous. Ogmo can slide under this." --Ku
	},
	["x)"] = {
		name = "Short Spikes (Left)",
		categories = {"tiles"},
		rotations = {"x(", "x&"},
		order = 44,
		tiles = {"shortspikesW"},
		objects = {},
		tooltip = "Shorter, perhaps, but no less pointy and dangerous."
	},
	["O#"] = {
		name = "Hint Block",
		categories = {"objects"},
		order = 45,
		tiles = {},
		objects = {"hintblock"},
		tooltip = "shows you some text when you hit it from below" --bert
	},
	["O$"] = {
		name = "Door",
		categories = {"objects"},
		order = 46,
		tiles = {},
		objects = {"door"},
		tooltip = "similar to a win tile, but requires interacting with it" --bert
	},
	["t8"] = {
		name = "Darkness",
		categories = {"tiles"},
		order = 47,
		tiles = {"dark"},
		objects = {},
		tooltip = "add a bit of dark to enhance the mood" -- bert
	},
	["t9"] = {
		name = "Lightness",
		categories = {"tiles"},
		order = 48,
		tiles = {"light"},
		objects = {},
		tooltip = "add a bit of light to detract from the mood" -- bert
	},
	["O%"] = {
		name = "launcher",
		categories = {"objects"},
		rotations = {"O*", "O&"},
		order = 49,
		tiles = {},
		objects = {"launcher"},
		tooltip = "it deadass launches shit" --bert
	},
	["O&"] = {
		name = "blue launcher",
		categories = {"objects"},
		rotations = {"O%", "O'"},
		order = 50,
		tiles = {},
		objects = {"launcher|variant:fast"},
		tooltip = "it deadass launches shit, but faster" --bert
	},
	["O'"] = {
		name = "yellow launcher",
		categories = {"objects"},
		rotations = {"O&", "O("},
		order = 51,
		tiles = {},
		objects = {"launcher|variant:fragile"},
		tooltip = "it deadass launches shit but we bought it at walmart for 3 bucks don't break it" --bert
	},
	["O("] = {
		name = "remote launcher",
		categories = {"objects"},
		rotations = {"O'", "O)"},
		order = 52,
		tiles = {},
		objects = {"launcher|variant:remote"},
		tooltip = "it launches you AFTER you touch it, when you're no longer inside it. trippy!" --bert
	},
	["O)"] = {
		name = "twin launcher",
		categories = {"objects"},
		rotations = {"O(", "O*"},
		order = 53,
		tiles = {},
		objects = {"launcher|variant:twin"},
		tooltip = "a launcher with two cannons. i wonder what that could mean" --bert
	},
	["O*"] = {
		name = "inert launcher",
		categories = {"objects"},
		rotations = {"O)", "O%"},
		order = 54,
		tiles = {},
		objects = {"launcher|variant:inert"},
		tooltip = "a launcher with no cannon, and yet it can still send you flying." --bert
	},
}

levelsymbols_sortedkeys_byraw = {} --by raw key text. i don't think you'd ever need this but it does sort by (kind of arbitrary, probably subject to change) categories and show when things were added in each category (except when things get deleted). see legend.txt for more info about the innate categories each key uses
levelsymbols_sortedkeys_byorder = {} --by corresponding values' "order" fields
for k, _ in pairs(levelsymbols) do
	table.insert(levelsymbols_sortedkeys_byraw, k)
	table.insert(levelsymbols_sortedkeys_byorder, k)
end
table.sort(levelsymbols_sortedkeys_byraw, function(a,b)
	return a < b
end)
table.sort(levelsymbols_sortedkeys_byorder, function(a,b)
	if levelsymbols[a].order == levelsymbols[b].order and a ~= b and not (levelsymbols[a].nevershow or levelsymbols[b].nevershow) --[[a ~= b is because occasionally sort tries something against itself for some reason]] then
		print("hm, symbols '" .. a .. "' and '" .. b .. "' share an order")
	end
	return levelsymbols[a].order < levelsymbols[b].order
end)

--what's great here is if e.g. the sequence goes "A, B, D, E, F, G, C, H" with each term's order being equal to its placement and i want C to display before D, i can just change C's order to 2.5 with no further effort required and nothing will break. order doesn't represent the literal placement in a table, just how the symbols should be sorted