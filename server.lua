local peacetimeActive = false

RegisterServerEvent('peacetime:sync')
AddEventHandler('peacetime:sync', function()
    TriggerClientEvent('peacetime:toggle', source, peacetimeActive)
end)

RegisterCommand(Config.Command, function(source, args, rawCommand)
    if IsPlayerAceAllowed(source, Config.ACEPerm) then
        if peacetimeActive then
            peacetimeActive = false
        else
            peacetimeActive = true
        end
        
        TriggerClientEvent('peacetime:toggle', -1, peacetimeActive)
    end
end)