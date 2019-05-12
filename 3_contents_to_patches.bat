@echo off
REM ^ Don't write everything to screen

REM - Allow modifying named variables inside parentheses
setlocal EnableDelayedExpansion

REM - Set the working folder
cd /D "%~dp0"

REM - Load the settings
if exist settings.txt (
  rename settings.txt settings.cmd
  call settings
  rename settings.cmd settings.txt
) else (
  set multicpk_mode=0
  set cpk_name=4cc_80_testpatch
  set move_cpks=1
  set pes_download_folder_location="C:\Program Files (x86)\Pro Evolution Soccer 2016\download"
  set admin_mode=0
  set dpfl_updating=1
)

REM - Create folders just in case
if not %multicpk_mode%==0 (

  set faces_foldername=Facescpk
  set uniform_foldername=Uniformcpk
  set bins_foldername=Binscpk

  md ".\patches_contents\%faces_foldername%" 2>nul
  md ".\patches_contents\%uniform_foldername%" 2>nul
  md ".\patches_contents\%bins_foldername%" 2>nul

) else (
  
  md ".\patches_contents\Singlecpk" 2>nul
)

REM - If Move Cpks mode is disabled set the output folder
if %move_cpks%==0 (
  
  set pes_download_folder_location=".\patches_output"
  
  md !pes_download_folder_location! 2>nul

)


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
      
      .\3_content_to_patches
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


if not %multicpk_mode%==0 (
  
  REM - Make sure that the folders are not empty to avoid cpkmakec errors
  >nul 2>nul dir /a-d /s ".\patches_contents\%faces_foldername%\*" && (echo ->nul) || (type nul >".\patches_contents\%faces_foldername%\placeholder")
  >nul 2>nul dir /a-d /s ".\patches_contents\%uniform_foldername%\*" && (echo ->nul) || (type nul >".\patches_contents\%uniform_foldername%\placeholder")
  if %bins_updating%==1 (
    >nul 2>nul dir /a-d /s ".\patches_contents\%bins_foldername%\*" && (echo ->nul) || (type nul >".\patches_contents\%bins_foldername%\placeholder")
  )


  REM - Make the Faces patch
  @echo - Making the Faces patch

  if %compression%==1 (
    .\Engines\cpkmakec ".\patches_contents\%faces_foldername%" "%faces_cpk_name%.cpk" -align=2048 -mode=FILENAME -mask -forcecompress
  ) else (
    .\Engines\cpkmakec ".\patches_contents\%faces_foldername%" "%faces_cpk_name%.cpk" -align=2048 -mode=FILENAME -mask
  )

  REM - Make the Uniform patch (kits, logos, portraits, boots, gloves, etc.)
  @echo - 
  @echo - Making the Uniform patch

  if %compression%==1 (
    .\Engines\cpkmakec ".\patches_contents\%uniform_foldername%" "%uniform_cpk_name%.cpk" -align=2048 -mode=FILENAME -mask -forcecompress
  ) else (
    .\Engines\cpkmakec ".\patches_contents\%uniform_foldername%" "%uniform_cpk_name%.cpk" -align=2048 -mode=FILENAME -mask
  )
  
  if %bins_updating%==1 (
  
    REM - Make the Bins patch (unicolor, teamcolor)
    @echo - 
    @echo - Making the Bins patch

    if %compression%==1 (
      .\Engines\cpkmakec ".\patches_contents\%bins_foldername%" "%bins_cpk_name%.cpk" -align=2048 -mode=FILENAME -mask -forcecompress
    ) else (
      .\Engines\cpkmakec ".\patches_contents\%bins_foldername%" "%bins_cpk_name%.cpk" -align=2048 -mode=FILENAME -mask
    )
  
  )
  
) else (

  REM - Make sure that the folder is not empty to avoid cpkmakec errors
  >nul 2>nul dir /a-d /s ".\patches_contents\Singlecpk\*" && (echo ->nul) || (type nul >".\patches_contents\Singlecpk\placeholder")


  REM - Make the single cpk patch
  @echo - Making the patch

  if %compression%==1 (
    .\Engines\cpkmakec ".\patches_contents\Singlecpk" "%cpk_name%.cpk" -align=2048 -mode=FILENAME -mask -forcecompress
  ) else (
    .\Engines\cpkmakec ".\patches_contents\Singlecpk" "%cpk_name%.cpk" -align=2048 -mode=FILENAME -mask
  )

)

del cpkmaker.out.csv 2>nul


REM - If Move Cpks mode is enabled
if %move_cpks%==1 (

  @echo -
  @echo - Move Cpks mode is enabled
  @echo -
  @echo - Moving the cpks to the download folder
  @echo -

)


if not %multicpk_mode%==0 (

  REM - Remove the cpks from the destination folder if present
  if exist %pes_download_folder_location%\"%faces_cpk_name%.cpk" (
    del %pes_download_folder_location%\"%faces_cpk_name%.cpk"
  )
  if exist %pes_download_folder_location%\"%uniform_cpk_name%.cpk" (
    del %pes_download_folder_location%\"%uniform_cpk_name%.cpk"
  )
  if %bins_updating%==1 (
    if exist %pes_download_folder_location%\"%bins_cpk_name%.cpk" (
      del %pes_download_folder_location%\"%bins_cpk_name%.cpk"
    )
  )
  
  REM - Move the cpks to the destination folder
  move ".\%faces_cpk_name%.cpk" %pes_download_folder_location% >nul
  move ".\%uniform_cpk_name%.cpk" %pes_download_folder_location% >nul
  if %bins_updating%==1 (
    move ".\%bins_cpk_name%.cpk" %pes_download_folder_location% >nul
  )
  
) else (

  REM - Remove the cpk from the destination folder if present
  if exist %pes_download_folder_location%\"%cpk_name%.cpk" (
    del %pes_download_folder_location%\"%cpk_name%.cpk"
  )

  REM - Move the cpk to the destination folder
  move ".\%cpk_name%.cpk" %pes_download_folder_location% >nul

)


REM - If Move Cpks mode is enabled
if %move_cpks%==1 (
  
  REM - If DpFileList Updating is enabled
  if %dpfl_updating%==1 (
  
    @echo -
    @echo - DpFileList editing is enabled
    @echo -
    
    REM - Get a temporary copy of the dpfl from the downloads folder
    copy %pes_download_folder_location%\DpFileList.bin .\Engines >nul
    
    
    REM - Update it
    if not %multicpk_mode%==0 (
      
      if %bins_updating%==1 (
        set cpk_name=%bins_cpk_name%
        call .\Engines\dpfl_update
      )
      
      set cpk_name=%faces_cpk_name%
      call .\Engines\dpfl_update
      
      set cpk_name=%uniform_cpk_name%
      call .\Engines\dpfl_update
      
    ) else (
    
      call .\Engines\dpfl_update
    )

    
    REM - And copy it back
    copy .\Engines\DpFileList.bin %pes_download_folder_location% >nul
    
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
