ESX = nil

Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
	end
end)

local openTarget = false
local open = false

--[[
RegisterCommand('billing', function(source, args)
  TriggerEvent("Alf-Billing:open")
end, false)

RegisterCommand('billing2', function(source, args)
  TriggerEvent("Alf-Billing:openSociety", args[1])
end, false)
]]
-----------------------------------------------------
--                     Events                      --
-----------------------------------------------------

-- Öffnet UI beim Source Spieler // Opens UI from Source Player

RegisterNetEvent('Alf-Billing:open')
AddEventHandler('Alf-Billing:open', function()
  CreateBill(true, "player")
  SetNuiFocus(true, true)
  open = true
end)

-- Öffnet UI beim Source Spieler für eine Society // Opens UI from Source Player to pay an Society bill

RegisterNetEvent('Alf-Billing:openSociety')
AddEventHandler('Alf-Billing:openSociety', function(society)
  CreateBill(true, society)
  SetNuiFocus(true, true)
  open = true
end)

-- Öffnet Alte Rechnung // Open an Old Bill

RegisterNetEvent('Alf-Billing:openOldBill')
AddEventHandler('Alf-Billing:openOldBill', function(id)
  LookUpBill(id)
  SetNuiFocus(true, true)
end)

-- Schließt UI beim Source Spieler // Close UI from Source Player

RegisterNetEvent('Alf-Billing:close')
AddEventHandler('Alf-Billing:close', function(source)
  CreateBill(false)
  SetNuiFocus(false, false)
  open = false
end)

-- Öffnet UI beim Target Spieler // Opens UI from Target Player

RegisterNetEvent('Alf-Billing:openTarget')
AddEventHandler('Alf-Billing:openTarget', function(price, label, content, society)
  ShowTargetBill(true, price, label, content, society)
  SetNuiFocus(true, true)
  openTarget = true
end)

-- Schließt UI beim Target Spieler // Close UI from Target Player

RegisterNetEvent('Alf-Billing:closeTarget')
AddEventHandler('Alf-Billing:closeTarget', function(target)
  ShowTargetBill(false)
  SetNuiFocus(false, false)
  openTarget = false
end)

-- Führt die Clipboard Animation aus // Clipboard Animation

RegisterNetEvent('Alf-Billing:Animation-Clipboard')
AddEventHandler('Alf-Billing:Animation-Clipboard', function()
  local player = PlayerPedId()
  RequestAnimDict("missfam4")
  TaskPlayAnim(player, "missfam4", "base", 2.0, 2.5, 1500, 49, 0, false, false, false)
  RemoveAnimDict("missfam4")
end)

-- Animation beim Ablehnen // Deny Animation

RegisterNetEvent('Alf-Billing:Animation-Deny')
AddEventHandler('Alf-Billing:Animation-Deny', function()
  local player = PlayerPedId()
  RequestAnimDict("gestures@m@standing@casual")
  TaskPlayAnim(player, "gestures@m@standing@casual", "gesture_no_way", 2.0, 2.5, 1500, 49, 0, false, false, false)
  RemoveAnimDict("gestures@m@standing@casual")
end)


-----------------------------------------------------
--                   Functions                    --
-----------------------------------------------------

-- Neue Rechnung erstellen // Create a New Bill

function CreateBill(enable, society)

  local player = PlayerPedId()
  TaskStartScenarioInPlace(player, "CODE_HUMAN_MEDIC_TIME_OF_DEATH", 0, true);


  ESX.TriggerServerCallback('Alf-Billing:getName', function(name)
    if Config.PriceLimit then
      SendNUIMessage({
        type = "enableui",
        target = "source",
        society = society,
        enable = enable,

        maxPrice = Config.MaxPrice
      })
    else
      SendNUIMessage({
        type = "enableui",
        target = "source",
        society = society,
        enable = enable
      })
    end
  end)
end

-- Öffnet Rechnung vom Target Spieler // Opens Bill by Target

function ShowTargetBill(enable, price, label, content, society)

  local player = PlayerPedId()
  TaskStartScenarioInPlace(player, "CODE_HUMAN_MEDIC_TIME_OF_DEATH", 0, true);

  ESX.TriggerServerCallback('Alf-Billing:getName', function(name)
    if Config.PriceLimit then
      SendNUIMessage({
        type = "enableui",
        target = "target",
        enable = enable,
        society = society,
        maxPrice = Config.MaxPrice,

        price   = price ,
        label   = label,
        content = content
      })
    else
      SendNUIMessage({
        type = "enableui",
        target = "target",
        enable = enable,
        society = society,

        price   = price ,
        label   = label,
        content = content
      })
    end
  end)
end

-- Anschauen Alter Rechnungen // Shows Old Bills

function LookUpBill()
  ESX.TriggerServerCallback('Alf-Billing:GetOldBill', function(name)
    SendNUIMessage({
      type = "enableui",
      target = "source",
      society = society,
      enable = enable
    })
  end)
end

-----------------------------------------------------
--                   NUI Callbacks                --
----------------------------------------------------

-- Bestätigung // Submit

RegisterNUICallback('submitSource', function(data, cb)
  CreateBill(false)
  SetNuiFocus(false, false)


  local player = PlayerPedId()
  ClearPedTasksImmediately(player)
  ClearAreaOfObjects(GetEntityCoords(player), 2.0, 0)

  local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
  local targetPlayer = GetPlayerServerId(closestPlayer)

  if closestDistance > 3.0 then
    ESX.ShowNotification(_U('noPlayerNearYou'))
  else
    TriggerServerEvent("Alf-Billing:SendToTarget", targetPlayer, data.price, data.title, data.text, data.society) 
    cb('ok')
  end
end)

RegisterNUICallback('submitTarget', function(data, cb)
  CreateBill(false)
  SetNuiFocus(false, false)

  local player = PlayerPedId()
  ClearPedTasksImmediately(player)
  ClearAreaOfObjects(GetEntityCoords(player), 2.0, 0)
  
  local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
  local targetPlayer = GetPlayerServerId(closestPlayer)

  if closestDistance > 3.0 then
    ESX.ShowNotification(_U('noPlayerNearYou'))
  else
    if data.society == "player" then
      TriggerServerEvent("Alf-Billing:PayBill", targetPlayer, data.price, data.title, data.text) 
      TriggerServerEvent("Alf-Billing:InsertSQL", targetPlayer, receiver, "player", "player", data.title, data.text, data.price) 
    else
      TriggerServerEvent("Alf-Billing:PayBillSociety", data.society, data.price, data.title, data.text, targetPlayer) 
      TriggerServerEvent("Alf-Billing:InsertSQL", targetPlayer, receiver, "society", data.society, data.title, data.text, data.price) 
    end
    cb('ok')
  end
end)



-- Abbruch // Cancel

RegisterNUICallback('cancel', function(data, cb)
  CreateBill(false)
  SetNuiFocus(false, false)

  local player = PlayerPedId()
  ClearPedTasksImmediately(player)
  ClearAreaOfObjects(GetEntityCoords(player), 2.0, 0)

  local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
  local targetPlayer = GetPlayerServerId(closestPlayer)


  TriggerServerEvent("Alf-Billing:DenyBill", targetPlayer) 

  cb('ok')
end)

RegisterNUICallback('escape', function(data, cb)
  CreateBill(false)
  SetNuiFocus(false, false)

  local player = PlayerPedId()
  ClearPedTasksImmediately(player)
  ClearAreaOfObjects(GetEntityCoords(player), 2.0, 0)



  local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
  local targetPlayer = GetPlayerServerId(closestPlayer)

  TriggerServerEvent("Alf-Billing:DenyBill", targetPlayer) 

  cb('ok')
end)