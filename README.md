# BodyCountRewards (Addon) — I Am Not Your Mom

> *I am not your mom. Add whatever unrealistic, overpowered traits you want.*

An addon mod for [BodyCountRewards](https://steamcommunity.com/sharedfiles/filedetails/?id=3660382016) that adds traits the base mod considers "not lore-friendly." It is also a complete, minimal reference implementation of BCR's third-party extensibility API. If you want to build your own trait pack, start here.

**Requires BodyCountRewards (BCR).** This is not a standalone mod.

---

## Added Traits

### Positive (Earnable)
| Trait | Cost | Rarity | Effect |
|-------|------|--------|--------|
| Brave | 4 | Uncommon | Panic reduction |
| Desensitized | 8 | Very Rare | Complete panic immunity |

### Negative (Removable)
| Trait | Cost | Rarity | Effect |
|-------|------|--------|--------|
| Short Sighted | 2 | Common | Reduced vision range |
| Hard of Hearing | 4 | Uncommon | Reduced hearing radius |
| Insomniac | 6 | Rare | Severe sleep penalty |
| Deaf | 12 | Very Rare | Complete hearing loss |

---

## Sandbox Options

Each trait has its own enable/disable toggle in the `BodyCountRewardsThirdPartyTraits` sandbox settings page. Sandbox options are available in 11 languages (EN, DE, ES, RU, PTBR, CN, KO, TR, FR, PL, UA).

---

## For Mod Developers

**This mod is a living code example.** If you want to add your own traits to BodyCountRewards, download this mod and study `BCRIAmNotYourMom.lua`. The entire registration is only about 65 lines.

Skip to the [Developer Guide](#developer-guide) below for a full walkthrough.

I will not develop addons for other mods. This project is a template. Do it yourself.

---

# Developer Guide

A step-by-step walkthrough for creating a BodyCountRewards trait addon.

## Quick Start

1. **Copy this addon's directory structure** as your starting point.
2. **Edit `mod.info`** (both root and versioned) with your mod ID, name, and `require=BCR`.
3. **Define your traits** in a Lua table with correct cost polarity (see [Trait Data Format](#trait-data-format)).
4. **Call `BCR.RegisterCustomTraits()`** to register them.
5. **Write `sandbox-options.txt`** with one boolean toggle per trait.
6. **Add translations** under `Translate/EN/Sandbox.json`.
7. **Test in-game** — run `BCR.RunThirdPartyTests()` in the console. BCR validates all addons at once.
## File Structure

Your addon must follow this layout. Only files marked `[required]` are mandatory. Others are optional.

```
YourAddon/
├── preview.png                              [optional] Steam Workshop preview image
├── workshop.txt                             [optional] Steam Workshop description
├── Contents/
│   └── mods/
│       └── YourAddon/
│           ├── mod.info                     [required] Root metadata
│           ├── poster.png                   [optional] Mod poster image
│           ├── <version>/
│           │   ├── mod.info                 [required] Versioned metadata
│           │   └── media/
│           │       ├── sandbox-options.txt  [required] Trait toggles
│           │       └── lua/
│           │           └── shared/
│           │               ├── YourAddon.lua    [required] Trait registration code
│           │               └── Translate/
│           │                   ├── EN/
│           │                   │   └── Sandbox.json
│           │                   ├── DE/
│           │                   │   └── Sandbox.json
│           │                   └── ... (one folder per language)
```

The Lua file must be in `shared/`, not `client/` or `server/`. BCR loads addon traits in SP and MP, so shared context is required.

## mod.info

### Root (`Contents/mods/YourAddon/mod.info`)

```
name=Your Addon Name
id=YourAddonID
modversion=1.0.0
icon=your_icon.png
poster=poster.png
description=Brief description.
tags=Build42;Multiplayer;Traits
require=BCR
```

The `require=BCR` line is mandatory. BCR must load before your addon.

### Versioned (`Contents/mods/YourAddon/42.19/mod.info`)

```
name=Your Addon Name
id=YourAddonID
modversion=1.0.0
versionMin=42.19
icon=your_icon.png
poster=poster.png
description=Full description with trait list.
tags=Build42;Multiplayer;Traits
require=BCR
```

Copy your icon and poster files into both the versioned directory and the root mod directory. Project Zomboid resolves assets from the versioned directory first.

## sandbox-options.txt

Each trait needs a boolean toggle. The page must be `BodyCountRewardsThirdPartyTraits` and the option name must follow the pattern `<YourNamespace>.allow_<TraitId>`. The namespace must match what you pass to `RegisterCustomTraits()`.

```txt
VERSION = 1,

-- Vanilla trait: "base:Brave" -> allow_base_Brave
option YourNamespace.allow_base_Brave
{
    type = boolean,
    default = true,
    page = BodyCountRewardsThirdPartyTraits,
    translation = BCR_Addon_Enable_Brave,
}

-- Custom mod trait: "SomeMod:TraitName" -> allow_SomeMod_TraitName
option YourNamespace.allow_SomeMod_TraitName
{
    type = boolean,
    default = true,
    page = BodyCountRewardsThirdPartyTraits,
    translation = BCR_Addon_Enable_TraitName,
}
```

Key rules:
- `VERSION = 1,` header line is required.
- `page = BodyCountRewardsThirdPartyTraits` is the fixed page name. BCR reads all options on this page.
- Option name pattern: `allow_<TraitId>` where `:` in the trait ID becomes `_` (e.g. `"base:Brave"` -> `allow_base_Brave`, `"SomeMod:TraitName"` -> `allow_SomeMod_TraitName`). The namespace must match your `RegisterCustomTraits()` call.
- `translation` key is your translation lookup key. Define it in `Sandbox.json`.

## Translation Setup

Create `Translate/EN/Sandbox.json` (and matching files for each language you support):

```json
{
    "Sandbox_BodyCountRewardsThirdPartyTraits": "Third-Party Trait Toggles",

    "Sandbox_BCR_Addon_Enable_Brave": "Enable Brave",
    "Sandbox_BCR_Addon_Enable_Brave_tooltip": "Allow Brave in the reward pool.<LINE> <RGB:0.67,0.26,0.26> Cost 4 (Uncommon) <LINE> A higher zombie kill count has a higher chance of giving you this trait.",

    "Sandbox_BCR_Addon_Enable_Desensitized": "Enable Desensitized",
    "Sandbox_BCR_Addon_Enable_Desensitized_tooltip": "Allow Desensitized in the reward pool.<LINE> <RGB:1.0,0.68,0.26> Cost 8 (Very Rare) <LINE> A higher zombie kill count has a higher chance of giving you this trait."
}
```

Rules:
- `Sandbox_BodyCountRewardsThirdPartyTraits` is the sandbox page title. Define this in every language file.
- Translation keys follow the pattern `Sandbox_BCR_Addon_Enable_<TraitId>`.
- Tooltip keys append `_tooltip`.
- Use `<LINE>` for line breaks and `<RGB:R,G,B>` for colored text in tooltips.
- Copy the English JSON to each language folder. AI-generated translations are acceptable for the initial release. Mark them as automatically translated so native speakers can contribute improvements.

## Trait Data Format

### Cost Polarity (critical — the most common mistake)

**Positive (earnable) traits use negative costs. Negative (removable) traits use positive costs.**

```lua
-- CORRECT
local POSITIVE_TRAITS = {
    { id = "base:Brave",      cost = -4 },  -- negative cost = earnable
    { id = "base:Desensitized", cost = -8 },
}

local NEGATIVE_TRAITS = {
    { id = "base:ShortSighted", cost = 2 },   -- positive cost = removable
    { id = "base:Deaf",       cost = 12 },
}
```

The absolute value determines drop rarity at runtime:

| Cost (absolute) | Rarity |
|-----------------|--------|
| 1 to 2 | Common |
| 3 to 4 | Uncommon |
| 5 to 6 | Rare |
| 7+ | Very Rare |

Higher cost means lower drop chance in BCR's weighted random selection. Traits with cost 10+ will almost never appear until cheaper traits are cleared from the pool.

### Trait IDs

Trait IDs use the ResourceLocation format (`namespace:PascalCase`), e.g. `"base:Brave"`, `"base:Deaf"`. BCR validates every trait ID against the engine via `CharacterTrait.get(ResourceLocation.of(traitId))`. This works for vanilla traits (`base:` namespace) and custom mod traits (`ModNamespace:TraitName`) equally.

### Exclusions (Mutual Exclusivity)

Exclusions define which traits block each other. BCR checks exclusivity before offering any trait and will never award a trait that conflicts with one the player already has.

```lua
local EXCLUSIONS = {
    ["base:Brave"]          = {"base:Cowardly", "base:Agoraphobic", "base:Claustrophobic"},
    ["base:Desensitized"]   = {"base:AdrenalineJunkie", "base:Agoraphobic", "base:Claustrophobic", "base:Cowardly", "base:Hemophobic"},
    ["base:ShortSighted"]   = {"base:EagleEyed"},
    ["base:HardOfHearing"]  = {"base:KeenHearing", "base:Deaf"},
    ["base:Insomniac"]      = {"base:NeedsLessSleep"},
    ["base:Deaf"]           = {"base:KeenHearing", "base:HardOfHearing"},
    -- Reverse directions for traits in the base BCR exclusion table
    ["base:AdrenalineJunkie"] = {"base:Desensitized"},
    ["base:EagleEyed"]        = {"base:ShortSighted"},
    ["base:KeenHearing"]      = {"base:HardOfHearing", "base:Deaf"},
    ["base:NeedsLessSleep"]   = {"base:Insomniac"},
    ["base:Cowardly"]         = {"base:Brave", "base:Desensitized"},
    ["base:Agoraphobic"]      = {"base:Brave", "base:Desensitized"},
    ["base:Claustrophobic"]   = {"base:Brave", "base:Desensitized"},
    ["base:Hemophobic"]       = {"base:Desensitized"},
}
```

**Exclusions are not bidirectional by default.** If trait A excludes trait B, you must also add trait B excluding trait A. The reverse entries above show this pattern.

Exclusions also work across addons. If your addon's trait conflicts with a trait in the base BCR mod or another addon, add it to your exclusion table. BCR merges all exclusion tables at runtime.

## Registration API

```lua
BCR.RegisterCustomTraits(sourceName, sandboxNamespace, positiveTraits, negativeTraits, exclusions)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `sourceName` | string | Display name shown in the Stats UI catalog (e.g. `"I Am Not Your Mom"`) |
| `sandboxNamespace` | string | Prefix for sandbox toggles, must match `sandbox-options.txt` (e.g. `"IAmNotYourMom"`) |
| `positiveTraits` | table or nil | Array of `{ id = "base:TraitId", cost = -4 }` entries. Pass `nil` if none. |
| `negativeTraits` | table or nil | Array of `{ id = "base:TraitId", cost = 2 }` entries. Pass `nil` if none. |
| `exclusions` | table or nil | Table of `{ ["base:TraitId"] = {"base:BlockedId", ...} }`. Pass `nil` if none. |

**Returns:** The number of successfully registered traits, or crashes with an error message.

Always wrap the call in `pcall` and check the return count:

```lua
local ok, count = pcall(function()
    return BCR.RegisterCustomTraits(ADDON_NAME, SANDBOX_NAMESPACE, POSITIVE_TRAITS, NEGATIVE_TRAITS, EXCLUSIONS)
end)

if not ok then
    print("[YourAddon] FATAL -- registration crashed: " .. tostring(count))
    return
end
if not count or count == 0 then
    print("[YourAddon] FATAL -- no traits registered. Is BCR loaded before this addon?")
    return
end
```

A count of 0 means registration failed (BCR not loaded, or all traits rejected by validation). Non-zero means at least some traits registered successfully.

## Lua File Template

Minimal starting point for `YourAddon.lua`:

```lua
BCR = BCR or {}

local ADDON_NAME = "Your Addon Name"
local SANDBOX_NAMESPACE = "YourNamespace"

local POSITIVE_TRAITS = {
    { id = "base:TraitId", cost = -4 },
}

local NEGATIVE_TRAITS = {
    { id = "base:WeaknessId", cost = 2 },
}

local EXCLUSIONS = {
    ["base:TraitId"]        = {"base:ConflictingTrait"},
    ["base:ConflictingTrait"] = {"base:TraitId"},
}

function YourAddon_RunTests()
    local passed, failed = 0, 0
    local function ok(msg, condition)
        if condition then
            passed = passed + 1
            print("[YourAddon Test] PASS: " .. msg)
        else
            failed = failed + 1
            print("[YourAddon Test] FAIL: " .. msg)
        end
    end

    print("===== YourAddon Self-Test =====")

    ok("BCR global exists", BCR ~= nil)
    ok("RegisterCustomTraits exists", BCR.RegisterCustomTraits ~= nil)

    -- Check your traits are in the merged lists
    local function isInList(list, id)
        if not list then return false end
        for _, e in ipairs(list) do
            if e.id == id then return true end
        end
        return false
    end
    ok("Trait registered (positive)", isInList(BCR.CustomPositiveTraits, "base:TraitId"))
    ok("Trait registered (negative)", isInList(BCR.CustomNegativeTraits, "base:WeaknessId"))

    -- Metadata checks
    ok("Source name correct", BCR.CustomTraitSources["base:TraitId"] == ADDON_NAME)
    ok("Sandbox namespace correct", BCR.CustomTraitNamespaces["base:TraitId"] == SANDBOX_NAMESPACE)

    -- Engine resolution (the definitive test)
    ok("GetTraitUserdata resolves", BCR.GetTraitUserdata("base:TraitId") ~= nil)
    ok("Sandbox toggle active", BCR.IsTraitAllowed("base:TraitId") == true)

    -- Exclusion checks
    ok("Exclusion exists", exclContains("base:TraitId", "base:ConflictingTrait"))
    ok("Reverse exclusion exists", exclContains("base:ConflictingTrait", "base:TraitId"))

    -- Re-registration must be blocked
    local okRereg, cnt = pcall(function()
        return BCR.RegisterCustomTraits(ADDON_NAME, SANDBOX_NAMESPACE, {{id = "base:TraitId", cost = -4}}, nil, nil)
    end)
    ok("Re-registration blocked", okRereg and cnt == 0)

    -- Fake traits must be rejected
    local okFake, cntFake = pcall(function()
        return BCR.RegisterCustomTraits(ADDON_NAME, SANDBOX_NAMESPACE, {{id = "FAKE_TRAIT", cost = -5}}, nil, nil)
    end)
    ok("Fake trait rejected", okFake and cntFake == 0)

    print("===== Addon: " .. tostring(passed) .. " passed, " ..
        tostring(failed) .. " failed =====")

    -- > MANDATORY: Run BCR's core validation against ALL registered addons
    local coreOk = true
    if BCR_RunThirdPartyTests then
        coreOk = BCR_RunThirdPartyTests()
    end

    return failed == 0 and coreOk
end

local ok, count = pcall(function()
    return BCR.RegisterCustomTraits(ADDON_NAME, SANDBOX_NAMESPACE, POSITIVE_TRAITS, NEGATIVE_TRAITS, EXCLUSIONS)
end)

if not ok then
    print("[YourAddon] FATAL -- registration crashed: " .. tostring(count))
    return
end
if not count or count == 0 then
    print("[YourAddon] FATAL -- no traits registered. Is BodyCountRewards (BCR) loaded before this addon?")
    return
end

print("[YourAddon] Loaded. Run YourAddon_RunTests() or BCR.RunThirdPartyTests() to verify.")
```

## Testing

### Console Commands

| Command | What It Does |
|---------|-------------|
| `BCR_RunThirdPartyTests()` | Core BCR validation. Iterates all registered third-party traits and checks that each has a source, a sandbox namespace, and resolves to valid engine userdata. Runs against every addon at once. |
| `BCR.RunThirdPartyTests()` | Alias for the above. |

Run `BCR.RunThirdPartyTests()` to confirm your traits pass core validation.

### What BCR_RunThirdPartyTests Validates

- Every registered trait has a non-nil source name (`BCR.CustomTraitSources[traitId]`)
- Every registered trait has a non-nil sandbox namespace (`BCR.CustomTraitNamespaces[traitId]`)
- Every trait ID resolves to valid engine userdata via `BCR.GetTraitUserdata(traitId)`

It does NOT test gameplay-level assertions. While optional, you can write your own test function if you need deeper validation.

See `BCRIAmNotYourMom.lua` for the complete registration example.

---

## Verification Checklist

After building your addon, verify everything works. Run this command in the PZ console:
```
BCR.RunThirdPartyTests() -- BCR's core validation of ALL addons
```

**If it returns any failures, your addon has a bug.** Do not ship until it passes.

`BCR.RunThirdPartyTests()` is the **mandatory final gate**. It checks that every trait registered by every addon:
- Has a valid source name
- Has a valid sandbox namespace
- Resolves to real engine userdata via `CharacterTrait.get(ResourceLocation.of(traitId))`

If you register a custom mod trait like `SWTraits:SWBouncer` and `BCR.RunThirdPartyTests()` passes, you have confirmed the trait ID format, namespace, and engine resolution are all correct.

## Compatibility

- Build 42.19+ (Unstable)
- SP and MP
- Requires Body Count Rewards (BCR) loaded first
- Safe to remove mid-save if your traits are vanilla traits
- No vanilla file overwrites

## Common Pitfalls

### 1. Wrong cost polarity
Positive (earnable) traits need negative costs. Negative (removable) traits need positive costs. Getting this wrong will log warnings from BCR and produce incorrect drop weights.

### 2. Trait ID does not match ResourceLocation format
Trait IDs must use `namespace:PascalCase` format (e.g. `"base:Brave"`, `"SWTraits:SWBouncer"`). BCR resolves every trait ID via `CharacterTrait.get(ResourceLocation.of(traitId))`. This works for vanilla traits (`base:` namespace) and custom mod traits equally. Bogus IDs are rejected (registration returns 0 for them).

### 3. Exclusions not bidirectional
If `["base:TraitA"] = {"base:TraitB"}` is defined, `["base:TraitB"] = {"base:TraitA"}` must also be defined. BCR does not auto-reverse exclusions.

### 4. Lua file in wrong module context
Place your Lua file in `shared/`. If placed in `client/` or `server/`, it will not load in the other context. BCR addons need shared context for both SP and MP.

### 5. Sandbox namespace mismatch
The namespace passed to `RegisterCustomTraits()` must match the prefix in your `sandbox-options.txt` option names (`<namespace>.allow_<TraitId>`).

### 6. Removing addon mid-save
If your addon registers custom traits that do not exist in vanilla PZ, removing the addon may crash saves that still reference those traits. This is your responsibility as the addon author. This addon only registers vanilla traits (Brave, Desensitized, etc.), so it is safe to remove.

### 7. Not checking the return count
`RegisterCustomTraits()` returns a number. Zero means failure. Always check the return value.

### 8. Not wrapping registration in pcall
If BCR is not loaded, `RegisterCustomTraits` will not exist and the call will crash. Always `pcall`-wrap.

## License

MIT License — see [LICENSE](LICENSE).

## Links

- [BodyCountRewards (required)](https://steamcommunity.com/sharedfiles/filedetails/?id=3660382016)
- [GitHub Repository](https://github.com/Lenniitsch/PZ-BodyCountRewards-IAmNotYourMom)
