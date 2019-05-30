setlocal EnableDelayedExpansion


REM - Prepare the arguments for the cpk packer
if %compression%==1 (
  set cpkmaker_args=-align=2048 -mode=FILENAME -mask -forcecompress
) else (
  set cpkmaker_args=-align=2048 -mode=FILENAME -mask
)

rem rem Get the face folders loop out of the check, share more stuff

if %fox_mode%==0 (
  
  REM - PES 16/17 mode
  
  REM - Create a "real" folder if needed
  if not exist ".\patches_contents\%faces_foldername%\common\character0\model\character\face\real" (
    md ".\patches_contents\%faces_foldername%\common\character0\model\character\face\real" 2>nul
  )
  
  
  REM - For every face folder
  for /f "tokens=*" %%A in ('dir /a:d /b ".\extracted_exports\Faces" 2^>nul') do (
    
    set facename=%%A
    set faceid=!facename:~0,5!
    @echo - !facename!
    
    
    REM - Rename it to the player id
    rename ".\extracted_exports\Faces\%%A" "!faceid!" >nul
    
    REM - Make a properly structured temp folder
    md ".\faces_in_folders\!faceid!\common\character0\model\character\face\real"
    
    REM - Move the face folder to the temp folder
    move ".\extracted_exports\Faces\!faceid!" ".\faces_in_folders\!faceid!\common\character0\model\character\face\real" >nul
    
    REM - Make a cpk and put it in the Faces folder
    .\Engines\CpkMaker\cpkmakec ".\faces_in_folders\!faceid!" ".\patches_contents\%faces_foldername%\common\character0\model\character\face\real\!faceid!.cpk" !cpkmaker_args! >nul
    
    
    rd /S /Q ".\faces_in_folders\!faceid!" >nul
  )
  
  
) else (
  
  REM - PES 18/19 mode
  
  REM - Create a "real" folder if needed
  if not exist ".\patches_contents\%faces_foldername%\Asset\model\character\face\real" (
    md ".\patches_contents\%faces_foldername%\Asset\model\character\face\real" 2>nul
  )
  
  
  REM - For every face folder
  for /f "tokens=*" %%A in ('dir /a:d /b ".\extracted_exports\Faces" 2^>nul') do (
    
    set facename=%%A
    set faceid=!facename:~0,5!
    @echo - !facename!
    
    
    REM - Rename it to the player id
    rename ".\extracted_exports\Faces\%%A" "!faceid!" >nul
    
    REM - Delete the old face folder if present
    if exist ".\patches_contents\%faces_foldername%\Asset\model\character\face\real\!faceid!" (
      rd /S /Q ".\patches_contents\%faces_foldername%\Asset\model\character\face\real\!faceid!" >nul
    )
    
    REM - Make a temp folder
    md ".\faces_in_folders\!faceid!\#windx11"
    
    REM - Move the face folder to the temp folder
    move ".\extracted_exports\Faces\!faceid!" ".\faces_in_folders\!faceid!" >nul
    
    REM - Move the textures to a separate folder
    for /f "tokens=*" %%A in ('dir /b .\faces_in_folders\!faceid!\!faceid!\*.ftex 2^>nul') do (
      set texname=%%A
      move ".\faces_in_folders\!faceid!\!faceid!\!texname!" ".\faces_in_folders\!faceid!\#windx11" >nul
    )
    
    REM - Move the xml
    move ".\faces_in_folders\!faceid!\!faceid!\face.fpk.xml" ".\faces_in_folders\!faceid!" >nul
    
    REM - Rename the folder for packing
    rename ".\faces_in_folders\!faceid!\!faceid!" "face_fpk" >nul
    
    REM - Pack the fpk
    .\Engines\GzsTool\GzsTool.exe ".\faces_in_folders\!faceid!\face.fpk.xml"
    
    REM - Make the final folder structure
    md ".\patches_contents\%faces_foldername%\Asset\model\character\face\real\!faceid!\#Win" 2>nul
    md ".\patches_contents\%faces_foldername%\Asset\model\character\face\real\!faceid!\sourceimages" 2>nul
    
    REM - Move the fpk to the Faces folder
    move ".\faces_in_folders\!faceid!\face.fpk" ".\patches_contents\%faces_foldername%\Asset\model\character\face\real\!faceid!\#Win" >nul
    
    REM - Copy the generic fpkd to the same folder and rename it to face.fpkd
    copy ".\Engines\generic.fpkd" ".\patches_contents\%faces_foldername%\Asset\model\character\face\real\!faceid!\#Win" >nul
    rename ".\patches_contents\%faces_foldername%\Asset\model\character\face\real\!faceid!\#Win\generic.fpkd" "face.fpkd" >nul
    
    REM - Move the textures
    move ".\faces_in_folders\!faceid!\#windx11" ".\patches_contents\%faces_foldername%\Asset\model\character\face\real\!faceid!\sourceimages" >nul
    
    rd /S /Q ".\faces_in_folders\!faceid!" >nul
    
  )
  
)


REM - Finally delete the main folder and temp folder
rd /S /Q ".\extracted_exports\Faces" >nul
rd /S /Q ".\faces_in_folders" >nul


del cpkmaker.out.csv 2>nul

