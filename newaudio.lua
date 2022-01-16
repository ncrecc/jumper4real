--any comments here are from bert if not otherwise specified
audio = {
	loadedsongs = {},
	activesong = nil,
	loadedsfx = {},
	sfxplaying = {},
	activesongoneshot = false,
	musicvolume = 1,
	oldmusicvolume = 1, --potentially for music going quiet when you pause. in practice though, the music itself will probably pause, or have a highpass filter applied
	sfxvolume = 1,
	oldsfxvolume = 1
}

weakkey = {__mode = "k"}
weakvalue = {__mode = "v"}

setmetatable(audio.sfxplaying, weakkey) --audio.sfxplaying uses objects as its keys, so that each sound effect is unique to an object ("sourceless" sounds can be assigned to gamestates)

function audio.stopsong()
	if audio.activesong ~= nil then
		song = audio.loadedsongs[audio.activesong]
		if audio.activesongoneshot then
			song:stop()
		else
			song.loop_playing = false
			if song.intro ~= nil then song.intro:stop() end
			song.loop:stop()
		end
	end
	audio.activesong = nil
	audio.activesongoneshot = false
end

function audio.pausesong()
	if audio.activesong ~= nil then
		song = audio.loadedsongs[audio.activesong]
		if audio.activesongoneshot then
			song:pause()
		else
			--preserve song.loop_playing
			if song.intro ~= nil then song.intro:pause() end
			song.loop:pause()
		end
	end
end

function audio.flushpauses()
	for _,song in pairs(audio.loadedsongs) do
		if song.intro or song.loop then
			if song.intro then song.intro:seek(0) end
			song.loop:seek(0)
			song.loop_playing = false
		else v:seek(0) end
	end
end

function audio.playsong(songname, oneshot, pauseold)
	--is specifying it's a oneshot necessary? should this just be able to determine whether it's a oneshot on its own
	if pauseold then
		audio.pausesong()
	else
		audio.stopsong()
	end
	if audio.loadedsongs[songname] == nil then
		if not oneshot then
			audio.loadedsongs[songname] = {
				loop_playing = false, --initially this was for a dumb kludge to play the loop again when it wasn't already playing because i had no idea :setLooping() was a thing. i have no idea why i kept this. helps with pause() a bit i guess
				loop = love.audio.newSource("audial/" .. songname .. " loop.ogg", "stream")
			}
			if love.filesystem.getInfo("audial/" .. songname .. " intro.ogg") then
				audio.loadedsongs[songname].intro = love.audio.newSource("audial/" .. songname .. " intro.ogg", "stream")
			end
		else
			audio.loadedsongs[songname] = love.audio.newSource("audial/" .. songname .. ".ogg", "stream")
		end
	end
	song = audio.loadedsongs[songname]
	if oneshot then
		song:setVolume(audio.musicvolume)
		love.audio.play(song)
		audio.activesongoneshot = true
	else
		if song.intro ~= nil then
			song.intro:setVolume(audio.musicvolume)
		end
		song.loop:setVolume(audio.musicvolume)
		if song.intro ~= nil and not song.loop_playing then
			love.audio.play(song.intro)
		else
			song.loop:setLooping(true)
			love.audio.play(song.loop)
			song.loop_playing = true
		end
		audio.activesongoneshot = false
	end
	audio.activesong = songname
	print("now playing: " .. audio.activesong)
end

function audio.playsfx(object, soundname, looping)
	if not audio.loadedsfx[soundname] then audio.loadedsfx[soundname] = love.audio.newSource("audial/sfx/" .. soundname .. ".ogg", "static") end
	local sfx = audio.loadedsfx[soundname]:clone()
	sfx:setVolume(audio.sfxvolume)
	if looping then
		sfx:setLooping(true)
	end
	if not audio.sfxplaying[object] then
		audio.sfxplaying[object] = {}
		audio.sfxplaying[object][soundname] = {}
	end
	if not audio.sfxplaying[object][soundname] then
		audio.sfxplaying[object][soundname] = {}
	end
	
	local newtable = {["sfx"] = sfx, ["looping"] = looping}
	setmetatable(newtable, weakvalue)
	table.insert(audio.sfxplaying[object][soundname], {["sfx"] = sfx, ["looping"] = looping})
	love.audio.play(sfx)
end

function audio.stopsfx(object, soundname, mode)
	if audio.sfxplaying[object].soundname then
		local soundarray = audio.sfxplaying[object][soundname]
		if mode == "first" then
			soundarray[1].sfx:stop()
			table.remove(soundarray, 1)
		elseif mode == "last" then
			soundarray[#soundarray].sfx:stop()
			table.remove(soundarray, #soundarray)
		elseif mode == "all" then
			for i=1, #soundarray do
				soundarray[i].sfx:stop()
			end
		end
	end
	audio.loopingsfx[soundname] = nil
end

function audio.stoploopingsfxall()
	for _,sound in pairs(audio.loopingsfx) do
		sound:stop()
	end
	audio.loopingsfx = {}
end

function audio.changemusicvolume(vol)
	audio.musicvolume = vol
	if audio.activesong ~= nil and audio.loadedsongs[audio.activesong] ~= nil then
		song = audio.loadedsongs[audio.activesong]
		if audio.activesongoneshot then
			song:setVolume(vol)
		else
			if song.intro ~= nil then song.intro:setVolume(vol) end
			song.loop:setVolume(vol)
		end
	end
end

function audio.changesfxvolume(vol)
	audio.sfxvolume = vol
end

function audio.update()
	if (not audio.activesongoneshot) and (audio.activesong ~= nil) then
		song = audio.loadedsongs[audio.activesong]
		if (not song.loop_playing) and (not song.loop:isPlaying()) and (song.intro ~= nil and not song.intro:isPlaying()) then
			song.loop:setLooping(true)
			love.audio.play(song.loop)
			song.loop_playing = true
		end
	end
	if audio.activesongoneshot and not audio.loadedsongs[audio.activesong]:isPlaying() then
		print("stopping " .. audio.activesong)
		audio.stopsong()
	end
	
end