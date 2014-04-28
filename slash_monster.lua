local utils = require("utils")

local _M = {}

function _M.init()
	if not _M.initted then
		_M.initted = true
		_M.group = display.newGroup()
		_M.linegroup = display.newGroup()
		_M.images, _M.active, _M.newactive, _M.tokill, _M.linetable, _M.points = {}, {}, {}, {}, {}, {}
		--_M.images[4] = {}
		_M.spawnTime = 0
		_M.speed = 2
		_M.spawnFactor = 1
		_M.speedFactor = 1
		_M.images[0] = "imgs/enemies/e_slash/lvl_0.png"
		_M.images[1] = "imgs/enemies/e_slash/lvl_1.png"
		_M.images[2] = "imgs/enemies/e_slash/lvl_2.png"
		_M.images[3] = "imgs/enemies/e_slash/lvl_3.png"
		_M.images[4]--[[1]] = "imgs/enemies/e_slash/lvl_4a.png"
		--_M.images[4][2] = "e_slash/lvl_4b.png"
		_M.images[5] = "imgs/enemies/e_slash/tip.png"
		_M.images[6] = "imgs/enemies/e_slash/tip_0.png"
		_M.group:insert(_M.linegroup)
		
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
		return 0
	elseif gameTime <= 24*sec then
		return 0.3
	elseif gameTime <= 80*sec then
		return 0.37
	elseif gameTime <= 120*sec then
		return 0.21
	elseif gameTime <= 160*sec then
		return 0.08
	elseif gameTime <= 190*sec then
		return 0.21
	elseif gameTime <= 240*sec then
		return 0.26
	elseif gameTime <= 260*sec then
		return 0.21
	elseif gameTime <= 320*sec then
		return 0.26
	elseif gameTime <= 360*sec then
		return 0.29
	elseif gameTime <= 400*sec then
		return 0.31
	else return 0.35 end
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
	ent.x, ent.y, ent.level, ent.life = args.x, args.y, args.level, args.life
	ent.vx, ent.vy = utils.getNormal(args.x, args.y)
	ent.normAngle = math.atan2(ent.vy, ent.vx)*(180/math.pi)
	ent.powerup = args.powerup
	ent.snake = {}
	local imagePath = _M.images[_M.powerupDic[ent.powerup]] or _M.images[ent.level]
	
	for i=1,50 do
		local which = _M.images[5]
		local currTime = system.getTimer()
		if i > 1 then
			which = imagePath
		else
			if ent.powerup then
				which = _M.images[6]
			end
		end
		local segment = display.newImage(ent, which, -i*10*ent.vx, -i*10*ent.vy)
		segment.ind = i
		segment.origx, segment.origy = segment.x, segment.y
		segment.x = segment.origx - ent.vy*math.min(i*i, 15)*( math.sin( (currTime/80+i-1)*math.pi/4 ) )
		segment.y = segment.origy + ent.vx*math.min(i*i, 15)*( math.sin( (currTime/80+i-1)*math.pi/4 ) )
		table.insert(ent.snake, segment)
	end
	_M.group:insert(ent)
	for i = args.cutind or 1,50 do
		ent.snake[i].isVisible = false
		timer.performWithDelay(70+(i*10), function()
			ent.snake[i].isVisible = true
			if i == 50 then
				ent:addEventListener("touch", _M.kill)
				table.insert(_M.active, ent)
				return ent
			end
		end
		)
	end
	--[[if args.cutind then
		
	else
		ent:addEventListener("touch", _M.kill)
		table.insert(_M.active, ent)]]
	return ent
	--end
end

function _M.slash(event)
	local p = event.phase
	local X = event.x
	local Y = event.y
	if p == "began" then
		_M.points = {}
		table.insert(_M.points, X)
		table.insert(_M.points, Y)
	elseif p == "moved" then
		if #_M.points >= 4 then
			if #_M.points == 4 then
				local newLine = display.newLine(_M.linegroup, _M.points[1], _M.points[2], _M.points[3], _M.points[4])
				newLine.strokeWidth = 3
				table.insert(_M.linetable, newLine)
				timer.performWithDelay(200, function()
						_M.linegroup:remove(newLine)
						table.remove(_M.linetable, 1)
						table.remove(_M.points, 1)
						table.remove(_M.points, 1)
					end
				)
			else
				local newLine = display.newLine(_M.linegroup, _M.points[#_M.points-1], _M.points[#_M.points], X, Y)
				newLine.strokeWidth = 3
				table.insert(_M.linetable, newLine)
				timer.performWithDelay(200, function()
						_M.linegroup:remove(newLine)
						table.remove(_M.linetable, 1)
						table.remove(_M.points, 1)
						table.remove(_M.points, 1)
					end
				)
			end
		end
		table.insert(_M.points, X)
		table.insert(_M.points, Y)
	elseif p == "ended" then
		_M.points = {}
	end
end

function _M.degrade(args)
	local monster = args.ent
	local cutind = args.cutind
	if monster.life > 1 then
		local offset = math.random(50, 100)
		if monster.level == 2 then
			table.insert(_M.newactive, {x=monster.x, y=monster.y, level=monster.level, life=1, cut=cutind})
		elseif monster.level == 3 then
			table.insert(_M.newactive, {x=monster.x-offset*monster.vy, y=monster.y+offset*monster.vx, level=monster.level, life=1, cutind=cutind})
			table.insert(_M.newactive, {x=monster.x+offset*monster.vy, y=monster.y-offset*monster.vx, level=monster.level, life=1, cutind=cutind})
		elseif monster.level == 4 then
			table.insert(_M.newactive, {x=monster.x, y=monster.y, level=monster.level, life=1, cut=cutind})
			table.insert(_M.newactive, {x=monster.x-offset*monster.vy, y=monster.y+offset*monster.vx, level=monster.level, life=1, cutind=cutind})
			table.insert(_M.newactive, {x=monster.x+offset*monster.vy, y=monster.y-offset*monster.vx, level=monster.level, life=1, cutind=cutind})
		end
	end
	if monster.powerup == "flare" then
		_M.destroyAll()
	end
	monster.killSegment = cutind
	monster:removeEventListener("touch", _M.kill)
	monster.toKill = true
end

function _M.kill(event)
	local t = event.target
	local p = event.phase
	if p == "moved" then
		local whichSegment = 3
		for i=1,30 do
			local segment = t.snake[i]
			local X, Y = segment:contentToLocal(event.x, event.y)
			if -segment.contentWidth/2 <= X and X <= segment.contentWidth/2 and
			   -segment.contentHeight/2 <= Y and Y <= segment.contentHeight/2 then
			   	whichSegment = i
			end
		end
		local segsize = t.snake[whichSegment].contentWidth
		if #_M.points >= 4 then
			local pX, pY = event.x, event.y
			local X0 = _M.points[1]
			local Y0 = _M.points[2]
			local X1 = _M.points[#_M.points-1]
			local Y1 = _M.points[#_M.points]
			local d1 = (X0-pX)*(X0-pX) + (Y0-pY)*(Y0-pY)
			local d2 = (X1-pX)*(X1-pX) + (Y1-pY)*(Y1-pY)
			if d1+d2 >= segsize*segsize then
				_M.degrade({ent=t, cutind=whichSegment})
			end
		end
	end
end

function _M.destroy(monster)
	if not monster.killSegment then
		transition.to(monster, {time=500, alpha=0, onComplete=function() _M.group:remove(monster) end})
	else
		monster:removeEventListener("touch", _M.kill)
		for i=1,monster.killSegment-1 do
			transition.to(monster.snake[i], {time=500, alpha=0})
		end
		for i=monster.killSegment,30 do
			transition.to(monster.snake[i], {time=500, x=-500*monster.vx, y=-500*monster.vy})
		end
		timer.performWithDelay(550, function() _M.group:remove(monster) end )
	end
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
			v:removeEventListener("touch", _M.kill)
			_M.destroy(v)
		else
			table.insert(freshtable, v)
		end
	end
	_M.active = nil
	_M.active = freshtable
	local rate = _M.getSpawnRate(currTime)
	if rate > 0 and currTime - _M.spawnTime >= 1000/(_M.spawnFactor*rate) then
		local toggle = math.random(1,4)
		local X, Y = utils.randomPos()
		_M.spawn({x=X, y=Y, level=_M.getLevel(currTime), life = 2})
		_M.spawnTime = currTime
	end
	for k,v in next, _M.newactive do
		_M.spawn(v)
	end
	for k,v in next, _M.active do
		if v.snake then
			local speed = _M.speed
			for a,b in ipairs(v.snake) do
				b.x = b.origx - v.vy*math.min(a*a, 15)*( math.sin( (currTime/80+a-1)*math.pi/4 ) )
				b.y = b.origy + v.vx*math.min(a*a, 15)*( math.sin( (currTime/80+a-1)*math.pi/4 ) )
				if a > 1 then
					local prev = v.snake[a-1]
					b.rotation = math.atan2(prev.y-b.y, prev.x-b.x)*(180/math.pi)
				else
					b.rotation = v.normAngle
				end
			end
			if not v.powerup then
				speed = speed*_M.speedFactor
			end
			v.x = v.x + speed*v.vx
			v.y = v.y + speed*v.vy
		end
	end
	_M.newactive = {}
	_M.tokill = {}
end

function _M.purge()
	_M.initted = false
end

return _M