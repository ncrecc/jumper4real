win = class:new()

function win:editorimg()
	return graphics.load("win")
end

function win:init(x, y, edge, magicvalue)
	self.type = "win"
	self.x = x
	self.y = y
	self.width = tilesize
	self.height = tilesize
	self.edge = edge
	self.magicvalue = magicvalue
end

function win:setup(x, y, options, level, edge, magicvalue)
	return win:new(x, y, edge, magicvalue)
end

function win:update()
	local winners = {}
	if not self.edge then winners = mobtools.doOverlapScan(self, true)
	else winners = mobtools.doPastEdgeScan(self, self.edge, true) end
	for _,obj in ipairs(winners) do
		if obj.player and (not obj.gost) and obj.initializationdone and (not obj.cutscenemovement) then
			game.win(self.magicvalue or 1, self.level) --magicvalue is given by "magic number" levelsymbols
			break
		end
	end
end

function win:draw()
	if settings.seetheunseeable then love.graphics.draw(graphics.load("win"), self.x, self.y) end
	--[[
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(0, 0, 0, 1)
	if     self.edge == "down"  then love.graphics.print("v", self.x, self.y)
	elseif self.edge == "right" then love.graphics.print(">", self.x, self.y)
	elseif self.edge == "left"  then love.graphics.print("<", self.x, self.y)
	elseif self.edge == "up"    then love.graphics.print("^", self.x, self.y) end
	love.graphics.setColor(r, g, b, a)
	]]
end

return win