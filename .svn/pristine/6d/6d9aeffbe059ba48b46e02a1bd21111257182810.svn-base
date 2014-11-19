MsgC(Color(0, 255, 0), "Initialize Warning Module...\n")

HWarn = {}
include("sv_dbmgr.lua")
local hwarn_showmsg_on_warned = CreateConVar("hwarn_showmsg_on_warned", 1):GetBool()
function HWarn.Init()
	util.AddNetworkString("HWarn")
	concommand.Add("hwarn", HWarn.Warn)
	concommand.Add("hwarn_show", HWarn.ShowWarn)
end

function HWarn.WarnMsg(sid, warn, reason)
	local nick = HWarn.DB.NickFromSID(sid)
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
		  pl:PrintMessage(HUD_PRINTTALK, "해당 닉네임의 플레이어가 둘 이상입니다: " .. tostring(table.concat(curpls, ", ")))
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
	local nick = HWarn.DB.NickFromSID(sid)
	if !nick then	
		Error("Couldn't find matched nickname.")
	end
	local warn = HWarn.DB.GetWarn(sid)
	net.Start("HWarn")
	net.WriteString("showwarn")
	net.WriteString(nick)
	net.WriteInt(warn, 16)
	net.Broadcast()
	ulx.logString("Warning of " .. nick .. " is: " .. warn)
	MsgC(Color(0, 255, 0), "Warning of ", nick, " is: ") MsgC(Color(255, 0, 0), warn, "\n")
end

function HWarn.IsSteamID(str)
	return string.sub(str, 8, 8) == ":" and string.sub(str, 10, 10) == ":" and string.Left(str, 6) == "STEAM_"
end

HWarn.Init()
MsgC(Color(0, 255, 0), "Complete!\n")