menu_substates = {
	["title"] = {
		options = {
			[1] = {
				name = "play",
				--tooltip = "Play the game! (Levelset selection support soon!)",
				tooltip = "Select a levelset to play.", --thx to titku for making me not write something stupid here
				action = function()
					menu.changeSubstate("levelsets")
					--statemachine.setstate("game")
				end
			},
			[2] = {
				name = "settings",
				tooltip = "A variety of settings.",
				action = function()
					menu.changeSubstate("settings")
				end
			},
			[3] = {
				name = "editor",
				tooltip = "Work in progress, whoo!",
				--tooltip = "TODO! It will be awesome. Or at least usable. Awesomely usable?",
				action = function()
					statemachine.setstate("editor")
				end
			},
			[4] = {
				name = "quit",
				tooltip = "Quit ze game.",
				action = function()
					love.event.quit()
				end
			},
		},
		onLoad = function() end,
		onUpdate = function() end,
		linedistance = 40,
		offsetfromleft = 192,
		offsetfromtop = 96,
		showlogo = true
	},
	["settings"] = {
		options = {
		--[[
			[1] = {
				name = "audio: ",
				vartoggle = "playaudio",
				tooltip = "Play audio?",
				action = function()
					if universalsettings["playaudio"] then
						love.audio.setVolume(1)
					else
						love.audio.setVolume(0)
					end
				end
			},
		--]]
			[1] = {
				name = "sfx: ",
				vartoggle = "playsfx",
				tooltip = "Play sound effects?",
				action = function()
					if universalsettings["playsfx"] then
						audio.changesfxvolume(1)
					else
						audio.changesfxvolume(0)
					end
				end
			},
			[2] = {
				name = "music: ",
				vartoggle = "playmusic",
				tooltip = "Play the sweet music?",
				action = function()
					if universalsettings["playmusic"] then
						audio.changemusicvolume(1)
					else
						audio.changemusicvolume(0)
					end
				end
			},
			[3] = {
				name = "choice: ",
				vartoggle = "choice",
				tooltip = "Subscribe to the illusion of choice?",
				action = function() end
			},
			[4] = {
				name = "see the unseeable: ",
				vartoggle = "seetheunseeable",
				tooltip = "See invisible tiles (e.g. wintiles)?",
				action = function() end
			},
			[5] = {
				name = "back",
				tooltip = "Exit to the title screen.",
				action = function()
					if menu.changedsettings then
						writetouniversalsettings()
					end
					menu.changeSubstate("title")
					menu.picker = 2
					menu.changedsettings = false
				end
			}
		},
		onLoad = function() end,
		onUpdate = function() end,
		linedistance = 40,
		offsetfromleft = 192,
		offsetfromtop = 96
	},
	["levelsets"] = {
		options = {
		},
		onLoad = function()
			menu.options = {} --we have to explicitly do this or else some weird bug can pop up with table.sort somehow accessing the "back" button on subsequent visits of this menu and making it the second option... before the back button is actually loaded. pretty weird
			levelsets = love.filesystem.getDirectoryItems("levelling")
			ext_levelsets = love.filesystem.getDirectoryItems("ext_levelling")
			local i = 1
			while i <= #levelsets do
				local thislevelset = levelsets[i]
				local levelsetinfo = love.filesystem.read("levelling/" .. thislevelset .. "/LEVELINFO.txt")
				correctnewlines(levelsetinfo)
				levelsetinfo = split(levelsetinfo, "\n")
				local firstmap = levelsetinfo[3]
				menu.options[i] = {
					name = levelsetinfo[1],
					tooltip = levelsetinfo[2],
					action = function()
						game.currentlevelset = thislevelset --not clear that game.mapname and game.currentlevelset are globals :/ lots of stuff in game needs to be made a member of the game table
						game.mapname = firstmap
						statemachine.setstate("game")
					end
				}
				i = i + 1
			end
			local ii = 1
			while ii <= #ext_levelsets do
				local thislevelset = ext_levelsets[ii]
				if love.filesystem.getInfo("ext_levelling/" .. thislevelset .. "/LEVELINFO.txt") ~= nil then
					local levelsetinfo = love.filesystem.read("ext_levelling/" .. thislevelset .. "/LEVELINFO.txt")
					correctnewlines(levelsetinfo)
					levelsetinfo = split(levelsetinfo, "\n")
					local firstmap = levelsetinfo[3]
					menu.options[i] = {
						name = levelsetinfo[1],
						tooltip = levelsetinfo[2],
						action = function()
							game.currentlevelset = thislevelset --not clear that game.mapname and game.currentlevelset are globals :/ lots of stuff in game needs to be made a member of the game table
							game.mapname = firstmap
							statemachine.setstate("game")
						end
					}
				else
					menu.options[i] = {
						name = thislevelset,
						tooltip = "Hm. Either this it a standalone level (not yet supported), or a levelset with bad levelset info.",
						alpha = 0.5,
						action = function()
						end
					}
				end
				i = i + 1
				ii = ii + 1
			end
			table.sort(menu.options, function(a,b) return a.name < b.name end)
			menu.options[i] = {
				name = "back",
				tooltip = "Exit to the title screen.",
				action = function()
					menu.changeSubstate("title")
					menu.picker = 1
				end
			}
		end,
		onUpdate = function() end,
		linedistance = 40,
		offsetfromleft = 192,
		offsetfromtop = 96
	},
	["rhubarbrolled"] = {
		options = {
			[1] = {
				name = "rhubarbrolled",
				tooltip = "rhubarbrolled you stupid moron",
				action = function() end
			},
			[2] = {
				name = "back",
				tooltip = "stop being rhubarbrolled. you're lucky to have this option",
				action = function()
					menu.changeSubstate("title")
					menu.picker = 2
				end
			},
		},
		onLoad = function() end,
		onUpdate = function() end,
		linedistance = 40,
		offsetfromleft = 192,
		offsetfromtop = 96
	},
	["rhubarbsettings"] = {
		options = {
			[1] = {
				name = "play",
				tooltip = "Select a levelset to play.", --thx to titku for making me not write something stupid here
				action = function()
					menu.changeSubstate("levelsets")
				end
			},
			[2] = {
				name = "rhubarb",
				tooltip = "The fleshy, edible stalks of species and hybrids of Rheum in the family Polygonaceae.",
				action = function() end
			},
			[3] = {
				name = "bauble",
				tooltip = "Baubles, or Christmas ornaments, are decoration items, usually to decorate Christmas trees.",
				action = function() end
			},
			[4] = {
				name = "quit",
				tooltip = "Quit ze game.",
				action = function()
					love.event.quit()
				end
			},
		},
		onLoad = function() end,
		onUpdate = function() end,
		linedistance = 40,
		offsetfromleft = 192,
		offsetfromtop = 96
	}
}