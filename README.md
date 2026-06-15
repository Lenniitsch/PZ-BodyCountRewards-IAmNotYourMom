# BodyCountRewards — I Am Not Your Mom

> *I am not your mom. Add whatever unrealistic, overpowered traits you want.*

An addon mod for [BodyCountRewards](https://steamcommunity.com/sharedfiles/filedetails/?id=3660382016) that adds traits the base mod considers "not lore-friendly." Serves as a reference implementation of BCR's third-party extensibility API.

**Requires BodyCountRewards (BCR).** This is not a standalone mod.

---

## Added Traits

### Positive (Earnable)
| Trait | Cost | Rarity | Effect |
|-------|------|--------|--------|
| Brave | 4 | Uncommon | Panic reduction |
| Desensitized | 8 | Very Rare | Complete panic immunity + corpse looting immunity |

### Negative (Removable)
| Trait | Cost | Rarity | Effect |
|-------|------|--------|--------|
| Short Sighted | -2 | Common | Reduced vision range |
| Hard of Hearing | -4 | Uncommon | Reduced hearing radius |
| Insomniac | -6 | Rare | Severe sleep penalty |
| Deaf | -12 | VeryRare | Complete hearing loss |

---

## Sandbox Options

All traits are toggleable in the `BodyCountRewardsThirdPartyTraits` sandbox settings page. Uses its own namespace (`IAmNotYourMom`) — no overlap with base BCR settings.

---

## For Mod Developers

This mod is a **living code example** of BCR's extensibility API. To add your own traits to BodyCountRewards:

```lua
BCR.RegisterCustomTraits(
    "Your Addon Name",             -- shown in StatsUI catalog
    "YourSandboxNamespace",        -- matches your sandbox-options.txt prefix
    positiveTraits,                -- { { id = "TRAIT", cost = 4 }, ... }
    negativeTraits,                -- { { id = "WEAKNESS", cost = -2 }, ... }
    exclusions                     -- { ["TRAIT"] = {"CONFLICTING_TRAIT"}, ... }
)
```

Your traits automatically appear in BCR's reward pools, catalog, history, and sandbox toggles. See `BCRIAmNotYourMom.lua` for the full implementation.

---

## Compatibility

- Build 42.19+
- SP & MP
- Requires BodyCountRewards (BCR) loaded first
- Safe to remove mid-save

---

## License

MIT License — see [LICENSE](LICENSE).

## Links

- [BodyCountRewards (required)](https://steamcommunity.com/sharedfiles/filedetails/?id=3660382016)
- [GitHub Repository](https://github.com/Lenniitsch/PZ-BodyCountRewards-IAmNotYourMom)