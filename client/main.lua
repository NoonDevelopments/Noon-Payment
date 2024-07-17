local QBCore = exports['qb-core']:GetCoreObject()
local Config = Config or {}
local currentBillId = 1000
local pendingBills = {}

CreateThread(function()
    for business, data in pairs(Config.Business) do
        for _, register in ipairs(data.registers) do
            exports['qb-target']:AddBoxZone(register.name, register.coords, register.length, register.width, {
                name = register.name,
                heading = register.heading,
                debugPoly = register.debug,
                minZ = register.minZ,
                maxZ = register.maxZ,
            }, {
                options = {
                    {
                        type = "client",
                        event = "qb-payment:openRegister",
                        icon = "fas fa-cash-register",
                        label = "Open Register",
                        job = business
                    },
                    {
                        type = "client",
                        event = "qb-payment:openPaymentUI",
                        icon = "fas fa-money-bill-alt",
                        label = "Pay Bill",
                    }
                },
                distance = 1.5
            })
        end
    end
end)

RegisterNetEvent('qb-payment:openRegister')
AddEventHandler('qb-payment:openRegister', function()
    local player = QBCore.Functions.GetPlayerData()
    local jobName = player.job.name
    if Config.Business[jobName] then
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'openRegister',
            logo = Config.Business[jobName].logo,
            items = Config.Business[jobName].items
        })
    else
        QBCore.Functions.Notify('You do not have permission to use this.', 'error')
    end
end)

RegisterNetEvent('qb-payment:openPaymentUI')
AddEventHandler('qb-payment:openPaymentUI', function()
    local player = QBCore.Functions.GetPlayerData()
    local jobName = player.job.name
    local isJobWorker = Config.Business[jobName] ~= nil
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openPayment',
        logo = Config.Business[jobName].logo,
        bills = pendingBills,
        isJobWorker = isJobWorker,
        maxBills = Config.MaxActiveBills
    })
end)

RegisterNetEvent('qb-payment:updateBills')
AddEventHandler('qb-payment:updateBills', function(bills)
    pendingBills = bills
end)

RegisterNetEvent('qb-payment:notify')
AddEventHandler('qb-payment:notify', function(message)
    QBCore.Functions.Notify(message)
end)

RegisterNetEvent('qb-payment:billPaid')
AddEventHandler('qb-payment:billPaid', function(billId)
    pendingBills[billId] = nil
end)

RegisterNetEvent('qb-payment:billCancelled')
AddEventHandler('qb-payment:billCancelled', function(billId)
    pendingBills[billId] = nil
end)

RegisterNUICallback('submitBill', function(data, cb)
    if table.count(pendingBills) >= Config.MaxActiveBills then
        QBCore.Functions.Notify('Maximum number of active bills reached. Please process existing bills before creating new ones.', 'error')
        cb({ status = 'error' })
        return
    end

    local totalAmount = tonumber(data.totalAmount)
    if totalAmount and totalAmount > 0 then
        currentBillId = currentBillId + 1
        pendingBills[currentBillId] = { totalAmount = totalAmount }
        TriggerServerEvent('qb-payment:submitBill', totalAmount, currentBillId)
        cb({ status = 'ok' })
    else
        cb({ status = 'error' })
    end
end)

RegisterNUICallback('payBill', function(data, cb)
    local billId = tonumber(data.billId)
    if billId and pendingBills[billId] then
        TriggerServerEvent('qb-payment:payBill', billId)
        cb({ status = 'ok' })
    else
        cb({ status = 'error' })
    end
end)

RegisterNUICallback('cancelBill', function(data, cb)
    local billId = tonumber(data.billId)
    if billId and pendingBills[billId] then
        TriggerServerEvent('qb-payment:cancelBill', billId)
        cb({ status = 'ok' })
    else
        cb({ status = 'error' })
    end
end)

RegisterNUICallback('escape', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    cb('ok')
end)

function table.count(tbl)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
end
