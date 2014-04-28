module(..., package.seeall)
local utils = require("utils")
local tap_monster = require("tap_monster")
local flick_monster = require("flick_monster")
local slash_monster = require("slash_monster")
local light = require("light")

new = function ()
	
	------------------
	-- Groups
	------------------
	
	local localGroup = display.newGroup()
	local pauseGroup = display.newGroup()
	local gameOverGroup = display.newGroup()
	tap_monster.init()
	flick_monster.init()
	slash_monster.init()
	light.init()
	------------------
	-- Your code here
	------------------
	
	local bkg = display.newImage(localGroup, "imgs/etc/bg.jpg", W/2, H/2)
	local frenzyBkg = display.newImage(localGroup, "imgs/etc/bg_frenzy.jpg", W/2, H/2)
	local lex = display.newImage("imgs/etc/explosion_ring.png", W/2, H/2)
	local lbex = display.newImage("imgs/powerups/light_bomb_explosion.png", 0, 0)
	local gameTimer = display.newText(localGroup, "", 0, H/6, native.systemFont, 28)
	
	local pauseBtn = display.newImage("imgs/etc/btn_realm_back.png", 5*W/4, H/6)
	local pauseLayer = display.newRect(pauseGroup, W/2, H/2, 2*W, H)
	local pauseGraphic = display.newImage(pauseGroup, "imgs/pause/pause.png", W/2, H/2)
	local pauseHeading = display.newText(pauseGroup, "PAUSED", W/2, H/2-(pauseGraphic.contentHeight/4), native.systemFontBold, 32)
	local resumeText = display.newText(pauseGroup, "resume", W/2, H/2-(pauseGraphic.contentHeight/8), native.systemFontBold, 28)
	local mainMenuText = display.newText(pauseGroup, "main menu", W/2, H/2, native.systemFontBold, 28)
	
	local gameOverLayer = display.newRect(gameOverGroup, W/2, H/2, 2*W, H)
	local gameOverGraphic = display.newImage(gameOverGroup, "imgs/gameover/bg.png", W/2, H/2)
	local gameOverHeading = display.newText(gameOverGroup, "A", W/2, H/2-(gameOverGraphic.contentHeight/4), native.systemFontBold, 64)
	local restartBtn = display.newImage(gameOverGroup, "imgs/gameover/restart.png", W/2-(gameOverGraphic.contentWidth/4), H/2+(gameOverGraphic.contentHeight/4), native.systemFontBold, 28)
	local mainMenuBtn = display.newImage(gameOverGroup, "imgs/gameover/menu.png", W/2+(gameOverGraphic.contentWidth/4), H/2+(gameOverGraphic.contentHeight/4), native.systemFontBold, 28)
	
	local actionLayer = display.newRect(W/2, H/2, W*2, H)
	
	localGroup:insert(light.group)
	localGroup:insert(slash_monster.group)
	localGroup:insert(tap_monster.group)
	localGroup:insert(flick_monster.group)
	localGroup:insert(actionLayer)
	localGroup:insert(lbex)
	localGroup:insert(lex)
	localGroup:insert(pauseGroup)
	localGroup:insert(gameOverGroup)
	localGroup:insert(pauseBtn)
	pauseLayer.alpha, gameOverLayer.alpha, frenzyBkg.alpha, actionLayer.alpha = 0.2, 0.2, 0, 0.01
	pauseLayer:setFillColor(0)
	gameOverLayer:setFillColor(0)
	pauseGroup.isVisible = false
	gameOverGroup.isVisible = false
	lbex:scale(1 + 900/lbex.contentWidth, 1 + 900/lbex.contentHeight)
	lbex.alpha = 0
	lex.alpha = 0
	
	local gameTime = 0
	local flareTime, frenzyTime = math.random(67,73), 0
	local flarePrevTime, frenzyPrevTime, frenzyDuration, frenzied = 0, 48*1000, 16*1000, false
	local paused = false
	--[[local gameBgm = audio.loadStream("audio/bgm.mp3", {channel=2})
	local frenzyBgm = audio.loadStream("audio/bgm_frenzy2.mp3", {channel=3})
	audio.play(gameBgm, {loops=-1})
	audio.play(frenzyBgm)
	audio.pause({channel=3})]]

	local function pause(event)
		if event.phase == "began" and not paused then
			audio.pause({channel=2})
			paused = true
			pauseGroup.isVisible = true
		end
		return true
	end
	
	local function unpause(event)
		if event.phase == "began" then
			audio.resume({channel=2})
			pauseGroup.isVisible = false
			paused = false
		end
		return true
	end
	
	local function gameOver(args)
		paused = true
		gameOverGroup.isVisible = true
		local sessionScore = args.gameTime
		gameOverHeading.text = utils.warpTime({gameTime=sessionScore})
		local highscore = utils.readScore()
		if sessionScore > highscore then
			utils.writeScore({highscore=sessionScore})
		end
	end
	
	local function main_game(event)
		if event.phase == "began" then
			director:changeScene("main_game", "crossfade")
		end
	end
	
	local function main_menu(event)
		if event.phase == "began" then
			director:changeScene("main_menu", "crossfade")
		end
		return true
	end
	
	local function tick()
		if paused then return end
		gameTime = gameTime + 1000/fps
		gameTimer.text = utils.warpTime({gameTime=gameTime})
		
		if not frenzied and gameTime-frenzyPrevTime >= frenzyTime then
			--[[audio.pause({channel=2})
			audio.rewind(frenzyBgm)
			audio.play({channel=3})]]
			frenzied = true
			frenzyTime = 60*1000
			tap_monster.spawnFactor, flick_monster.spawnFactor, slash_monster.spawnFactor = 1.22, 1.22, 1.22
			tap_monster.speedFactor, flick_monster.speedFactor, slash_monster.speedFactor = 1.33, 1.33, 1.33
			transition.to(bkg, {time=500, alpha = 0})
			transition.to(frenzyBkg, {time=500, alpha = 1})
		end
		if frenzied and gameTime-frenzyPrevTime >= frenzyDuration then
			--[[audio.fadeOut({channel=3, time=300})
			audio.play(gameBgm)]]
			frenzied = false
			frenzyPrevTime = gameTime
			tap_monster.spawnFactor, flick_monster.spawnFactor, slash_monster.spawnFactor = 1, 1, 1
			tap_monster.speedFactor, flick_monster.speedFactor, slash_monster.speedFactor = 1, 1, 1
			transition.to(bkg, {time=500, alpha = 1})
			transition.to(frenzyBkg, {time=500, alpha = 0})
		end
		
		local deathrow = {}
		local purgatory = {}
		local explode = nil
		local lr = light.lightRadius
		local triggerD2 = lr*lr
		local explosionD2 = 4*triggerD2
		
		if gameTime-flarePrevTime >= flareTime*1000 then
			flarePrevTime = gameTime
			flareTime = math.random(67,73)
			local whichFlare = math.random(1,3)
			local X, Y = utils.randomPos()
			if whichFlare == 1 then
				tap_monster.spawn({x=X, y=Y, level=1, powerup="flare"})
			elseif whichFlare == 2 then
				flick_monster.spawn({x=X, y=Y, level=1, powerup="flare"})
			else
				slash_monster.spawn({x=X, y=Y, level=1, life=1, powerup="flare"})
			end
		end
		
		--Powerup explosions
		if tap_monster.explosion then
			local explosionInfo = tap_monster.explosion
			if explosionInfo.radius ~= -1 then
				lbex.x, lbex.y = explosionInfo.x, explosionInfo.y
				transition.to(lbex, {time=500, alpha=1.0, transition=easing.continuousLoop, onComplete=function() lbex.alpha=0 end})
			end
			for k,v in next, tap_monster.active do
				if explosionInfo.radius == -1 and not v.powerup then
					table.insert(deathrow, v)
				elseif not v.powerup then
					local dx, dy = v.x-explosionInfo.x, v.y-explosionInfo.y
					if dx*dx + dy*dy <= explosionInfo.radius*explosionInfo.radius then
						table.insert(deathrow, v)
					end
				end
			end
			for k,v in next, flick_monster.active do
				if explosionInfo.radius == -1 and not v.powerup then
					table.insert(deathrow, v)
				elseif not v.powerup then
					local dx, dy = v.group.x-explosionInfo.x, v.group.y-explosionInfo.y
					if dx*dx + dy*dy <= explosionInfo.radius*explosionInfo.radius then
						table.insert(deathrow, v)
					end
				end
			end
			for k,v in next, slash_monster.active do
				if explosionInfo.radius == -1 and not v.powerup then
					table.insert(deathrow, v)
				elseif not v.powerup then
					for i=1,#v.snake do
						local dx, dy = v.snake[i]:localToContent(v.snake[i].x, v.snake[i].y)
						dx, dy = dx-explosionInfo.x, v.y-explosionInfo.y
						if dx*dx + dy*dy <= explosionInfo.radius*explosionInfo.radius then
							table.insert(deathrow, v)
							break
						end
					end
				end
			end
			tap_monster.explosion = nil
		end
		
		--Light explosions
		for k,v in next, tap_monster.active do
			local dx, dy = v.x-(W/2), v.y-(H/2)
			if dx*dx + dy*dy <= explosionD2 and not v.powerup then table.insert(purgatory, v) end
			if dx*dx + dy*dy <= triggerD2 then
				if not v.powerup then
					explode = true
				elseif v.powerup == "flare" then
					table.insert(deathrow, v)
					light.lightRadius = light.lightRadius + 32
					light.light:scale(1+(32/light.lightRadius), 1+(32/light.lightRadius))
				elseif v.powerup == "lightbomb" then
					table.insert(deathrow, v)
					light.lightRadius = light.lightRadius + 16
					light.light:scale(1+(16/light.lightRadius), 1+(16/light.lightRadius))
				elseif v.powerup == "electroblast" then
					table.insert(deathrow, v)
					light.lightRadius = light.lightRadius + 64
					light.light:scale(1+(64/light.lightRadius), 1+(64/light.lightRadius))
				end
			end
		end
		for k,v in next, flick_monster.active do
			local dx, dy = v.group.x-(W/2), v.group.y-(H/2)
			if dx*dx + dy*dy <= explosionD2 and not v.powerup then table.insert(purgatory, v) end
			if dx*dx + dy*dy <= triggerD2 then
				if not v.powerup then
					explode = true
				elseif v.powerup == "flare" then
					table.insert(deathrow, v)
					light.lightRadius = light.lightRadius + 32
					light.light:scale(1+(32/light.lightRadius), 1+(32/light.lightRadius))
				end
			end
		end
		for k,v in next, slash_monster.active do
			local dx, dy = v.x-(W/2), v.y-(H/2)
			if dx*dx + dy*dy <= explosionD2 and not v.powerup then table.insert(purgatory, v) end
			if dx*dx + dy*dy <= triggerD2 then
				if not v.powerup then
					explode = true
				elseif v.powerup == "flare" then
					table.insert(deathrow, v)
					light.lightRadius = light.lightRadius + 32
					light.light:scale(1+(32/light.lightRadius), 1+(32/light.lightRadius))
				end
			end
		end
		
		for k,v in next, deathrow do
			v.toKill = true
		end
		
		if explode then
			--[[lex:scale(1 + 2*light.lightRadius/lex.contentWidth, 1 + 2*light.lightRadius/lex.contentHeight)
			transition.to(lex, {time=500, alpha=1.0, transition=easing.continuousLoop, onComplete=function()
					lex:scale(1 - 2*light.lightRadius/lex.contentWidth, 1 - 2*light.lightRadius/lex.contentHeight)
					end
				})]]
			
			for k,v in next, purgatory do
				v.toKill = true
			end
			if light.lightRadius/2 >= 8 then
				light.lightRadius = light.lightRadius/2
				light.light:scale(0.5, 0.5)
			else
				gameOver({gameTime=gameTime})
				return
			end
		end
		
		for k,v in next, light.active do
			local dx, dy = v.x-(W/2), v.y-(H/2)
			local collide = dx*dx + dy*dy <= light.lightRadius*light.lightRadius
			if collide and v.typ == "photon" then
				light.lightRadius = light.lightRadius+1
				light.light:scale(1+(1/light.lightRadius), 1+(1/light.lightRadius))
				light.photonCount = light.photonCount - 1
				v.toKill = true
			end
		end
		light.update({gameTime=gameTime})
		tap_monster.update({gameTime=gameTime})
		flick_monster.update({gameTime=gameTime})
		slash_monster.update({gameTime=gameTime})
	end
	
	actionLayer:addEventListener("touch", tap_monster.kill)
	actionLayer:addEventListener("touch", slash_monster.slash)
	actionLayer:addEventListener("touch", light.collect)
	Runtime:addEventListener("enterFrame", tick)
	pauseLayer:addEventListener("touch", function() return true end)
	pauseBtn:addEventListener("touch", pause)
	restartBtn:addEventListener("touch", main_game)
	mainMenuBtn:addEventListener("touch", main_menu)
	resumeText:addEventListener("touch", unpause)
	mainMenuText:addEventListener("touch", main_menu)
	------------------
	-- MUST return a display.newGroup()
	------------------
	
	localGroup.clean = function()
		actionLayer:removeEventListener("touch", tap_monster.kill)
		actionLayer:removeEventListener("touch", slash_monster.slash)
		actionLayer:removeEventListener("touch", light.collect)
		Runtime:removeEventListener("enterFrame", tick)
		pauseLayer:removeEventListener("touch", function() return true end)
		pauseBtn:removeEventListener("touch", pause)
		restartBtn:removeEventListener("touch", main_game)
		mainMenuBtn:removeEventListener("touch", main_menu)
		resumeText:removeEventListener("touch", unpause)
		mainMenuText:removeEventListener("touch", main_menu)
		tap_monster.purge()
		flick_monster.purge()
		slash_monster.purge()
		light.purge()
		localGroup:removeSelf()
	end
	
	return localGroup
	
	
end