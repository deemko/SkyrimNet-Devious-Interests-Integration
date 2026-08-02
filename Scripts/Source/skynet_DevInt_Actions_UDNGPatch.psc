ScriptName skynet_DevInt_Actions

; ============================================================================
; SkyrimNet integration for Devious Interests (unofficial, third-party).
; This script does NOT modify Devious Interests' own scripts. It only calls
; din_Main's existing public functions and reports outcomes back to SkyrimNet.
;
; Design notes (informed by an earlier audit of SkyrimNet_UDNG):
;  - Every action reports success AND failure via SendModEvent, never silently.
;  - _IsEligible checks the actual current game state (worn keyword, combat),
;    not just "is this theoretically possible", to avoid actions being listed
;    as eligible when they are guaranteed to fail.
;  - din_Main's BlacksmithUnlock/BondageOffer/etc. always target the player
;    (Devious Interests itself hardcodes libs.PlayerRef for these), so these
;    actions have no "target" parameter - the acting NPC is akOriginator, the
;    player is always the implicit target.
; ============================================================================

; ---- helpers -----------------------------------------------------------

din_Main Function GetDinMain() global
    ; Prefer EditorID lookup - more robust across Devious Interests versions than a
    ; hardcoded FormID, since EditorIDs rarely change even when a mod's FormIDs shift
    ; between releases (e.g. after adding/removing earlier records in the same plugin).
    din_Main dinMn = Quest.GetQuest("din_Main") as din_Main
    If dinMn == None
        ; Fallback to the original FormID-based lookup, in case GetQuest-by-editorID
        ; is unavailable or the quest was renamed - kept as a safety net, not primary.
        dinMn = Game.GetFormFromFile(3426, "DeviousInterests.esp") as din_Main
    EndIf
    Return dinMn
EndFunction

; UDNG compatibility check (see RegisterDevIntActions). 2048 = SkyrimNetUDNG.esp's own
; internal Quest FormID (0x800) - purely passive detection, does not touch UDNG at all.
Bool Function _IsUDNGInstalled() global
    Return Game.GetFormFromFile(2048, "SkyrimNetUDNG.esp") != None
EndFunction

Function SendDevIntEvent(String content, Actor source) global
    If source != None
        source.SendModEvent("SkyrimNetDevInt_Event", content, 0.0)
    EndIf
EndFunction

; Returns True only if the target was actually wearing the device and
; BlacksmithUnlock reports success (din_Main.UnlockSuccessful).
Bool Function _TryUnlock(din_Main dinMn, Keyword kw, String tier, Actor akTarget) global
    If dinMn == None || kw == None || akTarget == None
        Return False
    EndIf
    If !akTarget.WornHasKeyword(kw)
        Return False
    EndIf
    dinMn.BlacksmithUnlock(kw, tier)
    Return dinMn.UnlockSuccessful
EndFunction

; ---- generic "remove whatever restraint I can" fallback ---------------

Bool Function ExtCmdDinHelpRemoveRestraint_IsEligible(Actor akActor, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    Return dinMn != None && !akActor.IsInCombat() && Game.GetPlayer().WornHasKeyword(dinMn.libs.zad_Lockable)
EndFunction

Function ExtCmdDinHelpRemoveRestraint(Actor akOriginator, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    If dinMn == None
        Return
    EndIf
    Actor target = Game.GetPlayer()
    Bool wasBound = target.WornHasKeyword(dinMn.libs.zad_Lockable)
    dinMn.HelpRemoveRestraint(akOriginator)
    If wasBound && !target.WornHasKeyword(dinMn.libs.zad_Lockable)
        SendDevIntEvent(akOriginator.GetDisplayName() + " frees " + target.GetDisplayName() + " of their restraints", akOriginator)
    ElseIf wasBound
        SendDevIntEvent(akOriginator.GetDisplayName() + " tries to free " + target.GetDisplayName() + ", but something is still locked on", akOriginator)
    EndIf
EndFunction

; ---- 15 category-specific unlock actions -------------------------------

Bool Function ExtCmdDinUnlockCollar_IsEligible(Actor akActor, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    Return dinMn != None && !akActor.IsInCombat() && Game.GetPlayer().WornHasKeyword(dinMn.libs.zad_DeviousCollar)
EndFunction

Function ExtCmdDinUnlockCollar(Actor akOriginator, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    Actor target = Game.GetPlayer()
    If _TryUnlock(dinMn, dinMn.libs.zad_DeviousCollar, "basic", target)
        SendDevIntEvent(akOriginator.GetDisplayName() + " unlocks the collar from " + target.GetDisplayName(), akOriginator)
    Else
        SendDevIntEvent(akOriginator.GetDisplayName() + " tries to unlock the collar from " + target.GetDisplayName() + ", but it will not come off", akOriginator)
    EndIf
EndFunction

Bool Function ExtCmdDinUnlockBelt_IsEligible(Actor akActor, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    Return dinMn != None && !akActor.IsInCombat() && Game.GetPlayer().WornHasKeyword(dinMn.libs.zad_DeviousBelt)
EndFunction

Function ExtCmdDinUnlockBelt(Actor akOriginator, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    Actor target = Game.GetPlayer()
    If _TryUnlock(dinMn, dinMn.libs.zad_DeviousBelt, "advanced", target)
        SendDevIntEvent(akOriginator.GetDisplayName() + " unlocks the chastity belt from " + target.GetDisplayName(), akOriginator)
    Else
        SendDevIntEvent(akOriginator.GetDisplayName() + " tries to unlock the chastity belt from " + target.GetDisplayName() + ", but it will not come off", akOriginator)
    EndIf
EndFunction

Bool Function ExtCmdDinUnlockBlindfold_IsEligible(Actor akActor, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    Return dinMn != None && !akActor.IsInCombat() && Game.GetPlayer().WornHasKeyword(dinMn.libs.zad_DeviousBlindfold)
EndFunction

Function ExtCmdDinUnlockBlindfold(Actor akOriginator, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    Actor target = Game.GetPlayer()
    If _TryUnlock(dinMn, dinMn.libs.zad_DeviousBlindfold, "basic", target)
        SendDevIntEvent(akOriginator.GetDisplayName() + " unlocks the blindfold from " + target.GetDisplayName(), akOriginator)
    Else
        SendDevIntEvent(akOriginator.GetDisplayName() + " tries to unlock the blindfold from " + target.GetDisplayName() + ", but it will not come off", akOriginator)
    EndIf
EndFunction

Bool Function ExtCmdDinUnlockBoots_IsEligible(Actor akActor, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    Return dinMn != None && !akActor.IsInCombat() && Game.GetPlayer().WornHasKeyword(dinMn.libs.zad_DeviousBoots)
EndFunction

Function ExtCmdDinUnlockBoots(Actor akOriginator, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    Actor target = Game.GetPlayer()
    If _TryUnlock(dinMn, dinMn.libs.zad_DeviousBoots, "regular", target)
        SendDevIntEvent(akOriginator.GetDisplayName() + " unlocks the pony boots from " + target.GetDisplayName(), akOriginator)
    Else
        SendDevIntEvent(akOriginator.GetDisplayName() + " tries to unlock the pony boots from " + target.GetDisplayName() + ", but it will not come off", akOriginator)
    EndIf
EndFunction

Bool Function ExtCmdDinUnlockBra_IsEligible(Actor akActor, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    Return dinMn != None && !akActor.IsInCombat() && Game.GetPlayer().WornHasKeyword(dinMn.libs.zad_DeviousBra)
EndFunction

Function ExtCmdDinUnlockBra(Actor akOriginator, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    Actor target = Game.GetPlayer()
    If _TryUnlock(dinMn, dinMn.libs.zad_DeviousBra, "advanced", target)
        SendDevIntEvent(akOriginator.GetDisplayName() + " unlocks the chastity bra from " + target.GetDisplayName(), akOriginator)
    Else
        SendDevIntEvent(akOriginator.GetDisplayName() + " tries to unlock the chastity bra from " + target.GetDisplayName() + ", but it will not come off", akOriginator)
    EndIf
EndFunction

Bool Function ExtCmdDinUnlockClitPierc_IsEligible(Actor akActor, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    Return dinMn != None && !akActor.IsInCombat() && Game.GetPlayer().WornHasKeyword(dinMn.libs.zad_DeviousPiercingsVaginal)
EndFunction

Function ExtCmdDinUnlockClitPierc(Actor akOriginator, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    Actor target = Game.GetPlayer()
    If _TryUnlock(dinMn, dinMn.libs.zad_DeviousPiercingsVaginal, "regular", target)
        SendDevIntEvent(akOriginator.GetDisplayName() + " unlocks the clit piercing from " + target.GetDisplayName(), akOriginator)
    Else
        SendDevIntEvent(akOriginator.GetDisplayName() + " tries to unlock the clit piercing from " + target.GetDisplayName() + ", but it will not come off", akOriginator)
    EndIf
EndFunction

Bool Function ExtCmdDinUnlockCorset_IsEligible(Actor akActor, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    Return dinMn != None && !akActor.IsInCombat() && Game.GetPlayer().WornHasKeyword(dinMn.libs.zad_DeviousCorset)
EndFunction

Function ExtCmdDinUnlockCorset(Actor akOriginator, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    Actor target = Game.GetPlayer()
    If _TryUnlock(dinMn, dinMn.libs.zad_DeviousCorset, "regular", target)
        SendDevIntEvent(akOriginator.GetDisplayName() + " unlocks the corset from " + target.GetDisplayName(), akOriginator)
    Else
        SendDevIntEvent(akOriginator.GetDisplayName() + " tries to unlock the corset from " + target.GetDisplayName() + ", but it will not come off", akOriginator)
    EndIf
EndFunction

Bool Function ExtCmdDinUnlockGag_IsEligible(Actor akActor, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    Return dinMn != None && !akActor.IsInCombat() && Game.GetPlayer().WornHasKeyword(dinMn.libs.zad_DeviousGag)
EndFunction

Function ExtCmdDinUnlockGag(Actor akOriginator, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    Actor target = Game.GetPlayer()
    If _TryUnlock(dinMn, dinMn.libs.zad_DeviousGag, "regular", target)
        SendDevIntEvent(akOriginator.GetDisplayName() + " unlocks the gag from " + target.GetDisplayName(), akOriginator)
    Else
        SendDevIntEvent(akOriginator.GetDisplayName() + " tries to unlock the gag from " + target.GetDisplayName() + ", but it will not come off", akOriginator)
    EndIf
EndFunction

Bool Function ExtCmdDinUnlockGloves_IsEligible(Actor akActor, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    Return dinMn != None && !akActor.IsInCombat() && Game.GetPlayer().WornHasKeyword(dinMn.libs.zad_DeviousGloves)
EndFunction

Function ExtCmdDinUnlockGloves(Actor akOriginator, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    Actor target = Game.GetPlayer()
    If _TryUnlock(dinMn, dinMn.libs.zad_DeviousGloves, "regular", target)
        SendDevIntEvent(akOriginator.GetDisplayName() + " unlocks the gloves from " + target.GetDisplayName(), akOriginator)
    Else
        SendDevIntEvent(akOriginator.GetDisplayName() + " tries to unlock the gloves from " + target.GetDisplayName() + ", but it will not come off", akOriginator)
    EndIf
EndFunction

Bool Function ExtCmdDinUnlockHarness_IsEligible(Actor akActor, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    Return dinMn != None && !akActor.IsInCombat() && Game.GetPlayer().WornHasKeyword(dinMn.libs.zad_DeviousHarness)
EndFunction

Function ExtCmdDinUnlockHarness(Actor akOriginator, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    Actor target = Game.GetPlayer()
    If _TryUnlock(dinMn, dinMn.libs.zad_DeviousHarness, "regular", target)
        SendDevIntEvent(akOriginator.GetDisplayName() + " unlocks the harness from " + target.GetDisplayName(), akOriginator)
    Else
        SendDevIntEvent(akOriginator.GetDisplayName() + " tries to unlock the harness from " + target.GetDisplayName() + ", but it will not come off", akOriginator)
    EndIf
EndFunction

Bool Function ExtCmdDinUnlockHeavyBondage_IsEligible(Actor akActor, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    Return dinMn != None && !akActor.IsInCombat() && Game.GetPlayer().WornHasKeyword(dinMn.libs.zad_DeviousHeavyBondage)
EndFunction

Function ExtCmdDinUnlockHeavyBondage(Actor akOriginator, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    Actor target = Game.GetPlayer()
    If _TryUnlock(dinMn, dinMn.libs.zad_DeviousHeavyBondage, "advanced", target)
        SendDevIntEvent(akOriginator.GetDisplayName() + " unlocks the heavy bondage rig from " + target.GetDisplayName(), akOriginator)
    Else
        SendDevIntEvent(akOriginator.GetDisplayName() + " tries to unlock the heavy bondage rig from " + target.GetDisplayName() + ", but it will not come off", akOriginator)
    EndIf
EndFunction

Bool Function ExtCmdDinUnlockHobbleDress_IsEligible(Actor akActor, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    Return dinMn != None && !akActor.IsInCombat() && Game.GetPlayer().WornHasKeyword(dinMn.libs.zad_DeviousSuit)
EndFunction

Function ExtCmdDinUnlockHobbleDress(Actor akOriginator, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    Actor target = Game.GetPlayer()
    If _TryUnlock(dinMn, dinMn.libs.zad_DeviousSuit, "advanced", target)
        SendDevIntEvent(akOriginator.GetDisplayName() + " unlocks the hobble dress from " + target.GetDisplayName(), akOriginator)
    Else
        SendDevIntEvent(akOriginator.GetDisplayName() + " tries to unlock the hobble dress from " + target.GetDisplayName() + ", but it will not come off", akOriginator)
    EndIf
EndFunction

Bool Function ExtCmdDinUnlockLegCuffs_IsEligible(Actor akActor, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    Return dinMn != None && !akActor.IsInCombat() && Game.GetPlayer().WornHasKeyword(dinMn.libs.zad_DeviousLegCuffs)
EndFunction

Function ExtCmdDinUnlockLegCuffs(Actor akOriginator, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    Actor target = Game.GetPlayer()
    If _TryUnlock(dinMn, dinMn.libs.zad_DeviousLegCuffs, "basic", target)
        SendDevIntEvent(akOriginator.GetDisplayName() + " unlocks the leg cuffs from " + target.GetDisplayName(), akOriginator)
    Else
        SendDevIntEvent(akOriginator.GetDisplayName() + " tries to unlock the leg cuffs from " + target.GetDisplayName() + ", but it will not come off", akOriginator)
    EndIf
EndFunction

Bool Function ExtCmdDinUnlockArmCuffs_IsEligible(Actor akActor, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    Return dinMn != None && !akActor.IsInCombat() && Game.GetPlayer().WornHasKeyword(dinMn.libs.zad_DeviousArmCuffs)
EndFunction

Function ExtCmdDinUnlockArmCuffs(Actor akOriginator, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    Actor target = Game.GetPlayer()
    If _TryUnlock(dinMn, dinMn.libs.zad_DeviousArmCuffs, "basic", target)
        SendDevIntEvent(akOriginator.GetDisplayName() + " unlocks the arm cuffs from " + target.GetDisplayName(), akOriginator)
    Else
        SendDevIntEvent(akOriginator.GetDisplayName() + " tries to unlock the arm cuffs from " + target.GetDisplayName() + ", but it will not come off", akOriginator)
    EndIf
EndFunction

Bool Function ExtCmdDinUnlockNipPierc_IsEligible(Actor akActor, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    Return dinMn != None && !akActor.IsInCombat() && Game.GetPlayer().WornHasKeyword(dinMn.libs.zad_DeviousPiercingsNipple)
EndFunction

Function ExtCmdDinUnlockNipPierc(Actor akOriginator, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    Actor target = Game.GetPlayer()
    If _TryUnlock(dinMn, dinMn.libs.zad_DeviousPiercingsNipple, "regular", target)
        SendDevIntEvent(akOriginator.GetDisplayName() + " unlocks the nipple piercing from " + target.GetDisplayName(), akOriginator)
    Else
        SendDevIntEvent(akOriginator.GetDisplayName() + " tries to unlock the nipple piercing from " + target.GetDisplayName() + ", but it will not come off", akOriginator)
    EndIf
EndFunction

; ---- BondageOffer: an NPC (e.g. a bandit/captor) restrains the player ---
; severity: "light" | "medium" | "heavy" | "sex" (matches din_Main.BondageOffer)

Bool Function ExtCmdDinBondageOffer_IsEligible(Actor akActor, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    Return dinMn != None && akActor != Game.GetPlayer() && !Game.GetPlayer().IsDead()
EndFunction

Function ExtCmdDinBondageOffer(Actor akOriginator, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    If dinMn == None
        Return
    EndIf
    String severity = skyrimnetapi.GetJsonString(paramsJson, "severity", "medium")
    If severity != "light" && severity != "medium" && severity != "heavy" && severity != "sex"
        severity = "medium"
    EndIf
    Bool punishment = skyrimnetapi.GetJsonBool(paramsJson, "punishment", False)
    dinMn.BondageOffer(severity, akOriginator, punishment)
    SendDevIntEvent(akOriginator.GetDisplayName() + " restrains " + Game.GetPlayer().GetDisplayName() + " (severity: " + severity + ")", akOriginator)
EndFunction

; ---- Prostitution flow --------------------------------------------------

Bool Function ExtCmdDinProstitutionFuck_IsEligible(Actor akActor, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    Return dinMn != None && akActor != Game.GetPlayer()
EndFunction

Function ExtCmdDinProstitutionFuck(Actor akOriginator, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    If dinMn == None
        Return
    EndIf
    dinMn.FuckWhore(akOriginator)
    SendDevIntEvent(akOriginator.GetDisplayName() + " pays " + Game.GetPlayer().GetDisplayName() + " for sex", akOriginator)
EndFunction

Bool Function ExtCmdDinProstitutionBelt_IsEligible(Actor akActor, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    Return dinMn != None && !Game.GetPlayer().WornHasKeyword(dinMn.libs.zad_DeviousBelt)
EndFunction

Function ExtCmdDinProstitutionBelt(Actor akOriginator, String contextJson, String paramsJson) Global
    din_Main dinMn = GetDinMain()
    If dinMn == None
        Return
    EndIf
    dinMn.BeltWhore()
    If Game.GetPlayer().WornHasKeyword(dinMn.libs.zad_DeviousBelt)
        SendDevIntEvent(akOriginator.GetDisplayName() + " locks a chastity belt on " + Game.GetPlayer().GetDisplayName() + " as payment", akOriginator)
    Else
        SendDevIntEvent(akOriginator.GetDisplayName() + " tries to belt " + Game.GetPlayer().GetDisplayName() + ", but no belt could be found to use", akOriginator)
    EndIf
EndFunction

; ---- Decorator: player status, for use in prompts ------------------------

String Function dinint_get_status(Actor akSpeaker) Global
    din_Main dinMn = GetDinMain()
    If dinMn == None
        Return "{}"
    EndIf
    Actor player = Game.GetPlayer()
    String jailed = "false"
    String enslaved = "false"
    String chastity = "false"
    If dinMn.IsPlayerJailed
        jailed = "true"
    EndIf
    If dinMn.IsPlayerEnslaved
        enslaved = "true"
    EndIf
    If player.WornHasKeyword(dinMn.libs.zad_DeviousBelt) || player.WornHasKeyword(dinMn.libs.zad_DeviousBra)
        chastity = "true"
    EndIf
    Return "{\"is_jailed\": " + jailed + ", \"is_enslaved\": " + enslaved + ", \"in_chastity\": " + chastity + "}"
EndFunction

; ---- Registration (called once on game load, see skyrimnet_devint_PlayerAlias) --

Function RegisterDevIntActions() Global
    ; --- UDNG compatibility ---
    ; SkyrimNet_UDNG already covers "remove a Devious Devices item from the player"
    ; with its own ExtCmdUnequipX actions. If UDNG is installed, we skip registering
    ; our own overlapping unlock actions entirely so the LLM only ever sees ONE way
    ; to remove a given device (UDNG's), instead of two competing near-duplicate
    ; actions with different underlying mechanics (UDNG: free removal; DevInterests:
    ; BlacksmithUnlock, which can involve a gold cost). BondageOffer/Prostitution do
    ; not overlap with anything UDNG does, so those always register regardless.
    If !_IsUDNGInstalled()
        ; generic fallback
        skyrimnetapi.RegisterAction("DevInt_HelpRemoveRestraint", "Removes whatever Devious Devices restraint the player is currently wearing, if any is unlockable without a key.", "skynet_DevInt_Actions", "ExtCmdDinHelpRemoveRestraint_IsEligible", "skynet_DevInt_Actions", "ExtCmdDinHelpRemoveRestraint", "", "PAPYRUS_NESTED_ACTION", 1, "{}", "DEVINT_UNLOCK", "")

        ; 15 category-specific unlocks
        skyrimnetapi.RegisterAction("DevInt_UnlockCollar", "Unlocks and removes a Devious Devices collar from the player.", "skynet_DevInt_Actions", "ExtCmdDinUnlockCollar_IsEligible", "skynet_DevInt_Actions", "ExtCmdDinUnlockCollar", "", "PAPYRUS_NESTED_ACTION", 1, "{}", "DEVINT_UNLOCK", "")
        skyrimnetapi.RegisterAction("DevInt_UnlockBelt", "Unlocks and removes a Devious Devices chastity belt from the player.", "skynet_DevInt_Actions", "ExtCmdDinUnlockBelt_IsEligible", "skynet_DevInt_Actions", "ExtCmdDinUnlockBelt", "", "PAPYRUS_NESTED_ACTION", 1, "{}", "DEVINT_UNLOCK", "")
        skyrimnetapi.RegisterAction("DevInt_UnlockBlindfold", "Unlocks and removes a Devious Devices blindfold from the player.", "skynet_DevInt_Actions", "ExtCmdDinUnlockBlindfold_IsEligible", "skynet_DevInt_Actions", "ExtCmdDinUnlockBlindfold", "", "PAPYRUS_NESTED_ACTION", 1, "{}", "DEVINT_UNLOCK", "")
        skyrimnetapi.RegisterAction("DevInt_UnlockBoots", "Unlocks and removes Devious Devices pony boots from the player.", "skynet_DevInt_Actions", "ExtCmdDinUnlockBoots_IsEligible", "skynet_DevInt_Actions", "ExtCmdDinUnlockBoots", "", "PAPYRUS_NESTED_ACTION", 1, "{}", "DEVINT_UNLOCK", "")
        skyrimnetapi.RegisterAction("DevInt_UnlockBra", "Unlocks and removes a Devious Devices chastity bra from the player.", "skynet_DevInt_Actions", "ExtCmdDinUnlockBra_IsEligible", "skynet_DevInt_Actions", "ExtCmdDinUnlockBra", "", "PAPYRUS_NESTED_ACTION", 1, "{}", "DEVINT_UNLOCK", "")
        skyrimnetapi.RegisterAction("DevInt_UnlockClitPierc", "Unlocks and removes a Devious Devices clit piercing from the player.", "skynet_DevInt_Actions", "ExtCmdDinUnlockClitPierc_IsEligible", "skynet_DevInt_Actions", "ExtCmdDinUnlockClitPierc", "", "PAPYRUS_NESTED_ACTION", 1, "{}", "DEVINT_UNLOCK", "")
        skyrimnetapi.RegisterAction("DevInt_UnlockCorset", "Unlocks and removes a Devious Devices corset from the player.", "skynet_DevInt_Actions", "ExtCmdDinUnlockCorset_IsEligible", "skynet_DevInt_Actions", "ExtCmdDinUnlockCorset", "", "PAPYRUS_NESTED_ACTION", 1, "{}", "DEVINT_UNLOCK", "")
        skyrimnetapi.RegisterAction("DevInt_UnlockGag", "Unlocks and removes a Devious Devices gag from the player.", "skynet_DevInt_Actions", "ExtCmdDinUnlockGag_IsEligible", "skynet_DevInt_Actions", "ExtCmdDinUnlockGag", "", "PAPYRUS_NESTED_ACTION", 1, "{}", "DEVINT_UNLOCK", "")
        skyrimnetapi.RegisterAction("DevInt_UnlockGloves", "Unlocks and removes Devious Devices mitten gloves from the player.", "skynet_DevInt_Actions", "ExtCmdDinUnlockGloves_IsEligible", "skynet_DevInt_Actions", "ExtCmdDinUnlockGloves", "", "PAPYRUS_NESTED_ACTION", 1, "{}", "DEVINT_UNLOCK", "")
        skyrimnetapi.RegisterAction("DevInt_UnlockHarness", "Unlocks and removes a Devious Devices body harness from the player.", "skynet_DevInt_Actions", "ExtCmdDinUnlockHarness_IsEligible", "skynet_DevInt_Actions", "ExtCmdDinUnlockHarness", "", "PAPYRUS_NESTED_ACTION", 1, "{}", "DEVINT_UNLOCK", "")
        skyrimnetapi.RegisterAction("DevInt_UnlockHeavyBondage", "Unlocks and removes a Devious Devices heavy bondage rig from the player.", "skynet_DevInt_Actions", "ExtCmdDinUnlockHeavyBondage_IsEligible", "skynet_DevInt_Actions", "ExtCmdDinUnlockHeavyBondage", "", "PAPYRUS_NESTED_ACTION", 1, "{}", "DEVINT_UNLOCK", "")
        skyrimnetapi.RegisterAction("DevInt_UnlockHobbleDress", "Unlocks and removes a Devious Devices hobble dress from the player.", "skynet_DevInt_Actions", "ExtCmdDinUnlockHobbleDress_IsEligible", "skynet_DevInt_Actions", "ExtCmdDinUnlockHobbleDress", "", "PAPYRUS_NESTED_ACTION", 1, "{}", "DEVINT_UNLOCK", "")
        skyrimnetapi.RegisterAction("DevInt_UnlockLegCuffs", "Unlocks and removes Devious Devices leg cuffs from the player.", "skynet_DevInt_Actions", "ExtCmdDinUnlockLegCuffs_IsEligible", "skynet_DevInt_Actions", "ExtCmdDinUnlockLegCuffs", "", "PAPYRUS_NESTED_ACTION", 1, "{}", "DEVINT_UNLOCK", "")
        skyrimnetapi.RegisterAction("DevInt_UnlockArmCuffs", "Unlocks and removes Devious Devices arm cuffs from the player.", "skynet_DevInt_Actions", "ExtCmdDinUnlockArmCuffs_IsEligible", "skynet_DevInt_Actions", "ExtCmdDinUnlockArmCuffs", "", "PAPYRUS_NESTED_ACTION", 1, "{}", "DEVINT_UNLOCK", "")
        skyrimnetapi.RegisterAction("DevInt_UnlockNipPierc", "Unlocks and removes a Devious Devices nipple piercing from the player.", "skynet_DevInt_Actions", "ExtCmdDinUnlockNipPierc_IsEligible", "skynet_DevInt_Actions", "ExtCmdDinUnlockNipPierc", "", "PAPYRUS_NESTED_ACTION", 1, "{}", "DEVINT_UNLOCK", "")
    EndIf

    ; bondage offer / prostitution
    skyrimnetapi.RegisterAction("DevInt_BondageOffer", "The speaker physically restrains the player with Devious Devices. Parameter 'severity' must be one of: light, medium, heavy, sex.", "skynet_DevInt_Actions", "ExtCmdDinBondageOffer_IsEligible", "skynet_DevInt_Actions", "ExtCmdDinBondageOffer", "", "PAPYRUS_NESTED_ACTION", 1, "{\"severity\": \"String\"}", "DEVINT_BONDAGE", "")
    skyrimnetapi.RegisterAction("DevInt_ProstitutionFuck", "The speaker pays the player for sex, as part of the Devious Interests prostitution system.", "skynet_DevInt_Actions", "ExtCmdDinProstitutionFuck_IsEligible", "skynet_DevInt_Actions", "ExtCmdDinProstitutionFuck", "", "PAPYRUS_NESTED_ACTION", 1, "{}", "DEVINT_PROSTITUTION", "")
    skyrimnetapi.RegisterAction("DevInt_ProstitutionBelt", "The speaker locks a chastity belt on the player as a form of payment/punishment within the prostitution system.", "skynet_DevInt_Actions", "ExtCmdDinProstitutionBelt_IsEligible", "skynet_DevInt_Actions", "ExtCmdDinProstitutionBelt", "", "PAPYRUS_NESTED_ACTION", 1, "{}", "DEVINT_PROSTITUTION", "")
EndFunction

Function RegisterDevIntDecorators() Global
    skyrimnetapi.RegisterDecorator("dinint_get_status", "skynet_DevInt_Actions", "dinint_get_status")
EndFunction
