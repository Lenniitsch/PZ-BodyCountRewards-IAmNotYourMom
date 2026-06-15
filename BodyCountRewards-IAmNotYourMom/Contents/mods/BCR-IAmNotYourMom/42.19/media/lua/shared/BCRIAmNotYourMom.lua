-- ============================================================
-- BCR-IAmNotYourMom v1.0.0 -- Addon for BodyCountRewards (BCR)
-- Adds unrealistic / overpowered vanilla traits that the base
-- BCR mod considers "not lore-friendly."
--
-- This mod serves as a reference implementation of the
-- BCR.RegisterCustomTraits() extensibility API.
--
-- Console command:
--   BCR.RunThirdPartyTests()    -- core BCR check of all addons
-- ============================================================

BCR = BCR or {}

local ADDON_NAME = "I Am Not Your Mom"
local SANDBOX_NAMESPACE = "IAmNotYourMom"

local POSITIVE_TRAITS = {
    { id = "base:Brave",          cost = -4 },
    { id = "base:Desensitized",   cost = -8 },
}

local NEGATIVE_TRAITS = {
    { id = "base:ShortSighted",  cost = 2 },
    { id = "base:HardOfHearing", cost = 4 },
    { id = "base:Insomniac",      cost = 6 },
    { id = "base:Deaf",           cost = 12 },
}

local EXCLUSIONS = {
    ["base:Brave"]               = {"base:Cowardly", "base:Agoraphobic", "base:Claustrophobic"},
    ["base:Desensitized"]        = {"base:Agoraphobic", "base:Claustrophobic", "base:Cowardly", "base:Hemophobic"},
    ["base:ShortSighted"]       = {"base:EagleEyed"},
    ["base:HardOfHearing"]     = {"base:KeenHearing", "base:Deaf"},
    ["base:Insomniac"]           = {"base:NeedsLessSleep"},
    ["base:Deaf"]                = {"base:KeenHearing", "base:HardOfHearing"},
    ["base:EagleEyed"]          = {"base:ShortSighted"},
    ["base:KeenHearing"]        = {"base:HardOfHearing", "base:Deaf"},
    ["base:NeedsLessSleep"]    = {"base:Insomniac"},
    ["base:Cowardly"]            = {"base:Brave", "base:Desensitized"},
    ["base:Agoraphobic"]         = {"base:Brave", "base:Desensitized"},
    ["base:Claustrophobic"]      = {"base:Brave", "base:Desensitized"},
    ["base:Hemophobic"]          = {"base:Desensitized"},
}

-- ============================================================
-- REGISTRATION (core BCR handles all logging + diagnostics)
-- ============================================================

local ok, count = pcall(function()
    return BCR.RegisterCustomTraits(ADDON_NAME, SANDBOX_NAMESPACE, POSITIVE_TRAITS, NEGATIVE_TRAITS, EXCLUSIONS)
end)

if not ok then
    print("[BCR-IAmNotYourMom] FATAL -- registration crashed: " .. tostring(count))
    print("[BCR-IAmNotYourMom] Run BCR.RunThirdPartyTests() to diagnose.")
    return
end
if not count or count == 0 then
    print("[BCR-IAmNotYourMom] FATAL -- no traits registered. Is BodyCountRewards (BCR) loaded before this addon?")
    print("[BCR-IAmNotYourMom] Run BCR.RunThirdPartyTests() to diagnose.")
    return
end

print("[BCR-IAmNotYourMom] Loaded. Run BCR.RunThirdPartyTests() to verify.")