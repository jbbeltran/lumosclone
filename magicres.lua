local _M = {}

local screenW, screenH = display.contentWidth, display.contentHeight

_M.left = display.screenOriginX
_M.right = display.viewableContentWidth-_M.left
_M.top = display.screenOriginY
_M.bottom = display.viewableContentHeight-_M.top

_M.width = _M.right - _M.left
_M.height = _M.bottom - _M.top

--[[
-- magicres.apply
-- returns the scaled coordinates based on the current screen size
-- e.g.
-- game dimensions = 480x320 (iPhone)
-- device dimensions = 800x480 (droid)
-- magicres.apply(0,0) => left, top
-- magicres.apply(240, 160) => left + 400, top + 240
-- magicres.apply(480, 320) => left + width, top + height
--
-- useful for positioning UI elements
-- do not use this for positioning physics objects and stuff
--]]
function _M.apply(x, y)
	local xRatio = 1.0*x/screenW
	y = y or 0
	local yRatio = 1.0*y/screenH
	return 	{
				x = _M.left + (_M.width*xRatio), 
				y = _M.top + (_M.height*yRatio)
			}
end

function _M.imgscale(img)
	local ratio = 1.0
	if img.width >= img.height then
		ratio = 1.0*_M.width/img.width
	else
		ratio = 1.0*_M.height/img.height
	end
	img.xScale, img.yScale = ratio, ratio
end

function _M.newFullScreenRect()
    return display.newRect(_M.left, _M.top, _M.width, _M.height)
end

local math_random = math.random
function _M.randomW()
	return math_random(_M.left, _M.right)
end
function _M.randomH()
	return math_random(_M.top, _M.bottom)
end
function _M.getQuadrant(x, y)
	local midX = screenW/2
	local midY = screenH/2
	if x <= midX then
		if y <= midY then
			return 1
		else
			return 4
		end
	else
		if y <= midY then
			return 2
		else
			return 3
		end
	end
end

function _M.ratio_encode_x(x)
	local r = (x - screenW/2)/(_M.width/2)
	return math.floor(r*1000)
end
function _M.ratio_decode_x(r)
	return screenW/2 + (_M.width/2)*r/1000.0
end
function _M.ratio_encode_y(y)
	local r = (y - screenH/2)/(_M.height/2)
	return math.floor(r*1000)
end
function _M.ratio_decode_y(r)
	return screenH/2 + (_M.height/2)*r/1000.0
end

function _M.isOutOfBounds(pos, leeway)
	leeway = leeway or 0
	return pos.x < _M.left - leeway or pos.x > _M.right + leeway or pos.y < _M.top - leeway or pos.y > _M.bottom + leeway
end

function _M.createRandomEdgePosition()
	local dieRoll = math.random(1, 4)
	local x, y = 0, 0
	if dieRoll == 1 then
		--randomize from the left side
		x, y = _M.left, _M.randomH()--math.random(0, H)
	elseif dieRoll == 2 then
		--randomize from the right side
		x, y = _M.right, _M.randomH()
	elseif dieRoll == 3 then
		--randomize from the top side
		x, y = _M.randomW(), _M.top
	elseif dieRoll == 4 then
		--randomize from the bottom side
		x, y = _M.randomW(), _M.bottom
	end
	return {x=x, y=y}
end

return _M