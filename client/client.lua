local QBCore = exports['qb-core']:GetCoreObject()
local isInSafeZone = {} 
local uiState = false 

CreateThread(function()
    while true do
        local player = PlayerId()
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local newUiState = false 

        for index, v in pairs(Config.Bolgeler) do
            local distance = #(coords - v.coord)
            v.isInSafeZone = distance < v.radius
            isInSafeZone[index] = v.isInSafeZone

            if v.isInSafeZone then
                newUiState = true 
                
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
            end
        end

        if newUiState ~= uiState then
            setUiShow(newUiState)
            uiState = newUiState
        end

        Wait(500)
    end
end)

CreateThread(function()
    while true do
        local isInAnySafeZone = false
        for _, v in pairs(isInSafeZone) do
            if v then
                isInAnySafeZone = true
                break
            end
        end

        local myJob = QBCore.Functions.GetPlayerData().job.name
        if isInAnySafeZone and not IsWhitelistedJob(myJob) then
            if Config.DisablePunching then
                DisableControlAction(0, 140, true)
                DisableControlAction(0, 141, true)
                DisableControlAction(0, 142, true)
            end

            if Config.DisableFreeAim then
                DisableControlAction(0, 25, true)
            end

            if Config.DisableShooting then
                DisablePlayerFiring(PlayerId(), true)
            end
        end
        Wait(0)
    end
end)

for _, v in pairs(Config.Bolgeler) do
    local blip = AddBlipForRadius(v.coord.x, v.coord.y, v.coord.z, v.radius)
    SetBlipHighDetail(blip, true)
    SetBlipColour(blip, 2)
    SetBlipAlpha(blip, 128)
end

function setUiShow(bool)
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
