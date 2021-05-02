ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)
  ESX = obj
end)

ESX.RegisterServerCallback('Alf-Billing:getName', function(source, cb)
  local identifier = ESX.GetPlayerFromId(source).identifier
  MySQL.Async.fetchAll('SELECT firstname, lastname FROM users WHERE identifier = @identifier', {
      ['@identifier'] = identifier
  }, function(result)
      if result ~= nil then
          cb(result[1].firstname .. " " .. result[1].lastname)
      else
          cb(nil)
      end
  end)
end)

-----------------------------------------------------
-->                    Events                     <--
-----------------------------------------------------

ESX.RegisterUsableItem('bill', function(source)
	TriggerClientEvent("Alf-Billing:open", source)
end)

-----------------------------------------------------
-->                    Events                     <--
-----------------------------------------------------


--> An Gegenüberliegenden Spieler Senden

RegisterServerEvent('Alf-Billing:SendToTarget')
AddEventHandler('Alf-Billing:SendToTarget', function(target, price, title, content, society)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(target)
	if xTarget ~= nil then
		TriggerClientEvent("Alf-Billing:openTarget", xTarget.source, price, title, content, society)
	else
		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('noPlayerNearYou'))
	end
end)

RegisterServerEvent('Alf-Billing:HasItem')
AddEventHandler('Alf-Billing:HasItem', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.getInventoryItem('bill') > 0 then
		return true
	else
		return false
	end

end)

RegisterServerEvent('Alf-Billing:DenyBill')
AddEventHandler('Alf-Billing:DenyBill', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(target)

	TriggerClientEvent('esx:showNotification', xPlayer.source, _U('denyBill'))
	TriggerClientEvent('Alf-Billing:Animation-Deny', xPlayer.source)
	
	TriggerClientEvent('esx:showNotification', xTarget.source, _U('denyBill'))

end)



-----------------------------------------------------
-->             Rechnung Ausstellen               <--
-----------------------------------------------------


--> Privat

RegisterServerEvent('Alf-Billing:PayBill')
AddEventHandler('Alf-Billing:PayBill', function(target, price, title, content)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(target)

	price = (tonumber(price))
	price = (math.floor(price))

	--if xPlayer.getBank() >= price then
	if xPlayer.getAccount("bank").money then
		if Config.PriceLimit and price >= Config.MaxPrice then
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('overTheLimits'))
			print(xPlayer.identifier .. " makes a too big Bill")
		else
			xPlayer.removeAccountMoney('bank', price)
			xTarget.addAccountMoney('bank', price)
			
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('paidBill', price))
			TriggerClientEvent('esx:showNotification', xTarget.source, _U('TargetPaid', price))
			
			xTarget.removeInventoryItem('bill', 1)
		end
	else
		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('notEnoughMoney'))
	end
end)


--> Society

RegisterServerEvent('Alf-Billing:PayBillSociety')
AddEventHandler('Alf-Billing:PayBillSociety', function(society, price, title, content, target)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(target)

	price = (tonumber(price))
	price = (math.floor(price))

	--if xTarget.getBank() >= price then
	if xTarget.getAccount("bank").money then
		if Config.PriceLimit and price >= Config.MaxPrice then
			TriggerClientEvent('esx:showNotification', xTarget.source, _U('overTheLimits'))
			print(xPlayer.identifier .. " makes a too big Bill")
		else
			xTarget.removeAccountMoney('bank', price)
			
			TriggerEvent('esx_addonaccount:getSharedAccount', society, function(account)
				account.addMoney(price)
			end)
	
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('paidBill', price))
			TriggerClientEvent('esx:showNotification', xTarget.source, _U('TargetPaidSociety', price))
		end


	else
		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('notEnoughMoney'))
	end
end)



-----------------------------------------------------
-->             	SQL Import	                  <--
-----------------------------------------------------

RegisterServerEvent('Alf-Billing:InsertSQL')
AddEventHandler('Alf-Billing:InsertSQL', function(sender, receiver, target_type, society, label, content, price)
	local source 	= source
	local xSender	= ESX.GetPlayerFromId(sender)
	local xReceiver = ESX.GetPlayerFromId(source)

    MySQL.Async.execute("INSERT INTO `alf_billing` (`sender`, `receiver`, `target_type`, `target`, `label`, `description`, `price`) VALUES (@sender, @receiver, @target_type, @target, @label, @description, @price)", { 
        ['@sender'] 		= xSender.identifier,
        ['@receiver'] 		= xReceiver.identifier,
        ['@target_type'] 	= target_type,
		['@target'] 		= society,
        ['@label'] 			= label,
        ['@description'] 	= content,
		['@price'] 			= price,
    })

end)