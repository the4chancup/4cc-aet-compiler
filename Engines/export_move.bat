REM - Edits and moves the contents of the export to the root of extracted_exports

::=========================================================================
::BEGIN DEFINITION OF THE MACRO FOR CONVERTING TO HEXADECIMAL
::
setlocal disableDelayedExpansion
set LF=^


::Above 2 blank lines are required - do not remove
set ^"\n=^^^%LF%%LF%^%LF%%LF%^^"
set "echo=echo("
set macro_Call=for /f "tokens=1-26" %%a in

set macro.Num2Hex=do (%\n%
  setlocal enableDelayedExpansion%\n%
  set /a "dec=(%%~a)"%\n%
  if defined hex set "hex="%\n%
  set "map=0123456789ABCDEF"%\n%
  for /l %%n in (1,1,8) do (%\n%
    set /a "d=dec&15,dec>>=4"%\n%
    for %%d in (!d!) do set "hex=!map:~%%d,1!!hex!"%\n%
  )%\n%
  for %%v in (!hex!) do endlocal^&if "%%~b" neq "" (set "%%~b=%%v") else %echo%%%v%\n%
)
::
::END DEFINITION OF THE MACRO
::==========================================================================


REM - Allow modifying named variables inside parentheses
setlocal EnableDelayedExpansion

REM - Move everything except the folders
for /f "tokens=*" %%B in ('dir /a:-d /b ".\extracted_exports\!foldername!" 2^>nul') do (

  move ".\extracted_exports\!foldername!\%%B" ".\extracted_exports" >nul
)


REM - Move the folders' contents
set unknownexists=

for /f "tokens=*" %%B in ('dir /a:d /b ".\extracted_exports\!foldername!" 2^>nul') do (

  set unknown=1
  
  REM - Face folder
  if /i "%%B"=="Faces" (
  
    set unknown=
    
    REM - Create the main folder if not present
    if not exist ".\extracted_exports\%%B" (
      md ".\extracted_exports\%%B" 2>nul
    )
    
    REM - For each face folder
    for /f "tokens=*" %%C in ('dir /a:d /b ".\extracted_exports\!foldername!\%%B" 2^>nul') do (
    
      REM - Prepare the player ID
      set name=%%C
      set name=!teamid!!name:~3!
      set faceid=!name:~0,5!
      
      REM - If fox mode is enabled
      if defined fox_mode (
        
        REM - Edit the texture paths if requested
        if %fmdl_id_editing%==1 (
        
          REM - Level 1 - Just the hair_high fmdl
          if exist ".\extracted_exports\!foldername!\%%B\%%C\hair_high.fmdl" (
            call .\Engines\Python\fmdl_id_change ".\extracted_exports\!foldername!\%%B\%%C\hair_high.fmdl" !faceid!
          )
        )
        if %fmdl_id_editing%==2 (
          
          REM - Level 2 - Every fmdl
          for /f "tokens=*" %%D in ('dir /b ".\extracted_exports\!foldername!\%%B\%%C\*.fmdl"') do (
            call .\Engines\Python\fmdl_id_change ".\extracted_exports\!foldername!\%%B\%%C\%%D" !faceid!
          )
        )
        
        REM - Check if any dds textures exist
        >nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\%%B\%%C\*.dds" && (set dds_present=1) || (set dds_present=)
        
        if defined dds_present (
          
          REM - Convert the dds textures to ftex
          call .\Engines\Python\ftex_pack -m ".\extracted_exports\!foldername!\%%B\%%C" ".\extracted_exports\!foldername!\%%B\%%C"
          
          REM - And delete them
          for /f "tokens=*" %%D in ('dir /b ".\extracted_exports\!foldername!\%%B\%%C\*.dds"') do (
            del ".\extracted_exports\!foldername!\%%B\%%C\%%D" >nul
          )
        )
        
      )
      
      REM - Replace the dummy team ID with the actual one
      rename ".\extracted_exports\!foldername!\%%B\%%C" "!name!"
      
      REM - Delete the folder if already present
      if exist ".\extracted_exports\%%B\!name!" (
        rd /S /Q ".\extracted_exports\%%B\!name!"
      )
      
      REM - And move the face folder
      move ".\extracted_exports\!foldername!\%%B\!name!" ".\extracted_exports\%%B" >nul
    )
    
  )
  
  
  REM - Kit Configs folder
  if /i "%%B"=="Kit Configs" (
  
    set unknown=
    
    REM - Create the main folder if not present
    if not exist ".\extracted_exports\%%B" (
      md ".\extracted_exports\%%B" 2>nul
    )
    
    REM - Delete the team folder if already present
    if exist ".\extracted_exports\Kit Configs\!teamid!" (
      rd /S /Q ".\extracted_exports\Kit Configs\!teamid!"
    )
    
    REM - Create a folder with the team ID
    md ".\extracted_exports\Kit Configs\!teamid!" 2>nul
    
    
    REM - Prepare the texture filename
    set texname=u0!teamid!
    call .\Engines\CharLib str2hex texname texname_hex
    set texname_hexspc=

    for /l %%C in (0 2 8) do (
      
      if not defined texname_hexspc (
        set texname_hexspc=!texname_hex:~%%C,2!
      ) else (
        set texname_hexspc=!texname_hexspc! !texname_hex:~%%C,2!
      )
    )
    
    REM - For every kit config file
    for /f "tokens=*" %%C in ('dir /b ".\extracted_exports\!foldername!\%%B"') do (
      
      REM - Edit the texture names inside the config file so that they point to the proper textures
      for /l %%O in (0 1 4) do (
      
        REM - First check if the line is empty
        set /a position=40+%%O*16
      
        %macro_Call% ("position position_hex") %macro.Num2Hex%
        
        for /f "tokens=1-2" %%X in ('call .\Engines\hexed ".\extracted_exports\!foldername!\%%B\%%C" -d !position_hex! 1') do (
          set char=%%Y
        )
        
        REM - If the line begins with u write the proper texture name
        if !char!==75 (
        
          .\Engines\hexed ".\extracted_exports\!foldername!\%%B\%%C" -e !position_hex! !texname_hexspc!
        )
      
      )
      
      
      REM - Replace the dummy team ID in the filename with the actual one
      set name=%%C
      set name=!teamid!!name:~3!
      
      rename ".\extracted_exports\!foldername!\%%B\%%C" "!name!"
      
      REM - And move the file
      move ".\extracted_exports\!foldername!\%%B\!name!" ".\extracted_exports\%%B\!teamid!" >nul
    )
    
  )
  
  
  REM - Kit Textures folder
  if /i "%%B"=="Kit Textures" (
  
    set unknown=
    
    REM - Create the main folder if not present
    if not exist ".\extracted_exports\%%B" (
      md ".\extracted_exports\%%B" 2>nul
    )
    
    
    REM - If fox mode is enabled
    if defined fox_mode (
      
      REM - Check if any dds textures exist
      >nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\%%B\*.dds" && (set dds_present=1) || (set dds_present=)
      
      if defined dds_present (
        
        REM - Convert the dds textures to ftex
        call .\Engines\Python\ftex_pack -m ".\extracted_exports\!foldername!\%%B" ".\extracted_exports\!foldername!\%%B"
        
        REM - And delete them
        for /f "tokens=*" %%C in ('dir /b ".\extracted_exports\!foldername!\%%B\*.dds"') do (
          del ".\extracted_exports\!foldername!\%%B\%%C" >nul
        )
      )
      
    )
    
    
    REM - For every kit texture file
    for /f "tokens=*" %%C in ('dir /a:-d /b ".\extracted_exports\!foldername!\%%B" 2^>nul') do (
    
      REM - Replace the dummy team ID in the filename with the actual one
      set name=%%C
      set name=u0!teamid!!name:~5!
      
      rename ".\extracted_exports\!foldername!\%%B\%%C" "!name!"
      
      REM - And move the file
      move ".\extracted_exports\!foldername!\%%B\!name!" ".\extracted_exports\%%B" >nul
    )
    
  )
  
  
  REM - Logo folder
  if /i "%%B"=="Logo" (
  
    set unknown=
    
    REM - Create the main folder if not present
    if not exist ".\extracted_exports\%%B" (
      md ".\extracted_exports\%%B" 2>nul
    )
    
    REM - For every logo file
    for /f "tokens=*" %%C in ('dir /a:-d /b ".\extracted_exports\!foldername!\%%B" 2^>nul') do (
    
      REM - Replace the dummy team ID in the filename with the actual one
      set name=%%C
      set name=emblem_0!teamid!!name:~11!
      
      rename ".\extracted_exports\!foldername!\%%B\%%C" "!name!"
      
      REM - And move the file
      move ".\extracted_exports\!foldername!\%%B\!name!" ".\extracted_exports\%%B" >nul
    )
    
  )
  
  
  REM - Portraits folder
  if /i "%%B"=="Portraits" (
  
    set unknown=
    
    REM - Create the main folder if not present
    if not exist ".\extracted_exports\%%B" (
      md ".\extracted_exports\%%B" 2>nul
    )
    
    REM - For every portrait file
    for /f "tokens=*" %%C in ('dir /a:-d /b ".\extracted_exports\!foldername!\%%B" 2^>nul') do (
    
      REM - Replace the dummy team ID in the filename with the actual one
      set name=%%C
      set name=player_!teamid!!name:~10!
      
      rename ".\extracted_exports\!foldername!\%%B\%%C" "!name!"
      
      REM - And move the file
      move ".\extracted_exports\!foldername!\%%B\!name!" ".\extracted_exports\%%B" >nul
    )
    
  )
  
  
  REM - Boots folder
  if /i "%%B"=="Boots" (
  
    set unknown=
    
    REM - Create the main folder if not present
    if not exist ".\extracted_exports\%%B" (
      md ".\extracted_exports\%%B" 2>nul
    )
    
    REM - For each boots folder
    for /f "tokens=*" %%C in ('dir /a:d /b ".\extracted_exports\!foldername!\%%B" 2^>nul') do (
      
      REM - Delete the folder if already present
      if exist ".\extracted_exports\%%B\%%C" (
        rd /S /Q ".\extracted_exports\%%B\%%C"
      )
      
      REM - And move the folder
      move ".\extracted_exports\!foldername!\%%B\%%C" ".\extracted_exports\%%B" >nul
    )
  
  )
  
  
  REM - Gloves folder
  if /i "%%B"=="Gloves" (
  
    set unknown=
    
    REM - Create the main folder if not present
    if not exist ".\extracted_exports\%%B" (
      md ".\extracted_exports\%%B" 2>nul
    )
    
    REM - For each gloves folder
    for /f "tokens=*" %%C in ('dir /a:d /b ".\extracted_exports\!foldername!\%%B" 2^>nul') do (
      
      REM - Delete the folder if already present
      if exist ".\extracted_exports\%%B\%%C" (
        rd /S /Q ".\extracted_exports\%%B\%%C"
      )
      
      REM - And move the folder
      move ".\extracted_exports\!foldername!\%%B\%%C" ".\extracted_exports\%%B" >nul
    )
    
  )
  
  
  REM - Common folder
  if /i "%%B"=="Common" (
  
    set unknown=
    
    REM - Create the main folder if not present
    if not exist ".\extracted_exports\%%B" (
      md ".\extracted_exports\%%B" 2>nul
    )
    
    REM - First check that it isn't empty
    set movecommon=
    >nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\Common\*" && (set movecommon=1) || (echo ->nul)
  
    if defined movecommon (
    
      REM - Make a team folder with the team name after deleting it if already present
      if exist ".\extracted_exports\%%B\!team_clean!\" (
        rd /S /Q ".\extracted_exports\%%B\!team_clean!"
      )
      md ".\extracted_exports\%%B\!team_clean!" 2>nul
    
      REM - Move everything to that folder
      for /f "tokens=*" %%C in ('dir /a:-d /b ".\extracted_exports\!foldername!\%%B" 2^>nul') do (
        
        move ".\extracted_exports\!foldername!\%%B\%%C" ".\extracted_exports\%%B\!team_clean!" >nul
      )
    )
    
  )
  
  
  REM - Other folder
  if /i "%%B"=="Other" (
  
    set unknown=
    
    REM - Create the main folder if not present
    if not exist ".\extracted_exports\%%B" (
      md ".\extracted_exports\%%B" 2>nul
    )
    
    REM - First check that it isn't empty
    set moveother=
    >nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\Other\*" && (set moveother=1) || (echo ->nul)
  
    if defined moveother (
    
      REM - Make a team folder with the team id and name after deleting it if already present
      if exist ".\extracted_exports\%%B\!teamid! - !team_clean!\" (
        rd /S /Q ".\extracted_exports\%%B\!teamid! - !team_clean!"
      )
      md ".\extracted_exports\%%B\!teamid! - !team_clean!" 2>nul
    
      REM - Move everything to that folder
      for /f "tokens=*" %%C in ('dir /a:-d /b ".\extracted_exports\!foldername!\%%B" 2^>nul') do (
        
        move ".\extracted_exports\!foldername!\%%B\%%C" ".\extracted_exports\%%B\!teamid! - !team_clean!" >nul
      )
    )
    
  )
  
  
  REM - If the folder is out of the AET specifics
  if defined unknown (
    
    REM - Look for it later to avoid the Other folder getting reset
    set unknownexists=1
  )
  
)


REM - If there were any unknown folders
if defined unknownexists (

  REM - Look for it
  for /f "tokens=*" %%B in ('dir /a:d /b ".\extracted_exports\!foldername!" 2^>nul') do (

    set unknown=1
    
    if /i "%%B"=="Faces" set unknown=
    if /i "%%B"=="Kit Configs" set unknown=
    if /i "%%B"=="Kit Textures" set unknown=
    if /i "%%B"=="Logo" set unknown=
    if /i "%%B"=="Portraits" set unknown=
    if /i "%%B"=="Boots" set unknown=
    if /i "%%B"=="Gloves" set unknown=
    if /i "%%B"=="Common" set unknown=
    if /i "%%B"=="Other" set unknown=
    
    REM - If the folder was found
    if defined unknown (
    
      REM - First check that it isn't empty
      set moveother=
      >nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\%%B\*" && (set moveother=1) || (echo ->nul)
    
      if defined moveother (
      
        REM - Make a team folder in Other for the team if none is present
        if not exist ".\extracted_exports\Other\!teamid! - !team_clean!\" (
          md ".\extracted_exports\Other\!teamid! - !team_clean!" 2>nul
        )
        
        REM - Delete the folder if already present
        if exist ".\extracted_exports\Other\!teamid! - !team_clean!\%%B\" (
          rd /S /Q ".\extracted_exports\Other\!teamid! - !team_clean!\%%B"
        )
        
        REM - And move it
        move ".\extracted_exports\!foldername!\%%B" ".\extracted_exports\Other\!teamid! - !team_clean!" >nul
      )
    )
    
  )
)


