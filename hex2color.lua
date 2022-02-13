function hextocolor(hex, value)
	if not hex then error("hex provided to hextocolor is nil", 2) end
	return tonumber(string.sub(hex, 2, 3), 16)/256, tonumber(string.sub(hex, 4, 5), 16)/256, tonumber(string.sub(hex, 6, 7), 16)/256, value or 1
end