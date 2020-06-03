local smoker = 0.0
local smokeg = 0.0
local smokeb = 0.0
local size = 1.0

local offsets = {
	[GetHashKey("cuban800")] = { 0.0, -3.0, -0.3 },
	[GetHashKey("mogul")] = { 0.0, -5.0, 0.7 },
	[GetHashKey("rogue")] = { 0.0, -7.0, 0.6 },
	[GetHashKey("starling")] = { 0.0, -3.0, 0.6 },
	[GetHashKey("seabreeze")] = { 0.0, -3.0, 0.2 },
	[GetHashKey("tula")] = { 0.0, -5.0, 0.7 },
	[GetHashKey("bombushka")] = { 0.0, -21.0, 4.5 },
	[GetHashKey("hunter")] = { 0.0, -6.0, 0.0 },
	[GetHashKey("nokota")] = { 0.0, -4.0, 0.0 },
	[GetHashKey("pyro")] = { 0.0, -3.0, 0.3 },
	[GetHashKey("molotok")] = { 0.0, -5.0, 0.3 },
	[GetHashKey("havok")] = { 0.0, -4.0, 0.3 },
	[GetHashKey("alphaz1")] = { 0.0, -2.5, -0.2 },
	[GetHashKey("microlight")] = { 0.0, -2.0, 0.5 },
	[GetHashKey("howard")] = { 0.0, -3.5, 0.5 },
	[GetHashKey("avenger")] = { 0.0, -10.0, 1.0 },
	[GetHashKey("akula")] = { 0.0, -6.0, 0.0 },
	[GetHashKey("thruster")] = { 0.0, -0.5, 0.0 },
	[GetHashKey("oppressor2")] = { 0.0, -1.2, -0.1 },
	[GetHashKey("volatol")] = { 0.0, -20.0, 1.0 }
}

Citizen.CreateThread(function()
	DecorRegister("smoke_trail", 2)
	DecorRegister("smoke_trail_r", 3)
	DecorRegister("smoke_trail_b", 3)
	DecorRegister("smoke_trail_g", 3)
	DecorRegister("smoke_trail_size", 1)
	while true do
		Citizen.Wait(0)
		local ped = PlayerPedId()
		local veh = GetVehiclePedIsUsing(ped)
		if IsControlJustPressed(0, 20) and offsets[GetEntityModel(veh)] then
			DecorSetBool(veh, "smoke_trail", not DecorGetBool(veh, "smoke_trail"))
			DecorSetInt(veh, "smoke_trail_r", smoker)
			DecorSetInt(veh, "smoke_trail_g", smokeg)
			DecorSetInt(veh, "smoke_trail_b", smokeb)
			DecorSetFloat(veh, "smoke_trail_size", size)
		end
	end
end)

function GetPlayers()
    local players = {}
    for _, player in ipairs(GetActivePlayers()) do
	table.insert(players, player)
    end
    return pairs(players)
end
local ActiveFx = {}

Citizen.CreateThread(function()
	local particleDictionary = "scr_ar_planes"
	local particleName = "scr_ar_trail_smoke"
	RequestNamedPtfxAsset(particleDictionary)
	while not HasNamedPtfxAssetLoaded(particleDictionary) do
		Citizen.Wait(0)
	end
	local p1 = nil
	while true do
		Citizen.Wait(0)
		for ply in GetPlayers() do
			local player = ply-1
			local ped = GetPlayerPed(player)
			local veh = GetVehiclePedIsUsing(ped)
			if offsets[GetEntityModel(veh)] and DecorGetBool(veh, "smoke_trail") then
				local r = DecorGetInt(veh, "smoke_trail_r")
				local g = DecorGetInt(veh, "smoke_trail_g")
				local b = DecorGetInt(veh, "smoke_trail_b")
				local size = DecorGetFloat(veh, "smoke_trail_size")

				if not ActiveFx[veh] then
					UseParticleFxAssetNextCall(particleDictionary)
					local ox, oy, oz = offsets[GetEntityModel(veh)][1], offsets[GetEntityModel(veh)][2], offsets[GetEntityModel(veh)][3]
					ActiveFx[veh] = StartParticleFxLoopedOnEntityBone_2(particleName, veh, ox, oy, oz, 0.0, 0.0, 0.0, -1, size + 0.0, ox, oy, oz)
				elseif ActiveFx[veh] and not IsEntityDead(veh) then
					SetParticleFxLoopedScale(ActiveFx[veh], size+0.0)
					SetParticleFxLoopedRange(ActiveFx[veh], 10000.0)
					SetParticleFxLoopedColour(ActiveFx[veh], r + 0.0, g + 0.0, b + 0.0)
				end
			else
				if ActiveFx[veh] or IsEntityDead(veh) or not veh then
					StopParticleFxLooped(ActiveFx[veh], 0)
					ActiveFx[veh] = nil
				end
			end
		end
	end
end)

RegisterCommand("smokecolour", function(source, args, raw)
	local ped = PlayerPedId()
	local veh = GetVehiclePedIsUsing(ped)
	if offsets[GetEntityModel(veh)] then
		smoker = tonumber(args[1])
		smokeg = tonumber(args[2])
		smokeb = tonumber(args[3])
		DecorSetInt(veh, "smoke_trail_r", smoker)
		DecorSetInt(veh, "smoke_trail_g", smokeg)
		DecorSetInt(veh, "smoke_trail_b", smokeb)
	end
end)

RegisterCommand("smokesize", function(source, args, raw)
	local ped = PlayerPedId()
	local veh = GetVehiclePedIsUsing(ped)
	if offsets[GetEntityModel(veh)] then
		size = tonumber(args[1]) + 0.0
		if size > 5.0 then size = 5.0 end
		if size < 0.0 then size = 0.1 end 
		DecorSetFloat(veh, "smoke_trail_size", size)
	end
end)