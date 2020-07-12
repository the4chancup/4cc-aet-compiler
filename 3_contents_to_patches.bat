@echo off
REM ^ Don't write everything to screen

if not defined all_in_one (
  
  REM - Allow reading variables modified inside statements
  setlocal EnableDelayedExpansion
  
  REM - Set the working folder
  cd /D "%~dp0"
  
  REM - Load the settings
  call .\Engines\settings_init

  REM - Check if python is installed and was added to the PATH
  call .\Engines\python_check
)


REM - Prepare the arguments for the cpk packer
if %compression%==1 (
  set cpkmaker_args=-align=2048 -mode=FILENAME -mask -forcecompress
) else (
  set cpkmaker_args=-align=2048 -mode=FILENAME -mask
)

REM - Create folders just in case
md ".\patches_output" 2>nul

if %multicpk_mode%==1 (

  set faces_foldername=Facescpk
  set uniform_foldername=Uniformcpk
  set bins_foldername=Binscpk

  md ".\patches_contents\%faces_foldername%" 2>nul
  md ".\patches_contents\%uniform_foldername%" 2>nul
  md ".\patches_contents\%bins_foldername%" 2>nul

)

if %multicpk_mode%==0 (
  md ".\patches_contents\Singlecpk" 2>nul
)


REM - Unless all_in_one mode is enabled
if not defined all_in_one (
  
  REM - If move_cpks mode is enabled
  if %move_cpks%==1 (
  
    REM - Check the PES download folder
    if not exist %pes_download_folder_location%\ (
      
      echo - 
      echo - 
      echo - PES download folder not found.
      echo - Please set its correct path in the settings file.
      echo - The script will restart automatically after you close notepad.
      echo - 
      echo - 
      pause
      
      notepad .\settings.txt
      
      .\3_content_to_patches
      
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
)


REM - Make the patches
if %multicpk_mode%==1 (
  
  REM - Make sure that the folders are not empty to avoid cpkmakec errors
  >nul 2>nul dir /a-d /s ".\patches_contents\%faces_foldername%\*" && (echo ->nul) || (type nul >".\patches_contents\%faces_foldername%\placeholder")
  >nul 2>nul dir /a-d /s ".\patches_contents\%uniform_foldername%\*" && (echo ->nul) || (type nul >".\patches_contents\%uniform_foldername%\placeholder")
  if %bins_updating%==1 (
    >nul 2>nul dir /a-d /s ".\patches_contents\%bins_foldername%\*" && (echo ->nul) || (type nul >".\patches_contents\%bins_foldername%\placeholder")
  )


  REM - Make the Faces patch (faces, portraits)
  echo - 
  echo - Packing the Faces patch

  .\Engines\CpkMaker\cpkmakec ".\patches_contents\%faces_foldername%" ".\patches_output\%faces_cpk_name%.cpk" %cpkmaker_args%
  
  
  REM - Make the Uniform patch (kits, logos, boots, gloves, etc.)
  echo - 
  echo - Packing the Uniform patch

  .\Engines\CpkMaker\cpkmakec ".\patches_contents\%uniform_foldername%" ".\patches_output\%uniform_cpk_name%.cpk" %cpkmaker_args%
  
  
  if %bins_updating%==1 (
  
    REM - Make the Bins patch (unicolor, teamcolor)
    echo - 
    echo - Packing the Bins patch

    .\Engines\CpkMaker\cpkmakec ".\patches_contents\%bins_foldername%" ".\patches_output\%bins_cpk_name%.cpk" %cpkmaker_args%
    
  )
  
)

if %multicpk_mode%==0 (

  REM - Make sure that the folder is not empty to avoid cpkmakec errors
  >nul 2>nul dir /a-d /s ".\patches_contents\Singlecpk\*" && (echo ->nul) || (type nul >".\patches_contents\Singlecpk\placeholder")


  REM - Make the single cpk patch
  echo - 
  echo - Packing the patch

  .\Engines\CpkMaker\cpkmakec ".\patches_contents\Singlecpk" ".\patches_output\%cpk_name%.cpk" %cpkmaker_args%
  
)

del cpkmaker.out.csv 2>nul


REM - If Move Cpks mode is enabled
if %move_cpks%==1 (

  echo -
  echo - Move Cpks mode is enabled
  echo -
  echo - Moving the cpks to the download folder
  echo -

  if %multicpk_mode%==1 (

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
    move ".\patches_output\%faces_cpk_name%.cpk" %pes_download_folder_location% >nul
    move ".\patches_output\%uniform_cpk_name%.cpk" %pes_download_folder_location% >nul
    if %bins_updating%==1 (
      move ".\patches_output\%bins_cpk_name%.cpk" %pes_download_folder_location% >nul
    )
    
  )

  if %multicpk_mode%==0 (

    REM - Remove the cpk from the destination folder if present
    if exist %pes_download_folder_location%\"%cpk_name%.cpk" (
      del %pes_download_folder_location%\"%cpk_name%.cpk"
    )

    REM - Move the cpk to the destination folder
    move ".\patches_output\%cpk_name%.cpk" %pes_download_folder_location% >nul

  )
  
  
  REM - If DpFileList Updating is enabled
  if %dpfl_updating%==1 (
  
    echo -
    echo - DpFileList editing is enabled
    echo -
    
    REM - Get a temporary copy of the dpfl from the downloads folder
    copy %pes_download_folder_location%\DpFileList.bin .\Engines >nul
    
    REM - Update it
    if %multicpk_mode%==1 (
      
      if %bins_updating%==1 (
        set cpk_name=%bins_cpk_name%
        call .\Engines\dpfl_update
      )
      
      set cpk_name=%faces_cpk_name%
      call .\Engines\dpfl_update
      
      set cpk_name=%uniform_cpk_name%
      call .\Engines\dpfl_update
      
    )
    
    if %multicpk_mode%==0 (
      call .\Engines\dpfl_update
    )
    
    REM - And copy it back
    copy .\Engines\DpFileList.bin %pes_download_folder_location% >nul
    
    del .\Engines\DpFileList.bin
    
  )
  
)


echo -
echo -
echo - The patches have been created
echo -
echo - 4cc aet compiler by Shakes
echo -
echo -


if defined all_in_one (

  REM - Reset the all_in_one mode flag
  set all_in_one=
  
)

pause

