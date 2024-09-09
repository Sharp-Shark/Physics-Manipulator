-- Physics Manipulator
PM = {}

-- Imports
require 'PM/utilities'

-- Delta timing
PM.dt = {}

-- Client Selected Limb
PM.characterSelectedLimb = {}
PM.ragdollTimers = {}

-- Grab a limb
PM.grabLimb = function (pos, character, allowGrabSelf)
	local distance = 100
	local grabbedLimb = nil
	
	for other in Character.CharacterList do
		if (character ~= other) or allowGrabSelf then
			for limb in other.AnimController.Limbs do
				if Vector2.Distance(pos, limb.WorldPosition) < distance then
					grabbedLimb = limb
					distance = Vector2.Distance(pos, limb.WorldPosition)
				end
			end
		end
	end
	
	if limb ~= nil then print(limb.Name) end
	
	PM.characterSelectedLimb[character] = grabbedLimb
	return grabbedLimb
end

-- Multiplayer
if Game.IsMultiplayer then
	if SERVER then require 'PM/server' end
	if CLIENT then require 'PM/client' end
	return
end

-- Singleplayer
Hook.Add("think", "PM.think", function ()
	PM.dt.scale = 1
	if PM.dt.time ~= nil then
		local fps = 1 / (Timer.GetTime() - PM.dt.time)
		PM.dt.scale = 60 / fps
	end
	PM.dt.time = Timer.GetTime()
	
	for character in Character.CharacterList do
		if character.IsKeyDown(InputType.Shoot) and (PM.characterSelectedLimb[character] == nil) then
			PM.grabLimb(character.CursorWorldPosition, character, true)
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
		if character.IsKeyDown(InputType.Shoot) then
			limb.character.IsForceRagdolled = true
			limb.body.LinearVelocity = character.CursorWorldPosition - limb.WorldPosition
			PM.ragdollTimers[limb.character] = {character = limb.character, timer = 60}
		else
			PM.characterSelectedLimb[character] = nil
		end
	end
	
	return true
end)