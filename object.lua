object = class:new()
obj = object

object.type = "default_obj"
object.default_obj_img = graphics.load("default_obj")

function object:init(x, y)
	self.x = x
	self.y = y
	self.hmom = 0
	self.ymom = 0
	self.width = tilesize
	self.height = tilesize
end

function object:update() end

function object:draw()
	local myimage = graphics.load(object.type) or graphics.load("default_obj")
	love.graphics.draw(myimage, self.x, self.y)
end

function object:remove(level, index)
	if not level then level = self.level end
	if index then table.remove(level.objects, index)
	else
		for i,v in ipairs(level.objects) do
			if v == self then
				table.remove(level.objects, i); break;
			end
		end
	end
end

object.my_test_value = "zoinks"