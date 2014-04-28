local utils = require("utils")

local _M = {}

function _M.init()
	if not _M.initted then
		_M.initted = true
		_M.group = display.newGroup()
		_M.images = {}
		_M.active = {}
		--_M.newactive = {}
		_M.spawnTime = 0
		_M.flSpawnTime = 0
		_M.spawnFactor = 1
		_M.speedFactor = 1
		_M.speed = 150
		for i=1,4 do
			_M.images[i] = {}
		end
		_M.images[0] = "imgs/enemies/e_flick/level_0.png"
		_M.images[1][1] = "imgs/enemies/e_flick/level_1.png"
		_M.images[1][2] = "imgs/enemies/e_flick/level_1_1.png"
		_M.images[2][1] = "imgs/enemies/e_flick/level_2.png"
		_M.images[2][2] = "imgs/enemies/e_flick/level_2_1.png"
		_M.images[2][3] = "imgs/enemies/e_flick/level_2_2.png"
		_M.images[3][1] = "imgs/enemies/e_flick/level_3.png"
		_M.images[3][2] = "imgs/enemies/e_flick/level_3_1.png"
		_M.images[3][3] = "imgs/enemies/e_flick/level_3_2.png"
		_M.images[3][4] = "imgs/enemies/e_flick/level_3_3.png"
		_M.images[4][1] = "imgs/enemies/e_flick/level_4.png"
		_M.images[4][2] = "imgs/enemies/e_flick/level_4_1.png"
		_M.images[4][3] = "imgs/enemies/e_flick/level_4_2.png"
		_M.images[4][4] = "imgs/enemies/e_flick/level_4_3.png"
		_M.images[4][5] = "imgs/enemies/e_flick/level_4_4.png"
		
		_M.powerupDic = {
			["flare"] = 0
		}
		
		_M.level_distro = {
			[1] = {1},
			[2] = {1,2,2,2},
			[3] = {1,2,2,2,3,3,3,3,3,3},
			[4] = {2,3,3,3,3,3,3,3,4,4},
			[5] = {2,3,3,4,4,4,4,4,4,4}
		}
	end
end

function _M.getSpawnRate(gameTime)
	local sec = 1000
	if gameTime <= 8*sec then
		return 0
	elseif gameTime <= 16*sec then
		return 0.3
	elseif gameTime <= 24*sec then
		return 0
	elseif gameTime <= 80*sec then
		return 0.24
	elseif gameTime <= 120*sec then
		return 0.24
	elseif gameTime <= 160*sec then
		return 0.04
	elseif gameTime <= 190*sec then
		return 0.11
	elseif gameTime <= 240*sec then
		return 0.2
	elseif gameTime <= 260*sec then
		return 0.11
	elseif gameTime <= 320*sec then
		return 0.15
	elseif gameTime <= 360*sec then
		return 0.18
	elseif gameTime <= 400*sec then
		return 0.21
	else return 0.26 end
end

function _M.getLevel(gameTime)
	local sec = 1000
	local ind = 1
	if gameTime < 80*sec then
		ind = 1
	elseif gameTime < 160*sec then
		ind = 2
	elseif gameTime < 240*sec then
		ind = 3
	elseif gameTime < 300*sec then
		ind = 4
	else ind = 5 end
	return _M.level_distro[ind][math.random(1, #_M.level_distro[ind])]
end

function _M.spawn(args)
	local ret = {}
	ret.group = display.newGroup()
	local ent = ret.group
	ent.x, ent.y, ent.speed, ent.level, ent.life, ent.powerup, ent.prevTime = args.x, args.y, _M.speed, args.level, args.level, args.powerup, 0
	local imagePath = _M.images[_M.powerupDic[ent.powerup]] or _M.images[ent.level][1]
	ent.image = display.newImage(ret.group, imagePath, 0, 0)
	ent.image:scale(0.7, 0.7)
	ent.vx, ent.vy = utils.getNormal(args.x, args.y)
	ent.rotation = math.atan2(ent.vy, ent.vx)*(180/math.pi)+90
	
	_M.group:insert(ret.group)
	ret.group:addEventListener("touch", _M.kill)
	table.insert(_M.active, ret)
	return ret
end

function _M.degrade(args)
	local monster = args.obj.group
	if monster.life > 1 then
		monster.life = monster.life - 1
		monster.image:removeSelf()
		monster.image = nil
		monster.image = display.newImage(monster, _M.images[monster.level][monster.life+1], 0, 0)
		monster.image:scale(0.7, 0.7)
		monster.vx, monster.vy = utils.getNormal(monster.x, monster.y)
	else
		if monster.powerup == "flare" then
			_M.destroyAll()
		end
		args.obj.toKill = true
	end
end

function _M.kill(event)
	local t = event.target
	local p = event.phase
	if p == "began" then
		t.anchor = true
		t.prevTime = event.time
		t.x0, t.y0 = t.x, t.y
		display.getCurrentStage():setFocus(t)
		t.isFocus = true
	elseif t.isFocus then
		if p == "moved" then
			t.x, t.y = event.x, event.y
			local normvx, normvy = utils.getNormal(t.x0, t.y0, t.x, t.y)
			local currTime = event.time
			local elapsedTime = currTime-t.prevTime
			if elapsedTime <= 50 then elapsedTime = 50 end
			local speedx = (t.x-t.x0)/elapsedTime*1000
			local speedy = (t.y-t.y0)/elapsedTime*1000
			if speedx >= 300 then speedx = 300 end
			if speedx <= -300 then speedx = -300 end
			if speedy >= 300 then speedy = 300 end
			if speedy <= -300 then speedy = -300 end
			if math.abs(speedx) == 300 or math.abs(speedy) == 300 then 
				t.flinged = true
				t.vx, t.vy = 50*normvx, 50*normvy
			else
				t.flinged = false
			end
			t.prevTime = currTime
			t.x0, t.y0 = t.x, t.y
		elseif p == "ended" then
			t.anchor = false
			t.isFocus = false
			display.getCurrentStage():setFocus(nil)
		end
	end
	return true
end

function _M.destroy(monster)
	transition.to(monster, {time=500, alpha=0, onComplete=function () _M.group:remove(monster) end})
end

function _M.destroyAll()
	for k,v in ipairs(_M.active) do
		if not v.powerup then
			v.toKill = true
		end
	end
end

function _M.update(args)
	local currTime = args.gameTime
	local freshtable = {}
	for k,v in  next, _M.active do
		if v.toKill then
			v.group:removeEventListener("touch", _M.kill)
			_M.destroy(v.group)
		else
			table.insert(freshtable, v)
		end
	end
	_M.active = nil
	_M.active = freshtable
	local rate = _M.getSpawnRate(currTime)
	--print(rate)
	if rate > 0 and currTime - _M.spawnTime >= 1000/(_M.spawnFactor*rate) then
		local X, Y = utils.randomPos()
		_M.spawn({x=X, y=Y, level=_M.getLevel(currTime)})
		_M.spawnTime = currTime
	end
	for k,v in next, _M.active do
		local ent = v.group
		local newX, newY = ent.x, ent.y
		if not ent.anchor then
			if ent.x <= -10 or ent.x >= W+10 or ent.y <= -10 or ent.y >= H+10 then
				if ent.x <= -10 then newX = 0
				elseif ent.x >= W+10 then newX = W  end
				if ent.y <= -10 then newY = 0
				elseif ent.y >= H+10 then newY = H end
				
				if ent.flinged then
					ent.x, ent.y = newX, newY
					ent.vx, ent.vy = 0, 0
					local nvx, nvy = utils.getNormal(ent.x, ent.y)
					ent.speed = 0
					ent.rotation = math.atan2(nvy, nvx)*(180/math.pi)+90
					_M.degrade({obj=v})
					ent.flinged = false
					ent.vx, ent.vy = nvx, nvy
				elseif not ent.trans then
					ent.trans = true
					ent.vx, ent.vy = utils.getNormal(ent.x, ent.y)
					transition.to(ent, {time=500, x=newX, y=newY, rotation=math.atan2(ent.vy, ent.vx)*(180/math.pi)+90, onComplete=function() ent.trans = nil end})
				end
			else
				if ent.flinged then
					ent.x = ent.x+ent.vx
					ent.y = ent.y+ent.vy
				else
					ent.vx, ent.vy = utils.getNormal(ent.x, ent.y)
					ent.rotation = math.atan2(ent.vy, ent.vx)*(180/math.pi)+90
					ent.speed = ent.speed - 100/fps
					if ent.speed <= 0 then ent.speed = _M.speed end
					ent.x = ent.x+(ent.speed/fps*(_M.speedFactor*ent.vx))
					ent.y = ent.y+(ent.speed/fps*(_M.speedFactor*ent.vy))
				end
			end
		end
	end
end

function _M.purge()
	_M.initted = false
end

return _M