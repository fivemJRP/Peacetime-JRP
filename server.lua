-- Optimized by Justice Gaming Network (JGN) - Elevate your FiveM experience with top-tier scripts!

local peacetimeActive = false
local peacetimeTimer = nil  -- Cache timer handle for proper cleanup
local playerCooldowns = {}  -- Track per-player toggle cooldowns

-- Config validation on startup
Citizen.CreateThread(function()
    if not Config.WebhookURL or Config.WebhookURL == 'PUT WEBHOOK HERE' then
        print('Warning: Webhook URL not set in config.lua')
    end
    if Config.Duration < 0 then
        Config.Duration = 0
        print('Warning: Duration set to 0 (manual toggle only)')
    end
end)

RegisterServerEvent('peacetime:sync')
AddEventHandler('peacetime:sync', function()
    local hasBypass = Config.AllowAdminBypass and IsPlayerAceAllowed(source, Config.ACEPerm) or false
    TriggerClientEvent('peacetime:toggle', source, peacetimeActive, nil, hasBypass)  -- Pass nil activator and hasBypass
end)

RegisterCommand(Config.Command, function(source, args, rawCommand)
    if not IsPlayerAceAllowed(source, Config.ACEPerm) then
        TriggerClientEvent('chat:addMessage', source, {color = {255, 0, 0}, args = {'Peacetime', 'You lack permission to toggle peacetime.'}})
        return
    end
    
    -- Per-player cooldown (5s)
    local now = GetGameTimer()
    if playerCooldowns[source] and (now - playerCooldowns[source]) < 5000 then
        TriggerClientEvent('chat:addMessage', source, {color = {255, 0, 0}, args = {'Peacetime', 'Cooldown active. Wait 5 seconds.'}})
        return
    end
    playerCooldowns[source] = now
    
    Citizen.Wait(100)  -- Throttle rapid toggles
    local duration = tonumber(args[1]) or Config.Duration  -- Use argument or config default
    if duration < 0 then duration = 0 end  -- Ensure non-negative
    peacetimeActive = not peacetimeActive
    -- Send to each player with their bypass status
    for _, playerId in ipairs(GetPlayers()) do
        local hasBypass = Config.AllowAdminBypass and IsPlayerAceAllowed(playerId, Config.ACEPerm) or false
        TriggerClientEvent('peacetime:toggle', playerId, peacetimeActive, GetPlayerName(source), hasBypass)
    end
    -- Send server-wide chat message with duration
    local durationText = duration > 0 and ' for ' .. duration .. ' seconds' or ''
    local msg = (peacetimeActive and Config.Message.Active or Config.Message.Deactive):gsub('{activator}', GetPlayerName(source)) .. durationText
    TriggerClientEvent('chat:addMessage', -1, {color = peacetimeActive and {0, 255, 0} or {255, 0, 0}, args = {Config.Message.Prefix, msg}})
    SendWebhook(source, peacetimeActive, duration)  -- Pass duration
    
    -- Reintroduce timer for auto-toggle if Duration > 0
    if peacetimeActive and duration > 0 then
        if peacetimeTimer then Citizen.ClearTimeout(peacetimeTimer) end
        peacetimeTimer = Citizen.SetTimeout(duration * 1000, function()
            peacetimeActive = false
            -- Send to each player
            for _, playerId in ipairs(GetPlayers()) do
                local hasBypass = Config.AllowAdminBypass and IsPlayerAceAllowed(playerId, Config.ACEPerm) or false
                TriggerClientEvent('peacetime:toggle', playerId, peacetimeActive, 'System', hasBypass)
            end
            -- Server-wide chat message for auto-deactivation
            local autoMsg = Config.Message.Deactive:gsub('{activator}', 'System (Auto)') .. ' after ' .. duration .. ' seconds'
            TriggerClientEvent('chat:addMessage', -1, {color = {255, 0, 0}, args = {Config.Message.Prefix, autoMsg}})
            SendWebhook(-1, peacetimeActive, duration)
        end)
    elseif not peacetimeActive and peacetimeTimer then
        Citizen.ClearTimeout(peacetimeTimer)
        peacetimeTimer = nil
    end
end)

function SendWebhook(source, status, duration)  -- Add duration parameter
    local timestamp = os.date('%Y-%m-%d %H:%M:%S')
    local embedColor = status and 65280 or 16711680
    local thumbnailUrl = status and 'https://cdn.discordapp.com/attachments/763140004359700490/1035757081321545748/4DD38C8C-765B-48A0-BE0A-0B9B0AEE3A62.jpg?ex=68bb01b3&is=68b9b033&hm=5c64301551341f70488d8201a1078031c7b3019f06d6470f2243c6043388a2b7' or 'https://cdn.discordapp.com/attachments/763140004359700490/1035757081321545748/4DD38C8C-765B-48A0-BE0A-0B9B0AEE3A62.jpg?ex=68bb01b3&is=68b9b033&hm=5c64301551341f70488d8201a1078031c7b3019f06d6470f2243c6043388a2b7'
    local discordEmbed = {
        {
            ['color'] = embedColor,
            ['title'] = '🌿 Peacetime Toggled',
            ['description'] = '**' .. (source == -1 and 'System' or GetPlayerName(source)) .. '** toggled peacetime to `' .. tostring(status) .. '` at ' .. timestamp,
            ['thumbnail'] = {['url'] = thumbnailUrl},
            ['fields'] = {
                {['name'] = 'Duration', ['value'] = duration > 0 and tostring(duration) .. ' seconds' or 'Manual', ['inline'] = true},  -- Use actual duration
                {['name'] = 'Server Status', ['value'] = status and 'Peace Mode Active' or 'Normal Operations', ['inline'] = true}
            },
            ['footer'] = {['text'] = 'Powered by Justice Gaming Network (JGN) - Keep the peace! 🕊️'}
        }
    }
    
    -- Validate embed limits
    local embedJson = json.encode(discordEmbed)
    if #embedJson > 6000 then
        discordEmbed[1]['description'] = string.sub(discordEmbed[1]['description'], 1, 2000) .. '...'
        print('Webhook embed truncated to fit Discord limits')
    end
    
    if Config.WebhookURL then
        local payload = json.encode({username = Config.WebhookName, embeds = discordEmbed})
        if Config.Debug then
            print('Sending webhook to: ' .. string.sub(Config.WebhookURL, 1, 50) .. '...' .. ' | Payload size: ' .. #payload .. ' bytes')
        end
        -- Webhook retries with backoff
        local retryCount = 0
        local function attemptWebhook()
            PerformHttpRequest(Config.WebhookURL, function(err, text, headers)
                if err == 200 or err == 204 then
                    if Config.Debug then
                        print('Webhook sent successfully! Status: ' .. tostring(err))
                    end
                elseif (err == 0 or err == 429 or (err >= 500 and err < 600)) and retryCount < 3 then
                    retryCount = retryCount + 1
                    Citizen.Wait(1000 * retryCount)  -- Exponential backoff
                    attemptWebhook()
                elseif err == 0 then
                    if Config.Debug then
                        print('Webhook error: Network failure (status 0) - Check your webhook URL or internet connection. URL: ' .. string.sub(Config.WebhookURL, 1, 50) .. '...')
                    end
                elseif err == 429 then
                    if Config.Debug then
                        print('Webhook error: Rate limited (429) - Retrying...')
                    end
                elseif err >= 500 and err < 600 then
                    if Config.Debug then
                        print('Webhook error: Server error (' .. tostring(err) .. ') - Retrying...')
                    end
                else
                    if Config.Debug then
                        print('Webhook error: ' .. tostring(err) .. ' | Response: ' .. (text or 'No response') .. ' | Headers: ' .. json.encode(headers or {}))
                    end
                end
            end, 'POST', payload, { ['Content-Type'] = 'application/json' })
        end
        attemptWebhook()
    else
        if Config.Debug then
            print('Webhook URL not set in config.lua')
        end
    end
end