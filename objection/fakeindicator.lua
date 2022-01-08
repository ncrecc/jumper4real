fakeindicator = class:new() --this one was initially just added for the editor's sake

function fakeindicator:editorimg()
	return graphics.load("fakeindicator")
end

function fakeindicator:init(x, y)
	self.type = "fakeindicator"
	self.number = number
	self.x = x
	self.y = y
	self.width = tilesize
	self.height = tilesize
end

function fakeindicator:setup(x, y)
	return fakeindicator:new(x, y)
end

function fakeindicator:update(checkonly)
	--it doesn't do anything! it's purely visual
end

function fakeindicator:draw()
	if universalsettings.seetheunseeable then love.graphics.draw(graphics.load("fakeindicator"), self.x, self.y) end
end

return fakeindicator