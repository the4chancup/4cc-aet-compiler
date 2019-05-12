REM - Edit and move the contents of the export to the root of extracted_exports
@echo off
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
    
    REM - For each face folder
    for /f "tokens=*" %%C in ('dir /a:d /b ".\extracted_exports\!foldername!\%%B" 2^>nul') do (
    
      REM - Replace the dummy team ID with the actual one
      set name=%%C
      set name=!teamid!!name:~3!
      
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
    
    REM - Delete the folder if already present
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
      
      set name=%%C
      
      REM - Edit the texture names inside the config file so that they point to the proper textures
      for /l %%O in (0 1 4) do (
      
        REM - First check if the line is empty
        set /a position=40+%%O*16
      
        %macro_Call% ("position position_hex") %macro.Num2Hex%
        
        for /f "tokens=1-2" %%X in ('call .\Engines\hexed ".\extracted_exports\!foldername!\%%B\%%C" -d !position_hex! 1') do (
          set char=%%Y
        )
        
        REM - If the line is not empty write the proper texture name
        if not !char!==00 (
        
          .\Engines\hexed ".\extracted_exports\!foldername!\%%B\%%C" -e !position_hex! !texname_hexspc!
        )
      
      )
      
      
      REM - Replace the dummy team ID with the actual one
      set name=%%C
      set name=!teamid!!name:~3!
      
      rename ".\extracted_exports\!foldername!\%%B\%%C" "!name!"
      
      REM - And move the kit config file
      move ".\extracted_exports\!foldername!\%%B\!name!" ".\extracted_exports\%%B\!teamid!" >nul
    )
    
  )
  
  
  REM - Kit Textures folder
  if /i "%%B"=="Kit Textures" (
  
    set unknown=
    
    REM - For every kit texture file
    for /f "tokens=*" %%C in ('dir /a:-d /b ".\extracted_exports\!foldername!\%%B" 2^>nul') do (
    
      REM - Replace the dummy team ID with the actual one
      set name=%%C
      set name=u0!teamid!!name:~5!
      
      rename ".\extracted_exports\!foldername!\%%B\%%C" "!name!"
      
      REM - And move the kit texture file
      move ".\extracted_exports\!foldername!\%%B\!name!" ".\extracted_exports\%%B" >nul
    )
    
  )
  
  
  REM - Logo folder
  if /i "%%B"=="Logo" (
  
    set unknown=
    
    REM - For every logo file
    for /f "tokens=*" %%C in ('dir /a:-d /b ".\extracted_exports\!foldername!\%%B" 2^>nul') do (
    
      REM - Replace the dummy team ID with the actual one
      set name=%%C
      set name=emblem_0!teamid!!name:~11!
      
      rename ".\extracted_exports\!foldername!\%%B\%%C" "!name!"
      
      REM - And move the kit texture file
      move ".\extracted_exports\!foldername!\%%B\!name!" ".\extracted_exports\%%B" >nul
    )
    
  )
  
  
  REM - Portraits folder
  if /i "%%B"=="Portraits" (
  
    set unknown=
    
    REM - For every portrait file
    for /f "tokens=*" %%C in ('dir /a:-d /b ".\extracted_exports\!foldername!\%%B" 2^>nul') do (
    
      REM - Replace the dummy team ID with the actual one
      set name=%%C
      set name=player_!teamid!!name:~10!
      
      rename ".\extracted_exports\!foldername!\%%B\%%C" "!name!"
      
      REM - And move the kit texture file
      move ".\extracted_exports\!foldername!\%%B\!name!" ".\extracted_exports\%%B" >nul
    )
    
  )
  
  
  REM - Boots folder
  if /i "%%B"=="Boots" (
  
    set unknown=
    
    REM - For each boots folder
    for /f "tokens=*" %%C in ('dir /a:d /b ".\extracted_exports\!foldername!\%%B" 2^>nul') do (
      
      REM - Delete the folder if already present
      if exist ".\extracted_exports\%%B\%%C" (
        rd /S /Q ".\extracted_exports\%%B\%%C"
      )
      
      REM - And move the boots folder
      move ".\extracted_exports\!foldername!\%%B\%%C" ".\extracted_exports\%%B" >nul
    )
  
  )
  
  
  REM - Gloves folder
  if /i "%%B"=="Gloves" (
  
    set unknown=
    
    REM - For each gloves folder
    for /f "tokens=*" %%C in ('dir /a:d /b ".\extracted_exports\!foldername!\%%B" 2^>nul') do (
      
      REM - Delete the folder if already present
      if exist ".\extracted_exports\%%B\%%C" (
        rd /S /Q ".\extracted_exports\%%B\%%C"
      )
      
      REM - And move the gloves folder
      move ".\extracted_exports\!foldername!\%%B\%%C" ".\extracted_exports\%%B" >nul
    )
    
  )
  
  
  REM - Other folder
  if /i "%%B"=="Other" (
  
    set unknown=
    
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