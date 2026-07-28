# node7-directory

Premium native-inspired RedM server guide and location directory for the NODE7 Framework.

## Purpose

`node7-directory` provides a native Red Dead-style server directory for public work, employment boards, town services, travel points, commerce, and server guidance without modifying Rockstar frontend files.

## Features

- PAGE UP opens and closes the directory.
- `/directory` opens the same interface as a manual fallback.
- Direct RedM control polling using the native PAGE UP control hash.
- PAGE UP is handled directly by RedM input natives.
- Native-inspired black textured layout based on the Red Dead player and pause-menu presentation.
- Premium transitions with local open/select/close audio and native RedM ledger sounds when switching categories.
- NODE7 Core character, job, cash, bank, and gold information.
- Employment-board links for Valentine, Rhodes, Blackwater, Strawberry, and Saint Denis.
- All ten NODE7 public-work locations.
- Town services, travel points, keybind guide, and community guide.
- Mouse, keyboard, and controller-friendly navigation structure.
- PAGE UP, Escape, and Backspace close the interface.
- Proper NUI focus release on close and resource stop.
- No visible or opaque NUI while closed.
- External resources can register categories and entries dynamically.

## Installation

```cfg
ensure node7-core
ensure node7-jobcenter
ensure node7-directory
```

Only `node7-core` is a hard dependency. `node7-jobcenter` is optional; employment-board buttons report that the service is unavailable when it is not running.

## Controls

- `PAGE UP`: open or close the directory
- `Left/Right` or `A/D`: change section
- `Up/Down` or `W/S`: change entry
- `Enter`: use the primary action
- `R`: mark the selected route
- `Escape` or `Backspace`: close

The resource reads the RedM PAGE UP control directly (`0x446258B6`).

## Client registration

```lua
exports['node7-directory']:RegisterCategory({
    id = 'businesses',
    label = 'Businesses',
    order = 70
})

exports['node7-directory']:RegisterEntry({
    id = 'my_saloon',
    category = 'businesses',
    label = 'My Saloon',
    kicker = 'PLAYER BUSINESS',
    location = 'Valentine',
    description = 'A player-operated saloon.',
    details = {
        'Food and drink',
        'Player-operated service'
    },
    coords = vector3(-308.0, 806.0, 118.9),
    actions = {
        { id = 'route', label = 'Mark Route', type = 'route' },
        {
            id = 'open',
            label = 'Open Business',
            type = 'client_event',
            event = 'my-saloon:client:open'
        }
    }
})
```

## Server registration

Server resources can register global categories and entries. These are broadcast to every connected player and removed automatically when the owning resource stops.

```lua
exports['node7-directory']:RegisterEntry({
    id = 'server_service',
    category = 'services',
    label = 'Server Service',
    description = 'Registered from a server resource.',
    actions = {
        {
            id = 'use',
            label = 'Use Service',
            type = 'server_event',
            event = 'my-resource:server:useService'
        }
    }
})
```

The server event receives the player source as its first parameter.

## Supported actions

- `route`
- `command`
- `client_event`
- `server_event`
- `export`

Function callbacks are intentionally not accepted because they do not serialize reliably across resource boundaries.


## Native category sounds

Changing sections plays Red Dead ledger navigation audio through the RedM frontend audio native:

```lua
Config.NativeCategorySounds = {
    enabled = true,
    soundset = 'Ledger_Sounds',
    left = 'NAV_LEFT',
    right = 'NAV_RIGHT'
}
```

Entry selection keeps the lighter local navigation sound so category changes remain distinct.

## Category switching audio

Category changes always play local `category-left.ogg` or `category-right.ogg` cues. The optional RedM frontend sound call remains layered underneath but is not required for audible feedback.
