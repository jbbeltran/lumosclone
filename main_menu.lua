module(..., package.seeall)

new = function ()
	
	------------------
	-- Groups
	------------------
	
	local localGroup = display.newGroup()
	------------------
	-- Your code here
	------------------
	
	local bkg = display.newImage(localGroup, "imgs/etc/bg.jpg", W/2, H/2)
	--bkg:scale(H/bkg.contentWidth, W/bkg.contentHeight)
	local logo = display.newImage(localGroup, "imgs/mainmenu/logo.png", W/2, H/6)
	local normalModeBtn = display.newImage(localGroup, "imgs/mainmenu/play_normal.png", W/2, H/2)
	local statsBtn = display.newImage(localGroup, "imgs/mainmenu/highscores.png", W/2, 3*H/4)
	statsBtn:scale(2, 2)
	--local menuBgm = audio.loadStream("audio/bgm_menu2.mp3", {channel=1})
	--audio.play(menuBgm, {loops=-1})
	
	local function main_game(event)
		if event.phase == "began" then
			audio.pause(menuBgm)
			director:changeScene("main_game", "crossfade")
		end
		return true
	end
	
	local function stats(event)
		if event.phase == "began" then
			director:changeScene("stats", "crossfade")
		end
		return true
	end
	
	normalModeBtn:addEventListener("touch", main_game)
	statsBtn:addEventListener("touch", stats)
	------------------
	-- MUST return a display.newGroup()
	------------------
	
	localGroup.clean = function()
		normalModeBtn:removeEventListener("touch", main_game)
		statsBtn:removeEventListener("touch", stats)
		localGroup:removeSelf()
	end
	
	return localGroup
	
end