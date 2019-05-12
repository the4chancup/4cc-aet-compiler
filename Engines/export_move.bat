REM - Move the contents of the export to the root of extracted_exports

REM - Move everything except the folders
for /f "tokens=*" %%B in ('dir /a:-d /b ".\extracted_exports\!foldername!" 2^>nul') do (

  move ".\extracted_exports\!foldername!\%%B" ".\extracted_exports" >nul
)

REM - Move the folders' contents
set unknownexists=

for /f "tokens=*" %%B in ('dir /a:d /b ".\extracted_exports\!foldername!" 2^>nul') do (

  set unknown=1

  REM - Face folder
  if /i "%%B"=="Faces" (
  
    set unknown=
    
    REM - For each face folder
    for /f "tokens=*" %%C in ('dir /a:d /b ".\extracted_exports\!foldername!\%%B" 2^>nul') do (
      
      REM - Delete the folder if already present
      if exist ".\extracted_exports\%%B\%%C" (
        rd /S /Q ".\extracted_exports\%%B\%%C"
      )
      
      REM - And move the face folder
      move ".\extracted_exports\!foldername!\%%B\%%C" ".\extracted_exports\%%B" >nul
    )
  )
  
  REM - Kit Configs folder
  if /i "%%B"=="Kit Configs" (
  
    set unknown=
    
    REM - Delete the folder if already present
    if exist ".\extracted_exports\Kit Configs\!id!" (
      rd /S /Q ".\extracted_exports\Kit Configs\!id!"
    )
    
    REM - And move the kit config folder
    move ".\extracted_exports\!foldername!\%%B\!id!" ".\extracted_exports\%%B" >nul
    
  )
  
  REM - Kit Textures folder
  if /i "%%B"=="Kit Textures" (
  
    set unknown=
    
    REM - Move everything directly
    for /f "tokens=*" %%C in ('dir /a:-d /b ".\extracted_exports\!foldername!\%%B" 2^>nul') do (
      
      move ".\extracted_exports\!foldername!\%%B\%%C" ".\extracted_exports\%%B" >nul
    )
  )
  
  REM - Boots folder
  if /i "%%B"=="Boots" (
  
    set unknown=
    
    REM - For each boots folder
    for /f "tokens=*" %%C in ('dir /a:d /b ".\extracted_exports\!foldername!\%%B" 2^>nul') do (
      
      REM - Delete the folder if already present
      if exist ".\extracted_exports\%%B\%%C" (
        rd /S /Q ".\extracted_exports\%%B\%%C"
      )
      
      REM - And move the boots folder
      move ".\extracted_exports\!foldername!\%%B\%%C" ".\extracted_exports\%%B" >nul
    )
  )
  
  REM - Gloves folder
  if /i "%%B"=="Gloves" (
  
    set unknown=
    
    REM - For each gloves folder
    for /f "tokens=*" %%C in ('dir /a:d /b ".\extracted_exports\!foldername!\%%B" 2^>nul') do (
      
      REM - Delete the folder if already present
      if exist ".\extracted_exports\%%B\%%C" (
        rd /S /Q ".\extracted_exports\%%B\%%C"
      )
      
      REM - And move the gloves folder
      move ".\extracted_exports\!foldername!\%%B\%%C" ".\extracted_exports\%%B" >nul
    )
  )
  
  REM - Logo folder
  if /i "%%B"=="Logo" (
  
    set unknown=
    
    REM - Move everything directly
    for /f "tokens=*" %%C in ('dir /a:-d /b ".\extracted_exports\!foldername!\%%B" 2^>nul') do (
      
      move ".\extracted_exports\!foldername!\%%B\%%C" ".\extracted_exports\%%B" >nul
    )
  )
  
  REM - Other folder
  if /i "%%B"=="Other" (
  
    set unknown=
    
    REM - First check that it isn't empty
    set moveother=
    >nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\Other\*" && (set moveother=1) || (echo ->nul)
  
    if defined moveother (
    
      REM - Make a team folder with the team id and name after deleting it if already present
      if exist ".\extracted_exports\%%B\!id! - !team_clean!\" (
        rd /S /Q ".\extracted_exports\%%B\!id! - !team_clean!"
      )
      md ".\extracted_exports\%%B\!id! - !team_clean!" 2>nul
    
      REM - Move everything to that folder
      for /f "tokens=*" %%C in ('dir /a:-d /b ".\extracted_exports\!foldername!\%%B" 2^>nul') do (
        
        move ".\extracted_exports\!foldername!\%%B\%%C" ".\extracted_exports\%%B\!id! - !team_clean!" >nul
      )
    )
    
  )
  
  REM - If the folder is out of the AET specifics
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
    if /i "%%B"=="Kit Configs" set unknown=
    if /i "%%B"=="Kit Textures" set unknown=
    if /i "%%B"=="Boots" set unknown=
    if /i "%%B"=="Gloves" set unknown=
    if /i "%%B"=="Logo" set unknown=
    if /i "%%B"=="Other" set unknown=
    
    REM - If the folder was found
    if defined unknown (
    
      REM - First check that it isn't empty
      set moveother=
      >nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\%%B\*" && (set moveother=1) || (echo ->nul)
    
      if defined moveother (
      
        REM - Make a team folder in Other for the team if none is present
        if not exist ".\extracted_exports\Other\!id! - !team_clean!\" (
          md ".\extracted_exports\Other\!id! - !team_clean!" 2>nul
        )
        
        REM - Delete the folder if already present
        if exist ".\extracted_exports\Other\!id! - !team_clean!\%%B\" (
          rd /S /Q ".\extracted_exports\Other\!id! - !team_clean!\%%B"
        )
        
        REM - And move it
        move ".\extracted_exports\!foldername!\%%B" ".\extracted_exports\Other\!id! - !team_clean!" >nul
      )
    )
    
  )
)