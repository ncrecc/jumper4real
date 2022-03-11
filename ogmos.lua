ogmos = {
	["ogmo"] = {
		name = "Ogmo",
		order = 1,
		description = "The man. The myth. The legend. Well, maybe not a man, but Ogmo regardless." --Ku
	},
	["crude-examplemo"] = {
		name = "Crude Examplemo",
		order = 1.5,
		description = "it's french" --bert
	},
	["ogmodeluxe"] = {
		name = "OGMO DELUXE",
		order = 1.75,
		description = "LITERALLY THE BEST OGMO CONCEIVABLE BY MANKIND" --GEDDY
	},
	["popmo"] = {
		name = "Popmo",
		order = 2,
		description = "Ogmo's last words were \"Noo, don't turn me into a minimalist design!\"" --Ku
	},
	["ogmogus"] = {
		name = "Ogmogus",
		order = 3,
		description = "STOP POSTING ABOUT OGMO! I'M TIRED OF SEEING IT!" --buster
	},
	["8x8mo"] = {
		name = "8x8mo",
		order = 4,
		snapto = 2,
		description = "The shrink ray was a success! ...Partially." --Ku
	},
	["mo"] = {
		name = "MO",
		order = 5,
		snapto = 4,
		description = "HI MO" --Ku
	},
	["warrior"] = {
		name = "Warrior",
		order = 6,
		description = "In search of a new car, it's the Warrior, from Dicey Dungeons! Fanmade skin by not mario." --bert/Ku
	},
	["robot"] = {
		name = "Robot",
		order = 7,
		description = "In search of new spreadsheet software, it's the Robot, from Dicey Dungeons! Fanmade skin by not mario." --bert/Ku
	},
	["ogmolith"] = {
		name = "ogmolith",
		order = 1,
		snapto = 16,
		description = "yes",
		hidden = true
	}
}

for k,skin in pairs(ogmos) do
	--inefficient since we can just reuse quads for skins of the same width and height, but i'm tempted to just leave this as-is so loading time is equal to the amount of skins you have and isn't increased if some skins have different dimensions than others
	local skinimg = graphics.load("ogmos/" .. k)
	skin.quads = {}
	for i=0, 32 do --32 instead of 31. yes, we're starting at 0 and for loop syntax is inclusive in lua, so starting at 0 and iterating to 32 means we get 33 elements, but there is a 33rd element! gost's block, an object that acts like an additional ogmo and causes another ogmo to die when it dies
		--table.insert(ogmo.quads, love.graphics.newQuad((i % 4) * 16, math.floor(i / 4) * 16, 16, 16, 64, 160))
		skin.quads[ogmo.quaddefs[i + 1]] = love.graphics.newQuad((i % 4) * 16, math.floor(i / 4) * 16, 16, 16, skinimg:getWidth(), skinimg:getHeight())
	end
end

ogmo.quads = ogmos[game.ogmoskin].quads

ashleys = {
	["ashley"] = {
		name = "Ashley",
		description = "actually idk when ashley skins will ever be implemented. if ever. sorry lol" --bert
	}
}