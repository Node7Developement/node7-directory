Node7DirectoryServer = Node7DirectoryServer or {}

function Node7DirectoryServer.Notify(source, message, notifyType)
    if GetResourceState('node7-core') ~= 'started' then return false end
    return pcall(function()
        exports['node7-core']:Notify(source, {
            title = 'NODE7 DIRECTORY',
            description = tostring(message or ''),
            type = tostring(notifyType or 'info'),
            duration = 4500
        })
    end)
end
