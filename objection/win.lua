win = class:new()

function win:editorimg()
	return graphics:load("win")
end

function win:init(x, y, number)
	self.type = "win"
	self.number = number
	self.x = x
	self.y = y
	self.width = tilesize
	self.height = tilesize
end

function win:setup(x, y, options)
	tempnumber = 1
	if options ~= nil and options[1] ~= nil then tempnumber = tonumber(options[1]) end
	return win:new(x, y, tempnumber)
end

function win:update(checkonly)
	checkonly = checkonly or false
	for i=1, #loadedobjects do
		obj = loadedobjects[i]
		if obj ~= nil and obj.type == "ogmo" and not obj.gost then
			if math.abs(((obj.y) - self.y)) < self.height then
				if math.abs(((obj.x) - self.x)) < self.width then
					if not checkonly then
						game.win(self.number)
					end
				end
			end
		end
	end
end

function win:draw()
	if universalsettings.seetheunseeable then love.graphics.draw(graphics:load("win"), self.x, self.y) end
end

return win