levelsymbols = {
	["  "] = {
		name = "Eraser",
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
		tiles = {"floor"},
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
		objects = {"ogmo;gost"},
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
		name = "Choice Block (ON)",
		categories = {"objects"},
		order = 8,
		tiles = {},
		objects = {"choiceblock"},
		tooltip = "The solidity of this block is the player's choice! It's solid if Choice is ON." --ku
	},
	["O!"] = {
		name = "Choice Block (OFF)",
		categories = {"objects"},
		order = 9,
		tiles = {},
		objects = {"choiceblock;inverse"},
		tooltip = "The solidity of this block is the player's choice! It's solid if Choice is OFF." --ku
	},
	[" !"] = {
		name = "Win (1)",
		categories = {"invisible"},
		order = 10,
		tiles = {},
		objects = {"win;1"},
		tooltip = "Win tile! Takes you to the 1st exit specified for this level." --ku
	},
	[" \""] = {
		name = "Win (2)",
		categories = {"invisible"},
		order = 11,
		tiles = {},
		objects = {"win;2"},
		tooltip = "Win tile! Takes you to the 2nd exit specified for this level." --ku
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
	[" #"] = {
		name = "Invisible",
		categories = {"invisible"},
		order = 16,
		tiles = {"invisible"},
		objects = {},
		tooltip = "It looks exactly like nothing is here, and yet: an invisible block!" --ku
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
		name = "Tall",
		categories = {"tiles"},
		order = 18,
		tiles = {"tallwall"},
		objects = {},
		tooltip = "A red wall with mysterious bumps on it!" --ku
	},
	["t("] = {
		name = "Drippy",
		categories = {"tiles"},
		order = 19,
		tiles = {"drippywall"},
		objects = {},
		tooltip = "This blue wall mysteriously inverts light's effect on it." --ku
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
		name = "Short Spikes (Down)",
		categories = {"tiles"},
		rotations = {"t1", "t/"},
		order = 25,
		tiles = {"shortspikes"},
		objects = {},
		tooltip = "woahhhh how did the spikes get so short i'm tripping balls" --bert
	},
	["t/"] = {
		name = "reserved - short spikes right",
		categories = {"tiles"},
		rotations = {"t.", "t0"},
		order = 26,
		tiles = {"shortspikes"},
		objects = {},
		tooltip = "woahhhh how did the spikes get so short i'm tripping balls"
	},
	["t0"] = {
		name = "reserved - short spikes up",
		categories = {"tiles"},
		rotations = {"t/", "t1"},
		order = 27,
		tiles = {"shortspikes"},
		objects = {},
		tooltip = "woahhhh how did the spikes get so short i'm tripping balls"
	},
	["t1"] = {
		name = "reserved - short spikes left",
		categories = {"tiles"},
		rotations = {"t0", "t."},
		order = 28,
		tiles = {"shortspikes"},
		objects = {},
		tooltip = "woahhhh how did the spikes get so short i'm tripping balls"
	},
	["t2"] = {
		name = "Slope (Down-Right)",
		categories = {"tiles"},
		rotations = {"t3", "t5"},
		order = 29,
		tiles = {"slopeSE"},
		objects = {},
		tooltip = "a slope" --bert
	},
	["t3"] = {
		name = "Slope (Down-Left)",
		categories = {"tiles"},
		rotations = {"t4", "t2"},
		order = 30,
		tiles = {"slopeSW"},
		objects = {},
		tooltip = "a slope"
	},
	["t4"] = {
		name = "Slope (Up-Left)",
		categories = {"tiles"},
		rotations = {"t5", "t3"},
		order = 31,
		tiles = {"slopeNW"},
		objects = {},
		tooltip = "a slope"
	},
	["t5"] = {
		name = "Slope (Up-Right)",
		categories = {"tiles"},
		rotations = {"t2", "t4"},
		order = 32,
		tiles = {"slopeNE"},
		objects = {},
		tooltip = "a slope"
	},
	["O\""] = {
		name = "Jump Arrow",
		categories = {"objects"},
		order = 33,
		tiles = {},
		objects = {"jumparrow"},
		tooltip = "restores your double jump if you've used it. takes a while to regenerate" --bert
	}
}

levelsymbols_sortedkeys_byraw = {} --by raw key text. i don't think you'd ever need this but it does sort by (kind of arbitrary, probably subject to change) categories and show when things were added in each category. see legend.txt for more info about the innate categories each key uses
levelsymbols_sortedkeys_byorder = {} --by corresponding values' "order" fields
for k, _ in pairs(levelsymbols) do
	table.insert(levelsymbols_sortedkeys_byraw, k)
	table.insert(levelsymbols_sortedkeys_byorder, k)
end
table.sort(levelsymbols_sortedkeys_byraw, function(a,b)
	return a < b
end)
table.sort(levelsymbols_sortedkeys_byorder, function(a,b)
	if levelsymbols[a].order == levelsymbols[b].order and a ~= b --[[a ~= b is because occasionally sort tries something against itself for some reason]] then
		print("hm, symbols '" .. a .. "' and '" .. b .. "' share an order")
	end
	return levelsymbols[a].order < levelsymbols[b].order
end)

--what's great here is if e.g. the sequence goes "A, B, D, E, F, G, C, H" with each term's order being equal to its placement and i want C to display before D, i can just change C's order to 2.5 with no further effort required and nothing will break. order doesn't represent the literal placement in a table, just how the symbols should be sorted