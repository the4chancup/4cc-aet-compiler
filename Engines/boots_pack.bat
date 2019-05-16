setlocal EnableDelayedExpansion


if %fox_mode%==0 (

  REM - PES 16/17 mode
  
  REM - Create a "boots" folder if needed
  if not exist ".\patches_contents\%uniform_foldername%\common\character0\model\character\boots" (
    md ".\patches_contents\%uniform_foldername%\common\character0\model\character\boots" 2>nul
  )
  
  REM - Move the boots to the Uniform cpk folder
  for /f %%A in ('dir /b ".\extracted_exports\Boots" 2^>nul') do (
    
    if exist ".\patches_contents\%uniform_foldername%\common\character0\model\character\boots\%%A" (
      rd /S /Q ".\patches_contents\%uniform_foldername%\common\character0\model\character\boots\%%A"
    )
    
    move ".\extracted_exports\Boots\%%A" ".\patches_contents\%uniform_foldername%\common\character0\model\character\boots" >nul
  )
  
  
) else (
  
  REM - PES 18/19 mode
  
  REM - Create a "boots" folder if needed
  if not exist ".\patches_contents\%faces_foldername%\Asset\model\character\boots" (
    md ".\patches_contents\%faces_foldername%\Asset\model\character\boots" 2>nul
  )
  
  
  REM - For every boots folder
  for /f "tokens=*" %%A in ('dir /a:d /b ".\extracted_exports\Boots" 2^>nul') do (
    
    set object_type=boots
    set object_folder=boots
    set object_name=%%A
    set object_id=!object_name:~0,5!
    @echo - !object_name!
    
    
    if !object_type!==face (
      REM - Rename it to the id
      rename ".\extracted_exports\Boots\!object_name!" "!object_id!" >nul
    )
    
    REM - Delete the old boots folder if present
    if exist ".\patches_contents\%faces_foldername%\Asset\model\character\!object_folder!\!object_id!" (
      rd /S /Q ".\patches_contents\%faces_foldername%\Asset\model\character\!object_folder!\!object_id!" >nul
    )
    
    REM - Make a temp folder
    md ".\temp\!object_id!\#windx11"
    
    REM - Move the folder to the temp folder
    move ".\extracted_exports\Boots\!object_id!" ".\temp\!object_id!" >nul
    
    REM - Move the textures to a separate folder
    for /f "tokens=*" %%A in ('dir /b .\temp\!object_id!\!object_id!\*.ftex') do (
      set object_tex_name=%%A
      move ".\temp\!object_id!\!object_id!\!object_tex_name!" ".\temp\!object_id!\#windx11" >nul
    )
    
    REM - Move the xml
    move ".\temp\!object_id!\!object_id!\!object_type!.fpk.xml" ".\temp\!object_id!" >nul
    
    REM - Rename the folder for packing
    rename ".\temp\!object_id!\!object_id!" "!object_type!_fpk" >nul
    
    REM - Pack the fpk
    .\Engines\GzsTool\GzsTool.exe ".\temp\!object_id!\!object_type!.fpk.xml"
    
    REM - Make the final folder structure
    md ".\patches_contents\%faces_foldername%\Asset\model\character\!object_folder!\!object_id!\#Win" 2>nul
    
    REM - Move the fpk to the contents folder
    move ".\temp\!object_id!\!object_type!.fpk" ".\patches_contents\%faces_foldername%\Asset\model\character\!object_folder!\!object_id!\#Win" >nul
    
    REM - Copy the generic fpkd to the same folder and rename it
    copy ".\Engines\generic.fpkd" ".\patches_contents\%faces_foldername%\Asset\model\character\!object_folder!\!object_id!\#Win" >nul
    rename ".\patches_contents\%faces_foldername%\Asset\model\character\!object_folder!\!object_id!\#Win\generic.fpkd" "!object_type!.fpkd" >nul
    
    REM - Move the textures
    if !object_type!==face (
    
      md ".\patches_contents\%faces_foldername%\Asset\model\character\!object_folder!\!object_id!\sourceimages" 2>nul
      move ".\temp\!object_id!\#windx11" ".\patches_contents\%faces_foldername%\Asset\model\character\!object_folder!\!object_id!\sourceimages" >nul
      
    ) else (
    
      move ".\temp\!object_id!\#windx11" ".\patches_contents\%faces_foldername%\Asset\model\character\!object_folder!\!object_id!" >nul
    
    )
    
    rd /S /Q ".\temp\!object_id!" >nul
    
  )
  
)


REM - Finally delete the main folder and temp folder
rd /S /Q ".\extracted_exports\Boots" >nul
rd /S /Q ".\temp" >nul

