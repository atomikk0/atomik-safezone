local QBCore = exports['qb-core']:GetCoreObject()
local ui = false
local isInSafeZone = false

CreateThread(function()
    while true do
        local player = PlayerId()
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        for _, v in pairs(Config.Bolgeler) do
            local distance = #(coords - v.coord)
            isInSafeZone = distance < v.radius

            if isInSafeZone then
                Wait(100)
                setUiShow(true)
                
                if Config.DisableDriveBy then
                    SetPlayerCanDoDriveBy(player, false)
                end
            
                if Config.AntiVDM then
                    Wait(0)
                    local vehList = GetGamePool('CVehicle')
                    for _, vehicle in pairs(vehList) do
                        SetEntityNoCollisionEntity(vehicle, ped, true)
                    end
                end
            
                if Config.LimitSpeed then
                    local vehicle = GetVehiclePedIsIn(ped, false)
                    if IsEntityAVehicle(vehicle) then
                        local currentSpeed = GetEntitySpeed(vehicle)
                        local safezonespeed = Config.maxSafeZoneSpeed / 3.6
                        local maxSpeedMps = safezonespeed * 1.05 
                        if currentSpeed > maxSpeedMps then
                            SetEntityMaxSpeed(vehicle, maxSpeedMps)
                        end
                    end
                end    
            
                local myJob = QBCore.Functions.GetPlayerData().job.name
                if Config.DisableDrawWeapon and not IsWhitelistedJob(myJob) then
                    SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true) 
                end
            else
                Wait(500)

                if Config.DisableDriveBy then
                    SetPlayerCanDoDriveBy(player, true)
                end
            
                if Config.LimitSpeed then
                    local vehicle = GetVehiclePedIsIn(ped, false)
                    if IsEntityAVehicle(vehicle) then
                        SetEntityMaxSpeed(vehicle, 1000.0)
                    end
                end
            
                setUiShow(false)
            end
        end
    end
end)

CreateThread(function()
    while true do
        if isInSafeZone then
            if Config.DisablePunching then
                DisableControlAction(0, 140, true)
                DisableControlAction(0, 141, true)
                DisableControlAction(0, 142, true)
            end

            if Config.DisableFreeAim then
                DisableControlAction(0, 63, true)
            end

            if Config.DisableShooting then
                DisablePlayerFiring(PlayerId(), true)
            end
        end
        Wait(100)
    end
end)



for _, v in pairs(Config.Bolgeler) do
    local blip = AddBlipForRadius(v.coord.x, v.coord.y, v.coord.z, v.radius)
    SetBlipHighDetail(blip, true)
    SetBlipColour(blip, 2)
    SetBlipAlpha(blip, 128)
end

function setUiShow(bool)
    ui = bool
    SendNUIMessage({
        type = "show",
        show = bool
    })
end

function IsWhitelistedJob(job)
    for _, whitelistedJob in pairs(Config.WhitelistedJobs) do
        if job == whitelistedJob then
            return true
        end
    end
    return false
end
