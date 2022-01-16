graphics = {}

graphics.loadedgraphics = {}
graphics.storedimagedata = {}
--graphics.loadedquads = {}

function graphics.load(graphicname)
	if graphics.loadedgraphics[graphicname] == nil then
		graphics.loadedgraphics[graphicname] = love.graphics.newImage("imagery/" .. graphicname .. ".png")
	end
	return graphics.loadedgraphics[graphicname]
end

function graphics.getimagedata(graphicname)
	if graphics.storedimagedata[graphicname] == nil then
		graphics.storedimagedata[graphicname] = love.graphics.newImageData("imagery/" .. graphicname .. ".png")
	end
	return graphics.storedimagedata[graphicname]
end

function graphics.disposeimagedata()
	graphics.storedimagedata = {}
end