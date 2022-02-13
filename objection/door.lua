door = class:new()

function door.editordraw(x, y, options)
	love.graphics.draw(graphics.load("door"), x, y)
end

function door:init(x, y, magicvalue) --typoed magicvalue as "nagucvakye" which sounds icelandic or something
	self.type = "door"
	self.x = x
	self.y = y
	self.hmom = 0
	self.ymom = 0
	self.width = tilesize
	self.height = tilesize
	self.solid = false
	self.magicvalue = magicvalue
	self.keytoprint = nil
	self.invalid = false
end

function door:setup(x, y, options, level, edge, magicvalue)
	return door:new(x, y, magicvalue)
end

function door:update()
	if (not self.invalid) and self.level.exits[self.magicvalue] == "" or not self.level.exits[self.magicvalue] then
		self.invalid = true
	end
	self.keytoprint = nil
	if not self.invalid then
		local overlaps = mobtools.doOverlapScan(self, true)
		for _,obj in ipairs(overlaps) do
			if obj.player and (not obj.gost) and obj.grounded then
				self.keytoprint = controls["P" .. obj.playerno .. "INTERACT"]
			end
		end
	end
end

function door:onInteract(interactor)
	if not self.invalid then
		local obj = interactor
		if obj.player and (not obj.gost) and obj.grounded and not obj.level.frozen then
			audio.playsfx("door")
			game.win(self.magicvalue or 1, self.level)
		end
	end
end

function door:draw()
	love.graphics.draw(graphics.load("door"), self.x, self.y)
	if self.keytoprint then
		printWithOutline(self.keytoprint, self.x + 4, self.y - tilesize) --+4 is completely arbitrary because i don't feel like centering it properly right now
	end
end

return door