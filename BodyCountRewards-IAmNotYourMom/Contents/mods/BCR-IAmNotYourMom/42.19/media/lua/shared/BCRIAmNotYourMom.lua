-- ============================================================
-- BCR-IAmNotYourMom v1.0.0 -- Addon for BodyCountRewards (BCR)
-- Adds unrealistic / overpowered vanilla traits that the base
-- BCR mod considers "not lore-friendly."
--
-- This mod serves as a reference implementation of the
-- BCR.RegisterCustomTraits() extensibility API.
--
-- Console commands:
--   BCRIAmNotYourMom_RunTests() -- addon-specific + core checks
--   BCR_RunThirdPartyTests()    -- core BCR check of all addons
--   BCR.RunThirdPartyTests()    -- alias for above
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
    ["base:Desensitized"]        = {"base:AdrenalineJunkie", "base:Agoraphobic", "base:Claustrophobic", "base:Cowardly", "base:Hemophobic"},
    ["base:ShortSighted"]       = {"base:EagleEyed"},
    ["base:HardOfHearing"]     = {"base:KeenHearing", "base:Deaf"},
    ["base:Insomniac"]           = {"base:NeedsLessSleep"},
    ["base:Deaf"]                = {"base:KeenHearing", "base:HardOfHearing"},
    ["base:AdrenalineJunkie"]   = {"base:Desensitized"},
    ["base:EagleEyed"]          = {"base:ShortSighted"},
    ["base:KeenHearing"]        = {"base:HardOfHearing", "base:Deaf"},
    ["base:NeedsLessSleep"]    = {"base:Insomniac"},
    ["base:Cowardly"]            = {"base:Brave", "base:Desensitized"},
    ["base:Agoraphobic"]         = {"base:Brave", "base:Desensitized"},
    ["base:Claustrophobic"]      = {"base:Brave", "base:Desensitized"},
    ["base:Hemophobic"]          = {"base:Desensitized"},
}

-- ============================================================
-- SELF-TEST -- always defined, even if registration fails
-- ============================================================

function BCRIAmNotYourMom_RunTests()
    local passed, failed = 0, 0

    local function ok(msg, condition)
        if condition then
            passed = passed + 1
            print("[BCR-IAmNotYourMom Test] PASS: " .. msg)
        else
            failed = failed + 1
            print("[BCR-IAmNotYourMom Test] FAIL: " .. msg)
        end
    end

    print("===== BCR-IAmNotYourMom Self-Test =====")

    ok("BCR global exists", BCR ~= nil)
    ok("RegisterCustomTraits exists", BCR.RegisterCustomTraits ~= nil)

    local function isInList(list, traitId)
        if not list then return false end
        for _, entry in ipairs(list) do
            if entry.id == traitId then return true end
        end
        return false
    end

    ok("BRAVE registered", isInList(BCR.CustomPositiveTraits, "base:Brave"))
    ok("DESENSITIZED registered", isInList(BCR.CustomPositiveTraits, "base:Desensitized"))
    ok("SHORT_SIGHTED registered", isInList(BCR.CustomNegativeTraits, "base:ShortSighted"))
    ok("DEAF registered", isInList(BCR.CustomNegativeTraits, "base:Deaf"))
    ok("INSOMNIAC registered", isInList(BCR.CustomNegativeTraits, "base:Insomniac"))
    ok("HARD_OF_HEARING registered", isInList(BCR.CustomNegativeTraits, "base:HardOfHearing"))

    ok("Source name correct for BRAVE", BCR.CustomTraitSources["base:Brave"] == ADDON_NAME)
    ok("Sandbox namespace correct", BCR.CustomTraitNamespaces["base:Brave"] == SANDBOX_NAMESPACE)

    local function exclContains(traitId, excludedId)
        local list = BCR.Exclusions and BCR.Exclusions[traitId]
        if not list then return false end
        for _, e in ipairs(list) do
            if e == excludedId then return true end
        end
        return false
    end

    ok("BRAVE -> COWARDLY", exclContains("base:Brave", "base:Cowardly"))
    ok("DESENSITIZED -> ADRENALINE_JUNKIE", exclContains("base:Desensitized", "base:AdrenalineJunkie"))
    ok("DESENSITIZED -> HEMOPHOBIC", exclContains("base:Desensitized", "base:Hemophobic"))
    ok("SHORT_SIGHTED -> EAGLE_EYED", exclContains("base:ShortSighted", "base:EagleEyed"))
    ok("DEAF -> KEEN_HEARING", exclContains("base:Deaf", "base:KeenHearing"))
    ok("INSOMNIAC -> NEEDS_LESS_SLEEP", exclContains("base:Insomniac", "base:NeedsLessSleep"))
    ok("Reverse: ADRENALINE_JUNKIE -> DESENSITIZED", exclContains("base:AdrenalineJunkie", "base:Desensitized"))
    ok("Reverse: KEEN_HEARING -> DEAF", exclContains("base:KeenHearing", "base:Deaf"))
    ok("Reverse: NEEDS_LESS_SLEEP -> INSOMNIAC", exclContains("base:NeedsLessSleep", "base:Insomniac"))

    ok("GetTraitUserdata resolves BRAVE", BCR.GetTraitUserdata("base:Brave") ~= nil)
    ok("GetTraitUserdata resolves DEAF", BCR.GetTraitUserdata("base:Deaf") ~= nil)

    local okRereg, cnt = pcall(function()
        return BCR.RegisterCustomTraits(ADDON_NAME, SANDBOX_NAMESPACE, {{id = "base:Brave", cost = 4}}, nil, nil)
    end)
    ok("Re-registration of BRAVE blocked", okRereg and cnt == 0)

    local okFake, cntFake = pcall(function()
        return BCR.RegisterCustomTraits(ADDON_NAME, SANDBOX_NAMESPACE, {{id = "FAKE_TRAIT", cost = -5}}, nil, nil)
    end)
    ok("Fake trait rejected", okFake and cntFake == 0)

    print("===== Addon: " .. tostring(passed) .. " passed, " ..
        tostring(failed) .. " failed =====")

    local coreOk = true
    if BCR_RunThirdPartyTests then
        coreOk = BCR_RunThirdPartyTests()
    end

    return failed == 0 and coreOk
end

-- ============================================================
-- REGISTRATION (core BCR handles all logging + diagnostics)
-- ============================================================

local ok, count = pcall(function()
    return BCR.RegisterCustomTraits(ADDON_NAME, SANDBOX_NAMESPACE, POSITIVE_TRAITS, NEGATIVE_TRAITS, EXCLUSIONS)
end)

if not ok then
    print("[BCR-IAmNotYourMom] FATAL -- registration crashed: " .. tostring(count))
    print("[BCR-IAmNotYourMom] Run BCRIAmNotYourMom_RunTests() to diagnose.")
    return
end
if not count or count == 0 then
    print("[BCR-IAmNotYourMom] FATAL -- no traits registered. Is BodyCountRewards (BCR) loaded before this addon?")
    print("[BCR-IAmNotYourMom] Run BCRIAmNotYourMom_RunTests() to diagnose.")
    return
end

print("[BCR-IAmNotYourMom] Loaded. Run BCRIAmNotYourMom_RunTests() or BCR.RunThirdPartyTests() to verify.")