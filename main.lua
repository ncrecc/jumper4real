--print(love)
--^it's tables all the way down man -bert
version = "0.3.1"
local lastversion = love.filesystem.read("version.txt")
if lastversion ~= version then
	love.filesystem.write("version.txt", version); print("updating version file");
	love.filesystem.write("Jumper 4 Real.chm", love.filesystem.read("Jumper 4 Real.chm")); print("updating help file");  --t.appendidentity
	love.filesystem.remove("Jumper 4 Real.chw"); print("deleting old help index");
end
tilesize = 16
scale = 1
--the above two settings don't actually do anything useful if changed
allowframeadvance = true
frameadvance = false

--this isn't enough like petscop i need to put info about a dead body in here or something

--print("boop bop mother fuckers")
--print(type(nil) == nil) this one exercise in pil got me, lol

function tern(expression, value1, value2) --more compact than declaring and running a function, and miles less ugly than (a and b or c), but doesn't short-circuit
	if expression then return value1 else return value2 end
end

function table.copy(src, dest, overwrite) --taken from the knytt stories mod "knytt stories ex" which might have taken this from elsewhere. does not recursively copy tables
	if not dest or overwrite then
		dest = dest or {}
		for k,v in pairs(src) do
			dest[k] = v
		end
	else
		for k,v in pairs(src) do
			if dest[k] == nil then
				dest[k] = v
			end
		end
	end
	return dest
end

function quad(...)
	return love.graphics.newQuad(...)
end

function set(...)
	local newtable = {}
	for k,v in pairs({...}) do
		newtable[v] = true
	end
	return newtable
end

function printWithOutline(str, x, y)
		x = x or 0
		y = y or 0
		local r, g, b, a = love.graphics.getColor()
		love.graphics.setColor(0, 0, 0, a)
		love.graphics.print(str, x - 1, y)
		love.graphics.print(str, x + 1, y)
		love.graphics.print(str, x, y - 1)
		love.graphics.print(str, x, y + 1)
		love.graphics.setColor(r, g, b, a)
		love.graphics.print(str, x, y)
end
function printAsTooltip(str, scale)
	love.graphics.printf(
		str,
		0,
		love.graphics.getHeight() - 16,
		(love.graphics.getWidth() / (scale or 0.75)),
		"center",
		0,
		scale or 0.75
	)
end

require "correctnewlines"

require "hex2color"
require "class"
require "split"

require "audio"
require "levelsymbols"
require "tiles"
require "graphics"

--[[do
	local teststring = "mycoolstringy"
	local splitby2 = nwidesplit(teststring, 2)
	for i, v in ipairs(splitby2) do
		print(i .. ": " .. v)
	end
	local splitby3 = nwidesplit(teststring, 3)
	for i, v in ipairs(splitby3) do
		print(i .. ": " .. v)
	end
end]]

--if levelsymbols["="] ~= nil then error("ERROR: equals sign (=) cannot be a level symbol") end

objects = {}
require "game"
require "cheat"
require "level"
objects["ogmo"] = require "objection/ogmo"
require "ogmos"
require "textfield"
require "button"
require "menu_substates"
require "menu"
require "editor_pages"
require "editor"
require "statemachine"

require "mobtools"

game.ogmoskin = love.filesystem.read("ogmoskin.txt") or "ogmo"
if not ogmos[game.ogmoskin] then game.ogmoskin = "ogmo" end
game.ogmosnapto = ogmos[game.ogmoskin].snapto or 1

--math.randomseed(os.time())

facts = love.filesystem.read("facts.txt")
facts = split(correctnewlines(facts), "\n")

function math.clamp(x, a, b) --help me i went down a rabbit hole of different methods of clamping. also this was originally for makecollisionmask to determine what range it should iterate in but i found it a lot easier to just don't impose restrictions on the for loops and don't do anything if getpixel returns nil
  return math.max(a, math.min(b, x))
end

objectfiles = love.filesystem.getDirectoryItems("objection")
for i=1, #objectfiles do
	local s = objectfiles[i]
	if s ~= "ogmo.lua" and string.sub(s, #s - 3) == ".lua" then
		object = require ("objection/" .. string.sub(s, 1, #s - 4))
		objects[string.sub(s, 1, #s - 4)] = object
	end
end


function makecollisionmask(imgdata, offsetx, offsety, width, height, ingameoffsetx, ingameoffsety)
	local mask = {}
	local maskheight = height or tilesize
	local maskwidth = width or tilesize
	local masktootall = maskheight > tilesize
	local masktoowide = maskwidth > tilesize
	if masktootall then
		print("woah bud, you have a mask that's too tall: " .. maskheight)
	end
	if masktoowide then
		print("woah bud, you have a mask that's too wide: " .. maskwidth)
	end
	for i=1, maskheight do mask[i] = {} end
	if not offsetx then offsetx = 0 end
	if not offsety then offsety = 0 end
	if not ingameoffsetx then ingameoffsetx = 0 end
	if not ingameoffsety then ingameoffsety = 0 end
	local trueleftbound = offsetx
	local truerightbound = offsetx + maskwidth - 1
	local truetopbound = offsety
	local truebottombound = offsety + maskheight - 1
	for y = offsety - ingameoffsety, (maskheight - 1) + offsety - ingameoffsety do
		for x = offsetx - ingameoffsetx, (maskwidth - 1) + offsetx - ingameoffsetx do
			local value = false
			if y >= truetopbound and y <= truebottombound and x >= trueleftbound and x <= truerightbound then
				local r, g, b, a = imgdata:getPixel(x, y)
				if a ~= nil and a > 0.75 then value = true end
			end
			mask[(y - offsety) + ingameoffsety + 1][(x - offsetx) + ingameoffsetx + 1] = value
		end
	end
	
	return mask
end

function ormasks(masks) --all masks should be the same size for this to work as intended. usually they'll be 16x16 so this is fine
	local mask = masks[1]
	for y=1, #mask do
		for x=1, #mask[y] do
			if not mask[y][x] then
				result = false
				for masknum=2, #masks do
					if masks[masknum] and masks[masknum][y][x] then
						result = true
						break
					end
				end
				mask[y][x] = result
			end
		end
	end
	return mask
end

function makemaskwithmultistring(maskstring, falsesymbol, truesymbol)
	local mask = {}
	local maskstring2 = correctnewlines(maskstring)
	local maskstringsplit = split(maskstring, "\n")
	for y=1, #maskstringsplit do
		local maskrowsplit = split(maskstringsplit[y], "")
		local newrow = {}
		for x=1, #maskrowsplit do
			if maskrowsplit[x] == truesymbol then
				newrow[x] = true
			elseif maskrowsplit[x] == falsesymbol then
				newrow[x] = false
			else
				print("unrecognized symbol in mask for makemaskwithmultistring: " .. maskrowsplit[x] .. " that was it")
			end
		end
		mask[y] = newrow
	end
	return mask
end

--[[
for tilename,tile in pairs(tiles) do
	if tile.gfxoffsets == nil then
		tile.gfxoffsets = {0, 0}
	end
	if tile.gfxoverride ~= nil and tile.gfxoverrideoffsets == nil then
		tile.gfxoverrideoffsets = {}
		for i=1, #tile.gfxoverride do
			tile.gfxoverrideoffsets[i] = {0, 0}
		end
	end
	if tile.automask then
		if tile.gfxoverride then
			local masks = {}
			for i=1, #tile.gfxoverride do
				masks[i] = makecollisionmask(love.image.newImageData("imagery/" .. tile.gfxoverride[i] .. ".png"), -1 * tile.gfxoverrideoffsets[i][1], -1 * tile.gfxoverrideoffsets[i][2])
			end
			tile.mask = ormasks(masks)
		else
			tile.mask = makecollisionmask(love.image.newImageData("imagery/" .. tilename .. ".png"), -1 * tile.gfxoffsets[1], -1 * tile.gfxoffsets[2])
		end
	end
end
]]
for tilename,tile in pairs(tiles) do
	if not tile.graphics then
		tile.graphics = {
			{}
		}
	end
	local masks = {}
	local i = 0
	for _,graphic in ipairs(tile.graphics) do
		--print(tilename)
		i = i + 1
		if not graphic.referencename then graphic.referencename = tilename end
		if not graphic.ingameoffset then graphic.ingameoffset = {0, 0} end
		if not graphic.quad then graphic.quad = {0, 0} end
		if tile.automask then
			if graphic.excludefromautomask then
				i = i - 1 --safe because i is only used for the masks array
				--alt approach would be just setting this index of masks to false, then tinkering with makecollisionmask a bit to ignore false masks completely (including when using the first mask supplied as the standard width and height for all masks). this would take a bit more code and would only be useful if a situation pops up where you want to know what graphic goes to what mask, specifically before the masks are orred
			else
				local referencedata = graphics.loadimagedata(graphic.referencename)
				graphic.reference = graphics.supply(graphic.referencename, referencedata)
				masks[i] = makecollisionmask(
					referencedata,
					graphic.quad[1] or 0,
					graphic.quad[2] or 0,
					graphic.quad[3] or tilesize,
					graphic.quad[4] or tilesize,
					graphic.ingameoffset[1] or 0,
					graphic.ingameoffset[2] or 0
				)
				--[[if tilename == "shortspikesS" then
					for ii=1, #masks[i] do
						local toprint = ""
						for iii=1, #masks[i][ii] do
							local toconcat = 0
							if masks[i][ii][iii] then toconcat = 1 end
							toprint = toprint .. toconcat
						end
						print(toprint)
					end
					print("====")
				end]]
				graphic.quad = love.graphics.newQuad(
					graphic.quad[1] or 0,
					graphic.quad[2] or 0,
					graphic.quad[3] or tilesize,
					graphic.quad[4] or tilesize,
					graphic.reference
				)
			end
		else
			graphic.reference = graphics.load(graphic.referencename)
			graphic.quad = love.graphics.newQuad(
				graphic.quad[1] or 0,
				graphic.quad[2] or 0,
				graphic.quad[3] or tilesize,
				graphic.quad[4] or tilesize,
				graphic.reference
			)
		end
	end
	if tile.makemask then --This is to supply your own mask if we're not doing it right. You can also supply a mask by literally just including a "mask" key pointing to a mask, and then not setting automask to true or including a makemask function. -Lirio
		tile.mask = tile:makemask()
	end
	if #masks > 0 then tile.mask = ormasks(masks) end
end
graphics.disposeimagedata() --comment this out and make referencedata a variable of each graphic if you ever need to access imagedata after generating masks

for objectname,object in pairs(objects) do
	if object.automask then
		object.mask = makecollisionmask(love.image.newImageData("imagery/" .. (object.maskimagename or objectname) .. ".png"))
	end
end

function strtobool(str) --lol
	local bools = {["true"] = true, ["false"] = false}
	return bools[str]
end

function booltostr(bool) --lol
	if(bool) then return "true" else return "false" end
end

writeto = {
	settings = function()
		--[=[
		local towrite = ""
		for i=1, #settingsargs do
			towrite = towrite .. booltostr(settings[settingsargs[i]]) .. "\n"
		end
		]=]
		local towrite = {}
		for i=1, #settingsargs do
			towrite[#towrite + 1] = booltostr(settings[settingsargs[i]])
		end
		love.filesystem.write("settings.txt",table.concat(towrite, "\n"))
	end,
	ogmoskin = function()
		love.filesystem.write("ogmoskin.txt",game.ogmoskin)
	end,
	unlockedcheats = function()
		local towrite = {}
		for i=1, #cheat.unlockedcheats do
			towrite[#towrite + 1] = cheat.unlockedcheats[i]
		end
		love.filesystem.write("unlockedcheats.txt",table.concat(towrite, "\n"))
	end,
	activecheats = function()
		local towrite = {}
		for i=1, #cheat.activecheats do
			towrite[#towrite + 1] = cheat.activecheats[i]
		end
		love.filesystem.write("activecheats.txt",table.concat(towrite, "\n"))
	end,
	controls = function()
		local towrite = ""
		local phase = nil
		for k,v in pairs(controls) do
			towrite = towrite "===" .. k .. "===\n|" .. v .. "\n"
		end
		love.filesystem.write("controls.txt",towrite)
	end
}

settingsargs = {
	"playaudio",
	"playsfx",
	"playmusic",
	"choice",
	"seetheunseeable"
}

settings = {
	playaudio = true,
	playsfx = true,
	playmusic = true,
	choice = nil,
	seetheunseeable = true
}

local settingsfile = love.filesystem.read("settings.txt")
if settingsfile ~= nil then
	settingsfile = correctnewlines(settingsfile) --probably unnecessary
	local ustemp = split(settingsfile, "\n")
	for i=1, #settingsargs do
		settings[settingsargs[i]] = strtobool(ustemp[i])
	end
else
	--Randomize the Choice variable the very first time the player starts the game, which should lead to some interesting results and reinforce that there is no canonical Choice value!
--	local choicerand = math.random()
	local choicerand = love.math.random(0, 1)
	if choicerand == 0 then choicerand = false
	else choicerand = true end
	settings.choice = choicerand
	writeto.settings()
end

controls = {}

do
	local controlsfile = love.filesystem.read("controls.txt")
	if controlsfile == nil then
		controlsfile = love.filesystem.read("defaultcontrols.txt")
		love.filesystem.write("controls.txt",controlsfile)
	end
	
	local phase = nil
	
	controlsfile = correctnewlines(controlsfile)
	controlsfile = split(controlsfile, "\n")
	for i, row in ipairs(controlsfile) do
		if string.sub(row, 1, 3) == "===" and string.sub(row, -3, -1) == "===" then
			phase = string.sub(row, 4, -4)
		else
			if string.sub(row, 1, 1) == "|" then row = string.sub(row, 2, -1) end
			if phase ~= nil then controls[phase] = row end
		end
	end
end

function love.load()
	if not settings.playaudio then love.audio.setVolume(0) end
	if not settings.playsfx then audio.changesfxvolume(0) end
	if not settings.playmusic then audio.changemusicvolume(0) end
	local unlockedcheats = split(correctnewlines(love.filesystem.read("unlockedcheats.txt") or ""), "\n")
	for i,v in ipairs(unlockedcheats) do
		local thischeat = cheat.get(v)
		if thischeat then print("cheat is unlocked: " .. v); thischeat.unlocked = true; table.insert(cheat.unlockedcheats, v) end
	end
	
	--kludge for automatically unlocking all cheats that are active but not unlocked
	local cheatset = {}
	for i,v in ipairs(cheat.unlockedcheats) do
		cheatset[v] = true
	end
	local activecheats = split(correctnewlines(love.filesystem.read("activecheats.txt") or ""), "\n")
	local updateunlocked = false
	for i,v in ipairs(activecheats) do
		if cheat.get(v) and not cheatset[v] then
			cheatset[v] = true
			print("cheat " .. v .. " was active but not unlocked, so it's unlocked now")
			table.insert(cheat.unlockedcheats, v)
			updateunlocked = true
		end
	end
	
	if updateunlocked then writeto.unlockedcheats() end
	
	menu.changeSubstate("title")
	statemachine.setstate("menu")
	
	for i,v in ipairs(activecheats) do
		local thischeat = cheat.get(v)
		if thischeat then print("starting with cheat: " .. v); cheat.invoke(thischeat) end
	end
	menu.changed.activecheats = false
end

function love.quit()
	menu.handleWrites()
end

function love.update(dt)
	if statemachine.currentstate ~= game then frameadvance = false end
	if not frameadvance then statemachine.currentstate.update(dt) end
	audio.update()
end

function love.keypressed(key)
	if statemachine.currentstate == game and key == "f" and allowframeadvance then frameadvance = not frameadvance end
	if frameadvance and key == "g" then statemachine.currentstate.update(dt) end
	statemachine.currentstate.keypressed(key)
	if key == "f1" and (statemachine.currentstate == editor or statemachine.currentstate == menu) then
		love.system.openURL("file://"..love.filesystem.getSaveDirectory().."/Jumper 4 Real.chm"); print("opening help file");
	end
end

function love.mousepressed(x, y, button)
	if statemachine.currentstate.mousepressed then
		statemachine.currentstate.mousepressed(x, y, button)
	end
end

function love.mousereleased(x, y, button)
	if statemachine.currentstate.mousereleased then
		statemachine.currentstate.mousereleased(x, y, button)
	end
end

function love.textinput(t)
	if statemachine.currentstate.textinput then
		statemachine.currentstate.textinput(t)
	end
end

function love.filedropped(file)
	if statemachine.currentstate.filedropped then
		statemachine.currentstate.filedropped(file)
	end
end

function love.wheelmoved(x, y)
	if statemachine.currentstate.wheelmoved then
		statemachine.currentstate.wheelmoved(x, y)
	end
end

function love.draw()
	statemachine.currentstate.draw()
	if statemachine.currentstate == game or statemachine.currentstate == editor then
		
	end
end