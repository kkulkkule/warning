MsgC(Color(0, 255, 0), "Initialize Warning Module...\n")

HWarn = {}

function HWarn.Init()

end

function HWarn.ReceiveMsg()
	local t = net.ReadString()
	
	if t == "warn" then
		local nick = net.ReadString()
		local warn = net.ReadInt(16)
		local reason = net.ReadString()
		
		chat.AddText(Color(0, 255, 0), nick .. "님께서 경고 ", Color(255, 0, 0), tostring(warn), Color(0, 255, 0), "회를 받으셨습니다. [", Color(255, 127, 0), reason, Color(0, 255, 0), "]")
	elseif t == "showwarn" then
		local nick = net.ReadString()
		local warn = net.ReadInt(16)
		
		chat.AddText(Color(0, 255, 0), nick .. "님의 경고 횟수는 [", Color(255, 127, 0), tostring(warn), Color(0, 255, 0), "]회 입니다.")
	end
end
net.Receive("HWarn", HWarn.ReceiveMsg)

function HWarn.ChatHook(pl, text, tc, dead)
	local client = LocalPlayer()
	if pl ~= client then
		return
	end
	
	local args = string.Explode(" ", text)
	table.remove(args, 1)
	
	if string.Left(text, 5) == "!warn" then
		local ns = args[1]		
		local warn = args[2]
		local reason = args[3]
		if !reason or reason == "" then
			reason = "알 수 없는 이유"
		end
		for i = 4, table.Count(args) do 
			reason = reason .. " " .. tostring(args[i])
		end
		
		RunConsoleCommand("hwarn", "\"" .. ns .. "\"", warn, "\"" .. reason .. "\"")
	elseif string.Left(text, 9) == "!showwarn" then
		local sid = args[1] or LocalPlayer():SteamID()
		RunConsoleCommand("hwarn_show", "\"" .. sid .. "\"")
	end
end
hook.Remove("OnPlayerChat", "HWarnChatHook", HWarn.ChatHook)
hook.Add("OnPlayerChat", "HWarnChatHook", HWarn.ChatHook)

HWarn.Init()

MsgC(Color(0, 255, 0), "Complete!\n")