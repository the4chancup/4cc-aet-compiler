@echo off
REM ^ Don't write everything to screen

if not defined all_in_one (

  REM - Set the working folder
  cd /D "%~dp0"
  
  REM - Load the settings
  call .\Engines\settings_init
)


REM - Set the name for the folders to put stuff into
if %multicpk_mode%==0 (

  set faces_foldername=Singlecpk
  set uniform_foldername=Singlecpk
  set bins_foldername=Singlecpk
  
) 

if %multicpk_mode%==1 (

  set faces_foldername=Facescpk
  set uniform_foldername=Uniformcpk
  set bins_foldername=Binscpk
  
)


REM - Create folders just in case
md ".\patches_contents\%faces_foldername%" 2>nul
md ".\patches_contents\%uniform_foldername%" 2>nul


@echo - 
@echo - Preparing the patch folders
@echo - 


REM - If Bins Updating is enabled
if %bins_updating%==1 (

  REM - Create the folders just in case
  md ".\patches_contents\%bins_foldername%\common\etc" 2>nul
  md ".\patches_contents\%bins_foldername%\common\character0\model\character\uniform\team" 2>nul
  
  REM - Update the relevant bin files
  call .\Engines\bins_update
  
  REM - And copy them to the Bins cpk folder
  copy ".\Bin Files\TeamColor.bin" ".\patches_contents\%bins_foldername%\common\etc" >nul
  copy ".\Bin Files\UniColor.bin" ".\patches_contents\%bins_foldername%\common\character0\model\character\uniform\team" >nul
  
  
  REM - If there's a Kit Configs folder
  if exist ".\extracted_exports\Kit Configs" (
    
    REM - Compile a UniformParam file
    .\Engines\Python\uniparam_compile ".\extracted_exports\Kit Configs" ".\Bin Files\UniformParameter.bin" >nul
    
    REM - And copy it to the Bins cpk folder
    copy ".\Bin Files\UniformParameter.bin" ".\patches_contents\%bins_foldername%\common\character0\model\character\uniform\team" >nul
  )
)


set other_message=


REM - If there's a Faces folder, pack its folders
if exist ".\extracted_exports\Faces" (

  @echo - 
  @echo - Packing the face folders

  call .\Engines\faces_pack
)


REM - If there's a Kit Configs folder, move its stuff
if exist ".\extracted_exports\Kit Configs" (
  
  @echo - 
  @echo - Moving the kit configs
  
  
  REM - Create a "team" folder if needed
  if not exist ".\patches_contents\%uniform_foldername%\common\character0\model\character\uniform\team" (
    md ".\patches_contents\%uniform_foldername%\common\character0\model\character\uniform\team" 2>nul
  )

  REM - Move the kit configs to the Uniform cpk folder
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

  @echo - 
  @echo - Moving the kit textures
  
  
  if %fox_mode%==0 (
    
    REM - Create a "texture" folder if needed
    if not exist ".\patches_contents\%uniform_foldername%\common\character0\model\character\uniform\texture" (
      md ".\patches_contents\%uniform_foldername%\common\character0\model\character\uniform\texture" 2>nul
    )
    
    REM - Move the kit textures to the Uniform cpk folder
    for /f %%A in ('dir /b ".\extracted_exports\Kit Textures" 2^>nul') do (  
      move ".\extracted_exports\Kit Textures\%%A" ".\patches_contents\%uniform_foldername%\common\character0\model\character\uniform\texture" >nul
    )
    
  ) else (
    
    REM - Create a "texture" folder if needed
    if not exist ".\patches_contents\%uniform_foldername%\Asset\model\character\uniform\texture\#windx11" (
      md ".\patches_contents\%uniform_foldername%\Asset\model\character\uniform\texture\#windx11" 2>nul
    )
    
    REM - Move the kit textures to the Uniform cpk folder
    for /f %%A in ('dir /b ".\extracted_exports\Kit Textures" 2^>nul') do (
      move ".\extracted_exports\Kit Textures\%%A" ".\patches_contents\%uniform_foldername%\Asset\model\character\uniform\texture\#windx11" >nul
    )
    
  )
  
  REM . Then delete the main folder
  rd /S /Q ".\extracted_exports\Kit Textures" >nul
  
)


REM - If there's a Boots folder, move or pack its stuff
if exist ".\extracted_exports\Boots" (

  if %fox_mode%==0 (
  
    @echo - 
    @echo - Moving the boots
    
  ) else (
  
    @echo - 
    @echo - Packing the boots folders
    
  )
  
  call .\Engines\boots_pack
)


REM - If there's a Gloves folder, move its stuff
if exist ".\extracted_exports\Gloves" (
  
  if %fox_mode%==0 (
  
    @echo - 
    @echo - Moving the gloves
    
  ) else (
  
    @echo - 
    @echo - Packing the gloves folders
    
  )
  
  call .\Engines\gloves_pack
)


REM - If there's a Collars folder, move its stuff
if exist ".\extracted_exports\Collars" (
  
  if not defined other_message (
    set other_message=1
    
    @echo - 
    @echo - Moving the other stuff
  )
    
  REM - Create the folder structure if needed
  if not exist ".\patches_contents\%faces_foldername%\Asset\model\character\uniform\nocloth\#Win" (
    md ".\patches_contents\%faces_foldername%\Asset\model\character\uniform\nocloth\#Win" 2>nul
  )
  
  REM - Move the collars to the Faces cpk folder
  for /f %%A in ('dir /b ".\extracted_exports\Collars" 2^>nul') do (
    move ".\extracted_exports\Collars\%%A" ".\patches_contents\%faces_foldername%\Asset\model\character\uniform\nocloth\#Win" >nul
  )

  REM . Then delete the main folder
  rd /S /Q ".\extracted_exports\Collars" >nul
)


REM - If there's a Portraits folder, move its stuff
if exist ".\extracted_exports\Portraits" (

  if not defined other_message (
    set other_message=1
    
    @echo - 
    @echo - Moving the other stuff
  )
  
  REM - Create a "player" folder if needed
  if not exist ".\patches_contents\%faces_foldername%\common\render\symbol\player" (
    md ".\patches_contents\%faces_foldername%\common\render\symbol\player" 2>nul
  )
  
  REM - Move the portraits to the Faces cpk folder
  for /f %%A in ('dir /b ".\extracted_exports\Portraits" 2^>nul') do (
    move ".\extracted_exports\Portraits\%%A" ".\patches_contents\%faces_foldername%\common\render\symbol\player" >nul
  )

  REM . Then delete the main folder
  rd /S /Q ".\extracted_exports\Portraits" >nul

)


REM - If there's a Logo folder, move its stuff
if exist ".\extracted_exports\Logo" (

  if not defined other_message (
    set other_message=1
    
    @echo - 
    @echo - Moving the other stuff
  )
  
  REM - Create a "flag" folder if needed
  if not exist ".\patches_contents\%uniform_foldername%\common\render\symbol\flag" (
    md ".\patches_contents\%uniform_foldername%\common\render\symbol\flag" 2>nul
  )

  REM - Move the logos to the Uniform cpk folder
  for /f %%A in ('dir /b ".\extracted_exports\Logo" 2^>nul') do (
    move ".\extracted_exports\Logo\%%A" ".\patches_contents\%uniform_foldername%\common\render\symbol\flag" >nul
  )

  REM . Then delete the main folder
  rd /S /Q ".\extracted_exports\Logo" >nul
  
)


REM - Set the common folder path depending on the fox mode setting
if %fox_mode%==0 (
  set common_path=common\character1\model\character\uniform\common
) else (
  set common_path=Asset\model\character\common
)
  
REM - If there's a Common folder, move its stuff
if exist ".\extracted_exports\Common" (

  if not defined other_message (
    set other_message=1
    
    @echo - 
    @echo - Moving the other stuff
  )
  
  
  REM - Create a "common" folder if needed
  if not exist ".\patches_contents\%faces_foldername%\%common_path%" (
    md ".\patches_contents\%faces_foldername%\%common_path%" 2>nul
  )
  
  REM - Move the team folders to the Faces cpk folder
  for /f %%A in ('dir /b ".\extracted_exports\Common" 2^>nul') do (
  
    if %fox_mode%==0 (
    
      if exist ".\patches_contents\%faces_foldername%\%common_path%\%%A" (
        rd /S /Q ".\patches_contents\%faces_foldername%\%common_path%\%%A"
      )
      
      move ".\extracted_exports\Common\%%A" ".\patches_contents\%faces_foldername%\%common_path%" >nul
    
    ) else (
      
      REM - Check if any dds textures exist
      >nul 2>nul dir /a-d /s ".\extracted_exports\Common\%%A\*.dds" && (set dds_present=1) || (set dds_present=)
      
      if defined dds_present (
        
        REM - Convert the dds textures to ftex
        for /f "tokens=*" %%B in ('dir /b ".\extracted_exports\Common\%%A\*.dds"') do (
          call .\Engines\FtexTool\FtexTool -f 0 ".\extracted_exports\Common\%%A\%%B" >nul
        )
        
        REM - And delete them
        for /f "tokens=*" %%B in ('dir /b ".\extracted_exports\Common\%%A\*.dds"') do (
          del ".\extracted_exports\Common\%%A\%%B" >nul
        )
      )
      
      md ".\patches_contents\%faces_foldername%\%common_path%\%%A\sourceimages\#windx11" 2>nul
     
      for /f %%B in ('dir /b ".\extracted_exports\Common\%%A" 2^>nul') do (
        move ".\extracted_exports\Common\%%A\%%B" ".\patches_contents\%faces_foldername%\%common_path%\%%A\sourceimages\#windx11" >nul
      )
      
    )
    
  )
  
  REM . Then delete the main folder
  rd /S /Q ".\extracted_exports\Common" >nul

)


REM . Finally delete the extracted exports folder
rd /S /Q ".\extracted_exports" >nul


if defined all_in_one (

  @echo - 
  @echo - 
  @echo - Patch contents folder prepared
  @echo - 
  
  
) else (

  @echo - 
  @echo - 
  @echo - The patches contents folder has been prepared
  @echo - 
  @echo - 4cc aet compiler by Shakes
  @echo - 
  @echo - 

  pause
  
)

