local peacetimeActive = false

RegisterCommand(Config.Command, function(source, args, rawCommand)
    if IsPlayerAceAllowed(source, Config.ACEPerm) then
        if peacetimeActive then
            peacetimeActive = false
            TriggerClientEvent('peacetime:toggle', -1, false)
        else
            peacetimeActive = true
            TriggerClientEvent('peacetime:toggle', -1, true)
        end
    end
end)