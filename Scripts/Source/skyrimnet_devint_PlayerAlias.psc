ScriptName skyrimnet_devint_PlayerAlias extends ReferenceAlias

skyrimnet_devint_Groups Property groups Auto

Event OnInit()
    RegisterForModEvent("SkyrimNetReady", "OnSkyrimNetReady")
EndEvent

Event OnPlayerLoadGame()
    RegisterForModEvent("SkyrimNetReady", "OnSkyrimNetReady")
    Setup()
EndEvent

Event OnSkyrimNetReady(String eventName, String strArg, Float numArg, Form sender)
    Setup()
EndEvent

Function Setup()
    SkyrimNetApi.RegisterEventSchema("DevInt", "SkyrimNet_DevInt Event", "Events related to the Devious Interests integration (device unlocks, bondage offers, prostitution)", "[{\"name\":\"info\",\"type\":0,\"required\":true,\"description\":\"Event Info\"}]", "{\"recent_events\":\"{{info}}\",\"raw\":\"{{info}}\",\"compact\":\"{{info}}\",\"verbose\":\"{{info}}\"}", true, 20000)
    skynet_DevInt_Actions.RegisterDevIntActions()
    skynet_DevInt_Actions.RegisterDevIntDecorators()
EndFunction
