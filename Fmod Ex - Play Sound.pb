;Tutorial : FMODEX  - Play sound (mp3, ogg, etc ...)  
;
;PureBasic 5.50

EnableExplicit

IncludeFile "fmodex-min.pbi"

Enumeration
  #Mainform
  #Sound
  #SelectSound
  #Play
  #Pause
  #Stop
  #Volume
EndEnumeration

Define.l Event, GEvent, TiEvent

Global File.s, FmodSystem.i, Channel.i, Sound.i, Volume.f = 0.5, PauseStatus.b

Declare Start()
Declare Control(Value)
Declare onSelectSound()
Declare onPlay()
Declare onVolume()
Declare onPause()
Declare onStop()
Declare OnExit()

Start()

Procedure Start()
  OpenWindow(#Mainform, 0, 0, 300, 100, "Play Mp3", #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
  StringGadget(#Sound, 10, 20, 230, 22, "", #PB_String_ReadOnly)
  ButtonGadget(#SelectSound, 245, 20, 50, 22, "Select")
  TextGadget(#PB_Any, 10, 50, 30, 20, "Vol")
  TrackBarGadget(#Volume, 45, 45, 200, 24, 0, 100)
  SetGadgetState(#Volume, 50)
  
  ButtonGadget(#Play, 55, 70, 60, 22, "Start")
  ButtonGadget(#Pause, 117, 70, 60, 22, ">>")
  ButtonGadget(#Stop, 183, 70, 60, 22, "Stop")
  
  Control(#True)
  
  ;Declare FMOD System
  FMOD_System_Create(@fmodsystem)
  
  ;Init FMOD System
  FMOD_System_Init(FmodSystem, 32, #FMOD_INIT_NORMAL, 0)
  
  ;Triggers
  BindGadgetEvent(#SelectSound, @onSelectSound())
  BindGadgetEvent(#Play, @onPlay())
  BindGadgetEvent(#Volume, @onVolume())
  BindGadgetEvent(#Pause, @onPause())
  BindGadgetEvent(#Stop, @onStop())
  BindEvent(#PB_Event_CloseWindow, @onExit())
  
  Repeat : WaitWindowEvent(10) : ForEver
EndProcedure

Procedure Control(Value)
  DisableGadget(#Play, Value)
  DisableGadget(#Volume, Value)
  DisableGadget(#Pause, Value)
  DisableGadget(#Stop, Value)
EndProcedure

Procedure onSelectSound()
  ;Release previous sound
  If Sound <> 0
    FMOD_Sound_Release(Sound)
  EndIf
  
  SetGadgetText(#Pause, ">>")
  file = ""
  Control(#True)
  
  ;Select sound
  File = OpenFileRequester("Selectionner un fichier mp3","","Musique|*.mp3;*.wav;*.ogg;*.flac",0)
  If File <> ""
    SetGadgetText(#Sound, GetFilePart(File))
    FMOD_System_CreateStream(FmodSystem, Ascii(File), #FMOD_SOFTWARE, 0, @sound)
    Control(#False)
  EndIf
EndProcedure

Procedure onVolume()
  Protected Volume.f = GetGadgetState(#Volume)/100
  FMOD_Channel_SetVolume(Channel, Volume)
EndProcedure

Procedure onPlay()
  ;Play a sound on a free channel
  FMOD_System_PlaySound(fmodsystem, #FMOD_CHANNEL_FREE, sound, 0, @channel)
  
  ;Et on ajuste le volume (le son est compris entre 0.0 et 1.0)
  FMOD_Channel_SetVolume(Channel, Volume)
  
  SetGadgetText(#Pause, "||")
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

Procedure onStop()
  FMOD_Channel_Stop(Channel)
  SetGadgetText(#Pause, ">>")  
EndProcedure

Procedure onExit()
  FMOD_Channel_Stop(Channel)
  FMOD_System_Release(FmodSystem)
  End
EndProcedure
; IDE Options = PureBasic 5.50 beta 1 (Windows - x86)
; CursorPosition = 6
; FirstLine = 2
; Folding = --
; EnableXP