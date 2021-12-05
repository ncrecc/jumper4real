choiceblock = class:new()

function choiceblock.editorimg(options)
	inverse = false
	for i=1, #options do
		if options[i] == "inverse" then
			inverse = true
		end
	end
	--ignore choice for editor rendering
	me = "choiceblock_solid"
	if not inverse then me = "choiceblock_pass" end
	return graphics:load(me)
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
	self.solid = universalsettings.choice
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
	me = "choiceblock_solid"
	if not self.solid then me = "choiceblock_pass" end
	love.graphics.draw(graphics:load(me), self.x, self.y)
end

return choiceblock