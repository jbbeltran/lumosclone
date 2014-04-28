local utils = require("utils")

local _M = {}

function _M.init()
	if not _M.initted then
		_M.initted = true
		_M.group = display.newGroup()
		_M.active = {}
		_M.lightRadius = 64
		_M.photonCount = 0
		_M.lighttime = 0
		_M.light = display.newImage(_M.group, "imgs/light/light.png", W/2, H/2)
		_M.light:scale(_M.lightRadius/_M.light.contentWidth, _M.lightRadius/_M.light.contentHeight)
	end
end

function _M.spawn(args)
	local ent = display.newGroup()
	ent.x, ent.y = args.x, args.y
	ent.vx, ent.vy = utils.getNormal(ent.x, ent.y)
	ent.typ = args.typ
	if args.typ == "photon" then
		local photon = display.newImage(ent, "imgs/light/photon.png", 0, 0)
	end
	_M.group:insert(ent)
	table.insert(_M.active, ent)
	return ent
end

function _M.collect(event)
	local p = event.phase
	if p == "began" then
		local eventX = event.x
		local eventY = event.y
		for k,v in next, _M.active do
			local d2 = (eventX-v.x)*(eventX-v.x) + (eventY-v.y)*(eventY-v.y)
			if d2 <= --[[1600]] 3600 then
				if v.vx <= 1.0 then v.vx = v.vx * 50 end
				if v.vy <= 1.0 then v.vy = v.vy * 50 end
			end
		end
	end
end

function _M.update()
	local currTime = system.getTimer()
	local freshtable = {}
	if currTime-_M.lighttime >= 1000 then
		_M.lighttime = currTime
		_M.lightRadius = _M.lightRadius+1
		_M.light.contentWidth, _M.light.contentHeight = _M.lightRadius*2, _M.lightRadius*2
	end
	for k,v in next, _M.active do
		if v.toKill then
			v:removeEventListener("touch", _M.collect)
			_M.group:remove(v)
		else
			table.insert(freshtable, v)
		end
	end
	_M.active = nil
	_M.active = freshtable
	local maxPhotons = math.min(6, 2+math.floor(currTime/75000))
	for i=1, maxPhotons-_M.photonCount do
		local toggle = math.random(1,4)
		local X, Y = 0, 0
		if toggle == 1 then
			X, Y = 0, math.random(0, H)
		elseif toggle == 2 then
			X, Y = W, math.random(0, H)
		elseif toggle == 3 then
			X, Y = math.random(0, W), 0
		else
			X, Y = math.random(0, W), H
		end
		_M.spawn({x=X, y=Y, typ="photon"})
		_M.photonCount = _M.photonCount + 1
		_M.spawnTime = currTime
	end
	for k,v in next, _M.active do
		v.x = v.x + v.vx
		v.y = v.y + v.vy
	end
end

function _M.purge()
	_M.initted = false
end

return _M