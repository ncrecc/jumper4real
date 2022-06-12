function hextocolor(hex, value)
	if type(hex) ~= "string" or #hex ~= 7 then
		error("malformed hex code passed to hextocolor (type " .. type(hex) .. ", contents " .. tostring(hex) .. ") - this may indicate a worse issue with level being malformed", 2)
	end
	return tonumber(string.sub(hex, 2, 3), 16)/256, tonumber(string.sub(hex, 4, 5), 16)/256, tonumber(string.sub(hex, 6, 7), 16)/256, value or 1
end