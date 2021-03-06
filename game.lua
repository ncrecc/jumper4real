--game is basically a mini state machine to access levels

local font = love.graphics.getFont()
game = {
	width = 512,
	height = 512,
	levelsetpath = "",
	--[[
	playeramt = 0,
	liveplayeramt = 0,
	loadedobjects = {},
	leveloptions = {},
	mapname = "",
	exits = {},
	currentsong = "",
	map = {},
	tilemap = {}, --multiple tiles actually can go on each coordinate so each square here is represented by a table
	levelwidth = 512,
	levelheight = 512,
	hints = {},
	]]
	godmode = false,
	editormode = false,
	ogmoskin = "ogmo",
	ogmosnapto = 1,
	paused = false,
	pausedformenu = false,
	pausedfortextbox = false,
	textboxtext = love.graphics.newText(font, ""),
	textboxwraplimit = 350,
	textboxwidth = nil,
	textboxheight = nil,
	textboxpadding = 25,
	textboxX = nil,
	textboxY = nil,
	fact = nil,
	
	templatelevels = {},
	activelevels = {},
}

function game.begin()
	--[[
	if not game.editormode then
		game.map, game.tilemap, game.exits, game.currentsong, game.leveloptions, game.background = game.loadLevel(game.currentlevelset .. "/" .. game.mapname)
		audio.playsong(game.currentsong, false)
	end]]
end

function game.resetLevel()
	if game.templatelevels[1] then
		game.activelevels = {}
		game.activelevels[1] = game.templatelevels[1]:clone()
	end
end

function game.loadLevel(filepath, entrance)
	local leveldata = love.filesystem.read(filepath..".txt")
	if leveldata == nil then print "hey your level file ain't jack shit"; leveldata = love.filesystem.read("void.txt"); end
	leveldata = correctnewlines(leveldata)
	local baselevel = level:new(leveldata)
	baselevel:gamify(entrance, true)
	--check for diane levels... later
	game.templatelevels = {}
	game.activelevels = {}
	game.templatelevels[1] = baselevel
	game.activelevels[1] = baselevel:clone()
	if not game.editormode and (baselevel.music ~= audio.activesong or baselevel.options.playmusicevenifsame) then
		audio.playsong(baselevel.music, false, baselevel.options.pauseoldmusic)
	end
end

function game.loadLevelset(levelsetdir, levelsetinfo)
	game.levelsetpath = levelsetdir
	game.loadLevel(game.levelsetpath .. "/levels/" .. levelsetinfo[3], 0)
end

function game.update(dt)
	local doreset = false
	if not game.paused then
		--[=[
		for i=1, #objectnamelist do
			if game.loadedobjects[objectnamelist[i]] ~= nil then
				for ii=1, #game.loadedobjects[objectnamelist[i]] do
					game.loadedobjects[objectnamelist[i]][ii]:update()
				end
			end
		end
		]=]
		for i,level in ipairs(game.activelevels) do
			level:update()
			if level.doreset then doreset = true end
		end
	end
	if doreset then
		doreset = false
		print("resetting!")
		game.resetLevel()
	end
end

function game.showtextbox(text)
	game.pausedfortextbox = true
	game.paused = true
	game.textboxtext:setf(text, game.textboxwraplimit, "left")
	game.textboxheight = game.textboxtext:getHeight() + (game.textboxpadding * 2)
	game.textboxwidth = game.textboxtext:getWidth() + (game.textboxpadding * 2)
	game.textboxX = math.floor((game.width - game.textboxwidth) / 2)
	game.textboxY = math.floor((game.height - game.textboxheight) / 2)
end

function game.keypressed(key)
	if not game.paused then
		for i,level in ipairs(game.activelevels) do
			level:keypressed(key)
		end
	end
	--if key == "g" then game.showtextbox("hello. this is my incredibly lengthy text that is ridiculously lengthy") end
	if key == "escape" or (game.editormode and key == "tab") then
		if not game.editormode then
			statemachine.setstate("menu")
		else
			statemachine.setstate("editor")
		end
	elseif key == "return" and game.pausedfortextbox then game.pausedfortextbox = false
	elseif key == "p" then
		game.pausedformenu = not game.pausedformenu
		audio.playsfx("pause")
		if game.pausedformenu then
			game.fact = facts[love.math.random(1, #facts)]
			if audio.activesong ~= nil then
				song = audio.loadedsongs[audio.activesong]
			end
			if audio.activesongoneshot then
				song:setFilter(audio.lowpass)
			else
				if song.intro ~= nil then song.intro:setFilter(audio.lowpass) end
				song.loop:setFilter(audio.lowpass)
			end
		else
			if audio.activesong ~= nil then
				song = audio.loadedsongs[audio.activesong]
				if audio.activesongoneshot then
					song:setFilter()
				else
					if song.intro ~= nil then song.intro:setFilter() end
					song.loop:setFilter()
				end
			end
		end
	elseif cheat.isactive("smallsteps") then
		if key == "[" then
			for _,level in ipairs(game.activelevels) do
				for _,object in ipairs(level.objects) do
					if object.type == "ogmo" then
						object.x = object.x - 1
					end
				end
			end
		elseif key == "]" then
			for _,level in ipairs(game.activelevels) do
				for _,object in ipairs(level.objects) do
					if object.type == "ogmo" then
						object.x = object.x + 1
					end
				end
			end
		end
	end
	--[[
   if key == "rctrl" then
      debug.debug()
   end
   ]]--
	if game.pausedfortextbox or game.pausedformenu then game.paused = true else game.paused = false end
end

function game.mousepressed(x, y, button)
	if cheat.isactive("clique") and button == 1 then
		local toplevel = game.activelevels[#game.activelevels]
		local newogmo = ogmo:setup(x - (tilesize / 2), y - (tilesize / 2), {}, toplevel)
		table.insert(toplevel.objects, newogmo)
		newogmo.level = toplevel
		toplevel.liveplayeramt = toplevel.liveplayeramt + 1
	elseif cheat.isactive("scroller1") and button == 3 then
		for _,level in ipairs(game.activelevels) do
			for _,object in ipairs(level.objects) do
				if object.type == "ogmo" then
					if love.mouse.isDown(2) then
						object.vmom = object.vmom * 2
						object.hmom = object.hmom * 2
					else
						object.vmom = 0
						object.hmom = 0
					end
				end
			end
		end
	end
end

function game.wheelmoved(x, y)
	if cheat.isactive("scroller1") then
		if love.mouse.isDown(2) then x, y = y, x end
		for _,level in ipairs(game.activelevels) do
			for _,object in ipairs(level.objects) do
				if object.type == "ogmo" then
					object.vmom = object.vmom - y
					object.hmom = object.hmom + (x * 2)
				end
			end
		end
	end
end

function game.draw()
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(hextocolor(game.activelevels[1].background))
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	love.graphics.setColor(r, g, b, a)
	--ok i'll try to break this down step-by-step for future me's convenience
	--game.tilemap is like map but instead of containing just symbols it just contains the tile names the symbols would point to
	--for each row in the game.tilemap:
	for _,level in ipairs(game.activelevels) do
		level:draw()
	end
	if game.pausedfortextbox then
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.rectangle("fill", game.textboxX, game.textboxY, game.textboxwidth, game.textboxheight)
		love.graphics.setColor(0.2, 0.2, 0.2, 1)
		love.graphics.rectangle("line", game.textboxX, game.textboxY, game.textboxwidth, game.textboxheight)
		love.graphics.setColor(r, g, b, a)
		love.graphics.draw(game.textboxtext, game.textboxX + game.textboxpadding, game.textboxY + game.textboxpadding)
		love.graphics.printf("(press enter)", game.textboxX, (game.textboxY + game.textboxheight) - (math.floor(game.textboxpadding / 2)), game.textboxwidth / 0.75, "right", 0, 0.75)
	end
	if game.editormode then
		love.graphics.setColor(0.2, 0.2, 0.2)
		love.graphics.rectangle("fill", 0, 512, 512 + editor.addedwidth, 512)
		love.graphics.rectangle("fill", 512, 0, editor.addedwidth, 512)
		love.graphics.setColor(r, g, b, a)
	end
	if game.pausedformenu then
		love.graphics.setColor(0, 0, 0, 0.5)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
		love.graphics.setColor(r, g, b, a)
		printAsTooltip("fact: " .. game.fact)
	end
	if game.editormode then
		printWithOutline("testing level! press esc or tab to return to editor")
	end
end

function game.win(number, level)
	if statemachine.currentstate == game and not level.frozen then
		for _,level in ipairs(game.activelevels) do
			level.frozen = true
		end
		if game.editormode then
			statemachine.setstate("editor")
		else
			if number == nil then number = 1 end
			--if not level.exits[number] then error("invalid level exit " .. number, 2) end
			if not level.exits[number] then
				print("invalid level exit. entering void")
				game.loadLevel("void", number)
			else
				print ("won! time to load " .. level.exits[number])
				local newlevel = level.exits[number]
				if newlevel == "WINLEVELSET" then
					print("YOU WON THE LEVELSET!!!!!")
					statemachine.setstate("menu")
				else
					local pauseoldmusic = false
					local playmusicevenifsame = false
					game.loadLevel(game.levelsetpath .. "/levels/" .. newlevel, number)
				end
			end
		end
	end
end

function game.stop()
	game.templatelevels = {}
	game.activelevels = {}
	game.levelsetpath = ""
	if game.editormode then editor.returningfromgame = true end
	game.editormode = false
	audio.stoploopingsfxall()
	game.paused = false
	game.pausedformenu = false
	game.pausedfortextbox = false
	if audio.activesong ~= nil then
		song = audio.loadedsongs[audio.activesong]
		if audio.activesongoneshot then
			song:setFilter()
		else
			if song.intro ~= nil then song.intro:setFilter() end
			song.loop:setFilter()
		end
	end
end