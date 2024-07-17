local QBCore = exports['qb-core']:GetCoreObject()
local Config = Config or {}
local pendingBills = {}

RegisterServerEvent('qb-payment:submitBill')
AddEventHandler('qb-payment:submitBill', function(totalAmount, billId)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)

    if table.count(pendingBills) >= Config.MaxActiveBills then
        TriggerClientEvent('qb-payment:notify', src, 'Maximum number of active bills reached. Please process existing bills before creating new ones.')
        return
    end

    pendingBills[billId] = { totalAmount = totalAmount, playerId = player.PlayerData.citizenid, jobName = player.PlayerData.job.name }
    TriggerClientEvent('qb-payment:notify', -1, 'A new bill (#' .. billId .. ') has been submitted. Use the payment terminal to pay.')
    TriggerClientEvent('qb-payment:updateBills', -1, pendingBills)
end)

RegisterServerEvent('qb-payment:payBill')
AddEventHandler('qb-payment:payBill', function(billId)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local bill = pendingBills[billId]

    if bill then
        local jobName = bill.jobName
        player.Functions.RemoveMoney('bank', bill.totalAmount)
        exports['qb-banking']:AddMoney(jobName, bill.totalAmount, 'Bill #' .. billId)
        TriggerClientEvent('qb-payment:notify', bill.playerId, 'Your bill (#' .. billId .. ') has been paid.')
        TriggerClientEvent('qb-payment:billPaid', -1, billId)
        pendingBills[billId] = nil
        TriggerClientEvent('qb-payment:updateBills', -1, pendingBills)
    else
        TriggerClientEvent('qb-payment:notify', src, 'Invalid bill or insufficient permissions.')
    end
end)

RegisterServerEvent('qb-payment:cancelBill')
AddEventHandler('qb-payment:cancelBill', function(billId)
    local src = source
    if pendingBills[billId] then
        pendingBills[billId] = nil
        TriggerClientEvent('qb-payment:notify', src, 'Bill #' .. billId .. ' has been cancelled.')
        TriggerClientEvent('qb-payment:billCancelled', -1, billId)
        TriggerClientEvent('qb-payment:updateBills', -1, pendingBills)
    else
        TriggerClientEvent('qb-payment:notify', src, 'Invalid bill or insufficient permissions.')
    end
end)

function table.count(tbl)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
end

function OpenRegister()
    TriggerClientEvent('openregister', source)
end

function OpenPayment(amount)
    TriggerClientEvent('openpayment', source, amount)
end
