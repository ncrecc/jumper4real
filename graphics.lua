loadedgraphics = {}

graphics = {}

function graphics:load(graphicname)
	if loadedgraphics[graphicname] == nil then
		loadedgraphics[graphicname] = love.graphics.newImage("imagery/" .. graphicname .. ".png")
	end
	return loadedgraphics[graphicname]
end