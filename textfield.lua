textfield = class:new()

function textfield:init(x, y, width, height, id, textsource, tooltip)
	self.id = id
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.focus = false
	self.textsource = textsource
	self.tooltip = tooltip
end

function textfield:setup(x, y, width, height, id, textsource, tooltip)
	return textfield:new(x, y, width, height, id, textsource, tooltip)
end

function textfield:update()
end

function textfield:draw()
	local r, g, b, a = love.graphics.getColor()
	
	local unfocusoutercolor = 0.4
	local unfocusinnercolor = 0.6
	local focusoutercolor = 0.6
	local focusinnercolor = 0.8
	
	local oc = unfocusoutercolor
	local ic = unfocusinnercolor
	if self.focus then
		oc = focusoutercolor
		ic = focusinnercolor
	end
	
	love.graphics.setColor(oc, oc, oc)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	if self.width >= 3 then
		love.graphics.setColor(ic, ic, ic)
		love.graphics.rectangle("fill", self.x + 1, self.y + 1, self.width - 2, self.height - 2)
	end
	if self.textsource ~= nil then
		local texttoprint = editor[self.textsource]
		if self.focus then
			texttoprint = texttoprint .. "|"
		end
		love.graphics.setColor(0, 0, 0)
		love.graphics.print(texttoprint, self.x + 1, self.y + 1)
	end
	love.graphics.setColor(r, g, b, a)
end

--return textfield