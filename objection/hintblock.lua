hintblock = object:new()

function hintblock.editordraw(x, y, options)
	love.graphics.draw(graphics.load("hintblock"), x, y)
end

function hintblock:init(x, y, text, deep)
	self.type = "hintblock"
	self.x = x
	self.y = y
	self.hmom = 0
	self.ymom = 0
	self.width = tilesize
	self.height = tilesize
	self.solid = true
	self.text = text
	self.deep = deep
end

function hintblock:setup(x, y, options, level, edge, magicvalue)
	if not magicvalue then magicvalue = 1 end
	local text = "This is a hint."
	local deep = false
	if level.hints[magicvalue] then text = level.hints[magicvalue] end
	if level.options["deephint" .. magicvalue] then deep = true end
	text = string.gsub(text, "\\n", "\n")
	return hintblock:new(x, y, text, deep)
end

function hintblock:update()
end

function hintblock:onCollide(collidee, side)
	if not game.pausedfortextbox and side == "up" and collidee.player and not collidee.gost then
		if not self.deep then audio.playsfx("hint")
		else audio.playsfx("hint deep") end
		game.showtextbox(self.text)
	end
end

function hintblock:draw()
	love.graphics.draw(graphics.load("hintblock"), self.x, self.y)
end

return hintblock