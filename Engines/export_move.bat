REM - Move the contents of the export to the root of extracted_exports

REM - Move everything except the folders
for /f "tokens=*" %%A in ('dir /a:-d /b ".\extracted_exports\!foldername!" 2^>nul') do (
  move ".\extracted_exports\!foldername!\%%A" .\extracted_exports >nul
)

REM - Move the folders' content
set unknownexists=

for /f "tokens=*" %%B in ('dir /a:d /b ".\extracted_exports\!foldername!" 2^>nul') do (

  set unknown=1

  REM - Faces are directly in the Face folder
  if /i "%%B"=="Faces" (
  
    set unknown=
    
    REM - For each face folder
    for /f "tokens=*" %%C in ('dir /a:d /b ".\extracted_exports\!foldername!\%%B" 2^>nul') do (
      
      REM - Delete the folder if already present
      if exist ".\extracted_exports\Faces\%%C" (
        rd /S /Q ".\extracted_exports\Faces\%%C"
      )
      
      REM - And move the face folder
      move ".\extracted_exports\!foldername!\%%B\%%C" ".\extracted_exports\Faces" >nul
    )
  )
  
  REM - The Kits folder has a second layer
  if /i "%%B"=="Kits" (
  
    set unknown=
    
    REM - For each folder
    for /f "tokens=*" %%C in ('dir /b ".\extracted_exports\!foldername!\%%B" 2^>nul') do (
      
      REM - First check the kind of folder
      set check_foldername=%%C
      
      set check_test=!check_foldername:Config=!
      
      REM - If the folder has the kit configs
      if not "!check_test!"=="!check_foldername!" (
      
        REM - Look for every folder inside
        for /f "tokens=*" %%D in ('dir /b ".\extracted_exports\!foldername!\%%B\%%C" 2^>nul') do (
          
          REM - Delete the folder if already present
          if exist ".\extracted_exports\Kits\Kit Configs\%%D\" (
            rd /S /Q ".\extracted_exports\Kits\Kit Configs\%%D"
          )
          
          REM - And move the config folder
          move ".\extracted_exports\!foldername!\%%B\%%C\%%D" ".\extracted_exports\Kits\Kit Configs" >nul
        )
      )
      
      set check_test=!check_foldername:Texture=!
      
      REM - If the folder has the kit textures
      if not "!check_test!"=="!check_foldername!" (
      
        REM - Move everything directly
        for /f "tokens=*" %%D in ('dir /a:-d /b ".\extracted_exports\!foldername!\%%B\%%C" 2^>nul') do (
          
          REM - Unless it's a fucking Thumbs.db file
          set check_filename=%%D
          
          if /i not "!check_filename!"=="Thumbs.db" (
            move ".\extracted_exports\!foldername!\%%B\%%C\%%D" ".\extracted_exports\Kits\Kit Textures" >nul
          )
        )
      )
      
    )
  )
  
  REM - The Other folder has a second layer
  if /i "%%B"=="Other" (
  
    set unknown=
    
    REM - For each folder
    for /f "tokens=*" %%C in ('dir /b ".\extracted_exports\!foldername!\%%B" 2^>nul') do (
      
      REM - Check if it's empty
      set empty=
      
      dir /b /a ".\extracted_exports\!foldername!\%%B\%%C\*" | >nul findstr "^" && (echo ->nul) || (set empty=1)
      
      if not defined empty (
      
        REM - First check the kind of folder
        set check_foldername=%%C
        
        set check_test=!check_foldername:Boot=!
        
        REM - If the folder has boots
        if not "!check_test!"=="!check_foldername!" (
        
          REM - Look for every folder inside
          for /f "tokens=*" %%D in ('dir /a:d /b ".\extracted_exports\!foldername!\%%B\%%C" 2^>nul') do (
            
            REM - Delete the folder if already present
            if exist ".\extracted_exports\Other\Boots\%%D\" (
              rd /S /Q ".\extracted_exports\Other\Boots\%%D"
            )
            
            REM - And move the config folder
            move ".\extracted_exports\!foldername!\%%B\%%C\%%D" ".\extracted_exports\Other\Boots" >nul
          )
        )
        
        set check_test=!check_foldername:Glove=!
        
        REM - If the folder has gloves
        if not "!check_test!"=="!check_foldername!" (
        
          REM - Look for every folder inside
          for /f "tokens=*" %%D in ('dir /a:d /b ".\extracted_exports\!foldername!\%%B\%%C" 2^>nul') do (
            
            REM - Delete the folder if already present
            if exist ".\extracted_exports\Other\Gloves\%%D\" (
              rd /S /Q ".\extracted_exports\Other\Gloves\%%D"
            )
            
            REM - And move the config folder
            move ".\extracted_exports\!foldername!\%%B\%%C\%%D" ".\extracted_exports\Other\Gloves" >nul
          )
        )
        
        set check_test=!check_foldername:Other=!
        
        REM - If the folder has other stuff
        if not "!check_test!"=="!check_foldername!" (
        
          REM - First check that it isn't empty
          set moveother=
          >nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\%%B\%%C\*" && (set moveother=1) || (echo ->nul)
        
          if defined moveother (
        
            REM - Make a folder for the team after deleting any previously present one
            if exist ".\extracted_exports\Other\Other\!team_clean!\" (
              rd /S /Q ".\extracted_exports\Other\Other\!team_clean!\"
            )
            md ".\extracted_exports\Other\Other\!team_clean!\" 2>nul
          
            REM - Move everything directly
            for /f "tokens=*" %%D in ('dir /a:-d /b ".\extracted_exports\!foldername!\%%B\%%C" 2^>nul') do (
              move ".\extracted_exports\!foldername!\%%B\%%C\%%D" ".\extracted_exports\Kits\Kit Textures" >nul
            )
          )
        )
        
      )
    )
  )
  
  REM - If the folder is something out of the AET specifics
  if defined unknown (
  
    REM - Look for it later to avoid the Other folder getting reset
    set unknownexists=1
  )
  
)

REM - If there were any unknown folders
if defined unknownexists (

  REM - Look for it
  for /f "tokens=*" %%B in ('dir /a:d /b ".\extracted_exports\!foldername!" 2^>nul') do (

    set unknown=1
    
    if /i "%%B"=="Faces" set unknown=
    if /i "%%B"=="Kits" set unknown=
    if /i "%%B"=="Other" set unknown=
    
    REM - If the folder was found
    if defined unknown (
    
      REM - First check that it isn't empty
      set moveother=
      >nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\%%B\*" && (set moveother=1) || (echo ->nul)
    
      if defined moveother (
      
        REM - Make a folder in Other\Other for the team if none is present
        if not exist ".\extracted_exports\Other\Other\!team_clean!\" (
          md ".\extracted_exports\Other\Other\!team_clean!\" 2>nul
        )
        
        REM - Move the folder after deleting any previously present one
        if exist ".\extracted_exports\Other\Other\!team_clean!\%%B\" (
          rd /S /Q ".\extracted_exports\Other\Other\!team_clean!\%%B"
        )
        
        move ".\extracted_exports\!foldername!\%%B" ".\extracted_exports\Other\Other\!team_clean!" >nul
      )
      
    )
    
  )
)