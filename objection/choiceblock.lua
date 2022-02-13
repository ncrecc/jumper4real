choiceblock = class:new()

choiceblock.quads = {
	["solid"] = love.graphics.newQuad(0, 0, 16, 16, 32, 16),
	["pass"] = love.graphics.newQuad(16, 0, 16, 16, 32, 16)
}

function choiceblock.editordraw(x, y, options)
	inverse = false
	for i=1, #options do
		if options[i] == "inverse" then
			inverse = true
		end
	end
	local mystate = "pass"
	if (inverse and not settings.choice) or (not inverse and settings.choice) then mystate = "solid" end
	love.graphics.draw(graphics.load("choiceblock"), choiceblock.quads[mystate], x, y)
end

function choiceblock:init(x, y, inverse)
	self.type = "choiceblock"
	self.x = x
	self.y = y
	self.hmom = 0
	self.ymom = 0
	self.width = tilesize
	self.height = tilesize
	self.inverse = inverse
	self.solid = settings.choice
	if self.inverse then self.solid = not self.solid end
end

function choiceblock:setup(x, y, options)
	inverse = false
	for i=1, #options do
		if options[i] == "inverse" then
			inverse = true
		end
	end
	return choiceblock:new(x, y, inverse)
end

function choiceblock:update()
	--choiceblocks are boring and do nothing but be solid or solidn't
end

function choiceblock:draw()
	--me = "choiceblock_solid"
	--if (self.inverse and choice) or ((not self.inverse) and (not choice)) then me = "choiceblock_pass" end
	local mystate = "solid"
	if not self.solid then mystate = "pass" end
	love.graphics.draw(graphics.load("choiceblock"), choiceblock.quads[mystate], self.x, self.y)
end

return choiceblock