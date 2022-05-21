cheat = {
	cheats = {
		clique = {
			name = "point and clique",
			tooltip = "while in-game, spawn an ogmo wherever you click",
			active = false
		},
		nifty = {
			name = "nifty",
			tooltip = "draw on the menu with your mouse (ps1 controllers not supported)",
			active = false,
			imatoggle = true,
			action = function(self)
				cheat.toggle(self)
				for y=1, menu.height do
					menu.niftyimg[y] = {}
					for x=1, menu.width do
						menu.niftyimg[y][x] = false
					end
				end
			end
		},
		rhubarb = {
			name = "rhubarb menu",
			tooltip = "it's fairly self-explanatory",
			action = function()
				menu.changeSubstate("rhubarb")
			end
		},
		ransom = {
			name = "ransom in the sand",
			tooltip = "play Art of Noise - Ransom in the Sand",
			action = function()
				if audio.activesong ~= "ransom in the sand" then
					audio.playsong("ransom in the sand", true)
				end
			end
		},
		boing = {
			name = "boing",
			tooltip = "play boing",
			action = function()
				if audio.activesong ~= "boing" then
					audio.playsong("boing", true)
				end
			end
		},
		scroller1 = {
			name = "scroll to move",
			tooltip = "use scrollwheel to move ogmo up/down. hold right click and it moves left/right",
			active = false
		},
		agodami = {
			name = "god mode",
			tooltip = "ogmos only die from falling off-screen or pressing R",
			active = false
		},
		youreglue = {
			name = "i'm rubber",
			tooltip = "bouncy surfaces always forever",
			active = false
		},
		stackem = {
			name = "stack 'em to the heavens",
			tooltip = "levels are vertically separated into their individual layers",
			active = false
		},
		nwide = {
			name = "nwide",
			tooltip = "takes contents of clipboard, puts a | every 2 characters, prints it", --this is actually a utility for some complicated font shenanigans in a knytt stories level lol. named such because it was originally based on nwidesplit
			hidden = true,
			action = function()
				local cb = love.system.getClipboardText()
				if #cb > 500 then print("long string huh?") --this check is to make sure we don't paste irrelevant really long stuff and then do a bunch of useless processing. we've grappled with the knytt stories+ editor taking ctrl+c to mean "copy the level data of the current room" when we actually wanted to copy a sign string or whatnot
				--elseif string.sub(cb, 1, 2) ~= "OK" then print("not OK")
				else
					--local cb = string.sub(cb, 3, -1)
					local newstr = ""
					for i=1, #cb do
						newstr = newstr .. string.sub(cb, i, i) --not efficient but we're not translating the unabridged works of charles dickens here
						if i % 2 == 0 then newstr = newstr .. "|" end
						if i == #cb and i % 2 == 1 then newstr = newstr .. " |" end
					end
					print(newstr .. "\n")
				end
			end
		},
		jumper4imaginary = {
			name = "Jumper 4 Imaginary",
			tooltip = "i cannot believe it (mr trololo; mcdonald and wimbish - upful horns)",
			imatoggle = true,
			active = false,
			action = function(self)
				cheat.toggle(self)
				if self.active then
					menu.changelogo("J4I Logo")
					if audio.activesong ~= "trollful horns" then
						audio.playsong("trollful horns")
					end
				else
					menu.changelogo("J4R Logo 2x")
					if audio.activesong ~= "34" then
						audio.playsong("34")
					end
				end
			end
		},
		smallsteps = {
			name = "small steps",
			tooltip = "move ogmos by 1 px using the [ and ] keys",
			active = false
		},
		ogmolith = {
			name = "ogmolith",
			tooltip = "become the ogmolith",
			action = function()
				game.ogmoskin = "ogmolith"
				game.ogmosnapto = 16
				_G["ogmo"].quads = ogmos[game.ogmoskin].quads
			end
		},
		widescreen = {
			name = "widescreen",
			tooltip = "make it wider",
			imatoggle = true,
			active = false,
			action = function(self)
				cheat.toggle(self)
				if self.active then
					game.width = 1024
					menu.width = 1024
				else
					game.width = 512
					menu.width = 512
				end
				love.window.updateMode(menu.width, menu.height)
			end
		},
		wrongway = {
			name = "wrong way",
			tooltip = "launchers now spin counterclockwise, like in the original jumper games",
			active = false
		}
	},
	unlockedcheats = {},
	activecheats = {},
	get = function(name)
		if cheat.cheats[name] then return cheat.cheats[name] end
		return false
	end,
	isactive = function(name)
		if cheat.cheats[name] and cheat.cheats[name].active then return true end
		return false
	end,
	isunlocked = function(name)
		if cheat.cheats[name] and cheat.cheats[name].unlocked then return true end
		return false
	end,
	enable = function(thischeat)
		if thischeat.active == nil then error("tried to enable a non-bool cheat") end
		if not thischeat.active then
			table.insert(cheat.activecheats, thischeat.key)
			menu.changed.activecheats = true
		end
		thischeat.active = true
	end,
	disable = function(thischeat)
		if thischeat.active == nil then error("tried to disable a non-bool cheat") end
		if thischeat.active then
			local removeindex = 0
			for i,v in ipairs(cheat.activecheats) do
				if v == thischeat.key then
					removeindex = i
					break
				end
			end
			if removeindex ~= 0 then
				table.remove(cheat.activecheats, removeindex)
				menu.changed.activecheats = true
			else
				print("disabled a cheat that isn't on active list? " .. thischeat.key)
			end
		end
		thischeat.active = false
	end,
	toggle = function(thischeat)
		if thischeat.active == nil then error("tried to toggle a non-bool cheat") end
		if thischeat.active then cheat.disable(thischeat)
		else cheat.enable(thischeat) end
	end,
	act = function(thischeat)
		if thischeat.action == nil then error("tried to act a non-function cheat") end
		thischeat.action(thischeat)
	end,
	invoke = function(thischeat)
		if type(thischeat) ~= "table" then error("invoking a nonexistent cheat (of type " .. type(thischeat) .. ")", 2) end
		if thischeat.action ~= nil then cheat.act(thischeat)
		elseif thischeat.active ~= nil then cheat.toggle(thischeat) end
	end
}
for k,thischeat in pairs(cheat.cheats) do
	thischeat.key = k
end