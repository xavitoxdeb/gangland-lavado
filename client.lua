ESX = exports["es_extended"]:getSharedObject()
local laundering = false

function DrawText3D(coords, text, scale)
    local x, y, z = table.unpack(coords)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local camCoords = GetGameplayCamCoords()

    if onScreen then
        SetTextScale(scale, scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(playerCoords - Config.LaunderLocation)

        if distance < 10.0 then
            DrawMarker(1, Config.LaunderLocation.x, Config.LaunderLocation.y, Config.LaunderLocation.z - 1.0, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 255, 0, 0, 100, false, true, 2, false, false, false, false)

            if distance < 2.0 then
                DrawText3D(Config.LaunderLocation, "[E] Lavar Dinero", 0.4)

                if IsControlJustPressed(0, 38) then
                    ESX.TriggerServerCallback('esx_moneylaunder:checkPermissions', function(hasPermission)
                        if hasPermission then
                            OpenLaunderMenu()
                        else
                            ESX.ShowNotification("No tienes permiso para lavar dinero aquí.")
                        end
                    end)
                end
            end
        end
    end
end)

function OpenLaunderMenu()
    if laundering then
        ESX.ShowNotification("Ya estás lavando dinero.")
        return
    end

    local amount = tonumber(KeyboardInput("¿Cuánto dinero sucio quieres lavar?", "", 10))

    if amount and amount > 0 then
        laundering = true
        ESX.ShowNotification("Comenzando el lavado de dinero...")

        StartLaunderingAnimation(Config.AnimationTime)

        local endTime = GetGameTimer() + (Config.WaitTime * 60000)

        Citizen.CreateThread(function()
            while laundering do
                Citizen.Wait(0)
                local remainingTime = math.ceil((endTime - GetGameTimer()) / 1000)

                if remainingTime > 0 then
                    DrawText3D(Config.LaunderLocation, "Tiempo restante: " .. remainingTime .. "s", 0.4)
                else
                    laundering = false
                end
            end
        end)

        Citizen.Wait(Config.WaitTime * 60000)

        TriggerServerEvent('esx_moneylaunder:launderMoney', amount)

        ESX.ShowNotification("El proceso de lavado ha terminado.")
        laundering = false
    else
        ESX.ShowNotification("Cantidad inválida.")
    end
end

function StartLaunderingAnimation(duration)
    local playerPed = PlayerPedId()

    RequestAnimDict("amb@prop_human_bum_bin@base")
    while not HasAnimDictLoaded("amb@prop_human_bum_bin@base") do
        Citizen.Wait(100)
    end

    TaskPlayAnim(playerPed, "amb@prop_human_bum_bin@base", "base", 8.0, -8.0, duration * 1000, 1, 0, false, false, false)

    Citizen.Wait(duration * 1000)
    ClearPedTasksImmediately(playerPed)
end

function KeyboardInput(textEntry, exampleText, maxStringLength)
    AddTextEntry('FMMC_KEY_TIP1', textEntry)
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", exampleText, "", "", "", maxStringLength)

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end

    if UpdateOnscreenKeyboard() ~= 2 then
        return GetOnscreenKeyboardResult()
    else
        return nil
    end
end
