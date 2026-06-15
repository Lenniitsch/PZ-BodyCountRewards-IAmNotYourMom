-- ============================================================
-- BCR-IAmNotYourMom v1.0.0 — Addon for BodyCountRewards (BCR)
-- Adds unrealistic / overpowered vanilla traits that the base
-- BCR mod considers "not lore-friendly."
--
-- This mod serves as a reference implementation of the
-- BCR.RegisterCustomTraits() extensibility API.
-- ============================================================

BCR = BCR or {}

local ADDON_NAME = "I Am Not Your Mom"
local SANDBOX_NAMESPACE = "IAmNotYourMom"

local POSITIVE_TRAITS = {
    { id = "BRAVE",          cost = 4 },
    { id = "DESENSITIZED",   cost = 8 },
}

local NEGATIVE_TRAITS = {
    { id = "SHORT_SIGHTED",  cost = -2 },
    { id = "HARD_OF_HEARING", cost = -4 },
    { id = "INSOMNIAC",      cost = -6 },
    { id = "DEAF",           cost = -12 },
}

local EXCLUSIONS = {
    BRAVE               = {"COWARDLY", "AGORAPHOBIC", "CLAUSTROPHOBIC", "DESENSITIZED"},
    DESENSITIZED        = {"ADRENALINE_JUNKIE", "AGORAPHOBIC", "BRAVE", "CLAUSTROPHOBIC", "COWARDLY", "HEMOPHOBIC"},
    SHORT_SIGHTED       = {"EAGLE_EYED"},
    HARD_OF_HEARING     = {"KEEN_HEARING", "DEAF"},
    INSOMNIAC           = {"NEEDS_LESS_SLEEP"},
    DEAF                = {"KEEN_HEARING", "HARD_OF_HEARING"},
    ADRENALINE_JUNKIE   = {"DESENSITIZED"},
    EAGLE_EYED          = {"SHORT_SIGHTED"},
    KEEN_HEARING        = {"HARD_OF_HEARING", "DEAF"},
    NEEDS_LESS_SLEEP    = {"INSOMNIAC"},
}

local ok, count = pcall(function()
    return BCR.RegisterCustomTraits(ADDON_NAME, SANDBOX_NAMESPACE, POSITIVE_TRAITS, NEGATIVE_TRAITS, EXCLUSIONS)
end)

if ok then
    if count and count > 0 then
        print("[BCR-IAmNotYourMom] Registered " .. tostring(count) .. " trait(s). I'm not your mom — have fun!")
    else
        print("[BCR-IAmNotYourMom] No traits registered — all may already exist or failed validation.")
    end
else
    print("[BCR-IAmNotYourMom] Registration failed: " .. tostring(count))
end