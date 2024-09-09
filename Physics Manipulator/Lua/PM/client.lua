Hook.Add("think", "PM.think", function ()
	local pos
	if Character.Controlled ~= nil then
		pos = Character.Controlled.CursorWorldPosition
	end
	if pos ~= nil then
		local message = Networking.Start("PM.receiveCursorWorldPosition")
		message.WriteDouble(pos.X)
		message.WriteDouble(pos.Y)
		Networking.Send(message)
	end
	
	return true
end)