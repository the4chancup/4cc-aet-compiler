setlocal EnableDelayedExpansion

set object_type=%1
set object_source_folder=%2
set object_destination_folder=%3


if %fox_mode%==0 (

  REM - PES 16/17 mode
  
  REM - Set the destination path
  set "object_destination_path=patches_contents\%uniform_foldername%\common\character0\model\character\!object_destination_folder!"

  REM - Create a destination folder if needed
  if not exist ".\!object_destination_path!" (
    md ".\!object_destination_path!" 2>nul
  )
  
  REM - For every folder
  for /f %%A in ('dir /b ".\extracted_exports\!object_source_folder!" 2^>nul') do (
    
    set object_name=%%A
    
    if !object_type!==gloves (
       if %fox_19%==0 (
          set object_id=!object_name:~0,4!
       ) else (
         set object_id=!object_name:~0,5!
       )
    ) else (
      set object_id=!object_name:~0,5!
    )
    
    echo - !object_name!
    
    REM - Rename it with the proper id
    rename ".\extracted_exports\!object_source_folder!\%%A" "!object_id!" >nul
    
    REM - Delete the old folder if present
    if exist ".\!object_destination_path!\!object_id!" (
      rd /S /Q ".\!object_destination_path!\!object_id!"
    )

    REM - Move the folder
    move ".\extracted_exports\!object_source_folder!\!object_id!" ".\!object_destination_path!" >nul
  )
  
  
) else (
  
  REM - PES 18/19 mode

  REM - Set the destination path
  set "object_destination_path=patches_contents\%faces_foldername%\Asset\model\character\!object_destination_folder!"

  REM - Create a destination folder if needed
  if not exist ".\!object_destination_path!" (
    md ".\!object_destination_path!" 2>nul
  )
  
  REM - For every folder
  for /f "tokens=*" %%A in ('dir /a:d /b ".\extracted_exports\!object_source_folder!" 2^>nul') do (
    
    set object_name=%%A
    
    if !object_type!==gloves (
       if %fox_19%==0 (
          set object_id=!object_name:~0,4!
       ) else (
         set object_id=!object_name:~0,5!
       )
    ) else (
      set object_id=!object_name:~0,5!
    )
    
    echo - !object_name!
    
    
    REM - Rename it to the id
    rename ".\extracted_exports\!object_source_folder!\!object_name!" "!object_id!" >nul
    
    REM - Delete the old folder if present
    if exist ".\!object_destination_path!\!object_id!" (
      rd /S /Q ".\!object_destination_path!\!object_id!" >nul
    )
    
    REM - Make a temp folder
    md ".\temp\!object_id!\#windx11"
    
    REM - Move the folder to the temp folder
    move ".\extracted_exports\!object_source_folder!\!object_id!" ".\temp\!object_id!" >nul
    
    REM - Move the textures to a separate folder
    move ".\temp\!object_id!\!object_id!\*.ftex" ".\temp\!object_id!\#windx11" >nul
    
    REM - Move the xml
    move ".\temp\!object_id!\!object_id!\!object_type!.fpk.xml" ".\temp\!object_id!" >nul
    
    REM - Rename the folder for packing
    rename ".\temp\!object_id!\!object_id!" "!object_type!_fpk" >nul
    
    REM - Pack the fpk
    .\Engines\GzsTool\GzsTool.exe ".\temp\!object_id!\!object_type!.fpk.xml"
    
    REM - Make the final folder structure
    md ".\!object_destination_path!\!object_id!\#Win" 2>nul
    
    REM - Move the fpk to the contents folder
    move ".\temp\!object_id!\!object_type!.fpk" ".\!object_destination_path!\!object_id!\#Win" >nul
    
    REM - Copy the generic fpkd to the same folder and rename it
    copy ".\Engines\generic.fpkd" ".\!object_destination_path!\!object_id!\#Win" >nul
    rename ".\!object_destination_path!\!object_id!\#Win\generic.fpkd" "!object_type!.fpkd" >nul
    
    REM - Move the textures
    if !object_type!==face (
      
      md ".\!object_destination_path!\!object_id!\sourceimages" 2>nul
      move ".\temp\!object_id!\#windx11" ".\!object_destination_path!\!object_id!\sourceimages" >nul
      
    ) else (
    
      move ".\temp\!object_id!\#windx11" ".\!object_destination_path!\!object_id!" >nul
    
    )
    
    REM - Delete the temp folder
    rd /S /Q ".\temp\!object_id!" >nul
    
  )
  
)


REM - Finally delete the source folder and temp folder
rd /S /Q ".\extracted_exports\!object_source_folder!" >nul
rd /S /Q ".\temp" >nul

