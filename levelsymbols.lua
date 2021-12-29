levelsymbols = {
	["#"] = {
		tiles = {"wall"},
		objects = {},
		tooltip = "A wall. Standard for blocking Ogmos and Ogmoey creatures." --ku
	},
	["."] = {
		tiles = {"floor"},
		objects = {},
		tooltip = "Painting walls light-gray makes them further away on average, studies show." --ku
	},
	["X"] = {
		tiles = {"floor", "spike_ball"},
		objects = {},
		tooltip = "A spike so spiky it collapsed into a spherical shape." --ku
	},
	["A"] = {
		tiles = {"floor"},
		objects = {"ashley"},
		tooltip = "ashley <3" --diane
	},
	["Q"] = {
		tiles = {"floor"},
		objects = {"ashley;red|fast"},
		tooltip = "evil ashley be like" --diane
	},
	["P"] = {
		tiles = {"floor"},
		objects = {"ogmo"},
		tooltip = "The man. The myth. The legend. Well, maybe not a man, but Ogmo regardless." --ku
	},
	["G"] = {
		tiles = {"floor"},
		objects = {"ogmo;gost"},
		tooltip = "Gost's Block. It copies your movements, and you die if it dies." --ku
	},
	["?"] = {
		tiles = {"floor"},
		objects = {"choiceblock"},
		tooltip = "The solidity of this block is the player's choice! It's solid if Choice is ON." --ku
	},
	["!"] = {
		tiles = {"floor"},
		objects = {"choiceblock;inverse"},
		tooltip = "The solidity of this block is the player's choice! It's solid if Choice is OFF." --ku
	},
	["1"] = {
		tiles = {"floor"},
		objects = {"win;1"},
		tooltip = "Win tile! Takes you to the 1st exit specified for this level." --ku
	},
	["2"] = {
		tiles = {"floor"},
		objects = {"win;2"},
		tooltip = "Win tile! Takes you to the 2nd exit specified for this level." --ku
	},
	[" "] = {
		tiles = {"sky"},
		objects = {},
		tooltip = "This is the sky. You've seen it before, hopefully." --ku
	},
	["~"] = {
		tiles = {"sky", "cloud"},
		objects = {},
		tooltip = "A cloud. Completely decorative. Tends to make more sense outside." --ku
	},
	["%"] = {
		tiles = {"dirt"},
		objects = {},
		tooltip = "It's a big ol' clump of dirt!" --ku
	},
	["/"] = {
		tiles = {"sky", "dirtbg"},
		objects = {},
		tooltip = "A clump of dirt, much further away." --ku
	},
	["W"] = {
		tiles = {"dirt", "grass"},
		objects = {},
		tooltip = "A grassy floor, now with 80% less ticks!" --ku
	},
	["$"] = {
		tiles = {"sky"},
		objects = {"win;1"},
		tooltip = "Win tile! Takes you to the 1st exit specified for this level." --ku
	},
	["0"] = {
		tiles = {"sky"},
		objects = {"ogmo"},
		tooltip = "The man. The myth. The legend. Well, maybe not a man, but Ogmo regardless." --ku
	},
	["I"] = {
		tiles = {"sky", "invisible"},
		objects = {},
		tooltip = "It looks exactly like nothing is here, and yet: an invisible block!" --ku
	},
	["B"] = {
		tiles = {"black"},
		objects = {},
		tooltip = "Blackness lies beyond the walls of the facility." --ku
	},
	["b"] = {
		tiles = {"fakeblack"},
		objects = {"fakeindicator"},
		tooltip = "Ominous darkness that you can walk straight through." --ku
	},
	["|"] = {
		tiles = {"fakewall"},
		objects = {"fakeindicator"},
		tooltip = "A wall... OR IS IT??? This wall is completely nonsolid!" --ku
	},
	["K"] = {
		tiles = {"fakeblack"},
		objects = {"win;1", "fakeindicator"},
		tooltip = "Win tile! Takes you to the 1st exit specified for this level." --ku
	},
	["o"] = {
		tiles = {"fakeblack"},
		objects = {"ogmo", "fakeindicator"},
		tooltip = "The man. The myth. The legend. Well, maybe not a man, but Ogmo regardless." --ku
	},
	["C"] = {
		tiles = {"floor", "cloud"},
		objects = {},
		tooltip = "A cloud. Completely decorative. Tends to make more sense outside." --ku
	},
	["J"] = {
		tiles = {"tallwall"},
		objects = {},
		tooltip = "A red wall with mysterious bumps on it! Almost as though Bert were using it to test graphical offsets..." --ku
	},
	["D"] = {
		tiles = {"drippywall"},
		objects = {},
		tooltip = "This blue wall mysteriously inverts light's effect on it, as it helps Bert figure out what to do with drawing order!" --ku
		--lol thanks ku. she's referring to an issue i realized would happen (which i made this masterpiece graphic for) where tiles with graphics larger than 16x16 and little enough negaitve offset can be cut off by other tiles being drawn near them, including background tiles. ultimately i'll probably just rely on tile layers (editor & map support coming Eventually [tm]) and solve some of the more trivial issues by making it so tiles with offsets get drawn *after* everything else
		--...this doesn't have an offset (it just has  but never you mind that
	},
	["s"] = {
		tiles = {"floor", "slab"},
		objects = {},
		tooltip = "When you said these were \"half off\", I didn't know that's what you meant..." --ku
		--lol
	},
	["R"] = {
		tiles = {"rubber"},
		objects = {},
		tooltip = "It's a block made of rubber. You bounce off of it, rather than being erased. That's good." --bert
		--with drippywall and tallwall it was me who came up with them (for testing purposes) and made the shitty graphics and titku who made the witty tooltips. so for rubber, which titku drew and probably came up with (idr), we decided *i* would get to come up with a shitty tooltip for it. masterpiece, innit
	},
	["S"] = {
		tiles = {"floor", "sideslab"},
		objects = {},
		tooltip = "When you said these were \"half off\", I didn't know that's what you meant..." --ku
	},
	["k"] = {
		tiles = {"floor", "shortspikes"},
		objects = {},
		tooltip = "woahhhh how did the spikes get so short i'm tripping balls" --bert
	},
	["5"] = {
		tiles = {"floor", "slopeNW"},
		objects = {},
		tooltip = "a slope" --bert
	},
	["6"] = {
		tiles = {"floor", "slopeNE"},
		objects = {},
		tooltip = "a slope" --bert
	},
	["7"] = {
		tiles = {"floor", "slopeSE"},
		objects = {},
		tooltip = "a slope" --bert
	},
	["8"] = {
		tiles = {"floor", "slopeSW"},
		objects = {},
		tooltip = "a slope" --bert
	}
	--I stop writing tooltips for 2 seconds. :P -Ku
}