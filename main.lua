--print(love)
--^it's tables all the way down man -bert
tilesize = 16
scale = 1

--print("boop bop mother fuckers")
--print(type(nil) == nil) this one exercise in pil got me, lol

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

require "game"
require "textfield"
require "button"
require "menu_substates"
require "menu"
require "editor_pages"
require "editor"
require "statemachine"

require "mobtools"

--math.randomseed(os.time())

function math.clamp(x, a, b) --help me i went down a rabbit hole of different methods of clamping. also this was originally for makecollisionmask to determine what range it should iterate in but i found it a lot easier to just don't impose restrictions on the for loops and don't do anything if getpixel returns nil
  return math.max(a, math.min(b, x))
end

objects = {}
objectfiles = love.filesystem.getDirectoryItems("objection")
for i=1, #objectfiles do
	s = objectfiles[i]
	if string.sub(s, #s - 3) == ".lua" then
		object = require ("objection/" .. string.sub(s, 1, #s - 4))
		objects[string.sub(s, 1, #s - 4)] = object
	end
end


function makecollisionmask(imgdata, offsetx, offsety)
	local mask = {}
	local maskheight = tilesize
	local maskwidth = tilesize
	for i=1, maskheight do mask[i] = {} end
	if offsetx == nil then offsetx = 0 end
	if offsety == nil then offsety = 0 end
	for i = offsety, maskheight + offsety - 1 do
		for ii = offsetx, maskwidth + offsetx - 1 do
			local value = false
			local r, g, b, a = imgdata:getPixel(ii, i)
			if a ~= nil and a > 0.75 then value = true end
			mask[i - offsety + 1][ii - offsety + 1] = value
		end
	end
	
	return mask
end

function ormasks(masks) --all masks must be the same size for this to work as intended
	local mask = masks[1]
	for y=1, #mask do
		for x=1, #mask[y] do
			result = false
			for masknum=2, #masks do
				if masks[masknum][y][x] then
					result = true
					break
				end
			end
			mask[y][x] = result
		end
	end
	return mask
end

for k,v in pairs(tiles) do
	local tile = v
	local tilename = k
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
			masks = {}
			for i=1, #tile.gfxoverride do
				masks[i] = makecollisionmask(love.image.newImageData("imagery/" .. tile.gfxoverride[i] .. ".png"), -1 * tile.gfxoverrideoffsets[i][1], -1 * tile.gfxoverrideoffsets[i][2])
			end
			tile.mask = ormasks(masks)
		else
			tile.mask = makecollisionmask(love.image.newImageData("imagery/" .. tilename .. ".png"), -1 * tile.gfxoffsets[1], -1 * tile.gfxoffsets[2])
		end
	end
end

for k,v in pairs(objects) do
	local object = v
	local objectname = k
	if object.gfxoffsets == nil then
		object.gfxoffsets = {0, 0}
	end
	if object.gfxoverride ~= nil and object.gfxoverrideoffsets == nil then
		object.gfxoverrideoffsets = {}
		for i=1, #object.gfxoverride do
			object.gfxoverrideoffsets[i] = {0, 0}
		end
	end
	if object.automask then
		object.mask = makecollisionmask(love.image.newImageData("imagery/" .. objectname .. ".png"), -1 * object.gfxoffsets[1], -1 * object.gfxoffsets[2])
	end
end

function strtobool(str) --lol
	bools = {["true"] = true, ["false"] = false}
	return bools[str]
end

function booltostr(bool) --lol
	if(bool) then return "true" else return "false" end
end

function writetouniversalsettings()
	towrite = ""
	for i=1, #universalsettingsargs do
		towrite = towrite .. booltostr(universalsettings[universalsettingsargs[i]]) .. "\n"
	end
	love.filesystem.write("universalsettings.txt",towrite)
end

universalsettingsargs = {
	"playaudio",
	"playsfx",
	"playmusic",
	"choice",
	"seetheunseeable"
}

universalsettings = {
	playaudio = true,
	playsfx = true,
	playmusic = true,
	choice = nil,
	seetheunseeable = true
}

universalsettingsfile = love.filesystem.read("universalsettings.txt")
if universalsettingsfile ~= nil then
	correctnewlines(universalsettingsfile) --probably unnecessary
	local ustemp = split(universalsettingsfile, "\n")
	for i=1, #universalsettingsargs do
		universalsettings[universalsettingsargs[i]] = strtobool(ustemp[i])
	end
else
	--Randomize the Choice variable the very first time the player starts the game, which should lead to some interesting results and reinforce that there is no canonical Choice value!
--	local choicerand = math.random()
	local choicerand = love.math.random(0, 1)
	if choicerand == 0 then choicerand = false
	else choicerand = true end
	universalsettings.choice = choicerand
	writetouniversalsettings()
end

function love.load()
	if not universalsettings.playaudio then love.audio.setVolume(0) end
	if not universalsettings.playsfx then audio.changesfxvolume(0) end
	if not universalsettings.playmusic then audio.changemusicvolume(0) end
	statemachine.setstate("menu")
end

function love.update(dt)
	audio.update()
	statemachine.currentstate.update(dt)
end

function love.keypressed(key)
	statemachine.currentstate.keypressed(key)
end

function love.mousepressed(x, y, button)
	if statemachine.currentstate.mousepressed ~= nil then
		statemachine.currentstate.mousepressed(x, y, button)
	end
end

function love.mousereleased(x, y, button)
	if statemachine.currentstate.mousereleased ~= nil then
		statemachine.currentstate.mousereleased(x, y, button)
	end
end

function love.textinput(t)
	if statemachine.currentstate.textinput ~= nil then
		statemachine.currentstate.textinput(t)
	end
end

function love.draw()
	statemachine.currentstate.draw()
end