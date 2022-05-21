jumparrow = class:new()

jumparrow.automask = true

jumparrow.quads = {
	["active"] = love.graphics.newQuad(0, 0, 16, 16, 32, 16),
	["inactive"] = love.graphics.newQuad(16, 0, 16, 16, 32, 16)
}

function jumparrow.editordraw(x, y, options)
	love.graphics.draw(graphics.load("jumparrow"), jumparrow.quads["active"], x, y)
end

function jumparrow:init(x, y)
	self.type = "jumparrow"
	self.x = x
	self.y = y
	self.hmom = 0
	self.ymom = 0
	self.width = tilesize
	self.height = tilesize
	self.solid = false
	self.active = true
	self.inactivetimer = 0
	self.inactiveframes = 256
	self.passive = true -- "passive" objects ignore each other during the overlapscan. this is to help with a lag issue that can occur with too many objects doing dooverlapscan every frame and not immediately ruling each other out.
end

function jumparrow:setup(x, y, options)
	return jumparrow:new(x, y)
end

function jumparrow:update()
	if self.inactivetimer == 0 and not self.active then self.active = true
	else self.inactivetimer = self.inactivetimer - 1 end
	
	if self.active then
		local overlaps = mobtools.doOverlapScan(self, true)
		for _,obj in ipairs(overlaps) do
			if(obj.type == "ogmo") then
				if obj.jumps < (obj.defaultjumps - 1) then
					obj.jumps = obj.jumps + 1
				end
				self.active = false
				self.inactivetimer = self.inactiveframes
				break
			end
		end
	end
end

function jumparrow:draw()
	local mystate = "active"
	if not self.active then mystate = "inactive" end
	love.graphics.draw(graphics.load("jumparrow"), jumparrow.quads[mystate], self.x, self.y)
end

return jumparrow