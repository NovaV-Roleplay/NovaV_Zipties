ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


RegisterServerEvent('NovaV_zipties:cuff')
AddEventHandler('NovaV_zipties:cuff',function (target)
    TriggerClientEvent('anim:cuff')
end)


RegisterServerEvent('NovaV_zipties:startArest')
AddEventHandler('NovaV_zipties:startArest', function(target)
	local targetPlayer = ESX.GetPlayerFromId(target)

	TriggerClientEvent('esx_ruski_areszt:aresztowany', targetPlayer.source, source)
	TriggerClientEvent('esx_ruski_areszt:aresztuj', source)
end)

ESX.RegisterUsableItem('ziptie',function (playerId)
    local xPlayerrr = ESX.GetPlayerFromId(playerId)
    local xPlayers = ESX.GetExtendedPlayers()
    local coords = xPlayerrr.getCoords(true)
    local last_coords = nil
    local ret_player = nil
    if xPlayerrr.getInventoryItem('ziptie').count <= 0 then return end
    for _, xPlayer in pairs(xPlayers) do
        if xPlayerrr.getIdentifier() == xPlayer.getIdentifier() then
		elseif #(coords - xPlayer.getCoords(true)) <= 10 then
			if #(coords - xPlayer.getCoords(true)) < last_coords then
                if not xPlayer.isCuffed() then
                    last_coords = #(coords - xPlayer.getCoords(true))
                    ret_player = xPlayer
                end
            end
		end
    end
    if ret_player then
        xPlayerrr.triggerEvent('NovaV_zipties:arrest',ret_player.source,ret_player.getCoords(true))
    else
        xPlayerrr.showNotification('Keine Spieler in der Umgebung die du Fesseln könntest!')
    end
end)

ESX.RegisterUsableItem('cissor',function (playerId)
    local xPlayerrr = ESX.GetPlayerFromId(playerId)
    local xPlayers = ESX.GetExtendedPlayers()
    local coords = xPlayerrr.getCoords(true)
    local last_coords = nil
    local ret_player = nil
    if xPlayerrr.getInventoryItem('cissor').count <= 0 then return end
    for _, xPlayer in pairs(xPlayers) do
        if xPlayerrr.getIdentifier() == xPlayer.getIdentifier() then
		elseif #(coords - xPlayer.getCoords(true)) <= 10 then
			if #(coords - xPlayer.getCoords(true)) < last_coords then
                if xPlayer.isCuffed() then
                    last_coords = #(coords - xPlayer.getCoords(true))
                    ret_player = xPlayer
                end
            end
		end
    end
    if ret_player then
        ret_player.triggerEvent('uncuff')
    else
        xPlayerrr.showNotification('Keine Spieler in der Umgebung die du freibinden könntest!')
    end
end)




RegisterNetEvent('NovaV_zipties:SetCuffedState')
AddEventHandler('NovaV_zipties:SetCuffedState', function(state)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.Cuff(state)
end)



-- Register the cuff command.
RegisterCommand('cuff', function(source, args)
    -- If there is at least 1 argument passed to the command ("/cuff <id>" was used), we want to...
    if args[1] ~= nil then
        -- ...cuff the player specified by the argument (server id)
        TriggerClientEvent('anim:cuff', tonumber(args[1]))
    
    -- There's no arguments passed ("/cuff" was used.) then....
    else
        --... if the source is 0, that means the server console/RCON executed the command.
        if source == 0 then
            -- We obviously want to let them know that the console cannot be cuffed!
            -- So let's put some shame on them!
            print('You can\'t cuff from the console without specifying a player to cuff, you idiot!')
        end
    end
    
    -- And last but not least, make it restricted, only people with the "command.cuff" permission can use this command.
end, true)


RegisterCommand('uncuff', function(source, args)
    -- If there is at least 1 argument passed to the command ("/cuff <id>" was used), we want to...
    if args[1] ~= nil then
        -- ...cuff the player specified by the argument (server id)
        TriggerClientEvent('anim:uncuff', tonumber(args[1]))
    
    -- There's no arguments passed ("/cuff" was used.) then....
    else
        --... if the source is 0, that means the server console/RCON executed the command.
        if source == 0 then
            -- We obviously want to let them know that the console cannot be cuffed!
            -- So let's put some shame on them!
            print('You can\'t cuff from the console without specifying a player to cuff, you idiot!')
        
        -- if they were smart enough to be an actual player, but still not specify who to cuff, we
        -- want to hint that they may have forgotten to provide the ID to cuff, by cuffing the player themselves.
        -- lets see how long it takes before this command is ran again because the realized their foolish mistake! hehehe
        end
    end
    
    -- And last but not least, make it restricted, only people with the "command.cuff" permission can use this command.
end, true)