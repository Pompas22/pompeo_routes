config = {
    types = {
        ['hospitalsul'] = {
            perm = "Paramedic",
            spawnEntityCoords = {
                vec3(152.04,-995.55,29.35),
                vec3(122.23,-1707.0,29.25),
                vec3(253.27,-1212.07,29.32),
                vec3(415.84,-1723.23,29.22),
                vec3(119.95,-1324.36,29.37),
                vec3(-316.49,-895.67,31.07),
                vec3(-376.53,-102.59,39.07),
                vec3(153.24,195.54,106.25),
                vec3(-1552.08,39.26,57.78),
                vec3(-1322.0,-501.24,33.24),
                vec3(-533.38,-1100.21,22.39),
                vec3(342.2,-347.57,47.36),
                vec3(-496.06,593.94,123.58),
                vec3(-1422.3,-210.55,46.51),
                vec3(-1174.56,-876.73,14.07),
                vec3(-1183.91,-1105.71,3.42),
                vec3(-1603.55,-848.46,10.06),
                vec3(-1811.82,-1195.56,13.01),
                vec3(-201.13,-867.2,29.27),
                vec3(-1420.1,-1215.07,3.82),
            },
            entitys = {
                `mp_f_freemode_01`,
                `mp_m_freemode_01`,
                `csb_agent`,
                `ig_bankman`,
            },
            text = "Reanimar",
            reward = {min = 500,max = 5000},
            spawnService = function (coords)
                local model = config.types['hospitalsul'].entitys[math.random(#config.types['hospitalsul'].entitys)]
                RequestModel(model)
                while not HasModelLoaded(model) do
                    RequestModel(model)
                    Citizen.Wait(10)
                end
                local ped = CreatePed(4,model,coords.x,coords.y,coords.z-1,true)
                FreezeEntityPosition(ped,true)
                SetBlockingOfNonTemporaryEvents(ped,true)
                SetModelAsNoLongerNeeded(model)
                TaskPlayAnim(ped, LoadDict('dead'), "dead_a", 8.0, -8.0, -1, 1, 0, false, false, false)
                return ped
            end,
        },
        ['mechanic'] = {
            perm = "Mechanic",
            spawnEntityCoords = {
                vec3(-1501.43,-722.76,26.61),
                vec3(-615.75,341.57,85.11),
                vec3(13.47,-153.41,55.99),
                vec3(293.03,-610.82,43.37),
                vec3(235.92,-786.51,30.6),
                vec3(699.47,-1161.05,24.28),
                vec3(501.93,-1520.01,29.28),
                vec3(323.82,-1828.74,27.2),
                vec3(194.99,-2577.01,6.13),
                vec3(17.36,-1749.45,29.3),
                vec3(-330.1,-1495.22,30.67),
                vec3(-474.55,-1708.32,18.7),
                vec3(-582.22,-1126.52,22.17),
                vec3(-1329.0,-787.54,19.8),
                vec3(-340.32,286.63,85.45),
                vec3(1184.38,-1555.38,34.69),
                vec3(114.82,293.03,109.98),
                vec3(645.63,172.94,95.57),
                vec3(989.68,-191.63,71.66),
                vec3(1150.03,-996.6,45.22),
                vec3(1182.06,-1546.56,39.39),
                vec3(1115.65,-1502.46,34.69),
                vec3(-786.94,-809.31,20.62),
                vec3(-828.84,-760.98,21.99),
                vec3(-403.83,-1132.52,29.4),
                vec3(150.06,-1452.71,29.13),
                vec3(-116.8,-1696.66,29.2),
                vec3(-1022.34,-1102.19,1.92),
                vec3(38.37,-1731.48,29.3),
                vec3(-762.56,-1453.41,5.0),
                vec3(251.54,-1513.41,29.13),
                vec3(294.94,-1205.8,29.17),
                vec3(365.65,-826.54,29.28),
                vec3(-285.71,-613.84,33.41),
                vec3(456.98,-740.04,27.35),
                vec3(-679.29,292.54,82.01),
                vec3(836.1,-68.61,80.44),
                vec3(-272.43,422.64,108.9),
                vec3(-299.78,-884.29,31.07),
                vec3(-1653.46,-248.62,54.85),
                vec3(-582.88,-1126.4,22.17),
                vec3(-935.57,-2103.15,9.3),
                vec3(1175.15,-1547.74,39.39),
                vec3(1158.2,-1489.05,34.69),
            },
            deliveryCoords = {
                vec3(401.2,-1633.6,29.28),
                vec3(-1578.89,-842.58,9.97),
            },
            text = "Guinchar",
            jobVehicle = `flatbed`,
            entitys = {
                `sultan`,
                `panto`,
                `jackal`,
                `rumpo`,
                `asbo`,
                `asea`,
                `banshee`,
                `brioso2`,
                `fellon2`,
                `impaller`,
                `issi2`,
            },
            reward = {min = 2500,max = 5000},
            spawnService = function (coords)
                local model = config.types['mechanic'].entitys[math.random(#config.types['mechanic'].entitys)]
                local netExist,netVeh,mHash,myVeh = vSERVER.serverVehicle(model,coords.x,coords.y,coords.z+0.5)
                if NetworkDoesNetworkIdExist(netVeh) then
                    local nveh = NetToEnt(netVeh)
                    if DoesEntityExist(nveh) then
                        SetVehicleIsStolen(nveh,false)
                        SetVehicleNeedsToBeHotwired(nveh,false)
                        SetVehicleOnGroundProperly(nveh)
                        SetVehicleNumberPlateText(nveh, vSERVER.registerDrive())
                        SetEntityAsMissionEntity(nveh,true,true)
                        SetVehRadioStation(nveh,"OFF")
                        for i = 0,7 do
                            SetVehicleTyreBurst(nveh,i,true,1000.0)
                        end
                            SetVehicleDirtLevel(nveh, 15.0)
                            SetVehicleDoorsLocked(nveh,true)
                            SetVehicleDoorsLockedForAllPlayers(nveh,true)
                        return nveh
                    end
                end
			
				
            end,
        },
    },
    initCoords = {
        {coords = vec3(1144.04,-1543.41,35.38),type = "hospitalsul"},
        {coords = vec3(-1643.32,-818.33,10.42),type = "mechanic"},
    }
}
