local GlobalCategories = {}
local GlobalEntries = {}

local function debugPrint(message)
    if Config.Debug then print(('^5[node7-directory]^7 %s'):format(message)) end
end

local function playerSnapshot(source)
    local snapshot = {
        name = GetPlayerName(source) or 'Unknown',
        citizenid = 'UNKNOWN',
        job = { name = 'unemployed', label = 'Civilian', grade = 'Freelancer', onduty = false },
        money = { cash = 0, bank = 0, gold = 0 }
    }

    if GetResourceState('node7-core') ~= 'started' then return snapshot end

    local ok, player = pcall(function() return exports['node7-core']:GetPlayer(source) end)
    if not ok or type(player) ~= 'table' or type(player.PlayerData) ~= 'table' then return snapshot end

    local data = player.PlayerData
    local charinfo = type(data.charinfo) == 'table' and data.charinfo or {}
    local fullName = (('%s %s'):format(tostring(charinfo.firstname or ''), tostring(charinfo.lastname or ''))):gsub('^%s+', ''):gsub('%s+$', '')
    if fullName ~= '' then snapshot.name = fullName end
    snapshot.citizenid = tostring(data.citizenid or data.cid or snapshot.citizenid)

    if type(data.job) == 'table' then
        snapshot.job.name = tostring(data.job.name or snapshot.job.name)
        snapshot.job.label = tostring(data.job.label or snapshot.job.label)
        snapshot.job.onduty = data.job.onduty == true
        if type(data.job.grade) == 'table' then
            snapshot.job.grade = tostring(data.job.grade.name or data.job.grade.label or data.job.grade.level or snapshot.job.grade)
        elseif data.job.grade ~= nil then
            snapshot.job.grade = tostring(data.job.grade)
        end
    end

    local money = type(data.money) == 'table' and data.money or {}
    snapshot.money.cash = tonumber(money.cash or money.money or 0) or 0
    snapshot.money.bank = tonumber(money.bank or 0) or 0
    snapshot.money.gold = tonumber(money.gold or money.goldbars or 0) or 0
    return snapshot
end

local function allGlobalCategories()
    local result = {}
    for _, category in pairs(GlobalCategories) do result[#result + 1] = category end
    table.sort(result, function(a, b) return a.order == b.order and a.label < b.label or a.order < b.order end)
    return result
end

local function allGlobalEntries()
    local result = {}
    for _, entry in pairs(GlobalEntries) do result[#result + 1] = entry end
    table.sort(result, function(a, b) return a.order == b.order and a.label < b.label or a.order < b.order end)
    return result
end

RegisterNetEvent('node7-directory:server:requestSnapshot', function()
    local source = source
    TriggerClientEvent('node7-directory:client:snapshot', source, {
        player = playerSnapshot(source),
        categories = allGlobalCategories(),
        entries = allGlobalEntries()
    })
end)

RegisterNetEvent('node7-directory:server:executeAction', function(entryId, actionId)
    local source = source
    local entry = GlobalEntries[tostring(entryId or ''):lower()]
    if not entry then return end

    local selected
    for _, action in ipairs(entry.actions or {}) do
        if action.id == tostring(actionId or '') then selected = action break end
    end
    if not selected or selected.type ~= 'server_event' or not selected.event then return end
    TriggerEvent(selected.event, source, table.unpack(selected.args or {}))
end)

exports('RegisterCategory', function(data)
    local owner = GetInvokingResource() or 'unknown'
    local category = Node7DirectoryValidation.NormalizeCategory(data, owner)
    if not category then return false end
    GlobalCategories[category.id] = category
    TriggerClientEvent('node7-directory:client:globalCategory', -1, category)
    return true, category.id
end)

exports('RegisterEntry', function(data)
    local owner = GetInvokingResource() or 'unknown'
    local entry = Node7DirectoryValidation.NormalizeEntry(data, owner)
    if not entry then return false end
    GlobalEntries[entry.id] = entry
    TriggerClientEvent('node7-directory:client:globalEntry', -1, entry)
    return true, entry.id
end)

exports('RemoveEntry', function(entryId)
    entryId = tostring(entryId or ''):lower()
    local entry = GlobalEntries[entryId]
    if not entry then return false end
    local owner = GetInvokingResource()
    if owner and owner ~= entry.owner and owner ~= GetCurrentResourceName() then return false end
    GlobalEntries[entryId] = nil
    TriggerClientEvent('node7-directory:client:removeGlobalEntry', -1, entryId)
    return true
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then return end
    local removedEntries, removedCategories = {}, {}
    for id, entry in pairs(GlobalEntries) do
        if entry.owner == resourceName then GlobalEntries[id] = nil removedEntries[#removedEntries + 1] = id end
    end
    for id, category in pairs(GlobalCategories) do
        if category.owner == resourceName then GlobalCategories[id] = nil removedCategories[#removedCategories + 1] = id end
    end
    if #removedEntries > 0 or #removedCategories > 0 then
        TriggerClientEvent('node7-directory:client:ownerStopped', -1, resourceName, removedEntries, removedCategories)
    end
end)

debugPrint('Server registry ready')
