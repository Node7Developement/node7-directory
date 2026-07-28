Node7DirectoryClient = Node7DirectoryClient or {}

function Node7DirectoryClient.Notify(message, notifyType)
    local payload = {
        title = 'NODE7 DIRECTORY',
        description = tostring(message or ''),
        type = tostring(notifyType or 'info'),
        duration = 4500
    }

    if GetResourceState('node7-core') == 'started' then
        local ok = pcall(function() exports['node7-core']:Notify(payload) end)
        if ok then return end
    end

    print(('[node7-directory] %s'):format(payload.description))
end
