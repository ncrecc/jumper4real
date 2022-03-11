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
				name = "ogmos",
				tooltip = "personalize thyself.",
				action = function()
					menu.changeSubstate("ogmos")
				end
			},
			[3] = {
				name = "settings",
				tooltip = "A variety of settings.",
				action = function()
					menu.changeSubstate("settings")
				end
			},
			[4] = {
				name = "editor",
				tooltip = "make your own levels. some things like exits, music, and background color have to be set in the file.",
				--tooltip = "Think you have what it takes to outclass the official levels? You probably do!",
				--tooltip = "Make your own levels, just like the official levels.",
				--tooltip = "Work in progress, whoo!",
				--tooltip = "TODO! It will be awesome. Or at least usable. Awesomely usable?",
				action = function()
					statemachine.setstate("editor")
				end
			},
			[5] = {
				name = "quit",
				tooltip = "Quit ze game.",
				action = function()
					love.event.quit()
				end
			},
		},
		onLoad = function()
			if #cheat.unlockedcheats > 0 then
				table.insert(menu.options, 4, {
					name = "cheats",
					tooltip = "cheat not only the game but yourself",
					action = function()
						menu.changeSubstate("cheats")
					end
				})
			end
		end,
		onUpdate = function() end,
		onCheat = function(firstunlock)
			if firstunlock then
				table.insert(menu.options, 4, {
					name = "cheats",
					tooltip = "cheat not only the game but yourself",
					action = function()
						menu.changeSubstate("cheats")
					end
				})
				if menu.picker >= 4 then menu.movePicker("down") end
			end
		end,
		noback = true,
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
					if settings["playaudio"] then
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
				action = function() --this might look nonsensical but note that if vartoggle is defined, then the corresponding variable gets toggled in settings, *then* if action is defined it runs action
					if settings["playsfx"] then
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
					if settings["playmusic"] then
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
			--[[
			[5] = {
				name = "back",
				tooltip = "Exit to the title screen.",
				action = function()
					menu.changeSubstate("title")
					menu.picker = 2
				end
			}
			]]
		},
		backtooltip = "Exit to the title screen.",
		onLoad = function() end,
		onUpdate = function() end,
		linedistance = 40,
		offsetfromleft = 192,
		offsetfromtop = 96
	},
	["levelsets"] = {
		options = {},
		onLoad = function()
			--menu.options = {} --we have to explicitly do this or else some weird bug can pop up with table.sort somehow accessing the "back" button on subsequent visits of this menu and making it the second option... before the back button is actually loaded. pretty weird
			--i'm pretty sure whatever the situation described in the above line was was a consequence of not really getting how tables work (e.g. local a = {}; local b = a; b[1] = "blah"; print(a[1]); --> blah)
			local levelsets = love.filesystem.getDirectoryItems("levelsets")
			local ext_levelsets = love.filesystem.getDirectoryItems("ext_levelsets")
			local i = 1
			while i <= #levelsets do
				local thislevelset = levelsets[i]
				local levelsetinfo = love.filesystem.read("levelsets/" .. thislevelset .. "/LEVELINFO.txt")
				levelsetinfo = correctnewlines(levelsetinfo)
				levelsetinfo = split(levelsetinfo, "\n")
				local firstmap = levelsetinfo[3]
				menu.options[i] = {
					name = levelsetinfo[1],
					tooltip = levelsetinfo[2],
					action = function()
						game.loadLevelset("levelsets/" .. thislevelset, levelsetinfo)
						statemachine.setstate("game")
					end
				}
				i = i + 1
			end
			local ii = 1
			while ii <= #ext_levelsets do
				local thislevelset = ext_levelsets[ii]
				if love.filesystem.getInfo("ext_levelsets/" .. thislevelset .. "/LEVELINFO.txt") ~= nil then
					local levelsetinfo = love.filesystem.read("ext_levelsets/" .. thislevelset .. "/LEVELINFO.txt")
					levelsetinfo = correctnewlines(levelsetinfo)
					levelsetinfo = split(levelsetinfo, "\n")
					local firstmap = levelsetinfo[3]
					menu.options[i] = {
						name = levelsetinfo[1],
						tooltip = levelsetinfo[2],
						action = function()
							game.loadLevelset("ext_levelsets/" .. thislevelset, levelsetinfo)
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
			--[[
			menu.options[i] = {
				name = "back",
				tooltip = "Exit to the title screen.",
				action = function()
					menu.changeSubstate("title")
					menu.picker = 1
				end
			}
			]]
		end,
		backtooltip = "Exit to the title screen.",
		onUpdate = function() end,
		linedistance = 40,
		offsetfromleft = 192,
		offsetfromtop = 96
	},
	["cheats"] = {
		options = {},
		onLoad = function()
			menu.options = {}
			local cheatlist = cheat.unlockedcheats
			local i = 0
			for k,v in ipairs(cheatlist) do
				local thischeat = cheat.cheats[v]
				if thischeat then
					i = i + 1
					if thischeat.action and not thischeat.imatoggle then
						menu.options[i] = {
							name = thischeat.name,
							tooltip = thischeat.tooltip,
							action = function()
								thischeat.action(thischeat)
							end
						}
					else
						menu.options[i] = {
							name = thischeat.name,
							getname = function(self)
								if thischeat.active then return thischeat.name .. ": YES"
								else return thischeat.name .. ": NO" end
							end,
							tooltip = thischeat.tooltip,
							action = function()
								if thischeat.action then thischeat.action(thischeat) else cheat.toggle(thischeat) end
							end
						}
					end
				end
			end
			table.sort(menu.options, function(a,b) return string.lower(a.name) < string.lower(b.name) end)
			--[[
			menu.options[#menu.options + 1] = {
				name = "back",
				tooltip = "Exit to the title screen.",
				action = function()
					menu.changeSubstate("title")
					menu.picker = 3
				end
			}
			]]
		end,
		backtooltip = "Exit to the title screen.",
		--onCheat = function() menu.onLoad() menu.appendBackOption(nil, backtooltip) end,
		onCheat = function() menu.refresh() end,
		linedistance = 40,
		offsetfromleft = 192,
		offsetfromtop = 96
	},
	["ogmos"] = {
		options = {},
		onLoad = function()
			menu.options = {}
			local i = 0
			for k,ogmo in pairs(ogmos) do
				if ogmo and not ogmo.hidden then
					i = i + 1
					menu.options[i] = {
						getname = function(self)
							if game.ogmoskin == k then return ogmo.name .. " [CURRENT]"
							else return ogmo.name end
						end,
						tooltip = ogmo.description,
						order = ogmo.order,
						id = k,
						action = function()
							game.ogmoskin = k
							game.ogmosnapto = ogmo.snapto or 1
							_G["ogmo"].quads = ogmos[game.ogmoskin].quads
							menu.changed.ogmoskin = true
						end
					}
				end
			end
			table.sort(menu.options, function(a,b) return a.order < b.order end)
		end,
		onDraw = function()
			if menu.options[menu.picker].id then
				local skinimg = graphics.load("ogmos/" .. menu.options[menu.picker].id)
				local r, g, b, a = love.graphics.getColor()
				love.graphics.setColor(0.5, 0.5, 0.5, a)
				love.graphics.rectangle("fill", 42, math.floor((menu.height - (skinimg:getHeight() + 16)) / 2), skinimg:getWidth() + 16, skinimg:getHeight() + 16)
				love.graphics.setColor(r, g, b, a)
				love.graphics.draw(skinimg, 50, math.floor((menu.height - skinimg:getHeight()) / 2))
			end
		end,
		backtooltip = "Exit to the title screen.",
	},
	["rhubarbrolled"] = {
		options = {
			[1] = {
				name = "rhubarbrolled",
				tooltip = "rhubarbrolled you stupid moron",
				action = function() end
			},
			--[[
			[2] = {
				name = "back",
				tooltip = "stop being rhubarbrolled. you're lucky to have this option",
				action = function()
					menu.changeSubstate("rhubarbsettings")
					menu.picker = 2
				end
			},
			]]
		},
		backtooltip = "stop being rhubarbrolled. you're lucky to have this option",
		onLoad = function() end,
		onUpdate = function() end,
		linedistance = 40,
		offsetfromleft = 192,
		offsetfromtop = 96
	},
	["rhubarb"] = {
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
				action = function()
					menu.changeSubstate("rhubarbrolled")
				end
			},
			[3] = {
				name = "bauble",
				tooltip = "Baubles, or Christmas ornaments, are decoration items, usually to decorate Christmas trees.",
				action = function()
					menu.changeSubstate("bauble")
				end
			},
			[4] = {
				name = "back",
				tooltip = "why? are you scared of rhubarb?",
				action = function() menu.back() end
			},
			[5] = {
				name = "quit",
				tooltip = "Quit ze game.",
				action = function()
					love.event.quit()
				end
			},
		},
		noback = true,
		onLoad = function() end,
		onUpdate = function() end,
		linedistance = 40,
		offsetfromleft = 192,
		offsetfromtop = 96
	},
	["bauble"] = {
		options = {
			[1] = {
				name = "doink",
				tooltip = "yoink",
				action = function() end
			},
			[2] = {
				name = "sploink",
				tooltip = "ploink",
				action = function() end
			},
			[3] = {
				name = "third",
				tooltip = "yird, go to title",
				action = function() menu.changeSubstate("title") end
			},
			[4] = {
				name = "wait",
				tooltip = "bait",
				action = function() end
			},
			[5] = {
				name = "great",
				tooltip = "mate",
				action = function() end
			},
			[6] = {
				name = "hex",
				tooltip = "sex",
				action = function() end
			},
			[7] = {
				name = "7 should do",
				tooltip = "7 should be the max # of items displayed before it gets separated into pages",
				action = function() end
			},
			[8] = {
				name = "nex",
				tooltip = "gex",
				action = function() end
			},
			[9] = {
				name = "slurp",
				tooltip = "interp",
				action = function() end
			},
			[10] = {
				name = "car",
				tooltip = "rar",
				action = function() end
			},
			[11] = {
				name = "blink",
				tooltip = "slink",
				action = function() end
			},
			[12] = {
				name = "snare",
				tooltip = "flare. go to title",
				action = function() menu.changeSubstate("title") end
			},
			[13] = {
				name = "air",
				tooltip = "hair",
				action = function() end
			},
			[14] = {
				name = "mad",
				tooltip = "glad",
				action = function() end
			},
			[15] = {
				name = "fresh",
				tooltip = "mesh",
				action = function() end
			},
			[16] = {
				name = "pair",
				tooltip = "dare",
				action = function() end
			},
			[17] = {
				name = "slop",
				tooltip = "flop",
				action = function() end
			},
			[18] = {
				name = "jort",
				tooltip = "fort, go to title again",
				action = function() menu.changeSubstate("title") end
			},
			[19] = {
				name = "shield",
				tooltip = "yield",
				action = function() end
			},
		},
	},
}