;Tutorial : FMODEX  - Play Shout Cast  
;
;PureBasic 5.50

EnableExplicit

IncludeFile "fmodex-min.pbi"

Enumeration
  #Mainform
  #Pause
  #Volume
EndEnumeration

Global FmodSystem.i, Url.s, Channel.i, Sound.i, Volume.f, PauseStatus.b

Declare Start()
Declare onVolume()
Declare onPause()
Declare onExit()

Start()

Procedure Start()
  OpenWindow(#Mainform, 0, 0, 300, 100, "Play Shoutcast", #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
  TextGadget(#PB_Any, 10, 35, 30, 20, "Vol")
  TrackBarGadget(#Volume, 45, 30, 200, 26, 0, 100)
  SetGadgetState(#Volume, 50)
  
  ButtonGadget(#Pause, 117, 70, 50, 22, "||")
  
  ;Declare FMOD System
  FMOD_System_Create(@fmodsystem)
  
  ;Init FMOD System
  FMOD_System_Init(FmodSystem, 32, #FMOD_INIT_NORMAL, 0)
  
  ;Init shoutcast stream 
  Url ="http://server1.chilltrax.com:9000"
  FMOD_System_CreateStream(FmodSystem, Ascii(Url), #FMOD_CREATESTREAM, 0, @sound)
  
  ;Play Shoutcast on chanel 1
  FMOD_System_PlaySound(FmodSystem, 1, Sound, 0, @channel)
  
  ;Set Channel volume (between 0.0 and 1.0)
  FMOD_Channel_SetVolume(Channel, 0.5)
  
  ;Triggers
  BindGadgetEvent(#Volume, @onVolume())
  BindGadgetEvent(#Pause, @onPause())  
  BindEvent(#PB_Event_CloseWindow, @onExit())
  
  Repeat : WaitWindowEvent(10) : ForEver
EndProcedure

Procedure onVolume()
  Protected Volume.f = GetGadgetState(#Volume)/100
  FMOD_Channel_SetVolume(Channel, Volume)
EndProcedure

Procedure onPause()
  ;Get channel pause status
  FMOD_Channel_GetPaused(Channel, @PauseStatus) 
  
  If PauseStatus = #False
    FMOD_Channel_SetPaused(Channel, #True) ;Pause
    SetGadgetText(#Pause, ">>")
  Else
    FMOD_Channel_SetPaused(Channel, #False) ;Play
    SetGadgetText(#Pause, "||")
  EndIf
EndProcedure

Procedure onExit()
  FMOD_Channel_Stop(Channel)
  FMOD_System_Release(FmodSystem)
  End
EndProcedure
; IDE Options = PureBasic 5.50 beta 1 (Windows - x86)
; CursorPosition = 37
; FirstLine = 11
; Folding = -
; EnableXP