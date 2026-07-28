local isOpen = false
local lastOpen = 0
local activeRouteBlip
local localCategories = {}
local localEntries = {}
local globalCategories = {}
local globalEntries = {}
local playerSnapshot = {
    name = GetPlayerName(PlayerId()) or 'Unknown',
    citizenid = 'UNKNOWN',
    job = { label = 'Civilian', grade = 'Freelancer', onduty = false },
    money = { cash = 0, bank = 0, gold = 0 }
}

local RESOURCE = GetCurrentResourceName()
local OPEN_CONTROL = tonumber(Config.OpenControl) or 0x446258B6 -- RedM PAGE UP
local PLAY_SOUND_FRONTEND_NATIVE = 0x67C540AA08E4A6F5

local function debugPrint(message)
    if Config.Debug then
        print(('^5[node7-directory]^7 %s'):format(message))
    end
end

local function releaseFocus()
    SetNuiFocus(false, false)
    if type(SetNuiFocusKeepInput) == 'function' then
        SetNuiFocusKeepInput(false)
    end
end

local function plainConfig()
    local categories, entries = {}, {}

    for _, raw in ipairs(Config.Categories or {}) do
        local category = Node7DirectoryValidation.NormalizeCategory(raw, RESOURCE)
        if category then
            localCategories[category.id] = category
            categories[#categories + 1] = category
        end
    end

    for _, raw in ipairs(Config.Entries or {}) do
        local entry = Node7DirectoryValidation.NormalizeEntry(raw, RESOURCE)
        if entry then
            localEntries[entry.id] = entry
            entries[#entries + 1] = entry
        end
    end

    return categories, entries
end

local function mergedList(base, dynamic)
    local map, result = {}, {}

    for id, value in pairs(base) do map[id] = value end
    for id, value in pairs(dynamic) do map[id] = value end
    for _, value in pairs(map) do result[#result + 1] = value end

    table.sort(result, function(a, b)
        if (a.order or 999) == (b.order or 999) then
            return tostring(a.label) < tostring(b.label)
        end
        return (a.order or 999) < (b.order or 999)
    end)

    return result
end

local function payload()
    return {
        branding = Config.Branding,
        player = playerSnapshot,
        categories = mergedList(localCategories, globalCategories),
        entries = mergedList(localEntries, globalEntries),
        key = Config.OpenKeyLabel or 'PAGE UP',
        sound = {
            categoryEnabled = not (Config.CategorySound and Config.CategorySound.enabled == false),
            categoryVolume = (Config.CategorySound and tonumber(Config.CategorySound.volume)) or 0.42
        }
    }
end

local function sendRefresh()
    if isOpen then
        SendNUIMessage({ action = 'refresh', payload = payload() })
    end
end

local function closeDirectory()
    if not isOpen then
        releaseFocus()
        return
    end

    isOpen = false
    releaseFocus()
    SendNUIMessage({ action = 'close' })
end

local function closeNativePauseMenu()
    if Config.CloseNativePauseMenu ~= true then return end

    pcall(function()
        if type(IsPauseMenuActive) == 'function' and IsPauseMenuActive() then
            Citizen.InvokeNative(0x332B562EEDA62399)
        end
    end)
end

local function openDirectory()
    local now = GetGameTimer()
    if now - lastOpen < (Config.OpenCooldownMs or 500) then return end
    lastOpen = now

    if isOpen then
        closeDirectory()
        return
    end

    closeNativePauseMenu()
    isOpen = true

    -- Let Chromium paint the page before input focus is captured. This avoids a
    -- silent-looking input stall on slower RedM clients.
    SendNUIMessage({ action = 'open', payload = payload() })
    CreateThread(function()
        Wait(0)
        if not isOpen then return end
        SetNuiFocus(true, true)
        if type(SetNuiFocusKeepInput) == 'function' then
            SetNuiFocusKeepInput(false)
        end
    end)

    TriggerServerEvent('node7-directory:server:requestSnapshot')
end

local function clearRoute()
    pcall(function()
        Citizen.InvokeNative(0x4426D65E029A4DC0, false)
        Citizen.InvokeNative(0x9E0AB9AAEE87CE28)
    end)

    if activeRouteBlip and DoesBlipExist(activeRouteBlip) then
        RemoveBlip(activeRouteBlip)
    end

    activeRouteBlip = nil
end

local function markRoute(entry)
    local coords = entry and entry.coords
    if not coords then
        Node7DirectoryClient.Notify('This directory entry has no route coordinates.', 'error')
        return false
    end

    clearRoute()

    local x, y, z = coords.x + 0.0, coords.y + 0.0, coords.z + 0.0
    local routed = pcall(function()
        Citizen.InvokeNative(0x3D3D15AF7BCAAF83, joaat(Config.RouteColor or 'COLOR_WHITE'), true, true)
        Citizen.InvokeNative(0x64C59DD6834FA942, x, y, z, true)
        Citizen.InvokeNative(0x4426D65E029A4DC0, true)
    end)

    local ok, blip = pcall(function()
        local created = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, x, y, z)
        if created and created ~= 0 then
            Citizen.InvokeNative(0x74F74D3207ED525C, created, Config.RouteBlipSprite, true)
            SetBlipScale(created, Config.RouteBlipScale or 0.22)
            Citizen.InvokeNative(0x9CB1A1623062F402, created, entry.label or 'Directory Route')
        end
        return created
    end)

    if ok and blip and blip ~= 0 then
        activeRouteBlip = blip
    end

    if routed or activeRouteBlip then
        Node7DirectoryClient.Notify(('Route marked: %s'):format(entry.label or 'Directory location'), 'success')
        closeDirectory()
        return true
    end

    Node7DirectoryClient.Notify('Unable to create the RedM route.', 'error')
    return false
end

local function invokeExport(action)
    if not action.resource or not action.export then return false, 'invalid_export' end
    if GetResourceState(action.resource) ~= 'started' then return false, 'resource_not_started' end

    local exportTable = exports[action.resource]
    if not exportTable then return false, 'export_table_unavailable' end

    local handler = exportTable[action.export]
    if not handler then return false, 'export_unavailable' end

    local ok, result = pcall(function()
        return handler(table.unpack(action.args or {}))
    end)

    return ok, result
end

local function findEntry(entryId)
    entryId = tostring(entryId or ''):lower()
    return globalEntries[entryId] or localEntries[entryId]
end

local function findAction(entry, actionId)
    for _, action in ipairs(entry and entry.actions or {}) do
        if action.id == tostring(actionId or '') then return action end
    end
end

local function executeAction(entryId, actionId)
    local entry = findEntry(entryId)
    local action = findAction(entry, actionId)

    if not entry or not action then
        Node7DirectoryClient.Notify('Directory action is unavailable.', 'error')
        return
    end

    if action.type == 'route' then
        markRoute(entry)
        return
    end

    if action.type == 'command' and action.command then
        closeDirectory()
        ExecuteCommand(action.command:gsub('^/', ''))
        return
    end

    if action.type == 'client_event' and action.event then
        closeDirectory()
        TriggerEvent(action.event, table.unpack(action.args or {}))
        return
    end

    if action.type == 'server_event' then
        closeDirectory()
        TriggerServerEvent('node7-directory:server:executeAction', entry.id, action.id)
        return
    end

    if action.type == 'export' then
        local ok, reason = invokeExport(action)
        if ok then
            closeDirectory()
        else
            Node7DirectoryClient.Notify(('Service unavailable: %s'):format(tostring(reason)), 'error')
        end
    end
end

local function disableOpenControlThisFrame()
    Citizen.InvokeNative(0xFE99B66D079CF6BC, 0, OPEN_CONTROL, true)
    Citizen.InvokeNative(0xFE99B66D079CF6BC, 2, OPEN_CONTROL, true)
end

local function nativeBool(hash, ...)
    local value = Citizen.InvokeNative(hash, ...)
    return value == true or value == 1
end

local function openControlJustPressed()
    return nativeBool(0x91AEF906BCA88877, 0, OPEN_CONTROL)
        or nativeBool(0x91AEF906BCA88877, 2, OPEN_CONTROL)
end

plainConfig()

RegisterNetEvent('node7-directory:client:snapshot', function(data)
    if type(data) ~= 'table' then return end

    if type(data.player) == 'table' then
        playerSnapshot = data.player
    end

    for _, category in ipairs(type(data.categories) == 'table' and data.categories or {}) do
        local normalized = Node7DirectoryValidation.NormalizeCategory(category, category.owner)
        if normalized then globalCategories[normalized.id] = normalized end
    end

    for _, entry in ipairs(type(data.entries) == 'table' and data.entries or {}) do
        local normalized = Node7DirectoryValidation.NormalizeEntry(entry, entry.owner)
        if normalized then globalEntries[normalized.id] = normalized end
    end

    sendRefresh()
end)

RegisterNetEvent('node7-directory:client:globalCategory', function(category)
    local normalized = Node7DirectoryValidation.NormalizeCategory(category, category and category.owner)
    if normalized then
        globalCategories[normalized.id] = normalized
        sendRefresh()
    end
end)

RegisterNetEvent('node7-directory:client:globalEntry', function(entry)
    local normalized = Node7DirectoryValidation.NormalizeEntry(entry, entry and entry.owner)
    if normalized then
        globalEntries[normalized.id] = normalized
        sendRefresh()
    end
end)

RegisterNetEvent('node7-directory:client:removeGlobalEntry', function(entryId)
    globalEntries[tostring(entryId or ''):lower()] = nil
    sendRefresh()
end)

RegisterNetEvent('node7-directory:client:ownerStopped', function(_, entries, categories)
    for _, id in ipairs(entries or {}) do globalEntries[id] = nil end
    for _, id in ipairs(categories or {}) do globalCategories[id] = nil end
    sendRefresh()
end)

RegisterNetEvent('node7-directory:client:open', openDirectory)
RegisterNetEvent('node7-directory:client:close', closeDirectory)

RegisterNUICallback('close', function(_, cb)
    closeDirectory()
    cb({ ok = true })
end)

RegisterNUICallback('refresh', function(_, cb)
    TriggerServerEvent('node7-directory:server:requestSnapshot')
    cb({ ok = true })
end)

RegisterNUICallback('action', function(data, cb)
    executeAction(data and data.entryId, data and data.actionId)
    cb({ ok = true })
end)

RegisterNUICallback('categorySound', function(data, cb)
    local soundConfig = Config.NativeCategorySounds or {}
    if soundConfig.enabled == false then
        cb({ ok = false, reason = 'disabled' })
        return
    end

    local direction = tostring(data and data.direction or 'right'):lower()
    local soundName = direction == 'left'
        and (soundConfig.left or 'NAV_LEFT')
        or (soundConfig.right or 'NAV_RIGHT')
    local soundSet = soundConfig.soundset or 'Ledger_Sounds'

    local ok, err = pcall(function()
        Citizen.InvokeNative(
            PLAY_SOUND_FRONTEND_NATIVE,
            -1,
            soundName,
            soundSet,
            true
        )
    end)

    if not ok then
        debugPrint(('Native category sound failed: %s'):format(tostring(err)))
    end

    cb({ ok = ok })
end)

RegisterCommand(Config.Command or 'directory', function()
    openDirectory()
end, false)

CreateThread(function()
    while true do
        Wait(0)

        if isOpen then
            Citizen.InvokeNative(0x5F4B6931816E599B, 0)
            Citizen.InvokeNative(0x5F4B6931816E599B, 2)
        else
            -- Direct RedM PAGE UP control polling.
            disableOpenControlThisFrame()
            if openControlJustPressed() then
                openDirectory()
            end
        end
    end
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName == RESOURCE then
        releaseFocus()
        SendNUIMessage({ action = 'close' })
        TriggerServerEvent('node7-directory:server:requestSnapshot')
        print(('^2[node7-directory]^7 PAGE UP is ready (RedM control 0x%08X). Fallback: /%s'):format(OPEN_CONTROL, Config.Command or 'directory'))
    elseif resourceName == 'node7-core' then
        TriggerServerEvent('node7-directory:server:requestSnapshot')
    end
end)

AddEventHandler('onClientResourceStop', function(resourceName)
    if resourceName == RESOURCE then
        clearRoute()
        releaseFocus()
    end
end)

exports('Open', openDirectory)
exports('Close', closeDirectory)
exports('ClearRoute', clearRoute)
exports('RegisterCategory', function(data)
    local category = Node7DirectoryValidation.NormalizeCategory(data, GetInvokingResource() or 'unknown')
    if not category then return false end

    globalCategories[category.id] = category
    sendRefresh()
    return true, category.id
end)
exports('RegisterEntry', function(data)
    local entry = Node7DirectoryValidation.NormalizeEntry(data, GetInvokingResource() or 'unknown')
    if not entry then return false end

    globalEntries[entry.id] = entry
    sendRefresh()
    return true, entry.id
end)
exports('RemoveEntry', function(entryId)
    entryId = tostring(entryId or ''):lower()
    if not globalEntries[entryId] then return false end

    globalEntries[entryId] = nil
    sendRefresh()
    return true
end)
