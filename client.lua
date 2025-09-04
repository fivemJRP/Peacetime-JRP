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
        SetTimecycleModifier('hud_def_blur')
        SetTimecycleModifierStrength(0.5)
        local message = Config.Message.Active:gsub('{activator}', activator or 'Unknown')  -- This displays the activator in notifications
        ShowAdvancedNotification('CHAR_DEFAULT', 'CHAR_DEFAULT', Config.Message.Prefix, '~r~Peace Enforced!~s~', message, 1)
        BeginTextCommandDisplayHelp('STRING')
        AddTextComponentSubstringPlayerName('Peacetime is active: Weapons disabled. Stay chill!')
        EndTextCommandDisplayHelp(0, false, true, -1)
        if peacetimeThread then return end  -- Prevent duplicate threads to avoid resource waste
        peacetimeThread = Citizen.CreateThread(function()
            while peacetimeActive do
                Citizen.Wait(Config.LoopWait)  -- Configurable wait reduces CPU load; higher values improve performance but may delay enforcement
                local ped = PlayerPedId()
                if IsPedArmed(ped, 4) then
                    SetPlayerCanDoDriveBy(ped, false)
                    DisablePlayerFiring(ped, true)
                    SetPedCanSwitchWeapon(ped, false)  -- Additional control to fully disable weapon interactions
                end
            end
            peacetimeThread = nil  -- Clean up to free memory and prevent leaks
        end)
    else
        ClearTimecycleModifier()
        local message = Config.Message.Deactive:gsub('{activator}', activator or 'Unknown')  -- This displays the activator in notifications
        ShowAdvancedNotification('CHAR_DEFAULT', 'CHAR_DEFAULT', Config.Message.Prefix, '~g~Peace Lifted!~s~', message, 1)
        ClearHelp(true)
        if peacetimeThread then
            TerminateThread(peacetimeThread)  -- Efficiently stop thread when peacetime ends, saving CPU
            peacetimeThread = nil
        end
    end
end)