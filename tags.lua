tags = {}
local tags_img = graphics.load("ui/tags")

for i=0, 9 do
	tags["spawn" .. i] = {
		name = "Spawn " .. i,
		tooltip = "apply to objects. this object will only be present if the player entered from entrance #" .. i, --bert
		kind = "object",
		quad = quad(i * 8, 0, 8, 8, tags_img)
	}
	if i == 0 then tags["spawn" .. i].rotations = {"spawn9", "spawn1"}
	elseif i == 9 then tags["spawn" .. i].rotations = {"spawn8", "spawn0"}
	else tags["spawn" .. i].rotations = {"spawn" .. (i - 1), "spawn" .. (i + 1)} end
end

for i=0, 9 do
	tags["variant" .. i] = {
		name = "Variant " .. i,
		tooltip = "apply to objects. use variant #" .. i .. " of this object. means different things for different objects, and has no effect on most", --bert
		kind = "object",
		quad = quad(i * 8, 8, 8, 8, tags_img)
	}
	if i == 0 then tags["variant" .. i].rotations = {"variant9", "variant1"}
	elseif i == 9 then tags["variant" .. i].rotations = {"variant8", "variant0"}
	else tags["variant" .. i].rotations = {"variant" .. (i - 1), "variant" .. (i + 1)} end
end

tags["nomoveuntilcollide"] = {
	name = "No Moving Until Collision",
	tooltip = "apply to an ogmo. it won't be able to move at the start of the level until it hits a solid tile. good for \"cutscene falling\"", --bert
	kind = "ogmo",
	quad = quad(0, 16, 8, 8, tags_img)
}

tags["preservecareen"] = {
	name = "Preserve Careening",
	tooltip = "apply to an ogmo. if last level was exited while exiting ogmo was careening from a launcher, this ogmo will careen in the same direction.", --bert
	kind = "ogmo",
	quad = quad(8, 16, 8, 8, tags_img)
}

tags["preservejumpstate"] = {
	name = "Preserve Jump State",
	tooltip = "apply to an ogmo. if last level was exited when exiting ogmo's double-jump was depleted, this ogmo starts with its double-jump depleted.", --bert
	kind = "ogmo",
	quad = quad(0, 24, 8, 8, tags_img)
}

local dirs = {"up", "right", "down", "left"}
local dirs_titlecase = {"Up", "Right", "Down", "Left"}

for i,v in ipairs(dirs) do
	tags["edge" .. v] = {
		name = "Edge " .. dirs_titlecase[i],
		tooltip = "apply to objects. this object will act as though it is on the " .. v .. " border of the level.", --bert
		kind = "object",
		quad = quad(16 + (i * 8), 16, 8, 8, tags_img)
	}
	tags["face" .. v] = {
		name = "Face " .. dirs_titlecase[i] .. "ward",
		tooltip = "apply to objects. makes this object face " .. v .. "ward, if applicable.", --bert
		kind = "object",
		quad = quad(16 + (i * 8), 24, 8, 8, tags_img)
	}
end

tags["edgenone"] = {
	name = "Edge None",
	tooltip = "apply to objects. this object will act as though it is not on any border of the level, even if it is.", --bert
	kind = "object",
	quad = quad(48, 16, 8, 8, tags_img)
}

tags["facerandom"] = {
	name = "Face Random",
	tooltip = "apply to objects. makes this object face in a random direction, if applicable.", --bert
	kind = "object",
	quad = quad(48, 24, 8, 8, tags_img)
}

tags["edgeup"].rotations = {"edgenone", "edgeright"}
tags["edgeright"].rotations = {"edgeup", "edgedown"}
tags["edgedown"].rotations = {"edgeright", "edgeleft"}
tags["edgeleft"].rotations = {"edgedown", "edgenone"}
tags["edgenone"].rotations = {"edgeleft", "edgeup"}

tags["faceup"].rotations = {"facerandom", "faceright"}
tags["faceright"].rotations = {"faceup", "facedown"}
tags["facedown"].rotations = {"faceright", "faceleft"}
tags["faceleft"].rotations = {"facedown", "facerandom"}
tags["facerandom"].rotations = {"faceleft", "faceup"}

tags["invisible"] = {
	name = "Invisible",
	tooltip = "apply anywhere. makes this object/tile invisible. WIP", --bert
	kind = "any",
	quad = quad(56, 16, 8, 8, tags_img)
}

tags["fake"] = {
	name = "Fake",
	tooltip = "apply anywhere. makes this object/tile unsolid and have no effect on anything else. WIP", --bert
	kind = "any",
	quad = quad(64, 16, 8, 8, tags_img)
}

tags["camerafocus"] = {
	name = "Camera Focus",
	tooltip = "apply to an ogmo. this ogmo will be prioritized for camera focus (if it spawns).", --bert
	kind = "ogmo",
	quad = quad(72, 16, 8, 8, tags_img)
}

tags["preservevmom"] = {
	name = "Bottom Edge: Preserve Vertical Momentum",
	tooltip = "apply to an ogmo. if on the bottom edge, this ogmo will use the exiting ogmo's upward momentum instead of a fixed boost.", --bert
	kind = "ogmo",
	quad = quad(8, 24, 8, 8, tags_img)
}