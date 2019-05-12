@echo off
REM ^ Don't write everything to screen

REM - Allow modifying named variables inside parentheses
setlocal EnableDelayedExpansion

REM - Set the working folder
cd /D "%~dp0"

REM - Load the settings
call .\Engines\settings_init

REM - Set all_in_one mode
set all_in_one=1


REM - If move_cpks mode is enabled
if %move_cpks%==1 (

  REM - Check the PES download folder
  if not exist %pes_download_folder_location%\ (
    
    @echo - 
    @echo - 
    @echo - PES download folder not found.
    @echo - Please set its correct path in the settings file.
    @echo - The script will restart automatically after you close notepad.
    @echo - 
    @echo - 
    pause
    
    notepad .\settings.txt
    
    .\0_all_in_one
    
  ) else (
  
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
@echo - 
@echo - 4cc aet compiler - All-in-one mode
@echo - 
@echo - 

REM - Invoke the export extractor
call .\1_exports_to_extracted

REM - Invoke the contents packer
call .\2_extracted_to_contents

REM - Invoke the cpk packer
call .\3_contents_to_patches
