--any comments here are from bert if not otherwise specified
music = {
	loadedsongs = {},
	activesong = nil,
	activesongoneshot = false,
	musicvolume = 1,
	sfxvolume = 1
}

function music:stop()
	if self.activesong ~= nil then
		song = self.loadedsongs[self.activesong]
		if self.activesongoneshot then
			song:stop()
		else
			song.loop_playing = false
			if song.intro ~= nil then song.intro:stop() end
			song.loop:stop()
		end
	end
end

function music:pause()
	if self.activesong ~= nil then
		song = self.loadedsongs[self.activesong]
		if self.activesongoneshot then
			song:pause()
		else
			--preserve song.loop_playing
			if song.intro ~= nil then song.intro:pause() end
			song.loop:pause()
		end
	end
end

function music:flushpauses()
	for k,v in pairs(music.loadedsongs) do --this is literally the first time i've used pairs and the first time i realized you could just iterate through any table you want even if the keys aren't numerical. this project is probably doomed lol
		if v.intro or v.loop then
			if v.intro then v.intro:seek(0) end
			v.loop:seek(0)
			v.loop_playing = false
		else v:seek(0) end
	end
end

function music:play(songname, oneshot, pauseold)
	oneshot = oneshot or false --is this even necessary --originally this referred to "oneshot or false" but is specifying it's a oneshot necessary at all? should this just be able to determine whether it's a oneshot on its own
	if pauseold then
		self:pause()
	else
		self:stop()
	end
	if self.loadedsongs[songname] == nil then
		if not oneshot then
			self.loadedsongs[songname] = {
				loop_playing = false, --initially this was for a dumb kludge to play the loop again when it wasn't already playing because i had no idea :setLooping() was a thing. i have no idea why i kept this. helps with pause() a bit i guess
				loop = love.audio.newSource("audial/" .. songname .. " loop.ogg", "stream")
			}
			if love.filesystem.getInfo("audial/" .. songname .. " intro.ogg") then
				self.loadedsongs[songname].intro = love.audio.newSource("audial/" .. songname .. " intro.ogg", "stream")
			end
			self.activesongoneshot = false
		else
			self.loadedsongs[songname] = love.audio.newSource("audial/" .. songname .. ".ogg", "stream")
			self.activesongoneshot = true
		end
	end
	song = self.loadedsongs[songname]
	if oneshot then
		song:setVolume(music.musicvolume)
		love.audio.play(song)
	else
		if song.intro ~= nil then
			song.intro:setVolume(music.musicvolume)
		end
		song.loop:setVolume(music.musicvolume)
		if song.intro ~= nil and not song.loop_playing then
			love.audio.play(song.intro)
		else
			song.loop:setLooping(true)
			love.audio.play(song.loop)
			song.loop_playing = true
		end
	end
	self.activesong = songname
end

function music:playsfx(soundname) --this needs to be renamed from "music" to "audio" at some point lol. not sure why i named it music
	local sfx = love.audio.newSource("audial/sfx/" .. soundname .. ".ogg", "static")
	sfx:setVolume(music.sfxvolume)
	love.audio.play(sfx)
end

function music:changemusicvolume(vol)
	music.musicvolume = vol
	song = self.loadedsongs[self.activesong]
	if self.activesongoneshot then
		song:setVolume(vol)
	else
		if song.intro ~= nil then song.intro:setVolume(vol) end
		song.loop:setVolume(vol)
	end
end

function music:changesfxvolume(vol)
	music.sfxvolume = vol
end

function music:update()
	if (not self.activesongoneshot) and (self.activesong ~= nil) then
		song = self.loadedsongs[self.activesong]
		if (not song.loop_playing) and (not song.loop:isPlaying()) and (song.intro ~= nil and not song.intro:isPlaying()) then
			song.loop:setLooping(true)
			love.audio.play(song.loop)
			song.loop_playing = true
		end
	end
end