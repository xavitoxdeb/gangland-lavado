ESX = exports["es_extended"]:getSharedObject()

ESX.RegisterServerCallback('esx_moneylaunder:checkPermissions', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local job = xPlayer.getJob().name
    local group = xPlayer.getGroup()

    if group == 'admin' or job == 'unemployed' then
        cb(true)
    else
        cb(false)
    end
end)

RegisterServerEvent('esx_moneylaunder:launderMoney')
AddEventHandler('esx_moneylaunder:launderMoney', function(amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local blackMoney = xPlayer.getAccount('black_money').money

    if blackMoney >= amount then
        local washedMoney = math.floor(amount * Config.Percentage)

        xPlayer.removeAccountMoney('black_money', amount)
        xPlayer.addMoney(washedMoney)

        TriggerClientEvent('esx:showNotification', source, 'Has lavado ~r~$' .. amount .. '~s~ y has recibido ~g~$' .. washedMoney)
    else
        TriggerClientEvent('esx:showNotification', source, 'No tienes suficiente ~r~dinero sucio~s~ para lavar.')
    end
end)
