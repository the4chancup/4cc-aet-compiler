REM - Looks for the team ID

REM - Reset the main flags
set error=
set not_root=
set root_found=


REM - Check if the folders are at the root by searching for a note txt, the faces and kit configs folders first
if exist ".\extracted_exports\!foldername!\*.txt"        (set root_found=1)
if exist ".\extracted_exports\!foldername!\Faces"        (set root_found=1)
if exist ".\extracted_exports\!foldername!\Kit Configs"  (set root_found=1)
if exist ".\extracted_exports\!foldername!\Kit Textures" (set root_found=1)
if exist ".\extracted_exports\!foldername!\Portraits"    (set root_found=1)
if exist ".\extracted_exports\!foldername!\Boots"        (set root_found=1)
if exist ".\extracted_exports\!foldername!\Gloves"       (set root_found=1)
if exist ".\extracted_exports\!foldername!\Collars"      (set root_found=1)
if exist ".\extracted_exports\!foldername!\Logo"         (set root_found=1)
if exist ".\extracted_exports\!foldername!\Common"       (set root_found=1)
if exist ".\extracted_exports\!foldername!\Other"        (set root_found=1)


REM - If the folders aren't at the root
if not defined root_found (
  
  REM - Look in every folder for a faces or kit configs folder
  for /f "tokens=*" %%R in ('dir /a:d /b ".\extracted_exports\!foldername!" 2^>nul') do (
  
    if exist ".\extracted_exports\!foldername!\%%R\*.txt"        (set root_found=1)
    if exist ".\extracted_exports\!foldername!\%%R\Faces"        (set root_found=1)
    if exist ".\extracted_exports\!foldername!\%%R\Kit Configs"  (set root_found=1)
    if exist ".\extracted_exports\!foldername!\%%R\Kit Textures" (set root_found=1)
    if exist ".\extracted_exports\!foldername!\%%R\Portraits"    (set root_found=1)
    if exist ".\extracted_exports\!foldername!\%%R\Boots"        (set root_found=1)
    if exist ".\extracted_exports\!foldername!\%%R\Gloves"       (set root_found=1)
    if exist ".\extracted_exports\!foldername!\%%R\Collars"      (set root_found=1)
    if exist ".\extracted_exports\!foldername!\%%R\Logo"         (set root_found=1)
    if exist ".\extracted_exports\!foldername!\%%R\Common"       (set root_found=1)
    if exist ".\extracted_exports\!foldername!\%%R\Other"        (set root_found=1)
    
    if defined root_found (
    
      set not_root=1
      set foldername_inside=%%R
      
    )
    
  )
)


REM - If there's no files anywhere
if not defined root_found (
  
  REM - Skip the whole export
  if not %pass_through%==1 (
  
    set error=1
    rd /S /Q ".\extracted_exports\!foldername!"
  
  )
  
  echo - >> memelist.txt
  echo - !team!'s manager needs to get memed on (no files^) - Export discarded. >> memelist.txt
  set memelist=1
  
  if not %pause_when_wrong%==0 (
    
    echo - 
    echo - !team!'s manager needs to get memed on (no files^).
    echo - This export will be discarded.
    echo - 
    echo - Closing the script's window and fixing the export is recommended.
    echo - 
    
    pause
    
  )

)


REM - If the export is usable, continue
if not defined error (

  REM - Reset the flag for usable team name found
  set team_name_good=
  
  
  REM - If the folders are not at the root
  if defined not_root (

    REM - Move the stuff to the root
    for /f "tokens=*" %%C in ('dir /b ".\extracted_exports\!foldername!\!foldername_inside!"') do (
      move ".\extracted_exports\!foldername!\!foldername_inside!\%%C" ".\extracted_exports\!foldername!" >nul
    )
    
    REM - Delete the now empty folder
    rd /S /Q ".\extracted_exports\!foldername!\!foldername_inside!"
  )

  
  REM - Look for a txt file with Note in the filename
  set note_found=
  
  for /f "tokens=*" %%C in ('dir /a:-d /b ".\extracted_exports\!foldername!\*.txt" 2^>nul') do (
  
    set txt_name=%%C
    set txt_name_noteless=!txt_name:Note=!
    
    REM - If the file has Note in the filename rename it with the team name and store its name
    if not "!txt_name_noteless!"=="!txt_name!" (
    
      set note_found=1
      set note_name=!team_raw! Note.txt
      rename ".\extracted_exports\!foldername!\!txt_name!" "!note_name!" >nul
      
    )
  )
  
  
  REM - If there's a Note file try to get the team name from it
  if defined note_found (
  
    set team_name_found=
    
    for /f "tokens=1-2 usebackq" %%X in (".\extracted_exports\!foldername!\!note_name!") do (
      
      if not defined team_name_found (
        
        if /i "%%X"=="Team:" (
          
          set team_name_found=1
          set team_name=%%Y
          
        )
        
        if "%%Y"=="" (
          
          set team_name_found=1
          set team_name=%%X
          
        )
        
      )
    )
    
    if defined team_name_found (
    
      REM - If the name on the note file is different than the one on the export foldername print it
      if /i not !team_name! == !team! (
          <nul set /p =- Actual name: !team_name! 
      )
      
      REM - Search for the team ID on the list of team names
      for /f "tokens=1,* skip=1 usebackq" %%U in (".\teams_list.txt") do (
        
        if not defined team_name_good (
        
          if /i "!team_name!"=="%%V" (
          
            set teamid=%%U
            set team_name_good=1
            
          )
        )
      )

    )
    
  )
  
  
  REM - If there's no Note file or no usable team name was found on it
  if not defined team_name_good (
    
    REM - Check if the team name taken from the export foldername with brackets added is on the list
    for /f "tokens=1,* skip=1 usebackq" %%U in (".\teams_list.txt") do (
      
      if not defined team_name_good (
      
        if /i "!team!"=="%%V" (
        
          set teamid=%%U
          set team_name_good=1
          
        )
      )
    )
    
  )
  
  
  REM - If no usable team name was found even then
  if not defined team_name_good (
  
    REM - Skip the whole export
    if not %pass_through%==1 (
      
      set error=1
      rd /S /Q ".\extracted_exports\!foldername!"
      
    )
    
    echo - >> memelist.txt
    echo - !team!'s manager needs to get memed on (unusable team name^) - Export discarded. >> memelist.txt
    set memelist=1
    
    echo - 
    echo - !team!'s manager needs to get memed on (unusable team name^).
    echo - The team name was not found on the teams_list txt file.
    echo - This export will be discarded to prevent conflicts.
    echo - Adding the team name to the teams_list file and
    echo - restarting the script is recommended.
    echo - 
    
    if not %pause_when_wrong%==0 (
      pause
    )
    
  ) else (
  
    echo (ID: !teamid!^)
  )
  
)

