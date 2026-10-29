---
name: wow-addon-development
description: "Create, extend or debug World of Warcraft addons (Retail and Classic/Forever) in Lua: TOC files, SavedVariables, events, Settings options panel, locales, slash commands, vendor/bags/social APIs. Use when: writing an addon, adding a feature module, choosing a WoW API, fixing taint or nil errors, preparing a release. Sources: warcraft.wiki.gg and Blizzard's wow-ui-source."
argument-hint: "Feature or addon to build"
---

# WoW Addon Development

Reference knowledge for building addons the way Blizzard's UI and warcraft.wiki.gg document them.

## When to Use
- Creating a new addon or a new feature module inside one
- Picking the right API / event, or checking whether it exists on Retail and Classic
- Adding a checkbox/slider/dropdown to the Options > AddOns panel
- Diagnosing "attempt to call a nil value", taint, or protected-function errors

## Sources of truth (check before using an API)
1. Wiki raw page: `https://warcraft.wiki.gg/index.php?title=API:<Name>&action=raw` (events: `Event:<NAME>`). Send a custom `User-Agent` and wait a few seconds between requests, the wiki rate-limits.
2. Blizzard UI source: `https://github.com/Gethe/wow-ui-source` (branch `live`), e.g. `Interface/AddOns/Blizzard_UIPanels_Game/Mainline/MerchantFrame.lua` shows how Blizzard itself calls an API.
3. Never invent an API. If it cannot be verified, guard it (`if C_Foo and C_Foo.Bar then`) or leave the feature out.

## Project layout (one addon = one folder named like the TOC)
```
AddonName/
  AddonName.toc        # folder name, TOC name and SavedVariables prefix must match
  core.lua             # namespace, defaults, DB init, enable logic, slash commands
  options.lua          # Settings panel built from a feature registry
  modules/*.lua        # one file per feature, registers itself in the namespace
  locale/*.lua         # enUS = source of truth, other locales override
```

### TOC essentials
```
## Interface: 120105, 16001        # comma-separated: Retail, Classic/Forever
## Title: ...
## Notes: ...
## Version: x.y.z
## SavedVariables: AddonNameDB
## Category: Miscellaneous           # + Category-frFR, ... for localisation
```
Files load in listed order; each file receives `local ADDON_NAME, ns = ...` (the shared private table).

## Conventions
- **Private namespace** `ns` instead of globals. Only expose slash commands and the SavedVariables table globally.
- **SavedVariables**: create in `ADDON_LOADED` (when `arg1 == ADDON_NAME`), merge missing keys from `ns.defaults`, never overwrite user values.
- **Events**: one hidden frame, `RegisterEvent`, dispatch through a table `handlers[event](...)`.
- **Combat lockdown**: protected actions are forbidden in combat. Check `InCombatLockdown()` and defer to `PLAYER_REGEN_ENABLED`.
- **Modifier pause**: `IsShiftKeyDown()`, `IsControlKeyDown()`, `IsAltKeyDown()` evaluated at the moment of the event; let users pick which keys pause the addon.
- **Money**: values are copper. Format with `C_CurrencyInfo.GetCoinTextureString` or fallback `GetCoinTextureString`.
- **Retail vs Classic**: use feature detection, never `WOW_PROJECT_ID` unless unavoidable. Examples: `C_Container` (10.0+, also on current Classic clients), `C_Item.GetItemInfo or GetItemInfo`.
- **Do not hook or replace Blizzard functions** unless required; prefer `hooksecurefunc`. Avoid writing to Blizzard frames (taint).
- **Chat output**: one `Print` helper with the addon prefix; no spam, one summary line per action.

## Options panel (Settings API, Retail 10.0+, same on current Classic clients)
```lua
local category = Settings.RegisterVerticalLayoutCategory("AddonName")
local setting = Settings.RegisterAddOnSetting(category, "ADDON_KEY", "key", db,
    Settings.VarType.Boolean, "Label", defaultValue)
Settings.CreateCheckbox(category, setting, "Tooltip")
Settings.RegisterAddOnCategory(category)
-- open: Settings.OpenToCategory(category:GetID())
```
- Section header: `SettingsPanel:GetLayout(category):AddInitializer(CreateSettingsListSectionHeaderInitializer("Title"))`
- Child option greyed when parent unchecked: `initializer:SetParentInitializer(parentInitializer, function() return db.parentKey end)`
- Drive the panel from a **feature registry table** so adding an option is one entry, not new UI code.
- Guard every optional widget helper (`if CreateSettingsListSectionHeaderInitializer then`).

## Locales
`locale/enUS.lua` defines all keys unconditionally (fallback). Other files only run when `GetLocale()` matches and override keys. Use a metatable `__index = function(_, k) return k end` so a missing key shows its name instead of erroring.

## Verified APIs used for QoL features
| Need | API | Notes |
|------|-----|-------|
| Vendor opened | event `MERCHANT_SHOW` | no payload |
| Bag scan | `C_Container.GetContainerNumSlots(bag)`, `C_Container.GetContainerItemInfo(bag, slot)` | returns `nil` for empty slot; table has `quality`, `stackCount`, `hasNoValue`, `isLocked`, `hyperlink`, `itemID` |
| Bag indexes | `0 .. NUM_BAG_SLOTS` (+ reagent bag on Retail: `NUM_TOTAL_EQUIPPED_BAG_SLOTS`) | |
| Sell an item | `C_Container.UseContainerItem(bag, slot)` with merchant open | Blizzard marks it protected outside a merchant context |
| Sell price | 11th return of `GetItemInfo(link)` (`C_Item.GetItemInfo` on recent clients) | per unit, copper; multiply by `stackCount` |
| Repair | `CanMerchantRepair()`, `GetRepairAllCost()` -> `cost, canRepair`, `RepairAllItems(useGuildFunds)` | cost in copper; only valid with a repair merchant open |
| Guild repair | `IsInGuild()`, `CanGuildBankRepair()`, `GetGuildBankWithdrawMoney()` | remaining daily allowance in copper (huge number for guild master) |
| Player money | `GetMoney()` | copper |
| Summon | event `CONFIRM_SUMMON`, `C_SummonInfo.ConfirmSummon()` (old name `ConfirmSummon`) | |
| Resurrection | event `RESURRECT_REQUEST(inviter)`, `AcceptResurrect()` | |
| Duel | event `DUEL_REQUESTED(playerName)`, `CancelDuel()` | |
| Group invite | event `PARTY_INVITE_REQUEST(name, isTank, isHealer, isDamage, isNativeRealm, allowMultipleRoles, inviterGUID, questSessionActive)`, `AcceptGroup()` then `StaticPopup_Hide("PARTY_INVITE")` | |
| Relationship | `C_FriendList.IsFriend(guid)`, `C_BattleNet.GetAccountInfoByGUID(guid)`, `IsGuildMember(guid)` | all take a player GUID |

## Procedure for a new feature
1. Verify each API on the wiki / Blizzard source; note Retail vs Classic differences.
2. Add the default value in `ns.defaults`, a registry entry in `options.lua`, locale keys in `enUS` and `frFR`.
3. Implement the module as a function table registered on events; early-return when disabled, in combat (if protected) or when a pause key is held (`ns.IsPaused()`).
4. Print at most one concise chat line per action.
5. Validate: syntax-check every file (`luac -p` / `luajit -bl`), run the mock test harness in `tests/` if present, then test in game with `/reload` and `/console scriptErrors 1`.

## Release checklist
- TOC `## Interface` matches the current builds (`/dump (select(4, GetBuildInfo()))`).
- Version bumped in TOC and CHANGELOG; the GitHub workflow packages the `.toc`, `core.lua`, `options.lua`, `modules` and `locale`.
- No leftover debug prints or accidental globals.
