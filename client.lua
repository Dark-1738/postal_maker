local json = require("json")
local currentPostals = {}

local function savePostalsToFile()
    TriggerServerEvent('savePostals', currentPostals)
end

local function loadPostalsFromFile()
    TriggerServerEvent('loadPostals', function(postals)
        currentPostals = postals or {}
    end)
end

local function printTable(table, indent)
    if not indent then indent = 0 end
    for k, v in pairs(table) do
        local formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            print(formatting)
            printTable(v, indent + 1)
        else
            print(formatting .. v)
        end
    end
end

local function isEmpty(table)
    for _, _ in pairs(table) do
        return false
    end
    return true
end

RegisterCommand('pmake', function(source, args)
    local type = args[1]
    local code = tonumber(args[2])
    local valid = lib.table.contains(currentPostals, code)
    local ped = cache.ped
    local coords = GetEntityCoords(ped)
    local empty = isEmpty(currentPostals)
    if valid == nil then return TriggerEvent('chat:addMessage', { args = { "ERROR", "Code does not exist" } }) end
    if type == "remove" then
        if not code or code == nil then return TriggerEvent('chat:addMessage', { args = { "ERROR", "Missing 'CODE' value" } }) end

        table.remove(currentPostals, valid)
        savePostalsToFile()
        TriggerEvent('chat:addMessage', { args = { "SUCCESS", "Deleted postal: " .. code } })
    elseif type == "add" then
        if not code or code == nil then return TriggerEvent('chat:addMessage', { args = { "ERROR", "Missing 'CODE' value" } }) end

        table.insert(currentPostals, { x = coords.x, y = coords.y, code = code })
        savePostalsToFile()
        TriggerEvent('chat:addMessage', { args = { "SUCCESS", "Added postal: " .. code } })
    elseif type == "load" then
        if empty then return TriggerEvent('chat:addMessage', { args = { "ERROR", "Postals table is empty" } }) end

        loadPostalsFromFile()
        TriggerServerEvent(GetCurrentResourceName() .. ":server:loadPostals", currentPostals)
        TriggerEvent('chat:addMessage', { args = { "SUCCESS", "Loaded postals" } })
    elseif type == "clear" then
        if empty then return TriggerEvent('chat:addMessage', { args = { "ERROR", "Postals table is empty" } }) end

        TriggerEvent('chat:addMessage', { args = { "SUCCESS", "Cleared postals" } })
        for k, v in pairs(currentPostals) do
            currentPostals[k] = nil
        end
        savePostalsToFile()
    elseif type == "list" then
        if empty then return TriggerEvent('chat:addMessage', { args = { "ERROR", "Postals table is empty" } }) end

        printTable(currentPostals, 1)
        TriggerEvent('chat:addMessage', { args = { "SUCCESS", "Printed list of postals in console" } })
    end
end)

TriggerEvent('chat:addSuggestion', '/pmake', 'Postal maker.', {
    { name = "type", help = "Add/Remove/Load/Clear/List" },
    { name = "code", help = "The postal code you would like to delete. (only required if type is add/remove)" }
})

-- Load postals from file when the script starts
loadPostalsFromFile()
