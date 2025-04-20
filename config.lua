Config = {}
--'cdn-fuel' 'legacyfuel' 'lc_fuel'
Config.FuelScript = 'lc_fuel' 

-- Define refueling dock locations using vector3
Config.RefuelStations = {
    vector3(-805.68, -1481.26, 0.33), -- Example location 1
}

-- Max distance from a station to allow refueling
Config.StationRadius = 5.0

-- Refueling time (in ms) dont touch
Config.RefuelTime = 10000

-- The cost to refuel the aircraft to 100%
Config.RefuelCost = 250

-- (100 = full tank)
Config.RefuelAmount = 100
