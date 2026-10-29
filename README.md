# AutoMisc

Small quality-of-life automations for World of Warcraft (Retail `120105` and Forever `16001`).

## Features
Every feature is a checkbox in **Options > AddOns > AutoMisc** (or `/am config`).

| Feature | Default |
|---------|:-------:|
| Sell grey items at vendors (gold summary in chat) | on |
| Auto repair: guild funds first, then your own gold | on |
| Accept summons (never in combat) | off |
| Accept resurrections | off |
| Decline duels | off |
| Accept group invites from friends, Battle.net friends and guild members | off |

**Pause keys**: hold Shift, Ctrl or Alt to suspend the addon. Each key can be turned off in the options.

## Commands
| Command | Action |
|---------|--------|
| `/automisc` or `/am` | Show status |
| `/am on` / `/am off` | Enable / disable the addon |
| `/am config` | Open the options panel |

## Development
- Layout and conventions: [docs/PLAN.md](docs/PLAN.md)
- Copilot skill `wow-addon-development` and agent `WoW Addon Creator` live in `.github/`
- Tests with a simulated WoW API: `lua tests/run.lua` (Lua 5.2+; the addon itself targets WoW's Lua 5.1)
- `./sync.sh [--watch]` copies the addon into the WoW `AddOns` folders

## Test in game
1. `/console scriptErrors 1`, then `/reload`
2. `/am config`: the panel lists all options
3. Put a grey item in your bags, open a vendor: it is sold; hold Shift while opening: nothing happens
4. Damage your gear, open a repair vendor: guild funds are used when available, otherwise your gold
