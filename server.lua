local json = require("json")

RegisterNetEvent('savePostals')
AddEventHandler('savePostals', function(postals)
    local jsonData = json.encode(postals)
    SaveResourceFile(GetCurrentResourceName(), "currentPostals.json", jsonData, -1)
    print("Postals saved to currentPostals.json")
end)

RegisterNetEvent('loadPostals')
AddEventHandler('loadPostals', function(cb)
    local jsonData = LoadResourceFile(GetCurrentResourceName(), "currentPostals.json")
    local postals = {}
    if jsonData then
        postals = json.decode(jsonData)
        print("Postals loaded from currentPostals.json")
    else
        print("No existing postal data found")
    end
    cb(postals)
end)
