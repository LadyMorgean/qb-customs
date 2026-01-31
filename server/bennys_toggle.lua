local QBCore = exports['qb-core']:GetCoreObject()

local function CountOnDutyMechanics()
    local count = 0
    local players = QBCore.Functions.GetQBPlayers()

    for _, Player in pairs(players) do
        local job = Player.PlayerData.job
        if job and job.name == Config.MechanicJobName and job.onduty then
            count += 1
        end
    end

    return count
end

local function UpdateBennysState()
    if not Config.DynamicBennys then return end

    local onDuty = CountOnDutyMechanics()
    local bennysEnabled = onDuty < Config.DisableBennysWhenOnDutyAtLeast

    -- GlobalState replicates to all clients automatically
    if GlobalState.qb_customs_bennysEnabled ~= bennysEnabled then
        GlobalState.qb_customs_bennysEnabled = bennysEnabled
        GlobalState.qb_customs_mechanicsOnDuty = onDuty
        print(('[qb-customs-2] Mechanics on duty: %s | Bennys enabled: %s'):format(onDuty, tostring(bennysEnabled)))
    end
end

CreateThread(function()
    -- default to enabled on resource start until first check
    GlobalState.qb_customs_bennysEnabled = true
    GlobalState.qb_customs_mechanicsOnDuty = 0

    while true do
        UpdateBennysState()
        Wait((Config.BennysStateCheckSeconds or 15) * 1000)
    end
end)

-- Optional: update instantly on duty toggles if your server triggers these events
RegisterNetEvent('QBCore:Server:SetDuty', function()
    UpdateBennysState()
end)
