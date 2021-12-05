--print(love)
tilesize = 16
scale = 2

require "class"
require "split"
require "music"
require "levelsymbols"
require "tiles"
require "graphics"

require "game"
require "menu_substates"
require "menu"
require "editor_pages"
require "editor"
require "statemachine"

math.randomseed(os.time())

objects = {}
objectfiles = love.filesystem.getDirectoryItems("objection")
for i=1, #objectfiles do
	s = objectfiles[i]
	if string.sub(s, #s - 3) == ".lua" then
		object = require ("objection/" .. string.sub(s, 1, #s - 4))
		objects[string.sub(s, 1, #s - 4)] = object
	end
end

function strtobool(str)
	bools = {["true"] = true, ["false"] = false}
	return bools[str]
end

function booltostr(bool)
	if(bool) then return "true" else return "false" end
end

function writetouniversalsettings()
	towrite = ""
	for i=1, #universalsettingsargs do
		towrite = towrite .. booltostr(universalsettings[universalsettingsargs[i]]) .. "\r\n"
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
	local ustemp = split(universalsettingsfile, "\r\n")
	for i=1, #universalsettingsargs do
		universalsettings[universalsettingsargs[i]] = strtobool(ustemp[i])
	end
else
	--Randomize the Choice variable the very first time the player starts the game, which should lead to some interesting results and reinforce that there is no canonical Choice value!
	local choicerand = math.random()
	if choicerand == 0 then choicerand = false
	else choicerand = true end
	universalsettings.choice = choicerand
	writetouniversalsettings()
end

function love.load()
	statemachine.setstate("menu")
	if not universalsettings.playaudio then love.audio.setVolume(0) end
	if not universalsettings.playsfx then music:changesfxvolume(0) end
	if not universalsettings.playmusic then music:changemusicvolume(0) end
end

function love.update(dt)
	music:update()
	statemachine.currentstate.update(dt)
end

function love.keypressed(key)
	statemachine.currentstate.keypressed(key)
end

function love.draw()
	statemachine.currentstate.draw()
end