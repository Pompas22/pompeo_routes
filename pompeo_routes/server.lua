local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
vCLIENT = Tunnel.getInterface(GetCurrentResourceName())
vSERVER = {}
Tunnel.bindInterface(GetCurrentResourceName(),vSERVER)

function vSERVER.checkPermission(perm)
	local source = source
	local user_id = vRP.getUserId(source)
	
	return vRP.hasGroup(user_id, perm)
end

local acumulatedPayments = {}

function vSERVER.pay(serviceID)
    local source = source
    local user_id = vRP.getUserId(source)
    local payAmount = math.random(config.types[serviceID].reward.min,config.types[serviceID].reward.max)
    if user_id then
        if not acumulatedPayments[user_id] then acumulatedPayments[user_id] = 0 end
        acumulatedPayments[user_id] = acumulatedPayments[user_id] + payAmount
        TriggerClientEvent("Notify", source, 'verde', 'você ganhou R$'..payAmount..' por isso.',5000)
    end
end


RegisterNetEvent("Routes:receiveAcumulatedPayments")
AddEventHandler("Routes:receiveAcumulatedPayments", function ()
    local source = source
    local user_id = vRP.getUserId(source)

    if user_id then
        if acumulatedPayments[user_id] then
            vRP.generateItem(user_id,'dollars',acumulatedPayments[user_id],true)
            acumulatedPayments[user_id] = nil
        end
    end
end)

local plateVehs = {}

function vSERVER.registerDrive()
  
	local source = source
	local user_id = vRP.getUserId(source)

	if user_id then
		plateVehs[user_id] = "PDMS"..(1000 + user_id)
		TriggerEvent("engine:tryFuel",plateVehs[user_id],100)
		TriggerEvent("plateEveryone",plateVehs[user_id])

		return plateVehs[user_id]
	end
	return false
end

function vSERVER.serverVehicle(model,x,y,z)
	local spawnVehicle = 0
	local mHash = model
	local myVeh = CreateVehicle(mHash,x,y,z,0.0,true,true)

	while not DoesEntityExist(myVeh) and spawnVehicle <= 1000 do
		spawnVehicle = spawnVehicle + 1
		Citizen.Wait(100)
	end

	if DoesEntityExist(myVeh) then
		local vehPlate = vRP.generatePlate()
		SetVehicleNumberPlateText(myVeh,vehPlate)
		SetVehicleBodyHealth(myVeh,1000 + 0.0)

		local netVeh = NetworkGetNetworkIdFromEntity(myVeh)

		return true,netVeh,mHash,myVeh
	end

	return false
end