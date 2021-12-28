--any comments here are from bert if not otherwise specified
audio = {
	loadedsongs = {},
	activesong = nil,
	activesongoneshot = false,
	musicvolume = 1,
	sfxvolume = 1
}

function audio.stop()
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

function audio.pause()
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
	for k,v in pairs(audio.loadedsongs) do --this is literally the first time i've used pairs and the first time i realized you could just iterate through any table you want even if the keys aren't numerical. this project is probably doomed lol
		if v.intro or v.loop then
			if v.intro then v.intro:seek(0) end
			v.loop:seek(0)
			v.loop_playing = false
		else v:seek(0) end
	end
end

function audio.play(songname, oneshot, pauseold)
	oneshot = oneshot or false --is this even necessary --originally this referred to "oneshot or false" but is specifying it's a oneshot necessary at all? should this just be able to determine whether it's a oneshot on its own
	if pauseold then
		audio.pause()
	else
		audio.stop()
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

function audio.playsfx(soundname)
	local sfx = love.audio.newSource("audial/sfx/" .. soundname .. ".ogg", "static")
	sfx:setVolume(audio.sfxvolume)
	love.audio.play(sfx)
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
		audio.stop()
	end
	
end