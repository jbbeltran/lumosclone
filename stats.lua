module(..., package.seeall)
local utils = require("utils")

new = function ()
	
	------------------
	-- Groups
	------------------
	
	local localGroup = display.newGroup()
	
	------------------
	-- Your code here
	------------------
	
	local bkg = display.newImage(localGroup, "imgs/etc/bg.jpg", W/2, H/2)
	local mainMenuBtn = display.newImage(localGroup, "imgs/etc/btn_realm_back.png", -W/4, H/6)
	local normalModeGraphic = display.newImage(localGroup, "imgs/mainmenu/play_normal.png", W/4, H/3)
	local highscore = utils.warpTime({gameTime=utils.readScore()})
	local highScoreText = display.newText(localGroup, highscore, 3*W/4, H/3, native.systemFontBold, 64)
	
	local function main_menu(event)
		if event.phase == "began" then
			director:changeScene("main_menu", "crossfade")
		end
		return true
	end
	
	mainMenuBtn:addEventListener("touch", main_menu)
	
	------------------
	-- MUST return a display.newGroup()
	------------------
	
	localGroup.clean = function()
		mainMenuBtn:removeEventListener("touch", main_menu)
		localGroup:removeSelf()
	end
	
	return localGroup
	
end