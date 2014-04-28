local director = require("director")

W, H = display.contentWidth, display.contentHeight
fps = 30

local mainGroup = display.newGroup()
local main = function ()
	director:changeScene({from_start=true}, "main_menu")
	return true
end

main()
