local _M = {}

function _M.warpTime(args)
	local gameTime = args.gameTime
	local secs = (gameTime/1000)%60
	local mins = math.floor((gameTime/(1000*60))%60)
	local hrs = math.floor((gameTime/(1000*60*60))%24)
	local hrsStr, minsStr, secsStr = tostring(hrs), tostring(mins), tostring(secs)
	secsStr = string.format("%.2f", secs)
	if secs < 10 then secsStr = "0"..secsStr end
	if mins < 10 then minsStr = "0"..minsStr end
	if hrs < 10 then hrsStr = "0"..hrsStr end
	return hrsStr..":"..minsStr..":"..secsStr
end

function _M.randomPos()
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
	return X, Y
end

function _M.getNormal (X0,Y0,X1,Y1)
	local dirx = (X1 or W/2)-X0
	local diry = (Y1 or H/2)-Y0
	local d2 = dirx*dirx + diry*diry
	return dirx/math.sqrt(d2), diry/math.sqrt(d2)
end

function _M.readScore()
	local path = system.pathForFile("lumosscore.sav", system.DocumentsDirectory )
	local file = io.open(path, "r")
	local highscore = 0
	if file then
		local contents = file:read("*a")
		highscore = tonumber(contents)
		io.close(file)
	end
	return highscore
end
	
function _M.writeScore(args)
	local path = system.pathForFile("lumosscore.sav", system.DocumentsDirectory )
	local file = io.open(path, "w")
	local contents = tostring(args.highscore)
	file:write(contents)
	io.close(file)
	return true
end

return _M