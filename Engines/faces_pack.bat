@echo off
setlocal EnableDelayedExpansion

@echo - 
@echo - Packing the face folders into cpks


REM - Create a "player" folder for portraits if not present
if not exist ".\patches_contents\%faces_foldername%\common\render\symbol\player" (
  md ".\patches_contents\%faces_foldername%\common\render\symbol\player" 2>nul
)


if not defined fox_mode (
  
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
    
    REM - If the folder has a portrait
    if exist ".\extracted_exports\Faces\!faceid!\portrait.dds" (
      
      REM - Rename it with the player id
      set name=player_!faceid!.dds
      rename ".\extracted_exports\Faces\!faceid!\portrait.dds" "!name!"
      
      REM - And move it to the portraits folder
      move ".\extracted_exports\Faces\!faceid!\!name!" ".\patches_contents\%faces_foldername%\common\render\symbol\player" >nul
    )
    
    REM - Make a properly structured temp folder
    md ".\faces_in_folders\!faceid!\common\character0\model\character\face\real"
    
    REM - Move the face folder to the temp folder
    move ".\extracted_exports\Faces\!faceid!" ".\faces_in_folders\!faceid!\common\character0\model\character\face\real" >nul
    
    REM - Make a cpk and put it in the Faces folder
    if %compression%==1 (
      .\Engines\cpkmakec ".\faces_in_folders\!faceid!" ".\patches_contents\%faces_foldername%\common\character0\model\character\face\real\!faceid!.cpk" -align=2048 -mode=FILENAME -mask -forcecompress >nul
    ) else (
      .\Engines\cpkmakec ".\faces_in_folders\!faceid!" ".\patches_contents\%faces_foldername%\common\character0\model\character\face\real\!faceid!.cpk" -align=2048 -mode=FILENAME -mask >nul
    )
    
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
    
    REM - If the folder has a portrait
    if exist ".\extracted_exports\Faces\!faceid!\portrait.dds" (
      
      REM - Rename it with the player id
      set name=player_!faceid!.dds
      rename ".\extracted_exports\Faces\!faceid!\portrait.dds" "!name!"
      
      REM - And move it to the portraits folder
      move ".\extracted_exports\Faces\!faceid!\!name!" ".\patches_contents\%faces_foldername%\common\render\symbol\player" >nul
    )
    
    REM - Delete the old face folder if present
    if exist ".\patches_contents\%faces_foldername%\Asset\model\character\face\real\!faceid!" (
      rd /S /Q ".\patches_contents\%faces_foldername%\Asset\model\character\face\real\!faceid!" >nul
    )
    
    REM - Make a temp folder
    md ".\faces_in_folders\!faceid!\#windx11"
    
    REM - Move the face folder to the temp folder
    move ".\extracted_exports\Faces\!faceid!" ".\faces_in_folders\!faceid!" >nul
    
    REM - Move the textures to a separate folder
    for /f "tokens=*" %%A in ('dir /b .\faces_in_folders\!faceid!\!faceid!\*.ftex') do (
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
    
    REM - Copy an fpkd to the same folder
    copy ".\Engines\face.fpkd" ".\patches_contents\%faces_foldername%\Asset\model\character\face\real\!faceid!\#Win" >nul
    
    REM - Move the textures
    move ".\faces_in_folders\!faceid!\#windx11" ".\patches_contents\%faces_foldername%\Asset\model\character\face\real\!faceid!\sourceimages" >nul
    
    rd /S /Q ".\faces_in_folders\!faceid!" >nul
    
  )
  
  
)


REM - Finally delete the main folder and temp folder
rd /S /Q ".\extracted_exports\Faces" >nul
rd /S /Q ".\faces_in_folders" >nul

