HWarn.DB = {}

function HWarn.DB.Init()
	HWarn.DB.CheckTableExists()
end

function HWarn.DB.CheckTableExists()
	if !sql.TableExists("HWarn") then
		MsgC(Color(255, 0, 0), "No HWarn table found! Creating...\n")
		local q = sql.Query("CREATE TABLE HWarn(id INTEGER PRIMARY KEY ASC AUTOINCREMENT, sid TEXT NOT NULL, nick TEXT NOT NULL, warn INTEGER NOT NULL, totalwarn INTEGER NOT NULL DEFAULT 0, lastdate TEXT NOT NULL)")
	else
		MsgC(Color(0, 220, 0), "HWarn table found.\n")
	end
end

function HWarn.DB.AddPlayerInfo(pl)
	local nick = pl:Nick()
	local sid = pl:SteamID()
	if sid == "BOT" then
		return
	end
	local q = sql.Query("SELECT nick FROM HWarn WHERE sid='" ..sid .. "'")
	if istable(q) then
		local olddate = HWarn.DB.GetDateFromSID(sid)
		local oldy = string.Left(olddate, 2)
		local oldm = string.sub(olddate, 3, 4)
		local oldd = string.Right(olddate, 2)
		local curdate = HWarn.DB.GetDateString()
		local cury = string.Left(curdate, 2)
		local curm = string.sub(curdate, 3, 4)
		local curd = string.Right(curdate, 2)
		
		if oldy ~= cury or oldm ~= curm or oldd ~= curd then
			sql.Query("UPDATE HWarn SET warn=0 WHERE sid='" .. sid .. "'")
			sql.Query("UPDATE HWarn SET lastdate='" .. curdate .. "' WHERE sid='" .. sid .. "'")
		end
		
		local oldnick = HWarn.DB.NickFromSID(sid)
		if oldnick ~= nick then
			sql.Query("UPDATE HWarn SET nick='" .. nick .. "' WHERE sid='" .. sid .."'")
		end
	else
		q = sql.Query("INSERT INTO HWarn (sid, nick, warn, lastdate) VALUES ('" .. sid .. "', '" .. nick .. "', 0, '" .. HWarn.DB.GetDateString() .. "');")
	end
end
hook.Remove("PlayerInitialSpawn", "HWarnDBAddPlayerInfo", HWarn.DB.AddPlayerInfo)
hook.Add("PlayerInitialSpawn", "HWarnDBAddPlayerInfo", HWarn.DB.AddPlayerInfo)

function HWarn.DB.AddWarn(sid, warn, reason)
	if !sid then
		Error("No SID\n")
	end
	
	if !warn then
		Error("No warn amount\n")
	end
	
	local datestr = HWarn.DB.GetDateString()
	
	local curwarn = HWarn.DB.GetWarn(sid)
	local curtotalwarn = HWarn.DB.GetTotalWarn(sid)
	local q = sql.Query("UPDATE HWarn SET warn=" .. curwarn + warn .. ", lastdate='" .. datestr .. "', totalwarn=" .. curtotalwarn + warn .. " WHERE sid='" .. sid .."';")
	
	if curwarn + warn == 3 then
		ulx.banid(NULL, sid, 1440, "BAD ACT")
	elseif curwarn + warn >= 4 then
		ulx.banid(NULL, sid, 4320, "TOO MANY BAD ACT")
	end
	
	local allFiles = file.Find("polices/*.txt", "DATA")
	for _, v in pairs(allFiles) do 
		local data = file.Read("polices/" .. v, "DATA")
		local target = ""
		for v in string.gfind(data, "신고 대상자: .+%((STEAM_%d:%d:%d+)%)\r\n") do
			target = v
		end
		
		if target == sid then
			file.Append("polices/" .. v, "\r\nprocessed")
		end
	end
	
	HWarn.WarnMsg(sid, warn, reason)
end

function HWarn.DB.NickFromSID(sid)
	if !sid then
		Error("No SID\n")
	end
	local nick = sql.QueryValue("SELECT nick FROM HWarn WHERE sid='" .. sid .."'")
	if !nick then
		return false
	end
	return nick
end

function HWarn.DB.SIDFromNick(nick)
	if !nick then
		Error("No nick\n")
	end
	local sid = sql.QueryValue("SELECT sid FROM HWarn WHERE nick LIKE '%" .. nick .. "%'")
	if !sid then
		return false
	end
	return sid
end

function HWarn.DB.GetDateString()
	return os.date("%y/%m/%d", os.time())
end

function HWarn.DB.GetDateFromSID(sid)
	return sql.QueryValue("SELECT lastdate FROM HWarn WHERE sid='" .. sid .. "'")
end

function HWarn.DB.ReplaceBadCharacter(str)
	local s = string.Replace(str, "'", "")
	s = string.Replace(s, "\"", "")
	return s
end

function HWarn.DB.GetWarn(sid)
	return tonumber(sql.QueryValue("SELECT warn FROM HWarn WHERE sid='" .. sid .. "';")) or 0
end

function HWarn.DB.GetTotalWarn(sid)
	return tonumber(sql.QueryValue("SELECT totalwarn FROM HWarn WHERE sid='" .. sid .. "';")) or 0
end

HWarn.DB.Init()
MsgC(Color(0, 255, 0), "DB module loaded.\n")