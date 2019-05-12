REM - Check the export for every kind of errors

REM - Reset error flags
set error=1
set not_root=
set nestederror=
set faceserror=
set bootserror=
set gloveserror=

REM - Check if the folders are at the root by searching for the txt file first
if exist ".\extracted_exports\!foldername!\*.txt" (
  set error=
)

REM - If there isn't a txt file at the root
if defined error (
  
  REM - Look in every folder for a txt file
  for /f "tokens=*" %%R in ('dir /a:d /b ".\extracted_exports\!foldername!"') do (
  
    if exist ".\extracted_exports\!foldername!\%%R\*.txt" (
      
      set error=
      set foldername2=%%R
      set not_root=1
    )
  )
)
  
REM - If there's no txt file anywhere
if defined error (
  
  REM - Skip the whole export
  if not %pass_through%==1 (
    rd /S /Q ".\extracted_exports\!foldername!"
  
  ) else (
    set error=
  )
  
  @echo - >> memelist.txt
  @echo - !team!'s manager needs to get memed on (no txt file^) - Export discarded >> memelist.txt
  set memelist=1
  
  if not %pause_when_wrong%==0 (
    
    @echo - 
    @echo - !team!'s manager needs to get memed on (no txt file^)
    @echo - This export will be discarded to prevent conflicts,
    @echo - unless you choose to input the team's ID now
    @echo - 
    @echo - Stopping the script and fixing the export is recommended
    @echo - 
    
    pause
    
  )

)

REM - If the txt was found, continue
if not defined error (

  REM - If the folders are not at the root
  if defined not_root (

    REM - Move the stuff to the root
    for /f "tokens=*" %%B in ('dir /b ".\extracted_exports\!foldername!\!foldername2!"') do (
      move ".\extracted_exports\!foldername!\!foldername2!\%%B" ".\extracted_exports\!foldername!" >nul
    )
    
    REM - Delete the now empty folder
    rd /S /Q ".\extracted_exports\!foldername!\!foldername2!"
  )

  REM - Look for the txt file
  for /f "tokens=*" %%C in ('dir /a:-d /b ".\extracted_exports\!foldername!\*.txt"') do set txtname=%%C
  
  REM - Get the team's ID from the txt file
  set error=1
  set stop=
  
  for /f "tokens=1-2 usebackq" %%X in (".\extracted_exports\!foldername!\!txtname!") do (
    
    if not defined stop (
      
      if "%%X"=="ID:" (
        
        set error=
        set stop=1
        set /a id=%%Y
      )
      
      if "%%Y"=="" (
        
        set error=
        set stop=1
        set /a id=%%X
      )
      
      REM - Also check that the team ID is in the range 701-892
      if !id! LSS 701 (
        
        set error=1
        set stop=
      )
      if !id! GTR 892 (
        
        set error=1
        set stop=
      )
      
    )
  )

  REM - If there's no usable team ID
  if defined error (

    REM - Skip the whole export
    if not %pass_through%==1 (
      rd /S /Q ".\extracted_exports\!foldername!"
    ) else (
      set error=
    )
    
    @echo - >> memelist.txt
    @echo - !team!'s manager needs to get memed on (missing or unusable team ID^) - Export discarded >> memelist.txt
    set memelist=1
    
    @echo - 
    @echo - !team!'s manager needs to get memed on (missing or unusable team ID^)
    @echo - (txt files in the unsupported unicode format can cause this too^)
    @echo - This export will be discarded to prevent conflicts
    @echo - Stopping the script and fixing it is recommended
    @echo - 
    
    if not %pause_when_wrong%==0 (
      pause
    )
    
  )
  
)

REM - If the id was found and is in range, continue
if not defined error (
  
  REM - Check that the team ID doesn't conflict with another team's
  for /f "tokens=1-2 usebackq" %%V in (".\Engines\teamlist.txt") do (
    if not defined error (
      if "%%W"=="!id!" (
        set error=1
        set conflictteam=%%V
      )
    )
  )

  REM - If the team ID is in conflict
  if defined error (
    
    REM - Skip the whole export
    if not %pass_through%==1 (
      rd /S /Q ".\extracted_exports\!foldername!"
    ) else (
      set error=
    )
    
    @echo - >> memelist.txt
    @echo - The IDs of !conflictteam! and !team! are in conflict (ID: !id!^) - !team!'s export discarded >> memelist.txt
    set memelist=1
    
    @echo -
    @echo - The IDs of !conflictteam! and !team! are in conflict (ID: !id!^)
    @echo - !team!'s export will be discarded
    @echo - Stopping the script and fixing the conflict is recommended
    @echo -
    
    if not %pause_when_wrong%==0 (
      pause
    )
    
  REM - If the id is not in conflict
  ) else (

    REM - Add the team ID to the list
    @echo !team! !id! >> .\Engines\teamlist.txt
  )
)

REM - Soft checks start here -
REM - These checks don't discard the whole export, only parts of it


if not defined error (
  
  REM - Check for nested folders with repeating names
  for /f "tokens=*" %%D in ('dir /a:d /b ".\extracted_exports\!foldername!"') do (
    for  /f "tokens=*" %%E in ('dir /b ".\extracted_exports\!foldername!\%%D"') do (
      
      REM - If the folder has the same name as its parent folder
      if /i "%%E"=="%%D" (
        
        REM - (Except for the Other folder)
        if /i not "%%E"=="Other" (
          
          REM - Try to fix it, but warn about it later
          set nestederror=1
          
          REM - Move the stuff in the folder back one folder
          for /f "tokens=*" %%F in ('dir /b ".\extracted_exports\!foldername!\%%D\%%E"') do (
            move ".\extracted_exports\!foldername!\%%D\%%E\%%F" ".\extracted_exports\!foldername!\%%D" >nul
          )
          
          REM - Delete the now empty folder
          rd /S /Q ".\extracted_exports\!foldername!\%%D\%%E"
        )
      )
    )
  )
  
  REM - If something was wrong
  if defined nestederror (
  
    @echo - >> memelist.txt
    @echo - !team!'s manager needs to get memed on (wrongly nested folders^) >> memelist.txt
    set memelist=1
    
    @echo -
    @echo - !team!'s manager needs to get memed on (wrongly nested folders^)
    @echo - An attempt to automatically fix those folders has just been done
    @echo - Nothing has been discarded, though problems may still arise
    @echo -
    
    if not %pause_when_wrong%==0 (
      pause
    )
  )
  
)


if not defined error ( 

  REM - Check that the face folder names are correct
  if exist ".\extracted_exports\!foldername!\Faces" (
    
    for /f "tokens=*" %%G in ('dir /b ".\extracted_exports\!foldername!\Faces"') do (
      
      set facewrong=
      set facename=%%G
      
      if not "!facename:~0,3!"=="!id!" set facewrong=1
      if /i "!facename:~3,2!"=="XX" set facewrong=1
      
      if not defined facewrong (
        
        set facewrong=1

        REM - If the folder is in legacy format check the internal face folders too
        if exist ".\extracted_exports\!foldername!\Faces\!facename!\common" (
          
          if exist ".\extracted_exports\!foldername!\Faces\!facename!\common\character0\model\character\face\real\!facename!\face.xml" (
            set facewrong=
          )
          if exist ".\extracted_exports\!foldername!\Faces\!facename!\common\character0\model\character\face\real\!facename!\face_edithair.xml" (
            set facewrong=
          )
          
          if not defined facewrong (
            
            REM - And simplify the folder              
            for /f "tokens=*" %%H in ('dir /b ".\extracted_exports\!foldername!\Faces\!facename!\common\character0\model\character\face\real\!facename!"') do (
              
              move ".\extracted_exports\!foldername!\Faces\!facename!\common\character0\model\character\face\real\!facename!\%%H" ".\extracted_exports\!foldername!\Faces\!facename!" >nul
            )
            
            REM - Delete the now empty structure of folders
            rd /S /Q ".\extracted_exports\!foldername!\Faces\!facename!\common"
          )
        
        ) else (
          
          REM - Otherwise just check that the folder has a face.xml or a face_edithair.xml file
          if exist ".\extracted_exports\!foldername!\Faces\!facename!\face.xml" (
            set facewrong=
          )
          if exist ".\extracted_exports\!foldername!\Faces\!facename!\face_edithair.xml" (
            set facewrong=
          )
        )
        
      )
      
      if defined facewrong (
        
        if not defined faceserror (
          
          set faceserror=1
          
          @echo - >> memelist.txt
          @echo - !team!'s manager needs to get memed on (wrong face folder names^) >> memelist.txt
          set memelist=1
          
          @echo -
          @echo - !team!'s manager needs to get memed on (wrong face folder names^)
        ) 
        
        REM - If a face folder is named wrongly skip it
        if not %pass_through%==1 (
          rd /S /Q ".\extracted_exports\!foldername!\Faces\!facename!"
        )
        
        @echo - The face folder !facename! is wrong - Folder discarded >> memelist.txt
        
        @echo - The face folder !facename! is wrong
      )
    )
  )
  
  if defined faceserror (

    @echo - The face folders mentioned above will be discarded to prevent conflicts
    @echo - Stopping the script and fixing them is recommended
    @echo -
    
    if not %pause_when_wrong%==0 (
      pause
    )      
  )
  
)


if not defined error (

  REM - Check that the team config folder name is correct
  if exist ".\extracted_exports\!foldername!\Kits\Kit Configs" (
  
    if not exist ".\extracted_exports\!foldername!\Kits\Kit Configs\!id!" (
    
      REM - If the team config folder is named wrongly skip the kit configs folder
      if not %pass_through%==1 (
        rd /S /Q ".\extracted_exports\!foldername!\Kits\Kit Configs"
      )
      
      @echo - >> memelist.txt
      @echo - !team!'s manager needs to get memed on (wrong kit config folder name^) - Kit Configs discarded >> memelist.txt
      set memelist=1
      
      @echo -
      @echo - !team!'s manager needs to get memed on (wrong kit config folder name^)
      @echo - The Kit Configs folder will be discarded to prevent conflicts
      @echo - Stopping the script and fixing it is recommended
      @echo -
      
      if not %pause_when_wrong%==0 (
        pause
      )
    )
    
  )
)


if not defined error (

  REM - Check that the boot folder names are correct
  if exist ".\extracted_exports\!foldername!\Other\Boots" (
    for /f "tokens=*" %%I in ('dir /b ".\extracted_exports\!foldername!\Other\Boots"') do (
      
      set bootwrong=
      set bootsname=%%I
      
      if /i not "!bootsname:~0,1!"=="k" (
        set bootwrong=1
        
      ) else (
        
        call .\Engines\CharLib strlen bootsname len_bootsname
        if not "!len_bootsname!"=="5" set bootwrong=1
      )
      
      if defined bootwrong (
        
        if not defined bootserror (
          
          set bootserror=1
          
          @echo - >> memelist.txt
          @echo - !team!'s manager needs to get memed on (wrong boot folder names^) >> memelist.txt
          set memelist=1
          
          @echo -
          @echo - !team!'s manager needs to get memed on (wrong boot folder names^)
        ) 
        
        REM - If a boot folder is named wrongly skip it
        if not %pass_through%==1 (
          rd /S /Q ".\extracted_exports\!foldername!\Other\Boots\!bootsname!"
        )
        
        @echo - The boot folder !bootsname! is wrong - Folder discarded >> memelist.txt
        
        @echo - The boot folder !bootsname! is wrong
      )
    )
  )
  
  if defined bootserror (

    @echo - The boot folders mentioned above will be discarded since they're unusable
    @echo - Stopping the script and fixing them is recommended
    @echo -
    
    if not %pause_when_wrong%==0 (
      pause
    )
    
  )
)


if not defined error (  
  
  REM - Check that the glove folder names are correct
  if exist ".\extracted_exports\!foldername!\Other\Gloves" (
    for /f "tokens=*" %%J in ('dir /b ".\extracted_exports\!foldername!\Other\Gloves"') do (
      
      set glovewrong=
      set glovesname=%%J
      
      if /i not "!glovesname:~0,1!"=="g" (
        set glovewrong=1
        
      ) else (
        
        call .\Engines\CharLib strlen glovesname len_glovesname
        if not "!len_glovesname!"=="4" set glovewrong=1
      )
      
      if defined glovewrong (
        
        if not defined gloveserror (
          
          set gloveserror=1
          
          @echo - >> memelist.txt
          @echo - !team!'s manager needs to get memed on (wrong glove folder names^) >> memelist.txt
          set memelist=1
          
          @echo -
          @echo - !team!'s manager needs to get memed on (wrong glove folder names^)
        ) 
        
        REM - If a glove folder is named wrongly skip it
        if not %pass_through%==1 (
          rd /S /Q ".\extracted_exports\!foldername!\Other\Boots\!glovesname!"
        )
        
        @echo - The glove folder !glovesname! is wrong - Folder discarded  >> memelist.txt
        
        @echo - The glove folder !glovesname! is wrong
      )
    )
  )
  
  if defined gloveserror (

    @echo - The glove folders mentioned above will be discarded since they're unusable
    @echo - Stopping the script and fixing them is recommended
    @echo -
    
    if not %pause_when_wrong%==0 (
      pause
    )      
  )

)

