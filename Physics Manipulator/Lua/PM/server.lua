PM.cursors = {}

Networking.Receive("PM.receiveCursorWorldPosition", function (message, client)
	PM.cursors[client] = Vector2(message.ReadDouble(), message.ReadDouble())
end)

Hook.Add("think", "PM.think", function ()
	PM.dt.scale = 1
	if PM.dt.time ~= nil then
		local fps = 1 / (Timer.GetTime() - PM.dt.time)
		PM.dt.scale = 60 / fps
	end
	PM.dt.time = Timer.GetTime()
	
	for character in Character.CharacterList do
		local pos = PM.cursors[PM.findClientByCharacter(character)]
		if pos ~= nil then
			if character.IsKeyDown(InputType.Shoot) and (PM.characterSelectedLimb[character] == nil) then
				PM.grabLimb(pos, character, false)
			end
		end
	end
	
	for index, tbl in pairs(PM.ragdollTimers) do
		if tbl.timer > 0 then
			tbl.character.IsForceRagdolled = true
			PM.ragdollTimers[index].timer = tbl.timer - 1 * PM.dt.scale
		else
			tbl.character.IsForceRagdolled = false
			PM.ragdollTimers[index] = nil
		end
	end
	
	for character, limb in pairs(PM.characterSelectedLimb) do
		local pos = PM.cursors[PM.findClientByCharacter(character)]
		if pos ~= nil then
			if character.IsKeyDown(InputType.Shoot) then
				limb.character.IsForceRagdolled = true
				limb.body.LinearVelocity = pos - limb.WorldPosition
				PM.ragdollTimers[limb.character] = {character = limb.character, timer = 60}
			else
				PM.characterSelectedLimb[character] = nil
			end
		end
	end
	
	return true
end)