local peacetimeActive = false

Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/' .. Config.Command, Config.CommandSuggestion)
end)

AddEventHandler('playerSpawned', function()
    TriggerServerEvent('peacetime:sync')
end)

RegisterNetEvent('peacetime:toggle')
AddEventHandler('peacetime:toggle', function(status)
    peacetimeActive = status

    if status then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {Config.Message.Prefix, Config.Message.Active}
        }) 
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {Config.Message.Prefix, Config.Message.Deactive}
        }) 
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if peacetimeActive then
            local ped = PlayerPedId()
            local _, weaponHash = GetCurrentPedWeapon(ped)

            if weaponHash ~= GetHashKey('WEAPON_UNARMED') then
                SetPlayerCanDoDriveBy(ped, false)
                DisablePlayerFiring(ped, true)
            end
        end
    end
end)