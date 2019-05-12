@echo off
REM ^ Don't write everything to screen

REM - Allow modifying named variables inside parentheses
setlocal EnableDelayedExpansion

REM - Set the working folder
cd /D "%~dp0"

REM - Save the current working folder to a string
set working_folder=%~dp0

REM - Load the settings
if exist settings.txt (
  rename settings.txt settings.bat
  call settings
  rename settings.bat settings.txt
) else (
  set move_cpks=1
  set admin_mode=0
  set pause_when_wrong=1
  set full_patch=0
  set pass_through=0
)

REM - If all_in_one mode is enabled
if defined all_in_one (

  if not defined full_patch (
    set full_patch=0
  )

  REM - If Full patch mode is enabled
  if %full_patch%==1 (
    
    REM - Check the existance of the default_contents folder
    if not exist ".\default_contents" (
      
      @echo - 
      @echo - 
      @echo - default_contents folder not found
      @echo - Please get it and and copy it to the script's
      @echo - folder or disable Full Patch mode in the settings
      @echo - 
      @echo - 
      @echo - Do you want to exit or disable Full Patch mode and continue?
      @echo - X^) Exit
      @echo - C^) Continue
      @echo - 
      
      choice /c XC /m "- Choice: " /n
      set choice=!errorlevel!
      
      if "!choice!"=="1" (
        
        EXIT /b
        
      ) else (
      
        REM - Disable Full Patch mode
        set full_patch=0
        
        for /f "tokens=* usebackq" %%R IN (".\settings.txt") do (
          
          set line=%%R
          
          if "!line:~0,14!"=="set full_patch" (
            @echo set full_patch=>> settings_temp.txt
          ) else (
            @echo %%R>> settings_temp.txt
          )
        )
        
        del .\settings.txt
        
        rename .\settings_temp.txt settings.txt
      )
      
    )
  )
  
  REM - If move_cpks mode is enabled
  if %move_cpks%==1 (
  
    REM - Check the PES' download folder
    if not exist %pes_download_folder_location%\ (
      
      @echo - 
      @echo - 
      @echo - PES download folder not found
      @echo - Please set the correct path to it in the settings file
      @echo - The script will restart automatically after you close notepad
      @echo - 
      @echo - 
      pause
      
      notepad .\settings.txt
      
      .\exports_to_extracted
    )
    
    REM - Check if admin mode is needed
    call .\Engines\admin_check
    
    REM - If admin mode is needed or has been forced
    if !admin_mode!==1 (
    
      REM - If permissions haven't been asked yet
      if not defined admin_enabled (
        
        REM - Ask for admin permissions
        .\Engines\admin_request  
      )
    )
  )
)

@echo - 
@echo - Extracting and checking the exports
@echo - 

REM - Create folders just in case
md ".\exports_to_add" 2>nul
md ".\extracted_exports\Faces" 2>nul
md ".\extracted_exports\Kits\Kit Configs" 2>nul
md ".\extracted_exports\Kits\Kit Textures" 2>nul
md ".\extracted_exports\Other\Boots" 2>nul
md ".\extracted_exports\Other\Gloves" 2>nul
md ".\extracted_exports\Other\Other" 2>nul

REM - Clear flags for writing to file
set teamlist=
set memelist=

REM - Reset the files
@echo Team ID > .\Engines\teamlist.txt
@echo --- 4cc AET compiler legacy - List of problems --- > memelist.txt
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
  
  @echo - !team!
  
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
    rd /S /Q ".\extracted_exports\!foldername!" >nul
  )
  
  REM - Make a new folder inside the extracted_exports folder
  md ".\extracted_exports\!foldername!"
  
  
  if defined archive (
  
    REM - If marked as archive, extract the export to that folder
    .\Engines\7z.exe x ".\exports_to_add\%%A" -aoa -o".\extracted_exports\!foldername!" -xr^^!*.db >nul
  
  ) else (
    
    REM - If the export was in a folder just copy it
    robocopy ".\exports_to_add\!foldername!" ".\extracted_exports\!foldername!" /e /is /xf *.db >nul
  )
  
  
  REM - Check the export for every kind of errors
  call .\Engines\export_check
  
  
  REM - If it's fine
  if not defined error (
    
    REM - Copy the contents of the txt file to a common file for quick reading
    @echo . >> teamnotes.txt
    @echo - >> teamnotes.txt
    @echo -- !team!'s notes file - !txtname! >> teamnotes.txt
    @echo -  >> teamnotes.txt
    
    REM - Read and copy line per line
    for /f "tokens=* usebackq" %%R IN (".\extracted_exports\!foldername!\!txtname!") do (
      @echo %%R >> teamnotes.txt
    )
    
    
    REM - If compression is set to 2
    if %compression%==2 (

      REM - Zlib every txture
      call .\Engines\textures_zlib
    )

    
    REM - Move the contents of the export to the root of extracted_exports
    call .\Engines\export_move
    
    
    REM - Delete the now empty export folder
    rd /S /Q ".\extracted_exports\!foldername!"
  )
)



set other=

REM - Check if there are any files in the Other\Other folder
>nul 2>nul dir /a-d /s ".\extracted_exports\Other\Other\*" && (set other=1) || (echo ->nul)


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

REM - If there's something in the Other\Other folder
if defined other (
  set warn=1

  @echo - 
  @echo - There are some files in the extracted_exports\Other\Other folder
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

    @echo - After that you can continue and leave the pc unattended
  
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
  
  .\extracted_to_content
  
)

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
