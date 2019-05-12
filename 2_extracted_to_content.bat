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
  set multicpk_mode=0
  set bins_updating=1
)


REM - Set the name for the folders to put stuff into
if not %multicpk_mode%==0 (
  
  set faces_foldername=Facescpk
  set uniform_foldername=Uniformcpk
  set bins_foldername=Binscpk

) else (

  set faces_foldername=Singlecpk
  set uniform_foldername=Singlecpk
  set bins_foldername=Singlecpk
)


REM - Create folders just in case
md ".\patches_contents\%faces_foldername%\common\character0\model\character\face\real" 2>nul
md ".\patches_contents\%uniform_foldername%\common\render\symbol\flag" 2>nul
md ".\patches_contents\%uniform_foldername%\common\render\symbol\player" 2>nul
md ".\patches_contents\%uniform_foldername%\common\character0\model\character\uniform\team" 2>nul
md ".\patches_contents\%uniform_foldername%\common\character0\model\character\uniform\texture" 2>nul
md ".\patches_contents\%uniform_foldername%\common\character0\model\character\glove" 2>nul
md ".\patches_contents\%uniform_foldername%\common\character0\model\character\boots" 2>nul


@echo - 
@echo - Compiling the patch folders
@echo - 


REM - If Bins Updating is enabled
if %bins_updating%==1 (

  REM - Create the folders just in case
  md ".\patches_contents\%bins_foldername%\common\etc" 2>nul
  md ".\patches_contents\%bins_foldername%\common\character0\model\character\uniform\team" 2>nul
  
  
  REM - Update the relevant bin files
  call .\Engines\bins_update
  
  
  REM - And copy them
  copy ".\other_stuff\Bin Files\TeamColor.bin" ".\patches_contents\%bins_foldername%\common\etc" >nul
  copy ".\other_stuff\Bin Files\UniColor.bin" ".\patches_contents\%bins_foldername%\common\character0\model\character\uniform\team" >nul
)



@echo - 
@echo - Packing the face folders into cpks

REM - For every face folder
for /f "tokens=*" %%A in ('dir /a:d /b ".\extracted_exports\Faces" 2^>nul') do (
  
  set facename=%%A
  set faceid=!facename:~0,5!

  REM - Rename it to the player id
  rename ".\extracted_exports\Faces\%%A" "!faceid!" >nul
  
  REM - Make a properly structured temp folder
  md ".\faces_in_folders\!faceid!\common\character0\model\character\face\real"
  
  REM - Move the face folder to the temp folder
  move ".\extracted_exports\Faces\!faceid!" ".\faces_in_folders\!faceid!\common\character0\model\character\face\real" >nul
  
  REM - Make a cpk and put it in the Faces folder
  @echo - %%A
  
  if %compression%==1 (
    .\Engines\cpkmakec ".\faces_in_folders\!faceid!" ".\patches_contents\%faces_foldername%\common\character0\model\character\face\real\!faceid!.cpk" -align=2048 -mode=FILENAME -mask -forcecompress >nul
  ) else (
    .\Engines\cpkmakec ".\faces_in_folders\!faceid!" ".\patches_contents\%faces_foldername%\common\character0\model\character\face\real\!faceid!.cpk" -align=2048 -mode=FILENAME -mask >nul
  )
)

REM - Remove the temp faces folder if present
if exist faces_in_folders (
  rd /S /Q .\faces_in_folders >nul
)



@echo - 
@echo - Moving the kits

REM - Move the kit configs to the Uniform folder
for /f %%A in ('dir /b ".\extracted_exports\Kit Configs" 2^>nul') do (

  if exist ".\patches_contents\%uniform_foldername%\common\character0\model\character\uniform\team\%%A" (
    rd /S /Q ".\patches_contents\%uniform_foldername%\common\character0\model\character\uniform\team\%%A"
  )
  
  move ".\extracted_exports\Kit Configs\%%A" ".\patches_contents\%uniform_foldername%\common\character0\model\character\uniform\team" >nul
)

REM - Move the kit textures to the Uniform folder
for /f %%A in ('dir /b ".\extracted_exports\Kit Textures" 2^>nul') do (

  move ".\extracted_exports\Kit Textures\%%A" ".\patches_contents\%uniform_foldername%\common\character0\model\character\uniform\texture" >nul
)



@echo - 
@echo - Moving the logos, portraits, boots and gloves

REM - Move the logos to the Uniform folder
for /f %%A in ('dir /b ".\extracted_exports\Logo" 2^>nul') do (
  
  move ".\extracted_exports\Logo\%%A" ".\patches_contents\%uniform_foldername%\common\render\symbol\flag" >nul
)

REM - Move the portraits to the Uniform folder
for /f %%A in ('dir /b ".\extracted_exports\Portraits" 2^>nul') do (
  
  move ".\extracted_exports\Portraits\%%A" ".\patches_contents\%uniform_foldername%\common\render\symbol\player" >nul
)

REM - Move the boots to the Uniform folder
for /f %%A in ('dir /b ".\extracted_exports\Boots" 2^>nul') do (
  
  if exist ".\patches_contents\%uniform_foldername%\common\character0\model\character\boots\%%A" (
    rd /S /Q ".\patches_contents\%uniform_foldername%\common\character0\model\character\boots\%%A"
  )
  
  move ".\extracted_exports\Boots\%%A" ".\patches_contents\%uniform_foldername%\common\character0\model\character\boots" >nul
)

REM - Move the gloves to the Uniform folder
for /f %%A in ('dir /b ".\extracted_exports\Gloves" 2^>nul') do (
  
  if exist ".\patches_contents\%uniform_foldername%\common\character0\model\character\glove\%%A" (
    rd /S /Q ".\patches_contents\%uniform_foldername%\common\character0\model\character\glove\%%A"
  )
  
  move ".\extracted_exports\Gloves\%%A" ".\patches_contents\%uniform_foldername%\common\character0\model\character\glove" >nul
)


REM - Copy the extra sideload files to the Uniform folder
robocopy ".\other_stuff\common" ".\patches_contents\%uniform_foldername%\common" /e /is >nul



del cpkmaker.out.csv 2>nul


REM - If all_in_one mode is enabled invoke the next part of the process
if defined all_in_one (

  @echo - 
  @echo - 
  @echo - Patch content folders compiled
  @echo - 

  .\content_to_patches
)


@echo - 
@echo - 
@echo - The patches content folder has been compiled
@echo - 
@echo - 4cc aet compiler by Shakes
@echo - 
@echo - 

timeout /t 5
