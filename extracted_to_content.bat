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
  set bins_updating=0
)

REM - Create folders just in case
md ".\faces_in_folders" 2>nul
md ".\patches_contents\Faces\common\character0\model\character\face\real" 2>nul
md ".\patches_contents\Uniform\common\render\thumbnail\spike" 2>nul
md ".\patches_contents\Uniform\common\render\thumbnail\glove" 2>nul
md ".\patches_contents\Uniform\common\etc\pesdb" 2>nul
md ".\patches_contents\Uniform\common\character0\model\character\uniform\team" 2>nul
md ".\patches_contents\Uniform\common\character0\model\character\uniform\texture" 2>nul
md ".\patches_contents\Uniform\common\character0\model\character\uniform\nocloth" 2>nul
md ".\patches_contents\Uniform\common\character0\model\character\glove" 2>nul
md ".\patches_contents\Uniform\common\character0\model\character\d" 2>nul
md ".\patches_contents\Uniform\common\character0\model\character\boots" 2>nul
md ".\patches_contents\Uniform\common\character0\model\character\appearance" 2>nul


if not defined full_patch (
  set full_patch=0
)

REM - If Full patch mode is enabled
if %full_patch%==1 (
  
  REM - Unless all_in_one mode is enabled
  if not defined all_in_one (
  
    REM - Check the existance of the default_contents folder
    if not exist ".\default_contents" (
      
      @echo - 
      @echo - 
      @echo - default_contents folder not found
      @echo - Please get it and and copy it to the script's
      @echo - folder or disable Full Patch mode in the settings
      @echo - 
      @echo - 
      @echo - Do you want to exit or disable Full Patch mode and continue?
      @echo - X^) Exit
      @echo - C^) Continue
      @echo - 
      
      choice /c XC /m "- Choice: " /n
      set choice=!errorlevel!
      
      if "!choice!"=="1" (
        
        EXIT /b
        
      ) else (
      
        REM - Disable Full Patch mode
        set full_patch=0
        
        for /f "tokens=* usebackq" %%R IN (".\settings.txt") do (
          
          set line=%%R
          
          if "!line:~0,14!"=="set full_patch" (
            @echo set full_patch=>> settings_temp.txt
          ) else (
            @echo %%R>> settings_temp.txt
          )
        )
        
        del .\settings.txt
        
        rename .\settings_temp.txt settings.txt
      )
      
    )
  )
)

@echo - 
@echo - Compiling the patch folders
@echo - 

REM - If Full patch mode is still enabled
if %full_patch%==1 (
  
  @echo - 
  @echo - Full Patch mode is enabled
  @echo - 
  @echo - Copying the default content
  @echo - 
  
  REM - Copy the default files to the Uniform folder
  robocopy ".\default_contents" ".\patches_contents" /e /is >nul
  
  REM - Copy the bin files from other_stuff to the Uniform folder
  copy ".\other_stuff\Bin Files\TeamColor.bin" ".\patches_contents\Uniform\common\etc" >nul
  copy ".\other_stuff\Bin Files\UniColor.bin" ".\patches_contents\Uniform\common\character0\model\character\uniform\team" >nul
  copy ".\other_stuff\Bin Files\Team.bin" ".\patches_contents\Uniform\common\etc\pesdb" >nul
  copy ".\other_stuff\Bin Files\GloveList.bin" ".\patches_contents\Uniform\common\character0\model\character\glove" >nul
  copy ".\other_stuff\Bin Files\BootsList.bin" ".\patches_contents\Uniform\common\character0\model\character\boots" >nul
  copy ".\other_stuff\Bin Files\PlayerAppearance.bin" ".\patches_contents\Uniform\common\character0\model\character\appearance" >nul
)


REM - If Bins Updating is enabled
if %bins_updating%==1 (
  
  REM - Update the relevant bin files
  call .\Engines\bins_update
  
  REM - And copy them
  copy ".\other_stuff\Bin Files\TeamColor.bin" ".\patches_contents\Uniform\common\etc" >nul
  copy ".\other_stuff\Bin Files\UniColor.bin" ".\patches_contents\Uniform\common\character0\model\character\uniform\team" >nul
)


REM - Make a properly structured temp folder for every face and move the faces from the Faces folder
for /f %%A in ('dir /a:d /b ".\extracted_exports\Faces" 2^>nul') do (
  md ".\faces_in_folders\%%A\common\character0\model\character\face\real"
  move ".\extracted_exports\Faces\%%A" ".\faces_in_folders\%%A\common\character0\model\character\face\real" >nul
)

@echo - 
@echo - Packing the face folders into cpks

REM - Make a cpk of every face and put it in the Faces folder
for /f %%B in ('dir /a:d /b ".\faces_in_folders" 2^>nul') do (
  @echo - %%B
  .\Engines\cpkmakec ".\faces_in_folders\%%B" ".\patches_contents\Faces\common\character0\model\character\face\real\%%B.cpk" -align=2048 -mode=FILENAME -mask >nul
)


@echo - 
@echo - Moving the kits

REM - Move the kits to the Uniform folder
for /f %%A in ('dir /b "extracted_exports\Kits\Kit Configs" 2^>nul') do (
  if exist ".\patches_contents\Uniform\common\character0\model\character\uniform\team\%%A" (
    rd /S /Q ".\patches_contents\Uniform\common\character0\model\character\uniform\team\%%A"
  )
  move ".\extracted_exports\Kits\Kit Configs\%%A" ".\patches_contents\Uniform\common\character0\model\character\uniform\team" >nul
)
for /f %%A in ('dir /b "extracted_exports\Kits\Kit Textures" 2^>nul') do (
  move ".\extracted_exports\Kits\Kit Textures\%%A" ".\patches_contents\Uniform\common\character0\model\character\uniform\texture" >nul
)

@echo - 
@echo - Moving the boots, gloves and other stuff

REM - Move the boots to the Uniform folder
for /f %%A in ('dir /b "extracted_exports\Other\Boots" 2^>nul') do (
  if exist ".\patches_contents\Uniform\common\character0\model\character\boots\%%A" (
    rd /S /Q ".\patches_contents\Uniform\common\character0\model\character\boots\%%A"
  )
  move ".\extracted_exports\Other\Boots\%%A" ".\patches_contents\Uniform\common\character0\model\character\boots" >nul
)

REM - Move the gloves to the Uniform folder
for /f %%A in ('dir /b "extracted_exports\Other\Gloves" 2^>nul') do (
  if exist ".\patches_contents\Uniform\common\character0\model\character\glove\%%A" (
    rd /S /Q ".\patches_contents\Uniform\common\character0\model\character\glove\%%A"
  )
  move ".\extracted_exports\Other\Gloves\%%A" ".\patches_contents\Uniform\common\character0\model\character\glove" >nul
)


REM - Move the other stuff to the Uniform folder
for /f %%A in ('dir *.dds /b "other_stuff\Thumbnails\Boots" 2^>nul') do (
  move ".\other_stuff\Thumbnails\Boots\%%A" ".\patches_contents\Uniform\common\render\thumbnail\spike" >nul
)
for /f %%A in ('dir *.dds /b "other_stuff\Thumbnails\Gloves" 2^>nul') do (
  move ".\other_stuff\Thumbnails\Gloves\%%A" ".\patches_contents\Uniform\common\render\thumbnail\glove" >nul
)
for /f %%A in ('dir *.model /b "other_stuff\Nocloth Kits" 2^>nul') do (
  move ".\other_stuff\Nocloth Kits\%%A" ".\patches_contents\Uniform\common\character0\model\character\uniform\nocloth" >nul
)
for /f %%A in ('dir *.model /b "other_stuff\modD Models" 2^>nul') do (
  move ".\other_stuff\modD Models\%%A" ".\patches_contents\Uniform\common\character0\model\character\d" >nul
)


REM - Remove the temp folder
rd /S /Q .\faces_in_folders

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
