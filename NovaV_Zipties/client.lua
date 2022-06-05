--Skrypt By Ruski, Contact Information @Ruski#0001 on Discord, Made For PlanetaRP 

local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX               				= nil

local Aresztuje					= false		-- Zostaw na False innaczej bedzie aresztowac na start Skryptu
local Aresztowany				= false		-- Zostaw na False innaczej bedziesz Arresztowany na start Skryptu
 
local AnimArrest			= 'mp_arrest_paired'	-- Sekcja Katalogu Animcji
local AnimVerhafter 			= 'cop_p2_back_left'	-- Animacja Aresztujacego
local AnimVerhaftet			= 'crook_p2_back_left'	-- Animacja Aresztowanego
local OstatnioAresztowany		= 0						-- Mozna sie domyslec ;)

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

end)



RegisterNetEvent('esx_ruski_areszt:aresztowany')
AddEventHandler('esx_ruski_areszt:aresztowany', function(target)
	Aresztowany = true

	local playerPed = GetPlayerPed(-1)
	local targetPed = GetPlayerPed(GetPlayerFromServerId(target))

	RequestAnimDict(AnimArrest)

	while not HasAnimDictLoaded(AnimArrest) do
		Citizen.Wait(10)
	end

	AttachEntityToEntity(GetPlayerPed(-1), targetPed, 11816, -0.1, 0.45, 0.0, 0.0, 0.0, 20.0, false, false, false, false, 20, false)
	TaskPlayAnim(playerPed, AnimArrest, AnimVerhaftet, 8.0, -8.0, 5500, 33, 0, false, false, false)

	Citizen.Wait(950)
	DetachEntity(GetPlayerPed(-1), true, false)

	Aresztowany = false
end)

RegisterNetEvent('esx_ruski_areszt:aresztuj')
AddEventHandler('esx_ruski_areszt:aresztuj', function()
	local playerPed = GetPlayerPed(-1)

	RequestAnimDict(AnimArrest)

	while not HasAnimDictLoaded(AnimArrest) do
		Citizen.Wait(10)
	end

	TaskPlayAnim(playerPed, AnimArrest, AnimVerhafter, 8.0, -8.0, 5500, 33, 0, false, false, false)

	Citizen.Wait(3000)

	Aresztuje = false

end)

-- Glówna Funkcja Animacji
RegisterNetEvent('NovaV_zipties:arrest')
AddEventHandler('NovaV_zipties:arrest',function (target,distance)
	local closestPlayer = GetPlayerPed(GetPlayerFromServerId(target))

	if distance ~= -1 and distance <= Config.ArrestDistance and not Aresztuje and not Aresztowany and not IsPedInAnyVehicle(GetPlayerPed(-1)) and not IsPedInAnyVehicle(GetPlayerPed(closestPlayer)) then
		Aresztuje = true
		
		-- Drukuje Notyfikacje
		TriggerServerEvent('NovaV_zipties:startArest', GetPlayerServerId(closestPlayer))									-- Rozpoczyna Funkcje na Animacje (Cala Funkcja jest Powyzej^^^)

		Citizen.Wait(2100)																									-- Czeka 2.1 Sekund
		TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 2.0, 'cuffseffect', 0.7)									-- Daje Effekt zakuwania (Wgrywasz Plik .ogg do InteractSound'a i ustawiasz nazwe "cuffseffect.ogg")

		Citizen.Wait(3100)																									-- Czeka 3.1 Sekund
		ESX.ShowNotification("Du hast " .. GetPlayerName(closestPlayer) .. " fest genommen!")					-- Drukuje Notyfikacje
		TriggerServerEvent('NovaV_zipties:cuff', GetPlayerServerId(closestPlayer))									-- Zakuwa Poprzez Prace esx_policejob, Mozna zmienic Funkcje na jaka kolwiek inna.
	else
		ESX.ShowNotification('Es gibt keine Person in deiner Umgebung die du Fesseln kannst')
	end
	
end)





local cuffed = false
local dict = "mp_arresting"
local anim = "idle"
-- Set the animation flag to 49, this will make it only show on the upper part of
-- the body, thus not affecting player's legs (movement).
local flags = 49
local ped = PlayerPedId()
-- This variable is used to keep track of changes in the cuffed state.
-- Needed to make sure certain checks are only ran once but should still
-- be in a timer/loop.
local changed = false
-- Set the default MP ped's "teeth" skin variations for male/female MP ped.
-- This is done so we can switch to the handcuffs (if the ped is MP male/female model)
-- when the ped gets cuffed, and switch back to whatever their previous "teeth"
-- skin customization was. Due to different amount of total skin variations for male/female
-- peds, 2 variables are needed to keep track of both.
local prevMaleVariation = 0
local prevFemaleVariation = 0
-- Loading the hashes for female/male MP peds once.
local femaleHash = GetHashKey("mp_f_freemode_01")
local maleHash = GetHashKey("mp_m_freemode_01")

RegisterNetEvent('anim:cuff')
AddEventHandler('anim:cuff', function()
    -- (re)set the ped variable, for some reason the one set previously doesn't always work.
    ped = PlayerPedId()
    
    -- Load the animation dictionary.
    RequestAnimDict(dict)
    
    -- If it's not loaded (yet), wait until it's done loading.
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(0)
    end
    

    if not cuffed then
        -- If it's the female MP model, set the previous skin variation to the
        -- currently used values (this value will be used later when uncuffing)
        -- Next, enable the handcuff models.
        if GetEntityModel(ped) == femaleHash then -- mp female
            prevFemaleVariation = GetPedDrawableVariation(ped, 7)
            SetPedComponentVariation(ped, 7, 25, 0, 0)
        
        -- If it's the male MP model, do the same thing as above, but for the Male ped instead.
        elseif GetEntityModel(ped) == maleHash then -- mp male
            prevMaleVariation = GetPedDrawableVariation(ped, 7)
            SetPedComponentVariation(ped, 7, 41, 0, 0)
        end
        
        -- Enable handcuffs using the native. This makes it so you can't start a
        -- vehicle if the engine is off and you're handcuffed. You can also not pull out any
        -- weapons when on foot. In a vehicle this is broken however so more attack/weapon
        -- prevention checks are done in a loop further down in the script.
        SetEnableHandcuffs(ped, true)
        
        -- Enable the handcuffed animation using the ped, dict, anim and flags variables (defined above).
        TaskPlayAnim(ped, dict, anim, 8.0, -8, -1, flags, 0, 0, 0, 0)
        cuffed = true
		TriggerServerEvent('NovaV_zipties:SetCuffedState',true)
        
    end
    
    -- Change the cuffed state to be the inverse of the previous state.
    
    
    -- Set changed to true, this is used for something that is only ran once but still needs to be in a slow loop.
    changed = true
end)


RegisterNetEvent('anim:uncuff')
AddEventHandler('anim:uncuff', function()
    ped = PlayerPedId()

    if cuffed then
        ClearPedTasks(ped)
        
        SetEnableHandcuffs(ped, false)
        
        UncuffPed(ped)
        
        if GetEntityModel(ped) == femaleHash then -- mp female
            SetPedComponentVariation(ped, 7, prevFemaleVariation, 0, 0)

        elseif GetEntityModel(ped) == maleHash then -- mp male
            SetPedComponentVariation(ped, 7, prevMaleVariation, 0, 0)
        end
        cuffed = false
		TriggerServerEvent('NovaV_zipties:SetCuffedState',false)
    end
    changed = true
end)



Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        if not changed then
            ped = PlayerPedId()

            local IsCuffed = IsPedCuffed(ped) 
            
            
            if IsCuffed and not IsEntityPlayingAnim(PlayerPedId(), dict, anim, 3) then
                
                -- Wait 500ms before playing/setting the cuffed animation again.
                Citizen.Wait(500)
                TaskPlayAnim(ped, dict, anim, 8.0, -8, -1, flags, 0, 0, 0, 0)
            end
        
        else
            changed = false
        end
    end
end)


Citizen.CreateThread(function()
    while true do
        
        Citizen.Wait(0)
        
		ped = PlayerPedId()
        
        -- If the player is currently cuffed....
        if cuffed then
            
            
            DisableControlAction(0, 69, true) -- INPUT_VEH_ATTACK
            DisableControlAction(0, 92, true) -- INPUT_VEH_PASSENGER_ATTACK
            DisableControlAction(0, 114, true) -- INPUT_VEH_FLY_ATTACK
            DisableControlAction(0, 140, true) -- INPUT_MELEE_ATTACK_LIGHT
            DisableControlAction(0, 141, true) -- INPUT_MELEE_ATTACK_HEAVY
            DisableControlAction(0, 142, true) -- INPUT_MELEE_ATTACK_ALTERNATE
            DisableControlAction(0, 257, true) -- INPUT_ATTACK2
            DisableControlAction(0, 263, true) -- INPUT_MELEE_ATTACK1
            DisableControlAction(0, 264, true) -- INPUT_MELEE_ATTACK2
            DisableControlAction(0, 24, true) -- INPUT_ATTACK
            DisableControlAction(0, 25, true) -- INPUT_AIM
            
            SetPedDropsWeapon(ped)
            
            local veh = GetVehiclePedIsIn(ped, false) 
            
            if DoesEntityExist(veh) and not IsEntityDead(veh) and GetPedInVehicleSeat(veh, -1) == ped then
                
                DisableControlAction(0, 59, true)
				ESX.showNotification("Your hands are cuffed, you can't stear!")
            end
        end
    end
end)
