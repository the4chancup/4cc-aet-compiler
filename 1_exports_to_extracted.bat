@echo off
REM ^ Don't write everything to screen

if not defined all_in_one (

  REM - Allow modifying named variables inside parentheses
  setlocal EnableDelayedExpansion

  REM - Set the working folder
  cd /D "%~dp0"
  
  REM - Load the settings
  call .\Engines\settings_init
)

REM - Save the current working folder to a string
set script_folder=%~dp0


@echo - 
@echo - Extracting and checking the exports
@echo - 

REM - Create folders just in case
md ".\exports_to_add" 2>nul
md ".\extracted_exports" 2>nul

REM - Clear the flag for writing to file
set memelist=

REM - Reset the files
@echo --- 4cc AET compiler id-less - List of problems --- > memelist.txt
@echo --- 4cc txt notes compilation --- > teamnotes.txt

@echo - 
@echo - Working on team:

REM - For every export
for /f "tokens=*" %%A in ('dir /b ".\exports_to_add"') do (
  
  REM - Reset the flags for marking as archive or folder
  set archive=
  set foldername=%%A
  
  REM - Get the team's name
  for /f "delims=+-_.:,;* " %%Z in ("%%A") do set team=%%Z
  
  REM - Convert it to full lowercase
  for %%T in ("!team!") do (
    for /f "delims=~" %%U in ('echo %%T^> ~%%T ^& dir /L /B ~%%T') do (
      set team=%%U
      del /Q ~%%T
    )
  )
  
  set team_clean=!team!
  
  REM - Add slashes (or brackets)
  if not "!team!"=="s4s" (
    set team=/!team!/
  ) else (
    set team=[!team!]
  )
  
  <nul set /p =- !team! 
  
  REM - Look for a dot near the end of the name
  REM - If there's a dot, mark as archive and remove the extension
  if "!foldername:~-3,1!"=="." (
    set archive=1
    set foldername=!foldername:~0,-3!
  ) else (
    if "!foldername:~-4,1!"=="." (
      set archive=1
      set foldername=!foldername:~0,-4!
    )
  )
  
  REM - Delete the old export folder if present
  if exist ".\extracted_exports\!foldername!" (
    rd /S /Q ".\extracted_exports\!foldername!"
  )
  
  REM - Make a new folder inside the extracted_exports folder
  md ".\extracted_exports\!foldername!"
  
  
  if defined archive (
  
    REM - If marked as archive, extract the export to that folder
    .\Engines\7z.exe x ".\exports_to_add\%%A" -aoa -o".\extracted_exports\!foldername!" -xr^^!*.db -xr^^!*.ini >nul
  
  ) else (
    
    REM - If the export was in a folder just copy it
    robocopy ".\exports_to_add\!foldername!" ".\extracted_exports\!foldername!" /e /is /xf *.db *.ini >nul
  )
  
  
  REM - Check the export for every kind of errors
  call .\Engines\export_check
  
  
  REM - If it's fine
  if not defined error (
    
    REM - Copy the contents of the txt file to a common file for quick reading
    @echo . >> teamnotes.txt
    @echo - >> teamnotes.txt
    @echo -- !team!'s note file - !txtname! >> teamnotes.txt
    @echo -  >> teamnotes.txt
    
    REM - Read and copy line per line
    for /f "tokens=* usebackq" %%R IN (".\extracted_exports\!foldername!\!txtname!") do (
      @echo %%R >> teamnotes.txt
    )
    
    
    REM - If compression is set to 2
    if %compression%==2 (
      
      if not defined fox_mode (
      
        REM - Zlib every texture
        call .\Engines\textures_zlib
        
      )
    )
    
    
    REM - Move the contents of the export to the root of extracted_exports
    call .\Engines\export_move
    
    
    REM - Delete the now empty export folder
    rd /S /Q ".\extracted_exports\!foldername!" >nul
  )
)

if exist ".\Engines\stored_zlibbed" (
  rd /S /Q ".\Engines\stored_zlibbed" >nul
)


set other=

REM - Check if there are any files in the Other folder
>nul 2>nul dir /a-d /s ".\extracted_exports\Other\*" && (set other=1) || (echo ->nul)


REM - Delete the memelist if everything went fine
if not defined memelist (
  
  del memelist.txt

) else (
  @echo - >> memelist.txt
  @echo - >> memelist.txt
)


set pause=

@echo - 
@echo - 
@echo - All the exports have been extracted and checked


if defined memelist (
  set warn=1
  @echo - (Some problems were found, check the memelist.txt file for details^)
  
)

REM - If there's something in the Other folder
if defined other (
  set warn=1

  @echo - 
  @echo - There are some files in the extracted_exports\Other folder
  @echo - 
  @echo - Please open it and check its contents, unless you have already done
  @echo - this previously for these exports
  @echo - 
)

if not defined warn (
  @echo - No problems were found
)

REM - If all_in_one mode is enabled invoke the next part of the process
if defined all_in_one (

  if defined warn (

    if defined other (
      @echo - After that you can continue and leave the pc unattended
    )
  
    if not %pause_when_wrong%==0 (
      pause
    ) else (
      @echo - Pause mode has been disabled
      @echo - If you need to pause this countdown press Ctrl-C
      @echo - You can then resume the script by pressing N, then Enter
      timeout /t 20
    )
  
  ) else (
    timeout /t 5
  )
  
  
) else (

  @echo - 
  @echo - 
  @echo - 4cc aet compiler by Shakes
  @echo - 
  @echo - 

  if defined warn (
    
    timeout /t 30
    
  ) else (
    
    timeout /t 20
  )

)

