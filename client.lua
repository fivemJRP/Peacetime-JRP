-- Optimized by Justice Gaming Network (JGN) - Elevate your FiveM experience with top-tier scripts!

local peacetimeActive = false
local peacetimeThread = nil  -- Cache thread handle for proper cleanup

Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/' .. Config.Command, Config.CommandSuggestion)
end)

AddEventHandler('playerSpawned', function()
    TriggerServerEvent('peacetime:sync')
end)

RegisterNetEvent('peacetime:toggle')
AddEventHandler('peacetime:toggle', function(status, activator, hasBypass)
    peacetimeActive = status
    
    if status then
        local message = Config.Message.Active:gsub('{activator}', activator or 'Unknown')
        SetNotificationTextEntry('STRING')
        AddTextComponentString('~r~' .. Config.Message.Prefix .. '~s~\n' .. message)
        DrawNotification(false, false)
        BeginTextCommandDisplayHelp('STRING')
        AddTextComponentSubstringPlayerName(Config.Message.HelpText)  -- Moved to config
        EndTextCommandDisplayHelp(0, false, true, -1)
        if peacetimeThread then return end
        peacetimeThread = Citizen.CreateThread(function()
            while peacetimeActive do
                Citizen.Wait(Config.LoopWait or 1)
                local ped = PlayerPedId()  -- Moved inside loop for dynamic ped changes
                if not hasBypass then  -- Skip disables if admin bypass is enabled
                    DisablePlayerFiring(ped, true)
                    SetPlayerCanDoDriveBy(ped, false)
                    DisableControlAction(0, 24, true)
                    DisableControlAction(0, 25, true)
                    DisableControlAction(0, 140, true)
                    DisableControlAction(0, 141, true)
                    DisableControlAction(0, 142, true)
                    DisableControlAction(0, 257, true)
                    DisableControlAction(0, 263, true)
                    DisableControlAction(0, 264, true)
                end
            end
            peacetimeThread = nil
        end)
    else
        local message = Config.Message.Deactive:gsub('{activator}', activator or 'Unknown')
        SetNotificationTextEntry('STRING')
        AddTextComponentString('~g~' .. Config.Message.Prefix .. '~s~\n' .. message)
        DrawNotification(false, false)
        ClearHelp(true)
        peacetimeActive = false  -- Signal natural exit
    end
end)