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
			tooltip = "move ogmos by 1 px, ignoring walls, using the [ and ] keys",
			active = false
		},
		ogmolith = {
			name = "ogmolith",
			tooltip = "become the ogmolith",
			action = function()
				game.ogmoskin = "ogmolith"
				game.ogmosnapto = 16
				_G["ogmo"].quads = ogmos[game.ogmoskin].quads --this was orignially located somewhere with a local "ogmo" variable so it needed to specify _G
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
			tooltip = "launchers now spin counterclockwise and faster",
			active = false
		},
		jumparound = {
			name = "jump up and get down",
			tooltip = "ogmo attempts to jump whenever possible",
			active = false
		},
		oldskoolbutlikewithak = {
			name = "oldskool but, like, with a k",
			tooltip = "old skool friction & acceleration - stop and start instantly",
			active = false
		},
		ogmobleatsforplentyofcheats = {
			name = "ogmo bleats for plenty of cheats",
			tooltip = "when used from cheats menu, unlocks ALL the cheats!",
			action = function()
				if menu.ischeatmenu then
					audio.playsfx("cheat")
					local lockedcheats_old = table.copy(cheat.lockedcheats)
					for i,v in ipairs(lockedcheats_old) do
						if not cheat.cheats[v].hidden then
							cheat.unlock(v)
						end
					end
					menu.changed.unlockedcheats = true
					menu.refresh()
				end
			end
		},
		ogmoshoutsmakecheatsgoout = {
			name = "ogmo shouts \"make cheats go out\"",
			tooltip = "when used from cheats menu, disables & re-locks ALL the cheats",
			action = function()
				if menu.ischeatmenu then
					audio.playsfx("cheat")
					local activecheats_old = table.copy(cheat.activecheats)
					for i,v in ipairs(activecheats_old) do
						cheat.disable(v)
					end
					
					cheat.unlockedcheats = {}
					cheat.lockedcheats = {}
					cheat.lockedcheats_withvox = {}
					cheat.activecheats = {}
					
					local _cheatswithvox = love.filesystem.getDirectoryItems("audial/sfx/vox/ogmosays/cheats")
					local cheatswithvox = {}
					for k,v in pairs(_cheatswithvox) do
						cheatswithvox[v] = true
					end
					
					for k,v in pairs(cheat.cheats) do
						if not v.unlocked then
							table.insert(cheat.lockedcheats, k)
							if cheatswithvox[k .. ".ogg"] then table.insert(cheat.lockedcheats_withvox, k) end
						end
					end
					menu.changed.unlockedcheats = true
					menu.back()
				end
			end
		}
	},
	unlockedcheats = {}, --set in love.load
	lockedcheats = {}, --set in love.load
	lockedcheats_withvox = {}, --set in love.load
	activecheats = {}, --set in love.load
	
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
	unlock = function(name)
		table.insert(cheat.unlockedcheats, name)
		cheat.cheats[name].unlocked = true
		for i,v in ipairs(cheat.lockedcheats) do
			if v == name then
				table.remove(cheat.lockedcheats, i)
				break
			end
		end
		for i,v in ipairs(cheat.lockedcheats_withvox) do --this redundancy could potentially be eliminated with a third table that maps indexes in lockedcheats to indexes in lockedcheats_withvox but is it worth the hassle?
			if v == name then
				table.remove(cheat.lockedcheats_withvox, i)
				break
			end
		end
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