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
md ".\patches_contents\%faces_foldername%" 2>nul
md ".\patches_contents\%uniform_foldername%" 2>nul


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
  copy ".\Bin Files\TeamColor.bin" ".\patches_contents\%bins_foldername%\common\etc" >nul
  copy ".\Bin Files\UniColor.bin" ".\patches_contents\%bins_foldername%\common\character0\model\character\uniform\team" >nul
)


set kitmess=
set othmess=


REM - If there's a Kit Configs folder, move its stuff
if exist ".\extracted_exports\Kit Configs" (

  if not defined kitmess (
    set kitmess=1
    
    @echo - 
    @echo - Moving the kits
  )
  
  REM - Create a "team" folder if needed
  if not exist ".\patches_contents\%uniform_foldername%\common\character0\model\character\uniform\team" (
    md ".\patches_contents\%uniform_foldername%\common\character0\model\character\uniform\team" 2>nul
  )

  REM - Move the kit configs to the Uniform folder
  for /f %%A in ('dir /b ".\extracted_exports\Kit Configs" 2^>nul') do (

    if exist ".\patches_contents\%uniform_foldername%\common\character0\model\character\uniform\team\%%A" (
      rd /S /Q ".\patches_contents\%uniform_foldername%\common\character0\model\character\uniform\team\%%A"
    )
    
    move ".\extracted_exports\Kit Configs\%%A" ".\patches_contents\%uniform_foldername%\common\character0\model\character\uniform\team" >nul
  )
  
  REM . Then delete the main folder
  rd /S /Q ".\extracted_exports\Kit Configs" >nul
  
)


REM - If there's a Kit Textures folder, move its stuff
if exist ".\extracted_exports\Kit Textures" (

  if not defined kitmess (
    set kitmess=1
    
    @echo - 
    @echo - Moving the kits
  )
  
  REM - Create a "texture" folder if needed
  if not exist ".\patches_contents\%uniform_foldername%\common\character0\model\character\uniform\texture" (
    md ".\patches_contents\%uniform_foldername%\common\character0\model\character\uniform\texture" 2>nul
  )
  
  REM - Move the kit textures to the Uniform folder
  for /f %%A in ('dir /b ".\extracted_exports\Kit Textures" 2^>nul') do (

    move ".\extracted_exports\Kit Textures\%%A" ".\patches_contents\%uniform_foldername%\common\character0\model\character\uniform\texture" >nul
  )
  
  REM . Then delete the main folder
  rd /S /Q ".\extracted_exports\Kit Textures" >nul
  
)



REM - If there's a Logo folder, move its stuff
if exist ".\extracted_exports\Logo" (

  if not defined othmess (
    set othmess=1
    
    @echo - 
    @echo - Moving the other stuff
  )
  
  REM - Create a "flag" folder if needed
  if not exist ".\patches_contents\%uniform_foldername%\common\render\symbol\flag" (
    md ".\patches_contents\%uniform_foldername%\common\render\symbol\flag" 2>nul
  )

  REM - Move the logos to the Uniform folder
  for /f %%A in ('dir /b ".\extracted_exports\Logo" 2^>nul') do (
    
    move ".\extracted_exports\Logo\%%A" ".\patches_contents\%uniform_foldername%\common\render\symbol\flag" >nul
  )

  REM . Then delete the main folder
  rd /S /Q ".\extracted_exports\Logo" >nul
  
)


REM - If there's a Portraits folder, move its stuff
if exist ".\extracted_exports\Portraits" (

  if not defined othmess (
    set othmess=1
    
    @echo - 
    @echo - Moving the other stuff
  )
  
  REM - Create a "player" folder if needed
  if not exist ".\patches_contents\%faces_foldername%\common\render\symbol\player" (
    md ".\patches_contents\%faces_foldername%\common\render\symbol\player" 2>nul
  )
  
  REM - Move the portraits to the Faces folder
  for /f %%A in ('dir /b ".\extracted_exports\Portraits" 2^>nul') do (
    
    move ".\extracted_exports\Portraits\%%A" ".\patches_contents\%faces_foldername%\common\render\symbol\player" >nul
  )

  REM . Then delete the main folder
  rd /S /Q ".\extracted_exports\Portraits" >nul

)


REM - If there's a Boots folder, move its stuff
if exist ".\extracted_exports\Boots" (

  if not defined othmess (
    set othmess=1
    
    @echo - 
    @echo - Moving the other stuff
  )
  
  REM - Create a "boots" folder if needed
  if not exist ".\patches_contents\%uniform_foldername%\common\character0\model\character\boots" (
    md ".\patches_contents\%uniform_foldername%\common\character0\model\character\boots" 2>nul
  )
  
  REM - Move the boots to the Uniform folder
  for /f %%A in ('dir /b ".\extracted_exports\Boots" 2^>nul') do (
    
    if exist ".\patches_contents\%uniform_foldername%\common\character0\model\character\boots\%%A" (
      rd /S /Q ".\patches_contents\%uniform_foldername%\common\character0\model\character\boots\%%A"
    )
    
    move ".\extracted_exports\Boots\%%A" ".\patches_contents\%uniform_foldername%\common\character0\model\character\boots" >nul
  )

  
  REM . Then delete the main folder
  rd /S /Q ".\extracted_exports\Boots" >nul

)


REM - If there's a Gloves folder, move its stuff
if exist ".\extracted_exports\Gloves" (

  if not defined othmess (
    set othmess=1
    
    @echo - 
    @echo - Moving the other stuff
  )
  
  REM - Create a "glove" folder if needed
  if not exist ".\patches_contents\%uniform_foldername%\common\character0\model\character\glove" (
    md ".\patches_contents\%uniform_foldername%\common\character0\model\character\glove" 2>nul
  )
  
  REM - Move the gloves to the Uniform folder
  for /f %%A in ('dir /b ".\extracted_exports\Gloves" 2^>nul') do (
    
    if exist ".\patches_contents\%uniform_foldername%\common\character0\model\character\glove\%%A" (
      rd /S /Q ".\patches_contents\%uniform_foldername%\common\character0\model\character\glove\%%A"
    )
    
    move ".\extracted_exports\Gloves\%%A" ".\patches_contents\%uniform_foldername%\common\character0\model\character\glove" >nul
  )
  
  REM . Then delete the main folder
  rd /S /Q ".\extracted_exports\Gloves" >nul

)


REM - If there's a Common folder, move its stuff
if exist ".\extracted_exports\Common" (

  if not defined othmess (
    set othmess=1
    
    @echo - 
    @echo - Moving the other stuff
  )
  
  REM - Create a "common" folder if needed
  if not exist ".\patches_contents\%faces_foldername%\common\character1\model\character\uniform\common" (
    md ".\patches_contents\%faces_foldername%\common\character1\model\character\uniform\common" 2>nul
  )
  
  REM - Move the team folders to the Faces folder
  for /f %%A in ('dir /b ".\extracted_exports\Common" 2^>nul') do (
    
    if exist ".\patches_contents\%faces_foldername%\common\character1\model\character\uniform\common\%%A" (
      rd /S /Q ".\patches_contents\%faces_foldername%\common\character1\model\character\uniform\common\%%A"
    )
    
    move ".\extracted_exports\Common\%%A" ".\patches_contents\%faces_foldername%\common\character1\model\character\uniform\common" >nul
  )
  
  REM . Then delete the main folder
  rd /S /Q ".\extracted_exports\Common" >nul

)


REM - If there's a Faces folder, pack its folders
if exist ".\extracted_exports\Faces" (
  call .\Engines\faces_pack
)



del cpkmaker.out.csv 2>nul


REM - If all_in_one mode is enabled invoke the next part of the process
if defined all_in_one (

  @echo - 
  @echo - 
  @echo - Patch contents folders compiled
  @echo - 
  
  
) else (

  @echo - 
  @echo - 
  @echo - The patches content folder has been compiled
  @echo - 
  @echo - 4cc aet compiler by Shakes
  @echo - 
  @echo - 

  timeout /t 5
  
)

