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
    { id = "BRAVE",          cost = -4 },
    { id = "DESENSITIZED",   cost = -8 },
}

local NEGATIVE_TRAITS = {
    { id = "SHORT_SIGHTED",  cost = 2 },
    { id = "HARD_OF_HEARING", cost = 4 },
    { id = "INSOMNIAC",      cost = 6 },
    { id = "DEAF",           cost = 12 },
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

    ok("BRAVE registered", isInList(BCR.CustomPositiveTraits, "BRAVE"))
    ok("DESENSITIZED registered", isInList(BCR.CustomPositiveTraits, "DESENSITIZED"))
    ok("SHORT_SIGHTED registered", isInList(BCR.CustomNegativeTraits, "SHORT_SIGHTED"))
    ok("DEAF registered", isInList(BCR.CustomNegativeTraits, "DEAF"))
    ok("INSOMNIAC registered", isInList(BCR.CustomNegativeTraits, "INSOMNIAC"))
    ok("HARD_OF_HEARING registered", isInList(BCR.CustomNegativeTraits, "HARD_OF_HEARING"))

    ok("Source name correct for BRAVE", BCR.CustomTraitSources["BRAVE"] == ADDON_NAME)
    ok("Sandbox namespace correct", BCR.CustomTraitNamespaces["BRAVE"] == SANDBOX_NAMESPACE)

    local function exclContains(traitId, excludedId)
        local list = BCR.Exclusions and BCR.Exclusions[traitId]
        if not list then return false end
        for _, e in ipairs(list) do
            if e == excludedId then return true end
        end
        return false
    end

    ok("BRAVE -> COWARDLY", exclContains("BRAVE", "COWARDLY"))
    ok("DESENSITIZED -> ADRENALINE_JUNKIE", exclContains("DESENSITIZED", "ADRENALINE_JUNKIE"))
    ok("DESENSITIZED -> HEMOPHOBIC", exclContains("DESENSITIZED", "HEMOPHOBIC"))
    ok("SHORT_SIGHTED -> EAGLE_EYED", exclContains("SHORT_SIGHTED", "EAGLE_EYED"))
    ok("DEAF -> KEEN_HEARING", exclContains("DEAF", "KEEN_HEARING"))
    ok("INSOMNIAC -> NEEDS_LESS_SLEEP", exclContains("INSOMNIAC", "NEEDS_LESS_SLEEP"))
    ok("Reverse: ADRENALINE_JUNKIE -> DESENSITIZED", exclContains("ADRENALINE_JUNKIE", "DESENSITIZED"))
    ok("Reverse: KEEN_HEARING -> DEAF", exclContains("KEEN_HEARING", "DEAF"))
    ok("Reverse: NEEDS_LESS_SLEEP -> INSOMNIAC", exclContains("NEEDS_LESS_SLEEP", "INSOMNIAC"))

    ok("GetTraitUserdata resolves BRAVE", BCR.GetTraitUserdata("BRAVE") ~= nil)
    ok("GetTraitUserdata resolves DEAF", BCR.GetTraitUserdata("DEAF") ~= nil)

    local okRereg, cnt = pcall(function()
        return BCR.RegisterCustomTraits(ADDON_NAME, SANDBOX_NAMESPACE, {{id = "BRAVE", cost = 4}}, nil, nil)
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