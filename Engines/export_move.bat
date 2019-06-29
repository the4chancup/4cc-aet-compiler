REM - Edits and moves the contents of the export to the root of extracted_exports

REM - Check if the macro for converting to hexadecimal is defined, run the library otherwise
if not defined macro.Num2Hex (
  .\Engines\MacroLib "%~f0"
)

REM - Allow reading variables modified inside statements
setlocal EnableDelayedExpansion


REM - Move everything except the folders
for /f "tokens=*" %%B in ('dir /a:-d /b ".\extracted_exports\!foldername!" 2^>nul') do (

  move ".\extracted_exports\!foldername!\%%B" ".\extracted_exports" >nul
)


REM - Move the folders' contents
set unknownexists=

for /f "tokens=*" %%B in ('dir /a:d /b ".\extracted_exports\!foldername!" 2^>nul') do (
  
  set folder_type_found=
  
  REM - Face folder
  if /i "%%B"=="Faces" (
  
    set folder_type_found=1
    
    REM - Create the main folder if not present
    if not exist ".\extracted_exports\%%B" (
      md ".\extracted_exports\%%B" 2>nul
    )
    
    REM - For each face folder
    for /f "tokens=*" %%C in ('dir /a:d /b ".\extracted_exports\!foldername!\%%B" 2^>nul') do (
    
      REM - Prepare the player ID
      set face_id_withname=%%C
      set face_id_withname=!teamid!!face_id_withname:~3!
      set face_id=!face_id_withname:~0,5!
      
      REM - If fox mode is enabled
      if %fox_mode%==1 (
        
        REM - Edit the texture paths if requested
        if %fmdl_id_editing%==1 (
        
          REM - Level 1 - Just the hair_high fmdl
          if exist ".\extracted_exports\!foldername!\%%B\%%C\hair_high.fmdl" (
            call .\Engines\Python\fmdl_id_change ".\extracted_exports\!foldername!\%%B\%%C\hair_high.fmdl" !face_id! >nul
          )
        )
        if %fmdl_id_editing%==2 (
          
          REM - Level 2 - Every fmdl
          for /f "tokens=*" %%D in ('dir /b ".\extracted_exports\!foldername!\%%B\%%C\*.fmdl"') do (
            call .\Engines\Python\fmdl_id_change ".\extracted_exports\!foldername!\%%B\%%C\%%D" !face_id! >nul
          )
        )
        
        REM - Check if any dds textures exist
        >nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\%%B\%%C\*.dds" && (set dds_present=1) || (set dds_present=)
        
        if defined dds_present (
          
          REM - Convert the dds textures to ftex
          call .\Engines\Python\ftex_pack -m ".\extracted_exports\!foldername!\%%B\%%C" ".\extracted_exports\!foldername!\%%B\%%C" >nul
          
          REM - And delete them
          for /f "tokens=*" %%D in ('dir /b ".\extracted_exports\!foldername!\%%B\%%C\*.dds"') do (
            del ".\extracted_exports\!foldername!\%%B\%%C\%%D" >nul
          )
        )
        
      )
      
      REM - Replace the dummy team ID with the actual one
      rename ".\extracted_exports\!foldername!\%%B\%%C" "!face_id_withname!"
      
      REM - Delete the folder if already present
      if exist ".\extracted_exports\%%B\!face_id_withname!" (
        rd /S /Q ".\extracted_exports\%%B\!face_id_withname!"
      )
      
      REM - And move the face folder
      move ".\extracted_exports\!foldername!\%%B\!face_id_withname!" ".\extracted_exports\%%B" >nul
    )
    
  )
  
  
  REM - Kit Configs folder
  if /i "%%B"=="Kit Configs" (
  
    set folder_type_found=1
    
    if %pass_through%==2 (
    
      REM - Check if the files are in an inner folder
      for /f "tokens=*" %%C in ('dir /b /a:d ".\extracted_exports\!foldername!\Kit Configs" 2^>nul') do (
        
        REM - If a folder was found move its contents to the root folder
        for /f "tokens=*" %%D in ('dir /b ".\extracted_exports\!foldername!\Kit Configs\%%C"') do (
        
          move ".\extracted_exports\!foldername!\Kit Configs\%%C\%%D" ".\extracted_exports\!foldername!\Kit Configs" >nul
        )
        
        REM - And delete the now empty folder
        rd /S /Q ".\extracted_exports\!foldername!\Kit Configs\%%C"
      )
    )
    
    REM - Create the main folder if not present
    if not exist ".\extracted_exports\%%B" (
      md ".\extracted_exports\%%B" 2>nul
    )
    
    REM - Delete the team folder if already present
    if exist ".\extracted_exports\Kit Configs\!teamid!" (
      rd /S /Q ".\extracted_exports\Kit Configs\!teamid!"
    )
    
    REM - Create a folder with the team ID
    md ".\extracted_exports\Kit Configs\!teamid!" 2>nul
    
    
    REM - Prepare the texture filename
    set texname=u0!teamid!
    call .\Engines\CharLib str2hex texname texname_hex
    set texname_hexspc=

    for /l %%C in (0 2 8) do (
      
      if not defined texname_hexspc (
        set texname_hexspc=!texname_hex:~%%C,2!
      ) else (
        set texname_hexspc=!texname_hexspc! !texname_hex:~%%C,2!
      )
    )
    
    REM - For every kit config file
    for /f "tokens=*" %%C in ('dir /b ".\extracted_exports\!foldername!\%%B\*.bin"') do (
      
      set zlibbed=
    
      REM - Check if it is zlibbed
      for /f "tokens=1-6 usebackq" %%D in (`call .\Engines\hexed ".\extracted_exports\!foldername!\%%B\%%C" -d 3 5`) do (
        
        REM - If the file has the WESYS label it's zlibbed
        if "%%E%%F%%G%%H%%I"=="5745535953" (
          
          set zlibbed=1
        )
      )
      
      REM - If the file is zlibbed
      if defined zlibbed (
      
        REM - Unzlib it
        .\Engines\zlibtool ".\extracted_exports\!foldername!\%%B\%%C" -d >nul
        
        REM - Delete the original file
        del ".\extracted_exports\!foldername!\%%B\%%C" >nul
        
        REM - And change the unzlibbed file's extension
        rename ".\extracted_exports\!foldername!\%%B\%%C.unzlib" "%%C" >nul

      )
      
      
      REM - Edit the texture names inside the config file so that they point to the proper textures
      for /l %%O in (0 1 4) do (
      
        REM - First check if the line is empty
        set /a position=40+%%O*16
      
        %macro_Call% ("position position_hex") %macro.Num2Hex%
        
        for /f "tokens=1-2" %%X in ('call .\Engines\hexed ".\extracted_exports\!foldername!\%%B\%%C" -d !position_hex! 1') do (
          set char=%%Y
        )
        
        REM - If the line begins with u write the proper texture name
        if !char!==75 (
        
          .\Engines\hexed ".\extracted_exports\!foldername!\%%B\%%C" -e !position_hex! !texname_hexspc!
        )
      
      )
      
      
      REM - Replace the dummy team ID in the filename with the actual one
      set object_name=%%C
      set object_name=!teamid!!object_name:~3!
      
      rename ".\extracted_exports\!foldername!\%%B\%%C" "!object_name!"
      
      REM - And move the file
      move ".\extracted_exports\!foldername!\%%B\!object_name!" ".\extracted_exports\%%B\!teamid!" >nul
    )
    
  )
  
  
  REM - Kit Textures folder
  if /i "%%B"=="Kit Textures" (
  
    set folder_type_found=1
    
    REM - Create the main folder if not present
    if not exist ".\extracted_exports\%%B" (
      md ".\extracted_exports\%%B" 2>nul
    )
    
    
    REM - If fox mode is enabled
    if %fox_mode%==1 (
      
      REM - Check if any dds textures exist
      >nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\%%B\*.dds" && (set dds_present=1) || (set dds_present=)
      
      if defined dds_present (
        
        REM - Convert the dds textures to ftex
        call .\Engines\Python\ftex_pack -m ".\extracted_exports\!foldername!\%%B" ".\extracted_exports\!foldername!\%%B" >nul
        
        REM - And delete them
        for /f "tokens=*" %%C in ('dir /b ".\extracted_exports\!foldername!\%%B\*.dds"') do (
          del ".\extracted_exports\!foldername!\%%B\%%C" >nul
        )
      )
      
      REM - Set the texture file extension to ftex
      set kit_tex_ext=ftex
      
    ) else (
      
      REM - Set the texture file extension to dds
      set kit_tex_ext=dds
      
    )
    
    
    REM - For every kit texture file
    for /f "tokens=*" %%C in ('dir /a:-d /b ".\extracted_exports\!foldername!\%%B\*.!kit_tex_ext!" 2^>nul') do (
    
      REM - Replace the dummy team ID in the filename with the actual one
      set object_name=%%C
      set object_name=u0!teamid!!object_name:~5!
      
      rename ".\extracted_exports\!foldername!\%%B\%%C" "!object_name!"
      
      REM - And move the file
      move ".\extracted_exports\!foldername!\%%B\!object_name!" ".\extracted_exports\%%B" >nul
    )
    
  )
  
  
  REM - Logo folder
  if /i "%%B"=="Logo" (
  
    set folder_type_found=1
    
    REM - Create the main folder if not present
    if not exist ".\extracted_exports\%%B" (
      md ".\extracted_exports\%%B" 2>nul
    )
    
    REM - For every logo file
    for /f "tokens=*" %%C in ('dir /a:-d /b ".\extracted_exports\!foldername!\%%B" 2^>nul') do (
    
      REM - Replace the dummy team ID in the filename with the actual one
      set object_name=%%C
      set object_name=emblem_0!teamid!!object_name:~11!
      
      rename ".\extracted_exports\!foldername!\%%B\%%C" "!object_name!"
      
      REM - And move the file
      move ".\extracted_exports\!foldername!\%%B\!object_name!" ".\extracted_exports\%%B" >nul
    )
    
  )
  
  
  REM - Portraits folder
  if /i "%%B"=="Portraits" (
  
    set folder_type_found=1
    
    REM - Create the main folder if not present
    if not exist ".\extracted_exports\%%B" (
      md ".\extracted_exports\%%B" 2>nul
    )
    
    REM - For every portrait file
    for /f "tokens=*" %%C in ('dir /a:-d /b ".\extracted_exports\!foldername!\%%B" 2^>nul') do (
    
      REM - Replace the dummy team ID in the filename with the actual one
      set object_name=%%C
      set object_name=player_!teamid!!object_name:~10!
      
      rename ".\extracted_exports\!foldername!\%%B\%%C" "!object_name!"
      
      REM - And move the file
      move ".\extracted_exports\!foldername!\%%B\!object_name!" ".\extracted_exports\%%B" >nul
    )
    
  )
  
  
  REM - Boots folder
  if /i "%%B"=="Boots" (
  
    set folder_type_found=1
    
    REM - Create the main folder if not present
    if not exist ".\extracted_exports\%%B" (
      md ".\extracted_exports\%%B" 2>nul
    )
    
    REM - For each boots folder
    for /f "tokens=*" %%C in ('dir /a:d /b ".\extracted_exports\!foldername!\%%B" 2^>nul') do (
      
      REM - Prepare the ID
      set bootsid=%%C
      
      REM - If fox mode is enabled
      if %fox_mode%==1 (
        
        REM - Edit the texture paths if requested
        if not %fmdl_id_editing%==0 (
        
          for /f "tokens=*" %%D in ('dir /b ".\extracted_exports\!foldername!\%%B\%%C\*.fmdl"') do (
            call .\Engines\Python\fmdl_id_change ".\extracted_exports\!foldername!\%%B\%%C\%%D" !bootsid! >nul
          )
        )
        
        REM - Check if any dds textures exist
        >nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\%%B\%%C\*.dds" && (set dds_present=1) || (set dds_present=)
        
        if defined dds_present (
          
          REM - Convert the dds textures to ftex
          call .\Engines\Python\ftex_pack -m ".\extracted_exports\!foldername!\%%B\%%C" ".\extracted_exports\!foldername!\%%B\%%C" >nul
          
          REM - And delete them
          for /f "tokens=*" %%D in ('dir /b ".\extracted_exports\!foldername!\%%B\%%C\*.dds"') do (
            del ".\extracted_exports\!foldername!\%%B\%%C\%%D" >nul
          )
        )
        
      )
      
      
      REM - Delete the folder if already present
      if exist ".\extracted_exports\%%B\%%C" (
        rd /S /Q ".\extracted_exports\%%B\%%C"
      )
      
      REM - And move the folder
      move ".\extracted_exports\!foldername!\%%B\%%C" ".\extracted_exports\%%B" >nul
    )
  
  )
  
  
  REM - Gloves folder
  if /i "%%B"=="Gloves" (
  
    set folder_type_found=1
    
    REM - Create the main folder if not present
    if not exist ".\extracted_exports\%%B" (
      md ".\extracted_exports\%%B" 2>nul
    )
    
    REM - For each gloves folder
    for /f "tokens=*" %%C in ('dir /a:d /b ".\extracted_exports\!foldername!\%%B" 2^>nul') do (
      
      REM - Prepare the ID
      set glovesid=%%C
      
      REM - If fox mode is enabled
      if %fox_mode%==1 (
        
        REM - Edit the texture paths if requested
        if not %fmdl_id_editing%==0 (
        
          for /f "tokens=*" %%D in ('dir /b ".\extracted_exports\!foldername!\%%B\%%C\*.fmdl"') do (
            call .\Engines\Python\fmdl_id_change ".\extracted_exports\!foldername!\%%B\%%C\%%D" !glovesid! >nul
          )
        )
        
        REM - Check if any dds textures exist
        >nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\%%B\%%C\*.dds" && (set dds_present=1) || (set dds_present=)
        
        if defined dds_present (
          
          REM - Convert the dds textures to ftex
          call .\Engines\Python\ftex_pack -m ".\extracted_exports\!foldername!\%%B\%%C" ".\extracted_exports\!foldername!\%%B\%%C" >nul
          
          REM - And delete them
          for /f "tokens=*" %%D in ('dir /b ".\extracted_exports\!foldername!\%%B\%%C\*.dds"') do (
            del ".\extracted_exports\!foldername!\%%B\%%C\%%D" >nul
          )
        )
        
      )
      
      
      REM - Delete the folder if already present
      if exist ".\extracted_exports\%%B\%%C" (
        rd /S /Q ".\extracted_exports\%%B\%%C"
      )
      
      REM - And move the folder
      move ".\extracted_exports\!foldername!\%%B\%%C" ".\extracted_exports\%%B" >nul
    )
    
  )
  
  
  REM - Common folder
  if /i "%%B"=="Common" (
  
    set folder_type_found=1
    
    REM - Create the main folder if not present
    if not exist ".\extracted_exports\%%B" (
      md ".\extracted_exports\%%B" 2>nul
    )
    
    REM - First check that it isn't empty
    set movecommon=
    >nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\Common\*" && (set movecommon=1) || (echo ->nul)
    
    if defined movecommon (
    
      REM - Make a team folder with the team name after deleting it if already present
      if exist ".\extracted_exports\%%B\!team_clean!\" (
        rd /S /Q ".\extracted_exports\%%B\!team_clean!"
      )
      md ".\extracted_exports\%%B\!team_clean!" 2>nul
    
      REM - Move everything to that folder
      for /f "tokens=*" %%C in ('dir /b ".\extracted_exports\!foldername!\%%B" 2^>nul') do (
        
        move ".\extracted_exports\!foldername!\%%B\%%C" ".\extracted_exports\%%B\!team_clean!" >nul
      )
    )
    
  )
  
  
  REM - Other folder
  if /i "%%B"=="Other" (
  
    set folder_type_found=1
    
    REM - Create the main folder if not present
    if not exist ".\extracted_exports\%%B" (
      md ".\extracted_exports\%%B" 2>nul
    )
    
    REM - First check that it isn't empty
    set moveother=
    >nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\Other\*" && (set moveother=1) || (echo ->nul)
  
    if defined moveother (
    
      REM - Make a team folder with the team id and name after deleting it if already present
      if exist ".\extracted_exports\%%B\!teamid! - !team_clean!\" (
        rd /S /Q ".\extracted_exports\%%B\!teamid! - !team_clean!"
      )
      md ".\extracted_exports\%%B\!teamid! - !team_clean!" 2>nul
    
      REM - Move everything to that folder
      for /f "tokens=*" %%C in ('dir /b ".\extracted_exports\!foldername!\%%B" 2^>nul') do (
        
        move ".\extracted_exports\!foldername!\%%B\%%C" ".\extracted_exports\%%B\!teamid! - !team_clean!" >nul
      )
    )
    
  )
  
  
  REM - If the folder is out of the AET specifics
  if not defined folder_type_found (
    
    REM - Look for it later to avoid the Other folder getting reset
    set folder_unknown_pres=1
  )
  
)


REM - If there were any unknown folders
if defined folder_unknown_pres (

  REM - Look for it
  for /f "tokens=*" %%B in ('dir /a:d /b ".\extracted_exports\!foldername!" 2^>nul') do (

    set folder_type_found=
    
    if /i "%%B"=="Faces"        set folder_type_found=1
    if /i "%%B"=="Kit Configs"  set folder_type_found=1
    if /i "%%B"=="Kit Textures" set folder_type_found=1
    if /i "%%B"=="Logo"         set folder_type_found=1
    if /i "%%B"=="Portraits"    set folder_type_found=1
    if /i "%%B"=="Boots"        set folder_type_found=1
    if /i "%%B"=="Gloves"       set folder_type_found=1
    if /i "%%B"=="Common"       set folder_type_found=1
    if /i "%%B"=="Other"        set folder_type_found=1
    
    REM - If the folder was found
    if not defined folder_type_found (
    
      REM - First check that it isn't empty
      set moveother=
      >nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\%%B\*" && (set moveother=1) || (echo ->nul)
    
      if defined moveother (
      
        REM - Make a team folder in Other for the team if none is present
        if not exist ".\extracted_exports\Other\!teamid! - !team_clean!\" (
          md ".\extracted_exports\Other\!teamid! - !team_clean!" 2>nul
        )
        
        REM - Delete the folder if already present
        if exist ".\extracted_exports\Other\!teamid! - !team_clean!\%%B\" (
          rd /S /Q ".\extracted_exports\Other\!teamid! - !team_clean!\%%B"
        )
        
        REM - And move it
        move ".\extracted_exports\!foldername!\%%B" ".\extracted_exports\Other\!teamid! - !team_clean!" >nul
      )
    )
    
  )
)


