ScriptName skyrimnet_devint_MCM extends Quest

; v1 does not implement a full SkyUI MCM menu - Devious Interests already has its
; own MCM (din_Config) for its core settings, and this integration just calls into
; din_Main's existing functions. These properties exist so the toggles below can be
; set via console (SetPropertyValue) or a future MCM menu without recompiling.

skyrimnet_devint_Groups Property groups Auto
String Property ModName = "SkyrimNet Devious Interests" Auto

Bool Property bAllowBondageOffer = True Auto
Bool Property bAllowProstitutionActions = True Auto
Bool Property bAllowUnlockActions = True Auto
