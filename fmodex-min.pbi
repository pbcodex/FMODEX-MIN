;/ FMODEX-Min.pbi for fmodex 
;/
;/ Based on the code of Froggerprogger - 27.02.2007 - http://www.purebasic.fr/english/viewtopic.php?f=12&t=25144
;/ Update       : falsam, 13.06.2016 (PB 5.50)
;/ Contributor  : El Papounet, nco2k, spikey

#FMOD_INIT_NORMAL = $0      ; All platforms - Initialize normally.
#FMOD_CREATESTREAM = $80    ; Decompress at runtime, streaming from the source provided (standard stream).
#FMOD_SOFTWARE = $40        ; Makes sound reside in software.
#FMOD_CHANNEL_FREE = -1     ; For a channel index, FMOD chooses a free voice using the priority system.
#FMOD_CHANNEL_REUSE = -2    ; For a channel index, re-use the channel handle that was passed in.

#FMOD_TIMEUNIT_MS = $1      ; Milliseconds.

Structure FMOD_TAG
  type.l                    ; [out] The type of this tag.
  datatype.l                ; [out] The type of data that this tag contains 
  *name                     ; [out] The name of this tag i.e. "TITLE", "ARTIST" etc.
  *_data                    ; [out] Pointer to the tag data - its format is determined by the datatype member 
  datalen.l                 ; [out] Length of the data contained in this tag 
  udated.l                  ; [out] True if this tag has been updated since last being accessed with Sound::getTag 
EndStructure

CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
  Global fmodLib = OpenLibrary(#PB_Any, "fmodex.dll")
CompilerElse
  Global fmodLib = OpenLibrary(#PB_Any, "fmodex64.dll")
CompilerEndIf

If fmodLib
  
  ;- FMOD_System_Create
  Prototype.l FMOD_System_Create_Prototype(*system)
  Global FMOD_System_Create.FMOD_System_Create_Prototype = GetFunction(fmodLib, "FMOD_System_Create")
  
  ;- FMOD_System_Init_
  Prototype.l FMOD_System_Init_Prototype (system.l, Maxchannels.l, flags.l, Extradriverdata.l);system.l, Maxchannels.l, flags.l, Extradriverdata.l
  Global FMOD_System_Init.FMOD_System_Init_Prototype = GetFunction(fmodLib, "FMOD_System_Init")
  
  ;- FMOD_System_CreateStream_
  Prototype.l FMOD_System_CreateStream_Prototype (system.l, Name_or_data.l, Mode.l, *exinfo, *Sound)
  Global FMOD_System_CreateStream.FMOD_System_CreateStream_Prototype = GetFunction(fmodLib, "FMOD_System_CreateStream")
  
  ;- FMOD_System_PlaySound_
  Prototype.l FMOD_System_PlaySound_Prototype (system.l, channelid.l, sound.l, paused.l, *channel)
  Global FMOD_System_PlaySound.FMOD_System_PlaySound_Prototype = GetFunction(fmodLib, "FMOD_System_PlaySound")
  
  ;- FMOD_Sound_Release_
  Prototype.l FMOD_Sound_Release_Prototype (sound.l)
  Global FMOD_Sound_Release.FMOD_Sound_Release_Prototype = GetFunction(fmodLib, "FMOD_Sound_Release")
  
  ;- FMOD_Channel_SetVolume
  Prototype.l FMOD_Channel_SetVolume_Prototype(channel.l, Volume.f)
  Global FMOD_Channel_SetVolume.FMOD_Channel_SetVolume_Prototype = GetFunction(fmodLib, "FMOD_Channel_SetVolume")  
  
  ;- FMOD_Channel_SetPaused_
  Prototype.l FMOD_Channel_SetPaused_Prototype (channel.l, paused.l)
  Global FMOD_Channel_SetPaused.FMOD_Channel_SetPaused_Prototype = GetFunction(fmodLib, "FMOD_Channel_SetPaused")
  
  ;- FMOD_Channel_GetPaused_
  Prototype.l FMOD_Channel_GetPaused_Prototype (channel.l, *paused)
  Global FMOD_Channel_GetPaused.FMOD_Channel_GetPaused_Prototype = GetFunction(fmodLib, "FMOD_Channel_GetPaused")
  
  ;- FMOD_Channel_Stop_
  Prototype.l FMOD_Channel_Stop_Prototype (channel.l)
  Global FMOD_Channel_Stop.FMOD_Channel_Stop_Prototype = GetFunction(fmodLib, "FMOD_Channel_Stop")
  
  ;- FMOD_System_Release
  Prototype.l FMOD_System_Release_Prototype(system.l)
  Global FMOD_System_Release.FMOD_System_Release_Prototype = GetFunction(fmodLib, "FMOD_System_Release")
  
  ;- FMOD_Channel_GetPosition_
  Prototype.l FMOD_Channel_GetPosition_Prototype (channel.l, *Position, Postype.l)
  Global FMOD_Channel_GetPosition.FMOD_Channel_GetPosition_Prototype = GetFunction(fmodLib, "FMOD_Channel_GetPosition")
  
  ;- FMOD_Channel_SetPosition_
  Prototype.l FMOD_Channel_SetPosition_Prototype (channel.l, Position.l, Postype.l)
  Global FMOD_Channel_SetPosition.FMOD_Channel_SetPosition_Prototype = GetFunction(fmodLib, "FMOD_Channel_SetPosition")
  
  ;- FMOD_Sound_GetLength_
  Prototype.l FMOD_Sound_GetLength_Prototype (sound.l, *Length, Lengthtype.l)
  Global FMOD_Sound_GetLength.FMOD_Sound_GetLength_Prototype = GetFunction(fmodLib, "FMOD_Sound_GetLength")
  
  ;- FMOD_Sound_GetNumTags_
  Prototype.l FMOD_Sound_GetNumTags_Prototype (sound.l, *Numtags, *Numtagsupdated)
  Global FMOD_Sound_GetNumTags.FMOD_Sound_GetNumTags_Prototype = GetFunction(fmodLib, "FMOD_Sound_GetNumTags")   
  
  ;- FMOD_Sound_GetTag_
  Prototype.l FMOD_Sound_GetTag_Prototype (sound.l, pNameOrNull.l, Index.l, *Tag)
  Global FMOD_Sound_GetTag.FMOD_Sound_GetTag_Prototype = GetFunction(fmodLib, "FMOD_Sound_GetTag")
  
  ;- FMOD_Channel_GetSpectrum_
  Prototype.l FMOD_Channel_GetSpectrum_Prototype (channel.l, *Spectrumarray, Numvalues.l, Channeloffset.l, Windowtype.l)
  Global FMOD_Channel_GetSpectrum.FMOD_Channel_GetSpectrum_Prototype = GetFunction(fmodLib, "FMOD_Channel_GetSpectrum")

Else
  Debug "fmodex.dll or fmodex64.dll is needed and is not found." 
  End
EndIf
; IDE Options = PureBasic 5.50 beta 1 (Windows - x86)
; FirstLine = 52
; Folding = -
; EnableXP