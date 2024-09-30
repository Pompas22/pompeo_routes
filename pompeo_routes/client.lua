local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

vSERVER = Tunnel.getInterface(GetCurrentResourceName())
vCLIENT = {}
Tunnel.bindInterface(GetCurrentResourceName(),vCLIENT)

local inService = false
local selected
local serviceID = ""
local entityCreated = false
local entity
local inProgress = false
-- mechanic
local deliverySelected
local routeBlip = nil


CreateThread(function ()

	for id,data in pairs(config.initCoords) do
		exports["target"]:AddCircleZone("Routes:"..id,data.coords,1.5,{
			name = "Routes:"..id
		},{
			shop = data.type,
			distance = 1.5,
			options = {
				{
					event = "Routes:initRoute",
					label = "Iniciar rota",
					tunnel = "client"
				},
				{
					event = "Routes:finishRoute",
					label = "Encerrar rota",
					tunnel = "client"
				},
				{
					event = "Routes:receiveAcumulatedPayments",
					label = "Receber pagamento",
					tunnel = "client"
				},
			}
		})
	end
end)

RegisterNetEvent('Routes:initRoute')
AddEventHandler('Routes:initRoute', function(Index)
	if not inService and vSERVER.checkPermission(config.types[Index[1]].perm) then
		inService = true
		serviceID = Index[1]
		selected = math.random(#config.types[serviceID].spawnEntityCoords)
		if routeBlip then
			RemoveBlip(routeBlip)
			routeBlip = nil
		end
		TriggerEvent("Notify","verde","Pegue o veículo de trabalho e inicie o serviço",8000)
		routeBlip = CreateBlip(config.types[serviceID].spawnEntityCoords[selected],config.types[serviceID].text)
		serviceThread()
	end
end)

RegisterNetEvent('Routes:finishRoute')
AddEventHandler('Routes:finishRoute', function()
	if inService then
		finishService()
	end
end)

RegisterNetEvent('Routes:receiveAcumulatedPayments')
AddEventHandler('Routes:receiveAcumulatedPayments', function()
	TriggerServerEvent('Routes:receiveAcumulatedPayments')
end)
	

function serviceThread()
	CreateThread(function ()
		while inService do
			local sleep = 1
			local ped = PlayerPedId()
			local pedcds = GetEntityCoords(ped)
			local jobTable = config.types[serviceID]
			local distance = #(pedcds - jobTable.spawnEntityCoords[selected])
			if not entityCreated and distance < 100 then
				entity = jobTable.spawnService(jobTable.spawnEntityCoords[selected])
				entityCreated = true
			end
			if entity then
				if not jobTable.deliveryCoords then
					if not inProgress and not IsEntityPlayingAnim(entity,'dead', "dead_a",3) then            
						TaskPlayAnim(entity, 'dead', "dead_a", 8.0, -8.0, -1, 1, 0, false, false, false)
					end
					local entityCoords = GetEntityCoords(entity)
					local distanceToEntity = #(pedcds - entityCoords)
					if distanceToEntity <= 5 then
						if not inProgress then
							DrawText3Ds(entityCoords.x, entityCoords.y, entityCoords.z, jobTable.text)
						end
						if distanceToEntity <= 1.5 and IsControlJustPressed(0,38) and not inProgress then
							inProgress = true
							TaskTurnPedToFaceEntity(ped,entity,5000)
							Wait(1000)
							TaskPlayAnim(ped, LoadDict("amb@medic@standing@tendtodead@base"),"base", 8.0, -8.0, -1, 1, 0, false, false, false)
							Wait(1000)
							TaskPlayAnim(ped, LoadDict("mini@cpr@char_a@cpr_str"),"cpr_pumpchest", 8.0, -8.0, -1, 1, 0, false, false, false)
							TriggerEvent("progress", 5000, "Reanimando...")
							Wait(5000)
							ClearPedTasks(ped)
							ClearPedTasks(entity)
							Wait(500)
							TaskPlayAnim(ped, LoadDict('mp_common'), 'givetake1_a', 8.0, -8.0, -1, 1, 0, false, false, false)
							TaskPlayAnim(entity, LoadDict('mp_common'), 'givetake1_a', 8.0, -8.0, -1, 1, 0, false, false, false)
							Wait(1500)
							ClearPedTasks(ped)
							ClearPedTasks(entity)
							vSERVER.pay(serviceID)
							FreezeEntityPosition(entity,false)
							SetBlockingOfNonTemporaryEvents(entity,false)
							TaskWanderStandard(entity,10.0,0)
							Wait(10000)
							DeleteEntity(entity)


							selected = math.random(#jobTable.spawnEntityCoords)
							inProgress = false
							entityCreated = false
						end
					end
				else
					local pedVeh = GetVehiclePedIsIn(ped)
					if GetEntityModel(pedVeh) == jobTable.jobVehicle then
						local entityCoords = GetEntityCoords(entity)
						local distanceToEntity = #(pedcds - entityCoords)
						if distanceToEntity <= 15 then
							if not IsEntityAttachedToEntity(pedVeh,entity) then
								DrawText3Ds(entityCoords.x, entityCoords.y, entityCoords.z, jobTable.text)
							else
								if not deliverySelected then
									deliverySelected = math.random(#jobTable.deliveryCoords)
									RemoveBlip(routeBlip)
									routeBlip = CreateBlip(jobTable.deliveryCoords[deliverySelected],"Ponto de entrega")
								end
								DrawText3Ds(entityCoords.x, entityCoords.y, entityCoords.z, "Leve o veiculo até o ponto de entrega")
								local deliveryDistance = #(entityCoords - jobTable.deliveryCoords[deliverySelected])
								if deliveryDistance <= 15 then
									DrawMarker(27,jobTable.deliveryCoords[deliverySelected].x,jobTable.deliveryCoords[deliverySelected].y,jobTable.deliveryCoords[deliverySelected].z-.98,0,0,0,0,0,0,5.0,5.0,5.0,255,255,255,150,0,0,0,0)
								end
								if deliveryDistance <= 5 then
									DeleteEntity(entity)
									selected = math.random(#jobTable.spawnEntityCoords)
									inProgress = false
									entityCreated = false
									entity = nil
									deliverySelected = nil
									if routeBlip then
										RemoveBlip(routeBlip)
										routeBlip = nil
									end
									routeBlip = CreateBlip(jobTable.spawnEntityCoords[selected],jobTable.text)
									vSERVER.pay(serviceID)
								end
							end
							
						end
					end
				end
			end
			Wait(sleep)
		end
	end)
end

function finishService()
	inService = false
	inProgress = false
	entityCreated = false
	selected = nil
	serviceID = ""
	DeleteEntity(entity)
end

LoadDict = function(Dict)
    while not HasAnimDictLoaded(Dict) do 
        Wait(0)
        RequestAnimDict(Dict)
    end

    return Dict
end

function DrawText3Ds(x,y,z,text)
	SetTextFont(4)
	SetTextCentre(1)
	SetTextEntry("STRING")
	SetTextScale(0.35,0.35)
	SetTextColour(255,255,255,150)
	AddTextComponentString(text)
	SetDrawOrigin(x,y,z,0)
	DrawText(0.0,0.0)
	local factor = (string.len(text) / 375) + 0.01
	DrawRect(0.0,0.0125,factor,0.03,38,42,56,200)
	ClearDrawOrigin()
end

function CreateBlip(coords,text)
	local blip = AddBlipForCoord(coords.x,coords.y,coords.z)
	SetBlipSprite(blip,1)
	SetBlipColour(blip,1)
	SetBlipScale(blip,0.4)
	SetBlipAsShortRange(blip,false)
	SetBlipRoute(blip,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(text)
	EndTextCommandSetBlipName(blip)
	return blip
end