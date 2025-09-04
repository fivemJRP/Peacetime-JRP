-- Optimized by Justice Gaming Network (JGN) - Elevate your FiveM experience with top-tier scripts!

local peacetimeActive = false
local peacetimeThread = nil  -- Cache thread handle for efficient start/stop management

Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/' .. Config.Command, Config.CommandSuggestion)
end)

AddEventHandler('playerSpawned', function()
    TriggerServerEvent('peacetime:sync')
end)

RegisterNetEvent('peacetime:toggle')
AddEventHandler('peacetime:toggle', function(status, activator)
    peacetimeActive = status
    
    if status then
        local message = Config.Message.Active:gsub('{activator}', activator or 'Unknown')
        SetNotificationTextEntry('STRING')
        AddTextComponentString('~r~' .. Config.Message.Prefix .. '~s~\n' .. message)
        DrawNotification(false, false)  -- Fixed to use valid natives
        BeginTextCommandDisplayHelp('STRING')
        AddTextComponentSubstringPlayerName('Peacetime is active: Weapons disabled. Stay chill!')
        EndTextCommandDisplayHelp(0, false, true, -1)
        if peacetimeThread then return end  -- Prevent duplicate threads to avoid resource waste
        peacetimeThread = Citizen.CreateThread(function()
            while peacetimeActive do
                Citizen.Wait(Config.LoopWait)
                local ped = PlayerPedId()
                -- Disable firing and controls without removing weapons or disabling wheel
                DisablePlayerFiring(ped, true)
                SetPlayerCanDoDriveBy(ped, false)
                -- Removed SetPedCanSwitchWeapon to keep weapon wheel accessible
                DisableControlAction(0, 24, true)  -- Attack
                DisableControlAction(0, 25, true)  -- Aim
                DisableControlAction(0, 140, true)  -- Melee
                DisableControlAction(0, 141, true)  -- Melee alt
                DisableControlAction(0, 142, true)  -- Melee heavy
                -- Additional disables for weapon firing
                DisableControlAction(0, 257, true)  -- Attack 2 (for some weapons)
                DisableControlAction(0, 263, true)  -- Input attack (alternative)
                DisableControlAction(0, 264, true)  -- Input aim (alternative)
            end
            peacetimeThread = nil  -- Clean up to free memory and prevent leaks
        end)
    else
        local message = Config.Message.Deactive:gsub('{activator}', activator or 'Unknown')
        SetNotificationTextEntry('STRING')
        AddTextComponentString('~g~' .. Config.Message.Prefix .. '~s~\n' .. message)
        DrawNotification(false, false)  -- Fixed to use valid natives
        ClearHelp(true)
        if peacetimeThread then
            TerminateThread(peacetimeThread)  -- Efficiently stop thread when peacetime ends, saving CPU
            peacetimeThread = nil
        end
        local ped = PlayerPedId()
        -- Removed SetPedCanSwitchWeapon enable since it's not disabled
    end
end)