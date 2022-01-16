--took me embarrassingly long to come up with this (2 days) after we realized github changes all cr lf to lf and i swore at the comp sci gods for making me suffer. -bert
function correctnewlines (str)
	local newstr = string.gsub(str, "\r\n", "\n")
	newstr = string.gsub(newstr, "\r", "\n")
	return newstr
end