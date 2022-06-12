graphics = {}

graphics.loadedimages = {}
graphics.loadedimagedata = {}
graphics.genericquads = {}

function graphics.stringdimensions(imageorname)
	local image = imageorname
	if type(imageorname == "string") then image = graphics.load(imageorname) end
	local dimensions = image:getDimensions()
	return dimensions[1] .. "," .. dimensions[2]
end

function graphics.genericquad(quadstring)
	local new = false
	if graphics.genericquads[quadstring] == nil then
		new = true
		local quadinfo = split(quadstring, ",")
		graphics.genericquads[quadstring] = quad(
			quadinfo[1],
			quadinfo[2],
			quadinfo[3],
			quadinfo[4],
			quadinfo[5],
			quadinfo[6]
		)
	end
	return graphics.genericquads[quadstring], new
end

function graphics.load(imagename)
	local new = false
	if graphics.loadedimages[imagename] == nil then
		if not love.filesystem.getInfo("imagery/" .. imagename .. ".png") then return false end
		new = true
		graphics.loadedimages[imagename] = love.graphics.newImage("imagery/" .. imagename .. ".png")
	end
	return graphics.loadedimages[imagename], new
end

function graphics.supply(imagename, imageordata)
	local new = false
	if graphics.loadedimages[imagename] == nil then
		new = true
		if imageordata:typeOf("Image") then
			graphics.loadedimages[imagename] = imageordata
		elseif imageordata:typeOf("ImageData") then
			graphics.loadedimages[imagename] = love.graphics.newImage(imageordata)
		else
			error("mate you sent something to graphics.supply that isn't image or imagedata", 2)
		end
	end
	return graphics.loadedimages[imagename], new
end

function graphics.loadimagedata(imagename)
	local new = false
	if graphics.loadedimagedata[imagename] == nil then
		if not love.filesystem.getInfo("imagery/" .. imagename .. ".png") then return false end
		new = true
		graphics.loadedimagedata[imagename] = love.image.newImageData("imagery/" .. imagename .. ".png")
	end
	return graphics.loadedimagedata[imagename], new
end

function graphics.disposeimagedata()
	local nonempty = false
	
	graphics.loadedimagedata = {}
end