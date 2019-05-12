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
  set dualcpk_mode=0
  set bins_updating=0
)


REM - Set the name for the folders to put stuff into
if not %dualcpk_mode%==0 (
  
  set faces_foldername=Faces
  set uniform_foldername=Uniform

) else (

  set faces_foldername=Root
  set uniform_foldername=Root
)


REM - Create folders just in case
md ".\patches_contents\%faces_foldername%\common\character0\model\character\face\real" 2>nul
md ".\patches_contents\%uniform_foldername%\common\render\symbol\flag" 2>nul
md ".\patches_contents\%uniform_foldername%\common\character0\model\character\uniform\team" 2>nul
md ".\patches_contents\%uniform_foldername%\common\character0\model\character\uniform\texture" 2>nul
md ".\patches_contents\%uniform_foldername%\common\character0\model\character\glove" 2>nul
md ".\patches_contents\%uniform_foldername%\common\character0\model\character\boots" 2>nul


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
  
  REM - Create folders just in case
  md ".\patches_contents\%uniform_foldername%\common\render\thumbnail\spike" 2>nul
  md ".\patches_contents\%uniform_foldername%\common\render\thumbnail\glove" 2>nul
  md ".\patches_contents\%uniform_foldername%\common\etc\pesdb" 2>nul
  md ".\patches_contents\%uniform_foldername%\common\character0\model\character\uniform\nocloth" 2>nul
  md ".\patches_contents\%uniform_foldername%\common\character0\model\character\d" 2>nul
  md ".\patches_contents\%uniform_foldername%\common\character0\model\character\appearance" 2>nul

  
  REM - Copy the default files to the Uniform folder
  robocopy ".\default_contents" ".\patches_contents" /e /is >nul

  
  REM - Copy the bin files from other_stuff to the Uniform folder
  copy ".\other_stuff\Bin Files\TeamColor.bin" ".\patches_contents\%uniform_foldername%\common\etc" >nul
  copy ".\other_stuff\Bin Files\UniColor.bin" ".\patches_contents\%uniform_foldername%\common\character0\model\character\uniform\team" >nul
  copy ".\other_stuff\Bin Files\Team.bin" ".\patches_contents\%uniform_foldername%\common\etc\pesdb" >nul
  copy ".\other_stuff\Bin Files\GloveList.bin" ".\patches_contents\%uniform_foldername%\common\character0\model\character\glove" >nul
  copy ".\other_stuff\Bin Files\BootsList.bin" ".\patches_contents\%uniform_foldername%\common\character0\model\character\boots" >nul
  copy ".\other_stuff\Bin Files\PlayerAppearance.bin" ".\patches_contents\%uniform_foldername%\common\character0\model\character\appearance" >nul
)


REM - If Bins Updating is enabled
if %bins_updating%==1 (

  REM - Create the etc folder just in case
  md ".\patches_contents\%uniform_foldername%\common\etc" 2>nul
  
  
  REM - Update the relevant bin files
  call .\Engines\bins_update
  
  
  REM - And copy them
  copy ".\other_stuff\Bin Files\TeamColor.bin" ".\patches_contents\%uniform_foldername%\common\etc" >nul
  copy ".\other_stuff\Bin Files\UniColor.bin" ".\patches_contents\%uniform_foldername%\common\character0\model\character\uniform\team" >nul
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
@echo - Moving the boots, gloves and logos

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


REM - Move the logos to the Uniform folder
for /f %%A in ('dir /b ".\extracted_exports\Logo" 2^>nul') do (
  
  move ".\extracted_exports\Logo\%%A" ".\patches_contents\%uniform_foldername%\common\render\symbol\flag" >nul
)


REM - Copy the other files to the Uniform folder
robocopy ".\other_stuff\common" ".\patches_contents\%uniform_foldername%\common" /e /is >nul



REM - Remove the temp faces folder if present
if exist faces_in_folders (
  rd /S /Q .\faces_in_folders >nul
)

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
