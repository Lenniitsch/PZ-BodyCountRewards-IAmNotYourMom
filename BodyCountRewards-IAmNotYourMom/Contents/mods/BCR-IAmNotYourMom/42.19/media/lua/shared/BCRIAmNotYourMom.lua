-- ============================================================
-- BCR-IAmNotYourMom v1.0.0 — Addon for BodyCountRewards (BCR)
-- Adds unrealistic / overpowered vanilla traits that the base
-- BCR mod considers "not lore-friendly."
--
-- This mod serves as a reference implementation of the
-- BCR.RegisterCustomTraits() extensibility API.
--
-- Console commands:
--   BCRIAmNotYourMom_RunTests() — verify hooking + trait integrity
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

local ALL_EXPECTED_POSITIVE = { BRAVE = true, DESENSITIZED = true }
local ALL_EXPECTED_NEGATIVE = { SHORT_SIGHTED = true, HARD_OF_HEARING = true, INSOMNIAC = true, DEAF = true }

-- ============================================================
-- REGISTRATION
-- ============================================================

local ok, count = pcall(function()
    return BCR.RegisterCustomTraits(ADDON_NAME, SANDBOX_NAMESPACE, POSITIVE_TRAITS, NEGATIVE_TRAITS, EXCLUSIONS)
end)

-- ============================================================
-- VERIFICATION — runs immediately after registration
-- ============================================================

local function verifyRegistration()
    if not ok then
        print("[BCR-IAmNotYourMom] REGISTRATION CRASHED: " .. tostring(count))
        return
    end
    if not count or count == 0 then
        print("[BCR-IAmNotYourMom] REGISTRATION FAILED — " ..
            "ensure BodyCountRewards (BCR) is loaded before this addon.")
        return
    end

    print("[BCR-IAmNotYourMom] ===== Hook Verification =====")
    print("[BCR-IAmNotYourMom] Source name: " .. ADDON_NAME)
    print("[BCR-IAmNotYourMom] Sandbox namespace: " .. SANDBOX_NAMESPACE)

    local issues = 0

    local function checkList(label, expectedTbl, customTbl)
        local foundCount = 0
        local expectedIds = {}
        for id, _ in pairs(expectedTbl) do
            expectedIds[id] = true
        end
        if customTbl then
            for _, entry in ipairs(customTbl) do
                local id = entry.id
                if id then
                    foundCount = foundCount + 1
                    expectedIds[id] = nil
                    local source = BCR.CustomTraitSources and BCR.CustomTraitSources[id]
                    local ns = BCR.CustomTraitNamespaces and BCR.CustomTraitNamespaces[id]
                    local sourceOk = source == ADDON_NAME
                    local nsOk = ns == SANDBOX_NAMESPACE
                    if sourceOk and nsOk then
                        print("[BCR-IAmNotYourMom]   OK  " .. id .. " (cost " ..
                            tostring(entry.cost) .. ")")
                    else
                        issues = issues + 1
                        print("[BCR-IAmNotYourMom]   BAD " .. id .. " — source='" ..
                            tostring(source) .. "' ns='" .. tostring(ns) .. "'")
                    end
                end
            end
        end
        for id, _ in pairs(expectedIds) do
            issues = issues + 1
            print("[BCR-IAmNotYourMom]   MISS " .. id .. " — not found in " .. label .. " list")
        end
        return foundCount
    end

    local posCount = checkList("positive", ALL_EXPECTED_POSITIVE, BCR.CustomPositiveTraits)
    local negCount = checkList("negative", ALL_EXPECTED_NEGATIVE, BCR.CustomNegativeTraits)

    print("[BCR-IAmNotYourMom] Registry: " .. tostring(posCount) .. " positive, " ..
        tostring(negCount) .. " negative trait(s)")

    local exclusionCount = 0
    for traitId, excludeList in pairs(EXCLUSIONS) do
        local stored = BCR.Exclusions[traitId]
        if not stored then
            if ALL_EXPECTED_POSITIVE[traitId] or ALL_EXPECTED_NEGATIVE[traitId] then
                issues = issues + 1
                print("[BCR-IAmNotYourMom]   MISS exclusion entry for " .. traitId)
            end
        else
            for _, expectedExclude in ipairs(excludeList) do
                local found = false
                for _, actual in ipairs(stored) do
                    if actual == expectedExclude then found = true; break end
                end
                if found then
                    exclusionCount = exclusionCount + 1
                else
                    issues = issues + 1
                    print("[BCR-IAmNotYourMom]   MISS exclusion " .. traitId ..
                        " -> " .. expectedExclude)
                end
            end
        end
    end
    print("[BCR-IAmNotYourMom] Exclusions: " .. tostring(exclusionCount) .. " entry(s) verified")

    if issues == 0 then
        print("[BCR-IAmNotYourMom] ===== All hooks verified — have fun! =====")
    else
        print("[BCR-IAmNotYourMom] ===== " .. tostring(issues) ..
            " ISSUE(S) FOUND — check above =====")
    end
end

verifyRegistration()

-- ============================================================
-- SELF-TEST — run via BCRIAmNotYourMom_RunTests() in console
-- ============================================================

function BCRIAmNotYourMom_RunTests()
    local passed, failed = 0, 0

    local function ok(description, condition)
        if condition then
            passed = passed + 1
            print("[BCR-IAmNotYourMom Test] PASS: " .. description)
        else
            failed = failed + 1
            print("[BCR-IAmNotYourMom Test] FAIL: " .. description)
        end
    end

    print("===== BCR-IAmNotYourMom Self-Test =====")

    ok("BCR global exists", BCR ~= nil)
    ok("BCR.RegisterCustomTraits exists", BCR.RegisterCustomTraits ~= nil)
    ok("BCR.CustomPositiveTraits is a table", type(BCR.CustomPositiveTraits) == "table")
    ok("BCR.CustomNegativeTraits is a table", type(BCR.CustomNegativeTraits) == "table")
    ok("BCR.CustomTraitSources is a table", type(BCR.CustomTraitSources) == "table")
    ok("BCR.CustomTraitNamespaces is a table", type(BCR.CustomTraitNamespaces) == "table")

    local function isInList(list, traitId)
        if not list then return false end
        for _, entry in ipairs(list) do
            if entry.id == traitId then return true end
        end
        return false
    end

    ok("BRAVE in CustomPositiveTraits", isInList(BCR.CustomPositiveTraits, "BRAVE"))
    ok("DESENSITIZED in CustomPositiveTraits", isInList(BCR.CustomPositiveTraits, "DESENSITIZED"))
    ok("SHORT_SIGHTED in CustomNegativeTraits", isInList(BCR.CustomNegativeTraits, "SHORT_SIGHTED"))
    ok("HARD_OF_HEARING in CustomNegativeTraits", isInList(BCR.CustomNegativeTraits, "HARD_OF_HEARING"))
    ok("INSOMNIAC in CustomNegativeTraits", isInList(BCR.CustomNegativeTraits, "INSOMNIAC"))
    ok("DEAF in CustomNegativeTraits", isInList(BCR.CustomNegativeTraits, "DEAF"))

    ok("BRAVE source = " .. ADDON_NAME, BCR.CustomTraitSources["BRAVE"] == ADDON_NAME)
    ok("DESENSITIZED source = " .. ADDON_NAME, BCR.CustomTraitSources["DESENSITIZED"] == ADDON_NAME)
    ok("BRAVE namespace = " .. SANDBOX_NAMESPACE, BCR.CustomTraitNamespaces["BRAVE"] == SANDBOX_NAMESPACE)

    local function exclusionContains(traitId, excludedId)
        local list = BCR.Exclusions[traitId]
        if not list then return false end
        for _, e in ipairs(list) do
            if e == excludedId then return true end
        end
        return false
    end

    ok("BRAVE excludes COWARDLY", exclusionContains("BRAVE", "COWARDLY"))
    ok("BRAVE excludes DESENSITIZED", exclusionContains("BRAVE", "DESENSITIZED"))
    ok("DESENSITIZED excludes ADRENALINE_JUNKIE", exclusionContains("DESENSITIZED", "ADRENALINE_JUNKIE"))
    ok("DESENSITIZED excludes HEMOPHOBIC", exclusionContains("DESENSITIZED", "HEMOPHOBIC"))
    ok("SHORT_SIGHTED excludes EAGLE_EYED", exclusionContains("SHORT_SIGHTED", "EAGLE_EYED"))
    ok("DEAF excludes KEEN_HEARING", exclusionContains("DEAF", "KEEN_HEARING"))
    ok("INSOMNIAC excludes NEEDS_LESS_SLEEP", exclusionContains("INSOMNIAC", "NEEDS_LESS_SLEEP"))

    ok("Reverse: ADRENALINE_JUNKIE excludes DESENSITIZED", exclusionContains("ADRENALINE_JUNKIE", "DESENSITIZED"))
    ok("Reverse: EAGLE_EYED excludes SHORT_SIGHTED", exclusionContains("EAGLE_EYED", "SHORT_SIGHTED"))
    ok("Reverse: KEEN_HEARING excludes HARD_OF_HEARING", exclusionContains("KEEN_HEARING", "HARD_OF_HEARING"))
    ok("Reverse: KEEN_HEARING excludes DEAF", exclusionContains("KEEN_HEARING", "DEAF"))
    ok("Reverse: NEEDS_LESS_SLEEP excludes INSOMNIAC", exclusionContains("NEEDS_LESS_SLEEP", "INSOMNIAC"))

    ok("GetTraitUserdata BRAVE", BCR.GetTraitUserdata("BRAVE") ~= nil)
    ok("GetTraitUserdata DESENSITIZED", BCR.GetTraitUserdata("DESENSITIZED") ~= nil)
    ok("GetTraitUserdata SHORT_SIGHTED", BCR.GetTraitUserdata("SHORT_SIGHTED") ~= nil)
    ok("GetTraitUserdata DEAF", BCR.GetTraitUserdata("DEAF") ~= nil)

    local okRereg, countAfter = pcall(function()
        return BCR.RegisterCustomTraits(ADDON_NAME, SANDBOX_NAMESPACE,
            {{id = "BRAVE", cost = 4}}, nil, nil)
    end)
    ok("Re-registration of BRAVE rejected (count=0)", okRereg and countAfter == 0)

    local okFake, countFake = pcall(function()
        return BCR.RegisterCustomTraits(ADDON_NAME, SANDBOX_NAMESPACE,
            {{id = "THIS_TRAIT_DOES_NOT_EXIST", cost = -5}}, nil, nil)
    end)
    ok("Fake trait registration rejected (count=0)", okFake and countFake == 0)

    print("===== " .. tostring(passed) .. " passed, " ..
        tostring(failed) .. " failed =====")

    return failed == 0
end

print("[BCR-IAmNotYourMom] Loaded. Run BCRIAmNotYourMom_RunTests() in console to verify.")