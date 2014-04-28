local utils = require("utils")

local _M = {}
local lbTime, ebTime = math.random(19, 25), math.random(57, 63)

function _M.init()
	if not _M.initted then
		_M.initted = true
		_M.group = display.newGroup()
		_M.images = {}
		_M.active = {}
		_M.newactive = {}
		_M.spawnTime, _M.lbSpawnTime, _M.ebSpawnTime = 0, 0, 0
		_M.spawnFactor = 1
		_M.speedFactor = 1
		_M.speed = 1
		_M.images[0] = "imgs/enemies/e_tap/level_0.png"
		_M.images[1] = "imgs/enemies/e_tap/level_1.png"
		_M.images[2] = "imgs/enemies/e_tap/level_2.png"
		_M.images[3] = "imgs/enemies/e_tap/level_3.png"
		_M.images[4] = "imgs/enemies/e_tap/level_4.png"
		_M.images[5] = "imgs/powerups/light_bomb.png"
		_M.images[6] = "imgs/powerups/electroblast.png"
		
		_M.powerupDic = {
			["lightbomb"] = 5,
			["electroblast"] = 6,
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
		return 2
	elseif gameTime <= 16*sec then
		return 0
	elseif gameTime <= 24*sec then
		return 0
	elseif gameTime <= 80*sec then
		return 2.1
	elseif gameTime <= 120*sec then
		return 1.6
	elseif gameTime <= 160*sec then
		return 1.6
	elseif gameTime <= 190*sec then
		return 1.8
	elseif gameTime <= 240*sec then
		return 2.1
	elseif gameTime <= 260*sec then
		return 2.1
	elseif gameTime <= 320*sec then
		return 1.8
	elseif gameTime <= 360*sec then
		return 1.9
	elseif gameTime <= 400*sec then
		return 2.0
	else return 2.3 end
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
	local ent = display.newGroup()
	ent.x, ent.y, ent.level = args.srcx or args.x, args.srcy or args.y, args.level
	ent.powerup = args.powerup
	local imagePath = _M.images[_M.powerupDic[ent.powerup]] or _M.images[ent.level]
	local image = display.newImage(ent, imagePath, 0, 0)
	transition.to(ent, {time=200, x=args.x, y=args.y, onComplete = function ()
			ent.vx, ent.vy = utils.getNormal(ent.x, ent.y)
			_M.group:insert(ent)
			table.insert(_M.active, ent)
		end
		})
	return ent
end

function _M.kill(event)
	if event.phase == "began" then
		local eventX = event.x
		local eventY = event.y
		for k,v in next, _M.active do
			local d2 = (eventX-v.x)*(eventX-v.x) + (eventY-v.y)*(eventY-v.y)
			if d2 <= --[[1600]] 3600 then
				_M.degrade(v)
			end
		end
	end
end

function _M.degrade(monster)
	if monster.level == 1 then
	elseif monster.level == 2 then
		table.insert(_M.newactive, {x=monster.x, y=monster.y, level=1})
	elseif monster.level == 3 then
		for i = 1,3 do
			table.insert(_M.newactive, {srcx=monster.x, srcy=monster.y, x=monster.x+math.random(-50,50), y=monster.y+math.random(-50,50), level=2})
		end
	elseif monster.level == 4 then
		for i = 1,4 do
			table.insert(_M.newactive, {srcx=monster.x, srcy=monster.y, x=monster.x+math.random(-50,50), y=monster.y+math.random(-50,50), level=3})
		end
	else
		
	end
	if monster.powerup then
		if monster.powerup == "flare" then
			_M.destroyAll()
		elseif monster.powerup == "lightbomb" then
			_M.explosion = {x=monster.x, y=monster.y, radius=300}
		else
			_M.explosion = {x=monster.x, y=monster.y, radius=-1}
		end
	end
	monster.toKill = true
end

function _M.destroy(monster)
	transition.to(monster, {time=500, alpha=0, onComplete=function() _M.group:remove(monster) end})
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
	for k,v in next, _M.active do
		if v.toKill then
			_M.destroy(v)
		else
			table.insert(freshtable, v)
		end
	end
	_M.active = nil
	_M.active = freshtable
	local rate = _M.getSpawnRate(currTime)
	if rate > 0 and currTime - _M.spawnTime >= 1000/(_M.spawnFactor*rate) then
		local X, Y = utils.randomPos()
		_M.spawn({x=X, y=Y, level=_M.getLevel(currTime)})
		_M.spawnTime = currTime
	end
	if currTime - _M.lbSpawnTime >= lbTime*1000 then
		local X, Y = utils.randomPos()
		_M.spawn({x=X, y=Y, level=1, powerup="lightbomb"})
		_M.lbSpawnTime = currTime
		lbTime = math.random(19, 25)
	end
	if currTime - _M.ebSpawnTime >= ebTime*1000 then
		local X, Y = utils.randomPos()
		_M.spawn({x=X, y=Y, level=1, powerup="electroblast"})
		_M.ebSpawnTime = currTime
		ebTime = math.random(57, 63)
	end
	for k,v in next, _M.newactive do
		_M.spawn(v)
	end
	for k,v in next, _M.active do
		local speed = _M.speed
		if not v.powerup then
			speed = speed * _M.speedFactor
		end
		v.x = v.x+(speed*v.vx)
		v.y = v.y+(speed*v.vy)
	end
	_M.newactive = nil
	_M.newactive = {}
end

function _M.purge()
	_M.initted = false
end

return _M