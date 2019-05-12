@echo off
REM ^ Don't write everything to screen

REM - Allow modifying named variables inside parentheses
setlocal EnableDelayedExpansion

REM - Set the working folder
cd /D "%~dp0"

REM - Load the settings
if exist settings.txt (
  rename settings.txt settings.bat
  call settings
  rename settings.bat settings.txt
) else (
  set cpk_name=test
  set move_cpks=1
  set pes_download_folder_location="C:\Program Files (x86)\Pro Evolution Soccer 2016\download"
  set admin_mode=0
  set dpfl_updating=1
)

REM - Create folders just in case
md ".\patches_contents\Faces" 2>nul
md ".\patches_contents\Uniform" 2>nul

REM - Unless all_in_one mode is enabled
if not defined all_in_one (
  
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
      
      .\content_to_patches
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
@echo - Packing the patches
@echo - 


REM - Make sure that the folders are not empty to avoid cpkmakec errors
>nul 2>nul dir /a-d /s ".\patches_contents\Faces\*" && (echo ->nul) || (type nul >".\patches_contents\Faces\placeholder")
>nul 2>nul dir /a-d /s ".\patches_contents\Uniform\*" && (echo ->nul) || (type nul >".\patches_contents\Uniform\placeholder")


REM - Make the Faces patch
@echo - Making the Faces patch

if %compression%==1 (
  .\Engines\cpkmakec ".\patches_contents\Faces" "%cpk_name%_faces.cpk" -align=2048 -mode=FILENAME -mask -forcecompress
) else (
  .\Engines\cpkmakec ".\patches_contents\Faces" "%cpk_name%_faces.cpk" -align=2048 -mode=FILENAME -mask
)

REM - Make the Uniform patch (kits, boots, gloves, etc.)
@echo - 
@echo - Making the Uniform patch

if %compression%==1 (
  .\Engines\cpkmakec ".\patches_contents\Uniform" "%cpk_name%_uniform.cpk" -align=2048 -mode=FILENAME -mask -forcecompress
) else (
  .\Engines\cpkmakec ".\patches_contents\Uniform" "%cpk_name%_uniform.cpk" -align=2048 -mode=FILENAME -mask
)


del cpkmaker.out.csv 2>nul


REM - If Move Cpks mode is enabled
if %move_cpks%==1 (

  @echo -
  @echo - Move Cpks mode is enabled
  @echo -
  @echo - Moving the cpks
  @echo -

  REM - Copy the cpks to the PES' download folder
  copy ".\%cpk_name%_faces.cpk" %pes_download_folder_location% >nul
  copy ".\%cpk_name%_uniform.cpk" %pes_download_folder_location% >nul

  REM - Delete the cpks in the script's folder
  del ".\%cpk_name%_faces.cpk"
  del ".\%cpk_name%_uniform.cpk"
  
  
  REM - If DpFileList Updating is enabled
  if %dpfl_updating%==1 (
    
    REM - Get a temporary copy of the dpfl from the downloads folder
    copy %pes_download_folder_location%\DpFileList.bin .\Engines >nul
    
    REM - Update it
    call .\Engines\dpfl_update
    
    REM - And copy it back if it was edited
    if not errorlevel 1 (
      copy .\Engines\DpFileList.bin %pes_download_folder_location% >nul
    )
    del .\Engines\DpFileList.bin
  )
)


@echo -
@echo -
@echo - The patches have been created
@echo -
@echo - 4cc aet compiler by Shakes
@echo -
@echo -

if defined all_in_one (
  REM - Reset the all_in_one mode flag
  set all_in_one=
  
  pause
  
) else (
  timeout /t 5
)
