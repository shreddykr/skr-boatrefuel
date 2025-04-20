local QBCore = exports['qb-core']:GetCoreObject()
local lastRefuelTime = 0
local isRefueling = false
local hasNotified = false
local lastNotificationTime = 0
local notificationCooldown = 10000
local inZone = false
local refuelCooldown = 0

CreateThread(function()
    while true do
        local player = PlayerPedId()
        local coords = GetEntityCoords(player)
        local inBoat = IsPedInAnyBoat(player)
        local sleep = 1500

        if inBoat then
            for _, zone in pairs(Config.RefuelStations) do
                local distanceToZone = #(coords - zone)

                if distanceToZone < 50.0 then
                    sleep = 0
                    DrawMarker(1, zone.x, zone.y, zone.z - 1.0, 0, 0, 0, 0, 0, 0, 6.0, 6.0, 1.0, 0, 0, 255, 200, false, true, 2, false, nil, nil, false)

                    if distanceToZone < 10.0 then
                        if (GetGameTimer() - lastNotificationTime) > notificationCooldown then
                            if not hasNotified then
                                exports.ox_lib:notify({
                                    title = "Dock Pump",
                                    description = "[E] Refuel Boat ($" .. Config.RefuelCost .. ")",
                                    position = "top-right",
                                    type = "info"
                                })
                                hasNotified = true
                                inZone = true
                                lastNotificationTime = GetGameTimer()
                            end
                        end

                        if IsControlJustReleased(0, 38) then -- E key
                            local veh = GetVehiclePedIsIn(player, false)
                            local currentFuel = GetVehicleFuelLevel(veh)

                            if currentFuel >= 90.0 then
                                QBCore.Functions.Notify("Your boat is already full of fuel!", "error")
                                hasNotified = false
                                inZone = true
                            else
                                if GetGameTimer() < refuelCooldown then
                                    local timeRemaining = math.floor((refuelCooldown - GetGameTimer()) / 1000)
                                    QBCore.Functions.Notify("Please wait " .. timeRemaining .. " seconds before refueling again.", "error")
                                    hasNotified = false
                                    inZone = true
                                else
                                    DisableControlAction(0, 75, true)
                                    DisableControlAction(0, 44, true)
                                    SetEntityInvincible(veh, true)

                                    QBCore.Functions.Notify("Refueling... Please wait", "inform", 15000)

                                    Citizen.Wait(15000)

                                    if Config.FuelScript == 'LegacyFuel' then
                                        exports['LegacyFuel']:SetFuel(veh, Config.RefuelAmount)
                                    elseif Config.FuelScript == 'cdn-fuel' then
                                        exports['cdn-fuel']:SetFuel(veh, Config.RefuelAmount)
                                    elseif Config.FuelScript == 'lc_fuel' then
                                        exports['lc_fuel']:SetFuel(veh, Config.RefuelAmount)
                                    else
                                        QBCore.Functions.Notify("Fuel script not configured properly!", "error")
                                        return
                                    end

                                    QBCore.Functions.Notify("Refueled to " .. Config.RefuelAmount .. "%.", "success")
                                    refuelCooldown = GetGameTimer() + 60000
                                    EnableControlAction(0, 75, true)
                                    EnableControlAction(0, 44, true)
                                    SetEntityInvincible(veh, false)
                                    lastRefuelTime = GetGameTimer()
                                end
                            end
                        end
                    end
                elseif inZone then
                    hasNotified = false
                    inZone = false
                end
            end
        end

        Wait(sleep)
    end
end)
