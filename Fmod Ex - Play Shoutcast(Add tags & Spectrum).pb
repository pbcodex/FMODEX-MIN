;Fmodex : Jouer un flux internet radio

EnableExplicit

IncludeFile "fmodex-min.pbi"

Enumeration Font
  #FontGlobal
  #FontAuthor
  #FontTitle
EndEnumeration

Enumeration Window
  #Mainform
EndEnumeration

Enumeration Gadget
  #WebRadio
  #Pause
  #Volume
  
  #Spectrum
  
  #TagICYName
  #TagICYUrl
  #TagAuthor
  #TagTitle
  
EndEnumeration

Global fmodsystem.i, Channel.i, Sound.i, Volume.f = 0.5, PauseStatus.b, N.i

Structure Radio
  Url.s
  Name.s
EndStructure
Global NewList WebRadio.Radio(), Url.s

Declare Start()
Declare MainFormShow()
Declare WebRadioLoad()
Declare ShowSpectrum()
Declare TagUpdate()

Declare onSelectShoutcast()
Declare onVolume()
Declare onPause()
Declare onExit()

Start()

Procedure Start()
  MainFormShow()
  WebRadioLoad()
  
  ;Declare FMOD System
  FMOD_System_Create(@fmodsystem)
  
  ;Init FMOD System
  FMOD_System_Init(fmodsystem, 32, #FMOD_INIT_NORMAL, 0)
  
  ;Init shoutcast stream 
  FirstElement(WebRadio())
  Url = WebRadio()\Url
  FMOD_System_CreateStream(fmodsystem, Ascii(Url), #FMOD_CREATESTREAM, 0, @sound)
    
  ;Play Shoutcast on chanel 1
  FMOD_System_PlaySound(fmodsystem, 1, sound, 0, @Channel)
  
  ;Set Channel volume (between 0.0 and 1.0)
  FMOD_Channel_SetVolume(Channel, 0.5)
    
  Repeat : WaitWindowEvent(10) : ForEver
EndProcedure

Procedure MainFormShow()    
  LoadFont(#FontGlobal, "Tahoma", 10)
  SetGadgetFont(#PB_Default, FontID(#FontGlobal)) 
  
  LoadFont(#FontAuthor, "Tahoma", 15)
  LoadFont(#FontTitle, "Tahoma", 12)
  
  OpenWindow(#Mainform, 0, 0, 300, 315, "Play Shoutcast & Spectrum", #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
  ComboBoxGadget(#WebRadio, 10, 10, 280, 24)
  
  TextGadget(#PB_Any, 5, 45, 30, 20, "Vol")
  TrackBarGadget(#Volume, 45, 45, 251, 26, 0, 100)
  SetGadgetState(#Volume, 50)
  
  ;Author and Title
  TextGadget(#TagAuthor, 5, 72, 290, 22, "?")
  SetGadgetFont(#TagAuthor, FontID(#FontAuthor)) 
  TextGadget(#TagTitle, 5, 95, 290, 22, "?")
  SetGadgetFont(#TagTitle, FontID(#FontTitle))
  
  ;Name of radio and website
  TextGadget(#TagICYName, 5, 120, 290, 22, "?")
  TextGadget(#TagICYUrl, 5, 150, 280, 22, "?")
  
  ;Spectrum
  CanvasGadget(#Spectrum, 5, 175, 290, 100)
  ButtonGadget(#Pause, 117, 285, 50, 24, "||")
  
  AddWindowTimer(#Mainform, 100, 100)
  AddWindowTimer(#Mainform, 101, 500)
  
  ;Triggers
  BindGadgetEvent(#WebRadio, @onSelectShoutcast())
  BindGadgetEvent(#Volume, @onVolume())
  BindGadgetEvent(#Pause, @onPause())
    
  BindEvent(#PB_Event_Timer, @ShowSpectrum(), #Mainform, 100)
  BindEvent(#PB_Event_Timer, @TagUpdate(), #Mainform, 101)
  BindEvent(#PB_Event_CloseWindow, @onExit())
EndProcedure


Procedure WebRadioLoad()
  Protected Buffer.s, i.i
  
  Restore WebRadio
  For i=1 To 9
    AddElement(WebRadio())
    
    Read.s Buffer     
    WebRadio()\Url = Buffer
    
    Read.s Buffer     
    WebRadio()\Name = Buffer
    
    AddGadgetItem(#WebRadio, -1, WebRadio()\Name)
    SetGadgetItemData(#WebRadio, i-1, i-1)
  Next 
  SetGadgetState(#WebRadio, 0)
EndProcedure

Procedure ShowSpectrum()
  Protected Dim SpectrumArray.f(128), i.i, j.i, Max, Position.i
  
  ;FMOD_Channel_GetSpectrum(() Obtain the output signal
  ;Spectrum Array is an array of 64 to 8192 amplitudes (power of 2)
  FMOD_Channel_GetSpectrum(Channel, SpectrumArray(), 64, 0, 0 )
  
  StartDrawing(CanvasOutput(#Spectrum))
  
  ;Clear canvas
  Box(0, 0, 290, 100, RGB(245, 245, 245)) 
  
  ;Draw border
  DrawingMode(#PB_2DDrawing_Outlined) 
  Box(0, 0, 290, 100, RGB(0, 0, 0)) 
  
  ;Draw amplitudes
  DrawingMode(#PB_2DDrawing_Default)
  For i=0 To 50
    Max= SpectrumArray(i)*300 
    
    Box(i*6, 100-max, 4, max-2, RGB(0, 191, 255)) 
    Box(i*6, 95-max, 4, 3, RGB(255, 0, 0)) ;Points rouges
  Next 
  
  StopDrawing()
  
EndProcedure


Procedure TagUpdate()
  Protected TagCount, Tag.FMOD_TAG, i, Title.s, Artist.s, ICYName.s, ICYUrl.s
  
  ;FMOD_Sound_GetNumTags() Get the tag numbers
  FMOD_Sound_GetNumTags(Sound, @TagCount, #Null) 
  
  For i=0 To TagCount-1      
    FMOD_Sound_GetTag(Sound, 0, i, @Tag) 
    
    Select UCase(PeekS(Tag\name, -1, #PB_Ascii))
        
      Case "ARTIST", "TPE1", "TPE2", "TP1"
        If Artist=""
          Artist = PeekS(Tag\_data, Tag\datalen, #PB_Ascii)
        EndIf
        
      Case "TITLE", "TIT1", "TIT2", "TT2"
        If Title=""
          Title = PeekS(Tag\_data, Tag\datalen, #PB_Ascii)
        EndIf
        
      Case "ICY-NAME"
        ICYName = PeekS(Tag\_data, Tag\datalen, #PB_Ascii)
        
      Case "ICY-URL"
        ICYUrl =   PeekS(Tag\_data, Tag\datalen, #PB_Ascii)
        
    EndSelect
  Next
  
  If Artist <> GetGadgetText(#TagAuthor)
    SetGadgetText(#TagAuthor, Artist)
  EndIf
  
  If Title <> GetGadgetText(#TagTitle)
    SetGadgetText(#TagTitle, Title)
  EndIf
  
  If ICYName <> GetGadgetText(#TagICYName) Or N<>0
    If Len(ICYName) > 47
      N+1
      If N > Len(ICYName)-47
        N = 0
      EndIf
    Else
      N=0
    EndIf
    
    SetGadgetText(#TagICYName, Mid(ICYName, N, 47))
  EndIf
  
  If ICYUrl <> GetGadgetText(#TagICYUrl)
    SetGadgetText(#TagICYUrl, ICYUrl)
  EndIf
  
EndProcedure

Procedure onSelectShoutcast()
  SelectElement(Webradio(), GetGadgetState(#WebRadio))
  FMOD_System_CreateStream(fmodsystem, Ascii(Webradio()\Url), #FMOD_CREATESTREAM, 0, @sound)
  TagUpdate()
  FMOD_System_PlaySound(fmodsystem, 1, sound, 0, @channel)
  FMOD_Channel_SetVolume(Channel, GetGadgetState(#Volume)/100)
EndProcedure


Procedure onVolume()
  Protected Volume.f = GetGadgetState(#Volume)/100
  FMOD_Channel_SetVolume(Channel, Volume)
EndProcedure

Procedure onPause()
  TagUpdate()
  
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

DataSection
  Webradio:
  
  Data.s "http://server1.chilltrax.com:9000", "Chilltrax"
  Data.s "http://broadcast.infomaniak.ch/frequencejazz-high.mp3","Jazz Radio"
  Data.s "http://stream.pulsradio.com:5000", "Pulse Radio"
  Data.s "http://stream1.chantefrance.com/Chante_France", "Chante France"
  Data.s "http://streaming202.radionomy.com:80/70s-80s-90s-riw-vintage-channel","RIWVintage Channel"
  Data.s "http://mfm.ice.infomaniak.ch/mfm-128.mp3", "MFM Radio"
  Data.s "http://broadcast.infomaniak.net/tsfjazz-high.mp3", "TSF Jazz"
  Data.s "http://199.101.51.168:8004", "Blues Connection"
  Data.S "http://185.33.22.15:10036", "GAIA"
EndDataSection

; IDE Options = PureBasic 5.50 beta 1 (Windows - x86)
; CursorPosition = 107
; FirstLine = 103
; Folding = ----
; EnableXP