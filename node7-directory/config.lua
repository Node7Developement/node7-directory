Config = Config or {}

Config.Debug = false
Config.Command = 'directory'
Config.OpenControl = 0x446258B6 -- RedM PAGE UP control hash
Config.OpenKeyLabel = 'PAGE UP'
Config.RouteColor = 'COLOR_WHITE'
Config.RouteBlipSprite = joaat('blip_shop_store')
Config.RouteBlipScale = 0.22
Config.CloseNativePauseMenu = true
Config.OpenCooldownMs = 500

-- Native RedM ledger navigation sounds used only when changing directory categories.
Config.NativeCategorySounds = {
    enabled = true,
    soundset = 'Ledger_Sounds',
    left = 'NAV_LEFT',
    right = 'NAV_RIGHT'
}

-- Guaranteed audible NUI category cues. These play immediately on every category change.
Config.CategorySound = {
    enabled = true,
    volume = 0.42
}

Config.Branding = {
    title = 'DIRECTORY',
    subtitle = 'NODE7 SERVER GUIDE',
    footer = 'NODE7 DEVELOPMENT STUDIOS'
}

Config.Categories = {
    { id = 'featured', label = 'Featured', order = 10 },
    { id = 'employment', label = 'Employment', order = 20 },
    { id = 'publicwork', label = 'Public Work', order = 30 },
    { id = 'services', label = 'Town Services', order = 40 },
    { id = 'commerce', label = 'Commerce', order = 50 },
    { id = 'travel', label = 'Travel', order = 60 },
    { id = 'guide', label = 'Server Guide', order = 70 }
}

-- All coordinates are RedM vector3 values. Entries without coordinates are guide pages.
Config.Entries = {
    {
        id = 'employment_valentine',
        category = 'employment',
        order = 10,
        label = 'Valentine Employment Board',
        kicker = 'PUBLIC EMPLOYMENT',
        location = 'Valentine',
        description = 'Review public occupations, accept a civilian job, and mark a route to the configured work site.',
        details = { 'No whitelist required', 'Public jobs only', 'Grade 0 assignment through NODE7 Core' },
        coords = vector3(-360.9735, 791.2225, 115.2034),
        actions = {
            { id = 'open', label = 'Open Employment Board', type = 'export', resource = 'node7-jobcenter', export = 'Open', args = { 'valentine' } },
            { id = 'route', label = 'Mark Route', type = 'route' }
        },
        featured = true
    },
    {
        id = 'employment_rhodes', category = 'employment', order = 20,
        label = 'Rhodes Employment Board', kicker = 'PUBLIC EMPLOYMENT', location = 'Rhodes',
        description = 'Public work notices and civilian employment for the Rhodes territory.',
        details = { 'No whitelist required', 'Public jobs only', 'Core-synchronized employment' },
        coords = vector3(1173.5817, -188.1004, 100.8338),
        actions = {
            { id = 'open', label = 'Open Employment Board', type = 'export', resource = 'node7-jobcenter', export = 'Open', args = { 'rhodes' } },
            { id = 'route', label = 'Mark Route', type = 'route' }
        }
    },
    {
        id = 'employment_blackwater', category = 'employment', order = 30,
        label = 'Blackwater Employment Board', kicker = 'PUBLIC EMPLOYMENT', location = 'Blackwater',
        description = 'Public work notices and civilian employment for the Blackwater territory.',
        details = { 'No whitelist required', 'Public jobs only', 'Core-synchronized employment' },
        coords = vector3(-908.6452, -1344.7482, 45.5606),
        actions = {
            { id = 'open', label = 'Open Employment Board', type = 'export', resource = 'node7-jobcenter', export = 'Open', args = { 'blackwater' } },
            { id = 'route', label = 'Mark Route', type = 'route' }
        }
    },
    {
        id = 'employment_strawberry', category = 'employment', order = 40,
        label = 'Strawberry Employment Board', kicker = 'PUBLIC EMPLOYMENT', location = 'Strawberry',
        description = 'Public work notices and civilian employment for the Strawberry territory.',
        details = { 'No whitelist required', 'Public jobs only', 'Core-synchronized employment' },
        coords = vector3(-1832.5391, -594.5669, 154.5630),
        actions = {
            { id = 'open', label = 'Open Employment Board', type = 'export', resource = 'node7-jobcenter', export = 'Open', args = { 'strawberry' } },
            { id = 'route', label = 'Mark Route', type = 'route' }
        }
    },
    {
        id = 'employment_saintdenis', category = 'employment', order = 50,
        label = 'Saint Denis Employment Board', kicker = 'PUBLIC EMPLOYMENT', location = 'Saint Denis',
        description = 'Public work notices and civilian employment for the Saint Denis territory.',
        details = { 'No whitelist required', 'Public jobs only', 'Core-synchronized employment' },
        coords = vector3(2444.2629, -1504.1483, 45.9690),
        actions = {
            { id = 'open', label = 'Open Employment Board', type = 'export', resource = 'node7-jobcenter', export = 'Open', args = { 'saintdenis' } },
            { id = 'route', label = 'Mark Route', type = 'route' }
        }
    },

    { id = 'work_lumberjack', category = 'publicwork', order = 10, label = 'Lumberjack', kicker = 'PUBLIC ROLE', location = 'Cumberland Forest', description = 'Cut, process, and haul timber for regional mills.', details = { 'Core job: lumberjack', 'Open to civilians', 'Work site route available' }, coords = vector3(-1421.76, -233.43, 99.82), actions = { { id = 'route', label = 'Mark Work Route', type = 'route' } } },
    { id = 'work_miner', category = 'publicwork', order = 20, label = 'Miner', kicker = 'PUBLIC ROLE', location = 'Annesburg', description = 'Mine approved ore and stone deposits.', details = { 'Core job: miner', 'Open to civilians', 'Work site route available' }, coords = vector3(2929.20, 1374.10, 45.20), actions = { { id = 'route', label = 'Mark Work Route', type = 'route' } } },
    { id = 'work_farmer', category = 'publicwork', order = 30, label = 'Farmer', kicker = 'PUBLIC ROLE', location = 'The Heartlands', description = 'Prepare fields, harvest produce, and deliver farm goods.', details = { 'Core job: farmer', 'Open to civilians', 'Work site route available' }, coords = vector3(-236.03, 626.79, 113.14), actions = { { id = 'route', label = 'Mark Work Route', type = 'route' } } },
    { id = 'work_ranchhand', category = 'publicwork', order = 40, label = 'Ranch Hand', kicker = 'PUBLIC ROLE', location = 'Emerald Ranch', description = 'Tend livestock and maintain ranch property.', details = { 'Core job: ranchhand', 'Open to civilians', 'Work site route available' }, coords = vector3(1417.72, 268.42, 89.62), actions = { { id = 'route', label = 'Mark Work Route', type = 'route' } } },
    { id = 'work_fisherman', category = 'publicwork', order = 50, label = 'Fisherman', kicker = 'PUBLIC ROLE', location = 'Flat Iron Lake', description = 'Fish approved waters and deliver fresh catches.', details = { 'Core job: fisherman', 'Open to civilians', 'Work site route available' }, coords = vector3(-724.36, -1250.67, 44.73), actions = { { id = 'route', label = 'Mark Work Route', type = 'route' } } },
    { id = 'work_hunter', category = 'publicwork', order = 60, label = 'Hunter', kicker = 'PUBLIC ROLE', location = 'Open Wilderness', description = 'Track game and deliver usable hunting materials.', details = { 'Core job: hunter', 'Open to civilians', 'Work site route available' }, coords = vector3(-1324.85, 396.31, 95.60), actions = { { id = 'route', label = 'Mark Work Route', type = 'route' } } },
    { id = 'work_wagoner', category = 'publicwork', order = 70, label = 'Freight Wagoner', kicker = 'PUBLIC ROLE', location = 'Valentine Freight Depot', description = 'Collect and deliver assigned freight loads.', details = { 'Core job: wagoner', 'Open to civilians', 'Work site route available' }, coords = vector3(-170.40, 629.64, 113.03), actions = { { id = 'route', label = 'Mark Work Route', type = 'route' } } },
    { id = 'work_postal', category = 'publicwork', order = 80, label = 'Postal Courier', kicker = 'PUBLIC ROLE', location = 'Valentine Post Office', description = 'Collect and deliver regional mail routes.', details = { 'Core job: postal', 'Open to civilians', 'Work site route available' }, coords = vector3(-178.72, 627.75, 114.10), actions = { { id = 'route', label = 'Mark Work Route', type = 'route' } } },
    { id = 'work_stablehand', category = 'publicwork', order = 90, label = 'Stable Hand', kicker = 'PUBLIC ROLE', location = 'Valentine Stable', description = 'Care for horses and maintain stable supplies.', details = { 'Core job: stablehand', 'Open to civilians', 'Work site route available' }, coords = vector3(-367.91, 787.72, 116.17), actions = { { id = 'route', label = 'Mark Work Route', type = 'route' } } },
    { id = 'work_townworker', category = 'publicwork', order = 100, label = 'Town Worker', kicker = 'PUBLIC ROLE', location = 'Valentine', description = 'Complete public maintenance and supply assignments.', details = { 'Core job: townworker', 'Open to civilians', 'Work site route available' }, coords = vector3(-269.37, 767.08, 118.12), actions = { { id = 'route', label = 'Mark Work Route', type = 'route' } } },

    { id = 'stable_valentine', category = 'services', order = 10, label = 'Valentine Stable', kicker = 'HORSE SERVICES', location = 'Valentine', description = 'Horse storage, ownership, equipment, and stable services.', details = { 'Stable services', 'Horse management', 'Town route' }, coords = vector3(-365.20, 791.94, 116.18), actions = { { id = 'route', label = 'Mark Route', type = 'route' } }, featured = true },
    { id = 'sheriff_valentine', category = 'services', order = 20, label = 'Valentine Sheriff Office', kicker = 'TOWN SERVICE', location = 'Valentine', description = 'Law office and public safety service for Valentine.', details = { 'Report emergencies', 'Pay attention to local law', 'Not a public employment role' }, coords = vector3(-276.01, 802.59, 119.41), actions = { { id = 'route', label = 'Mark Route', type = 'route' } } },
    { id = 'sheriff_blackwater', category = 'services', order = 30, label = 'Blackwater Sheriff Office', kicker = 'TOWN SERVICE', location = 'Blackwater', description = 'Law office and public safety service for Blackwater.', details = { 'Report emergencies', 'Pay attention to local law', 'Not a public employment role' }, coords = vector3(-757.27, -1269.34, 44.04), actions = { { id = 'route', label = 'Mark Route', type = 'route' } } },
    { id = 'post_emerald', category = 'services', order = 40, label = 'Emerald Ranch Post Office', kicker = 'POSTAL SERVICE', location = 'Emerald Ranch Station', description = 'Regional post office for telegrams and mail services.', details = { 'Send and receive mail', 'Postal route', 'Regional service' }, coords = vector3(1522.04, 439.54, 90.68), actions = { { id = 'route', label = 'Mark Route', type = 'route' } } },
    { id = 'post_wapiti', category = 'services', order = 50, label = 'Wapiti Post Office', kicker = 'POSTAL SERVICE', location = 'Wapiti', description = 'Northern regional post office and mail collection point.', details = { 'Send and receive mail', 'Postal route', 'Regional service' }, coords = vector3(-1765.084, -384.1582, 157.74119), actions = { { id = 'route', label = 'Mark Route', type = 'route' } } },

    { id = 'commerce_valentine_bank', category = 'commerce', order = 10, label = 'Valentine Bank', kicker = 'FINANCIAL SERVICE', location = 'Valentine', description = 'Banking and account services in central Valentine.', details = { 'Cash and account services', 'Central town location', 'Route only; banking resources can register an open action' }, coords = vector3(-308.50, 775.91, 118.70), actions = { { id = 'route', label = 'Mark Route', type = 'route' } }, featured = true },
    { id = 'commerce_valentine_gunsmith', category = 'commerce', order = 20, label = 'Valentine Gunsmith', kicker = 'COMMERCE', location = 'Valentine', description = 'Weapons, ammunition, and gunsmith services.', details = { 'Weapons and ammunition', 'Town commerce', 'Route to the Valentine gunsmith' }, coords = vector3(-280.4532, 778.9162, 118.5040), actions = { { id = 'route', label = 'Mark Route', type = 'route' } } },
    { id = 'commerce_valentine_hotel', category = 'commerce', order = 30, label = 'Valentine Hotel & Bath', kicker = 'LODGING', location = 'Valentine', description = 'Hotel lodging and bathing services.', details = { 'Bathing service', 'Hotel district', 'Route to the Valentine hotel' }, coords = vector3(-320.56, 762.41, 117.44), actions = { { id = 'route', label = 'Mark Route', type = 'route' } } },

    { id = 'travel_valentine_station', category = 'travel', order = 10, label = 'Valentine Station', kicker = 'TRAVEL', location = 'Valentine', description = 'Rail station and regional travel point.', details = { 'Train access', 'Postal service nearby', 'Valentine town route' }, coords = vector3(-169.47, 629.38, 114.03), actions = { { id = 'route', label = 'Mark Route', type = 'route' } }, featured = true },
    { id = 'travel_emerald_station', category = 'travel', order = 20, label = 'Emerald Ranch Station', kicker = 'TRAVEL', location = 'Emerald Ranch', description = 'Rail station serving the Heartlands and Emerald Ranch.', details = { 'Train access', 'Post office nearby', 'Heartlands route' }, coords = vector3(1522.04, 439.54, 90.68), actions = { { id = 'route', label = 'Mark Route', type = 'route' } } },

    {
        id = 'guide_getting_started', category = 'guide', order = 10,
        label = 'Getting Started', kicker = 'SERVER GUIDE', location = 'NODE7 Framework',
        description = 'A quick path for new characters joining the server.',
        details = {
            'Choose a public occupation at an employment board.',
            'Use PAGE UP to reopen this directory anywhere.',
            'Use the radial menu for nearby player and character actions.',
            'Store valuables and manage weight through NODE7 Inventory.',
            'Public jobs do not require a whitelist.'
        },
        actions = { { id = 'jobs', label = 'Open Employment Board', type = 'export', resource = 'node7-jobcenter', export = 'Open', args = { 'valentine' } } },
        featured = true
    },
    {
        id = 'guide_keybinds', category = 'guide', order = 20,
        label = 'Default Keybinds', kicker = 'SERVER GUIDE', location = 'Controls',
        description = 'Default NODE7 controls. Individual resources may allow players to change their bindings.',
        details = {
            'PAGE UP — Open NODE7 Directory',
            'G — Hold radial menu',
            'I — Open inventory',
            'Escape — Pause menu or close active interface',
            'F8 — Client console and copied development output'
        },
        actions = {}
    },
    {
        id = 'guide_public_jobs', category = 'guide', order = 30,
        label = 'Public Employment', kicker = 'SERVER GUIDE', location = 'Civilian Work',
        description = 'Public jobs are available to civilians without a whitelist.',
        details = {
            'Lumberjack, Miner, Farmer, Ranch Hand, Fisherman',
            'Hunter, Freight Wagoner, Postal Courier',
            'Stable Hand and Town Worker',
            'Law enforcement and medical careers are not offered through public employment.'
        },
        actions = { { id = 'jobs', label = 'Open Employment Board', type = 'export', resource = 'node7-jobcenter', export = 'Open', args = { 'valentine' } } }
    },
    {
        id = 'guide_rules', category = 'guide', order = 40,
        label = 'Community Conduct', kicker = 'SERVER GUIDE', location = 'Server Expectations',
        description = 'Core conduct expectations for a fair roleplay environment.',
        details = {
            'Respect other players and staff decisions.',
            'Do not exploit, duplicate, inject, or abuse resource errors.',
            'Keep roleplay actions consistent with your character and the scene.',
            'Do not use information your character could not reasonably know.',
            'Report technical problems instead of abusing them.'
        },
        actions = {}
    }
}
