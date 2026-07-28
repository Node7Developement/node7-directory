Node7DirectoryValidation = Node7DirectoryValidation or {}

local function plainVector(value)
    if type(value) ~= 'table' and type(value) ~= 'vector3' and type(value) ~= 'vector4' then return nil end
    if value.x == nil or value.y == nil or value.z == nil then return nil end
    return { x = value.x + 0.0, y = value.y + 0.0, z = value.z + 0.0, w = value.w and value.w + 0.0 or nil }
end

local function copyArray(value)
    local output = {}
    if type(value) ~= 'table' then return output end
    for i = 1, #value do output[#output + 1] = value[i] end
    return output
end

function Node7DirectoryValidation.NormalizeCategory(category, fallbackOwner)
    if type(category) ~= 'table' then return nil end
    local id = tostring(category.id or ''):lower():gsub('[^%w_%-]', '')
    if id == '' then return nil end
    return {
        id = id,
        label = tostring(category.label or id),
        order = tonumber(category.order) or 999,
        owner = tostring(category.owner or fallbackOwner or 'node7-directory')
    }
end

function Node7DirectoryValidation.NormalizeAction(action)
    if type(action) ~= 'table' then return nil end
    local actionType = tostring(action.type or ''):lower()
    local allowed = { route = true, command = true, client_event = true, server_event = true, export = true }
    if not allowed[actionType] then return nil end
    return {
        id = tostring(action.id or actionType),
        label = tostring(action.label or actionType),
        type = actionType,
        command = action.command and tostring(action.command) or nil,
        event = action.event and tostring(action.event) or nil,
        resource = action.resource and tostring(action.resource) or nil,
        export = action.export and tostring(action.export) or nil,
        args = copyArray(action.args)
    }
end

function Node7DirectoryValidation.NormalizeEntry(entry, fallbackOwner)
    if type(entry) ~= 'table' then return nil end
    local id = tostring(entry.id or ''):lower():gsub('[^%w_%-]', '')
    if id == '' then return nil end

    local actions = {}
    for _, action in ipairs(type(entry.actions) == 'table' and entry.actions or {}) do
        local normalized = Node7DirectoryValidation.NormalizeAction(action)
        if normalized then actions[#actions + 1] = normalized end
    end

    local details = {}
    for _, detail in ipairs(type(entry.details) == 'table' and entry.details or {}) do
        details[#details + 1] = tostring(detail)
    end

    return {
        id = id,
        category = tostring(entry.category or 'featured'):lower(),
        order = tonumber(entry.order) or 999,
        label = tostring(entry.label or id),
        kicker = tostring(entry.kicker or 'DIRECTORY'),
        location = tostring(entry.location or 'NODE7'),
        description = tostring(entry.description or ''),
        details = details,
        coords = plainVector(entry.coords),
        actions = actions,
        featured = entry.featured == true,
        owner = tostring(entry.owner or fallbackOwner or 'node7-directory')
    }
end
