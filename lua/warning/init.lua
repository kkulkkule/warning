MsgC(Color(0, 255, 0), "Initialize Warning Module...\n")

HWarn = {}

WARNING_URL = "http://kkulkkule.dyndns.info:8282/hlds/admin/warning"
GAME_NAME = "zs"

include("sv_dbmgr.lua")
local hwarn_showmsg_on_warned = CreateConVar("hwarn_showmsg_on_warned", 1):GetBool()
function HWarn.Init()
	util.AddNetworkString("HWarn")
	concommand.Add("hwarn", HWarn.Warn)
	concommand.Add("hwarn_show", HWarn.ShowWarn)
end
hook.Add("Initialize", "HWarn.Init", HWarn.Init)

function HWarn.WarnMsg(sid, warn, reason)
	-- local nick = HWarn.DB.NickFromSID(sid)
	if !nick then
		nick = sid
	end
	
	net.Start("HWarn")
	net.WriteString("warn")
	net.WriteString(nick)
	net.WriteInt(warn, 16)
	net.WriteString(reason)
	net.Broadcast()
	
	ulx.logString(nick .. " got " .. warn .. " warnings: " .. reason)
	if hwarn_showmsg_on_warned then
		HWarn.ShowWarnMsg(sid)
	end
end

function HWarn.Warn(pl, cmd, args, text)
	if pl ~= NULL and !pl:IsAdmin() then
		return
	end
	local sid = HWarn.DB.ReplaceBadCharacter(args[1])
	local warn = args[2]
	local reason = args[3]
	
	if string.len(reason) == 0 then
		reason = "'알 수 없는 이유'"
	end
	
	if args[4] then
		reason = args[3]
		for i = 4, table.Count(args) do
			reason = reason .. " " .. tostring(args[i])
		end
	end
	
	if !HWarn.IsSteamID(sid) then
		local curpls = {}
		for _, v in pairs(player.GetAll()) do
			if string.find(string.lower(v:Nick()), string.lower(sid)) then
			table.insert(curpls, v)
			end
		end
		if table.Count(curpls) > 1 then
			if pl == NULL then
				print(HUD_PRINTTALK, "Duplicated nickname.")
			else
				pl:PrintMessage(HUD_PRINTTALK, "해당 닉네임의 플레이어가 둘 이상입니다: " .. tostring(table.concat(curpls, ", ")))
			end
			return false
		elseif table.Count(curpls) == 1 then
			HWarn.DB.AddWarn(curpls[1]:SteamID(), warn, reason)
			return true
		end
		sid = HWarn.DB.SIDFromNick(sid)
	end
	
	HWarn.DB.AddWarn(sid, warn, reason)
end

function HWarn.ShowWarn(pl, cmd, args, text)
	if pl ~= NULL and !pl:IsAdmin() then
		return
	end
	local sid = HWarn.DB.ReplaceBadCharacter(args[1])
	if !HWarn.IsSteamID(sid) then
		local curpls = {}
		for _, v in pairs(player.GetAll()) do
			if string.find(string.lower(v:Nick()), string.lower(sid)) then
			table.insert(curpls, v)
			end
		end
		if table.Count(curpls) > 1 then
			pl:PrintMessage(HUD_PRINTTALK, "해당 닉네임의 플레이어가 둘 이상입니다: " .. tostring(table.concat(curpls, ", ")))
			return false
		elseif table.Count(curpls) == 1 then
			HWarn.ShowWarnMsg(curpls[1]:SteamID())
			return true
		end
		sid = HWarn.DB.SIDFromNick(sid)
	end
	HWarn.ShowWarnMsg(sid)
end

function HWarn.ShowWarnMsg(sid)
	-- local nick = HWarn.DB.NickFromSID(sid)
	if !nick then	
		Error("Couldn't find matched nickname.")
	end
	-- local warn = HWarn.DB.GetWarn(sid)
	
	http.Post(WARNING_URL, {game = GAME_NAME, action = "getWarn", sid = sid}, function(body, len, headers, status)
		local warn = tonumber(body)
		net.Start("HWarn")
		net.WriteString("showwarn")
		net.WriteString(nick)
		net.WriteInt(warn, 16)
		net.Broadcast()
		ulx.logString("Warning of " .. nick .. " is: " .. warn)
		MsgC(Color(0, 255, 0), "Warning of ", nick, " is: ") MsgC(Color(255, 0, 0), warn, "\n")
		
		local banTime = 0
		
		-- if warn == 1 then
			-- HWarn.KickConnectedPlayerBySID(sid)
		-- elseif warn == 2 then
			-- ulx.banid(NULL, sid, 60, "누적 경고 2회로 1시간 밴 당하셨습니다.")
			-- banTime = 1000 * 60 * 60
		-- elseif warn == 3 then
			-- ulx.banid(NULL, sid, 1440, "누적 경고 3회로 1일 밴 당하셨습니다.")
			-- banTime = 1000 * 60 * 60 * 24
		-- elseif warn > 3 then
			-- ulx.banid(NULL, sid, 4320, "누적 경고 횟수가 4회를 넘어 3일 밴 당하셨습니다.")
			-- banTime = 1000 * 60 * 60 * 24 * 3
		-- end
		
		if warn == 3 then
			ulx.banid(NULL, sid, 1440, "누적 경고 3회로 1일 밴 당하셨습니다.")
			banTime = 1440
		elseif warn > 3 then
			ulx.banid(NULL, sid, 4320, "누적 경고 4회로 1일 밴 당하셨습니다.")
			banTime = 4320
		end
		
		if warn >= 3 then
			http.Post(WARNING_URL, {game = GAME_NAME, action = "ban", sid = sid, ban = "1", banTime = tostring(banTime)}, function(body, len, headers, status)
				
			end)
		elseif warn < 3 then
			http.Post(WARNING_URL, {game = GAME_NAME, action = "ban", sid = sid, ban = "0"}, function()
				ulx.unban(NULL, sid)
			end)
		end
	end)
end

function HWarn.KickConnectedPlayerBySID(sid)
	for _, v in pairs(player.GetAll()) do
		if v:SteamID() == sid then
			ulx.kick(NULL, v, "누적 경고 1회로 인해 킥당하셨습니다.")
			return true
		end
	end
	return false
end

function HWarn.IsSteamID(str)
	return string.sub(str, 8, 8) == ":" and string.sub(str, 10, 10) == ":" and string.Left(str, 6) == "STEAM_"
end

MsgC(Color(0, 255, 0), "Complete!\n")