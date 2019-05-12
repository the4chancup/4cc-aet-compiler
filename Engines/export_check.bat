REM - Check the export for every kind of errors

REM - Reset the main error flags
set error=1
set not_root=


REM - Check if the folders are at the root by searching for the txt file first
if exist ".\extracted_exports\!foldername!\*.txt" (
  set error=
)

REM - If there isn't a txt file at the root
if defined error (
  
  REM - Look in every folder for a txt file
  for /f "tokens=*" %%R in ('dir /a:d /b ".\extracted_exports\!foldername!" 2^>nul') do (
  
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
    @echo - This export will be discarded to prevent conflicts
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
    for /f "tokens=*" %%C in ('dir /b ".\extracted_exports\!foldername!\!foldername2!"') do (
      move ".\extracted_exports\!foldername!\!foldername2!\%%C" ".\extracted_exports\!foldername!" >nul
    )
    
    REM - Delete the now empty folder
    rd /S /Q ".\extracted_exports\!foldername!\!foldername2!"
  )

  
  REM - Look for a txt file with Note in the filename
  for /f "tokens=*" %%C in ('dir /a:-d /b ".\extracted_exports\!foldername!\*.txt"') do (
  
    set check_filename=%%C
    set check_test=!check_filename:Note=!
    
    REM - If the file has Note in the filename store its name
    if not "!check_test!"=="!check_filename!" (
      set txtname=%%C
    )
  )
  
  
  REM - Get the team's name from the txt file
  set error=1
  set stop=
  
  for /f "tokens=1-2 usebackq" %%X in (".\extracted_exports\!foldername!\!txtname!") do (
    
    if not defined stop (
      
      if /i "%%X"=="Team:" (
        
        set stop=1
        set name=%%Y
      )
      
      if "%%Y"=="" (
        
        set stop=1
        set name=%%X
      )
      
    )
  )
  
  REM - Search for the team ID in the list of team names
  for /f "tokens=1,* skip=1 usebackq" %%U in (".\teams_list.txt") do (
    if defined error (
      if /i "!name!"=="%%V" (
        set teamid=%%U
        set error=
      )
    )
  )
  
  REM - If no team ID was found
  if defined error (

    REM - Skip the whole export
    if not %pass_through%==1 (
      rd /S /Q ".\extracted_exports\!foldername!"
    ) else (
      set error=
    )
    
    @echo - >> memelist.txt
    @echo - !team!'s manager needs to get memed on (unusable team name^) - Export discarded >> memelist.txt
    set memelist=1
    
    @echo -
    @echo - !team!'s manager needs to get memed on (unusable team name^)
    @echo - (txt files in the unsupported unicode format can cause this too^)
    @echo - This export will be discarded to prevent conflicts
    @echo - Adding the team name to the teams_list file and restarting the script
    @echo - is recommended
    @echo - 
    
    if not %pause_when_wrong%==0 (
      pause
    )
    
  ) else (
  
    @echo (ID: !teamid!^)
  )
  
)


REM - If the id was found, continue

REM - Soft checks start here -
REM - These checks don't discard the whole export, only parts of it


if not defined error (
  
  REM - Check for nested folders with repeating names
  set nestederror=
  
  for /f "tokens=*" %%D in ('dir /a:d /b ".\extracted_exports\!foldername!" 2^>nul') do (
    
    for  /f "tokens=*" %%E in ('dir /a:d /b ".\extracted_exports\!foldername!\%%D" 2^>nul') do (
      
      REM - If the folder has the same name as its parent folder
      if /i "%%E"=="%%D" (
        
        REM - Try to fix it, but warn about it later
        set nestederror=1
        
        REM - Make a temporary folder
        md ".\extracted_exports\Temp"
        
        REM - Move the stuff into the temporary folder
        for /f "tokens=*" %%F in ('dir /b ".\extracted_exports\!foldername!\%%D\%%E"') do (
          move ".\extracted_exports\!foldername!\%%D\%%E\%%F" ".\extracted_exports\Temp" >nul
        )
        
        REM - Delete the now empty folder
        rd /S /Q ".\extracted_exports\!foldername!\%%D\%%E"
        
        REM - Move the stuff into the proper folder
        for /f "tokens=*" %%F in ('dir /b ".\extracted_exports\Temp"') do (
          move ".\extracted_exports\Temp\%%F" ".\extracted_exports\!foldername!\%%D" >nul
        )
        
        REM - And delete the temporary folder
        rd /S /Q ".\extracted_exports\Temp"
      )
    )
  )
  
  REM - If some folders were nested, warn about it
  if defined nestederror (

    @echo - >> memelist.txt
    @echo - !team!'s manager needs to get memed on (nested folders^) - Fix Attempted >> memelist.txt
    set memelist=1
    
    @echo -
    @echo - !team!'s manager needs to get memed on (nested folders^)
    @echo - An attempt to automatically fix those folders has just been done
    @echo - Nothing has been discarded, though problems may still arise
    @echo -
    
    if not %pause_when_wrong%==0 (
      pause
    )
  )
  
)


if not defined error (

  REM - If a Faces folder exists and is not empty, check that the face folder names are correct
  set checkfaces=
  >nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\Faces\*" && (set checkfaces=1) || (echo ->nul)
  
  if defined checkfaces (
    
    set faceserror=
    
    REM - For every face folder
    for /f "tokens=*" %%C in ('dir /b /a:d ".\extracted_exports\!foldername!\Faces"') do (
      
      set facewrong=
      
      set facename=%%C
      

      REM - Check that the player number is within the 01-23 range
      if "!facename:~3,2!" LSS "01" set facewrong=1
      if "!facename:~3,2!" GTR "23" set facewrong=1
      
      
      if not defined facewrong (
        
        set facewrong=1

        REM - If the folder is in legacy format check the internal face folders too
        if exist ".\extracted_exports\!foldername!\Faces\!facename!\common" (
        
          set faceid=!facename:~0,5!
          
          if exist ".\extracted_exports\!foldername!\Faces\!facename!\common\character0\model\character\face\real\!faceid!\face.xml" (
            set facewrong=
          )
          if exist ".\extracted_exports\!foldername!\Faces\!facename!\common\character0\model\character\face\real\!faceid!\face_edithair.xml" (
            set facewrong=
          )
          
          if not defined facewrong (
            
            REM - And simplify the folder
            for /f "tokens=*" %%D in ('dir /b ".\extracted_exports\!foldername!\Faces\!facename!\common\character0\model\character\face\real\!faceid!"') do (
              
              move ".\extracted_exports\!foldername!\Faces\!facename!\common\character0\model\character\face\real\!faceid!\%%D" ".\extracted_exports\!foldername!\Faces\!facename!" >nul
            )
            
            REM - Delete the now empty structure of folders
            rd /S /Q ".\extracted_exports\!foldername!\Faces\!facename!\common"
          )
        
        ) else (
        
          REM - Otherwise just check that the folder has the essential face.xml or face_edithair.xml file
          if exist ".\extracted_exports\!foldername!\Faces\!facename!\face.xml" (
            set facewrong=
          )
          if exist ".\extracted_exports\!foldername!\Faces\!facename!\face_edithair.xml" (
            set facewrong=
          )
        )
        
      )
      
      
      REM - If the face folder has something wrong
      if defined facewrong (
        
        REM - Warn about the team having bad face folders
        if not defined faceserror (
          
          set faceserror=1
          
          @echo - >> memelist.txt
          @echo - !team!'s manager needs to get memed on (wrong face folder names^) >> memelist.txt
          set memelist=1
          
          @echo -
          @echo - !team!'s manager needs to get memed on (wrong face folder names^)
        ) 
        
        REM - And skip the face folder
        if not %pass_through%==1 (
          rd /S /Q ".\extracted_exports\!foldername!\Faces\!facename!"
        )
        
        @echo - The face folder !facename! is wrong - Folder discarded >> memelist.txt
        
        @echo - The face folder !facename! is wrong
      )
    
    )
  
    REM - If the team has bad face folders close the previously opened message
    if defined faceserror (

      @echo - The face folders mentioned above will be discarded to prevent conflicts
      @echo - Stopping the script and fixing them is recommended
      @echo -
      
      if not %pause_when_wrong%==0 (
        pause
      )      
    )
    
    REM - If there are files without folders in the Faces folder (cpks?) delete them
    for /f "tokens=*" %%C in ('dir /b /a:-d ".\extracted_exports\!foldername!\Faces" 2^>nul') do (
      del /F /Q ".\extracted_exports\!foldername!\Faces\%%C" >nul
    )
  
  ) else (
  
    REM - If the folder exists but is empty, delete it
    if exist ".\extracted_exports\!foldername!\Faces" (
      rd /S /Q ".\extracted_exports\!foldername!\Faces" >nul
    )
  )
)


if not defined error (

  REM - If a Kit Configs folder exists and is not empty, check that the amount of kit config files is correct
  set checkconfig=
  >nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\Kit Configs\*" && (set checkconfig=1) || (echo ->nul)
  
  if defined checkconfig (
  
    set configerror=
    
    REM - Look for a folder inside Kit Configs containing the kit config files
    for /f "tokens=*" %%C in ('dir /b /a:d ".\extracted_exports\!foldername!\Kit Configs" 2^>nul') do (
      
      REM - If a folder was found move its contents to the root folder
      for /f "tokens=*" %%D in ('dir /b ".\extracted_exports\!foldername!\Kit Configs\%%C"') do (
      
        move ".\extracted_exports\!foldername!\Kit Configs\%%C\%%D" ".\extracted_exports\!foldername!\Kit Configs" >nul
      )
      
      REM - And delete the now empty folder
      rd /S /Q ".\extracted_exports\!foldername!\Kit Configs\%%C"
    )
    
    set configs=0
  
    REM - For every kit config file
    for /f "tokens=*" %%C in ('dir /b ".\extracted_exports\!foldername!\Kit Configs"') do (
      
      set /a configs+=1
      
      set configname=%%C
      
      
      REM - Check the DEF part of the name
      if /i not "!configname:~3,5!"=="_DEF_" set configerror=1
      
      REM - Check the realUni part
      if /i not "!configname:~-12!"=="_realUni.bin" set configerror=1
      
    )
    
    REM - If something's wrong
    if defined configerror (
    
      REM - Skip the whole Kit Config folder
      if not %pass_through%==1 (
        rd /S /Q ".\extracted_exports\!foldername!\Kit Configs"
      )
      
      @echo - >> memelist.txt
      @echo - !team!'s manager needs to get memed on (wrong kit config names^) - Kit Configs discarded >> memelist.txt
      set memelist=1
      
      @echo -
      @echo - !team!'s manager needs to get memed on (wrong kit config names^)
      @echo - The Kit Configs folder will be discarded since it's unusable
      @echo - Stopping the script and fixing it is recommended
      @echo -
      
      if not %pause_when_wrong%==0 (
        pause
      )
    
    ) else (
    
      REM - Get the amount of proper kit color entries from the txt file
      call .\Engines\txtkits_count
      
      REM - Check that the amount of kit configs and kit color entries in the txt are the same
      if not "!kits!"=="!configs!" (
        
        @echo - >> memelist.txt
        @echo - !team!'s manager needs to get memed on (missing kit configs or txt kit color entries^) - Warning >> memelist.txt
        set memelist=1
        
        @echo - 
        @echo - The amount of !team!'s kit color entries is not
        @echo - equal to the amount of kit config files
        @echo - Stopping the script and fixing it is recommended
        @echo - 
        
        if not %pause_when_wrong%==0 (
          pause
        )
      )
    )
    
    
  ) else (
    
    REM - If it doesn't exist or is empty, warn about it
    @echo - >> memelist.txt
    @echo - !team!'s export doesn't have any Kit Configs - Warning >> memelist.txt
    set memelist=1
    
    REM - If the folder exists but is empty, delete it
    if exist ".\extracted_exports\!foldername!\Kit Configs" (
      rd /S /Q ".\extracted_exports\!foldername!\Kit Configs" >nul
    )
  )
  
)


if not defined error (

  REM - If a Kit Textures folder exists and is not empty, check that the kit textures' filenames are correct
  set checktexture=
  >nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\Kit Textures\*" && (set checktexture=1) || (echo ->nul)
  
  if defined checktexture (
    
    set textureerror=

    REM - For every texture
    for /f "tokens=*" %%C in ('dir /b ".\extracted_exports\!foldername!\Kit Textures"') do (
      
      set texturewrong=
      set texturename=%%C
      
      
      REM - Check that its name starts with u
      if /i not "!texturename:~0,1!"=="u" set texturewrong=1
      
      if not defined texturewrong (
      
        set texturewrong=1
      
        REM - Check that its name has p or g in the correct position
        if /i "!texturename:~5,1!"=="p" set texturewrong=
        if /i "!texturename:~5,1!"=="g" set texturewrong=
      )
      
    
      REM - If the texture is named wrongly
      if defined texturewrong (
        
        REM - Warn about the team having bad texture names
        if not defined textureerror (
          
          set textureerror=1
          
          @echo - >> memelist.txt
          @echo - !team!'s manager needs to get memed on (wrong kit texture names^) >> memelist.txt
          set memelist=1
          
          @echo -
          @echo - !team!'s manager needs to get memed on (wrong kit texture names^)
        ) 
        
        REM - And skip it
        if not %pass_through%==1 (
          del /F /Q ".\extracted_exports\!foldername!\Kit Textures\!texturename!"
        )
        
        @echo - The kit texture !texturename! is wrong - File discarded >> memelist.txt
        
        @echo - The kit texture !texturename! is wrong
      )
    
    )
    
    REM - If the team has bad kit textures close the previously opened message
    if defined textureerror (

      @echo - The kit textures mentioned above will be discarded since they're unusable
      @echo - Stopping the script and fixing them is recommended
      @echo -
      
      if not %pause_when_wrong%==0 (
        pause
      )      
    )

  ) else (
  
    REM - If the Kit Textures folder doesn't exist or is empty, warn about it
    @echo - >> memelist.txt
    @echo - !team!'s export doesn't have any Kit Textures - Warning >> memelist.txt
    set memelist=1
    
    REM - If the folder exists but is empty, delete it
    if exist ".\extracted_exports\!foldername!\Kit Textures" (
      rd /S /Q ".\extracted_exports\!foldername!\Kit Textures" >nul
    )
  )
)


if not defined error (

  REM - If a Logo folder exists and is not empty, check that the three logo images' filenames are correct
  set checklogo=
  >nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\Logo\*" && (set checklogo=1) || (echo ->nul)
  
  if defined checklogo (
    
    set logoerror=
    
    set logocount=0
    set logocountplus=0

    REM - For every image
    for /f "tokens=*" %%C in ('dir /b ".\extracted_exports\!foldername!\Logo"') do (
      
      set logowrong=
      set logoname=%%C
      set /a logocount+=1
      
      
      REM - Check that its name starts with emblem_
      if /i not "!logoname:~0,7!"=="emblem_" set logowrong=1
      
      
      REM - Check the suffix and increase the plus counter if present and correct
      if /i "!logoname:~11!"=="_r.png" set /a logocountplus+=1
      if /i "!logoname:~11!"=="_r_l.png" set /a logocountplus+=1
      if /i "!logoname:~11!"=="_r_ll.png" set /a logocountplus+=1
      
      
      if defined logowrong (
        set logoerror=1
      )
    
    )
    
    REM - Check that there are three total images, each with a correct suffix
    if not "!logocount!"=="3" set logoerror=1
    if not "!logocountplus!"=="3" set logoerror=1
    
    REM - If something's wrong
    if defined logoerror (
    
      REM - Skip the whole Logo folder
      if not %pass_through%==1 (
        rd /S /Q ".\extracted_exports\!foldername!\Logo"
      )
      
      @echo - >> memelist.txt
      @echo - !team!'s manager needs to get memed on (wrong logo filenames^) - Logo folder discarded >> memelist.txt
      set memelist=1
      
      @echo -
      @echo - !team!'s manager needs to get memed on (wrong logo filenames^)
      @echo - The Logo folder will be discarded since it's unusable
      @echo - Stopping the script and fixing it is recommended
      @echo -
      
      if not %pause_when_wrong%==0 (
        pause
      )
    )

  ) else (
  
    REM - If the folder exists but is empty, delete it
    if exist ".\extracted_exports\!foldername!\Logo" (
      rd /S /Q ".\extracted_exports\!foldername!\Logo" >nul
    )
  )
)


if not defined error (

  REM - If a Portraits folder exists and is not empty, check that the portraits' filenames are correct
  set checkportraits=
  >nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\Portraits\*" && (set checkportraits=1) || (echo ->nul)
  
  if defined checkportraits (
    
    set portraiterror=

    REM - For every portrait
    for /f "tokens=*" %%C in ('dir /b ".\extracted_exports\!foldername!\Portraits"') do (
      
      set portraitwrong=
      set portraitname=%%C
      
      
      REM - Check that the player number is within the 01-23 range
      if "!portraitname:~-6,2!" LSS "01" set portraitwrong=1
      if "!portraitname:~-6,2!" GTR "23" set portraitwrong=1
      
    
      REM - If the portrait is named wrongly
      if defined portraitwrong (
        
        REM - Warn about the team having bad portrait names
        if not defined portraiterror (
          
          set portraiterror=1
          
          @echo - >> memelist.txt
          @echo - !team!'s manager needs to get memed on (wrong portrait names^) >> memelist.txt
          set memelist=1
          
          @echo -
          @echo - !team!'s manager needs to get memed on (wrong portrait names^)
        ) 
        
        REM - And skip it
        if not %pass_through%==1 (
          del /F /Q ".\extracted_exports\!foldername!\Portraits\!portraitname!"
        )
        
        @echo - The portrait !portraitname! is wrong - File discarded >> memelist.txt
        
        @echo - The portrait !portraitname! is wrong
      )
    
    )
    
    REM - If the team has bad portraits close the previously opened message
    if defined portraiterror (

      @echo - The portraits mentioned above will be discarded since they're unusable
      @echo - Stopping the script and fixing them is recommended
      @echo -
      
      if not %pause_when_wrong%==0 (
        pause
      )      
    )

  ) else (
  
    REM - If the folder exists but is empty, delete it
    if exist ".\extracted_exports\!foldername!\Portraits" (
      rd /S /Q ".\extracted_exports\!foldername!\Portraits" >nul
    )
  )
)


if not defined error (

  REM - If a Boots folder exists and is not empty, check that the boots folder names are correct
  set checkboots=
  >nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\Boots\*" && (set checkboots=1) || (echo ->nul)
  
  if defined checkboots (
    
    set bootserror=
    
    REM - For every boots folder
    for /f "tokens=*" %%C in ('dir /b ".\extracted_exports\!foldername!\Boots"') do (
      
      set bootswrong=
      set bootsname=%%C
      
      REM - Check that its name starts with a k, and that it's 5 characters long
      if /i not "!bootsname:~0,1!"=="k" (
        
        set bootswrong=1
        
      ) else (
        
        call .\Engines\CharLib strlen bootsname len_bootsname
        if not "!len_bootsname!"=="5" set bootswrong=1
      )
      
      REM - If the boots folder is named wrongly
      if defined bootswrong (
        
        REM - Warn about the team having bad boots folders
        if not defined bootserror (
          
          set bootserror=1
          
          @echo - >> memelist.txt
          @echo - !team!'s manager needs to get memed on (wrong boots folder names^) >> memelist.txt
          set memelist=1
          
          @echo -
          @echo - !team!'s manager needs to get memed on (wrong boots folder names^)
        ) 
        
        REM - And skip it
        if not %pass_through%==1 (
          rd /S /Q ".\extracted_exports\!foldername!\Boots\!bootsname!"
        )
        
        @echo - The boots folder !bootsname! is wrong - Folder discarded >> memelist.txt
        
        @echo - The boots folder !bootsname! is wrong
      )
      
    )
  
    REM - If the team has bad boots folders close the previously opened message
    if defined bootserror (

      @echo - The boots folders mentioned above will be discarded since they're unusable
      @echo - Stopping the script and fixing them is recommended
      @echo -
      
      if not %pause_when_wrong%==0 (
        pause
      )      
    )
  
  ) else (
  
    REM - If the folder exists but is empty, delete it
    if exist ".\extracted_exports\!foldername!\Boots" (
      rd /S /Q ".\extracted_exports\!foldername!\Boots" >nul
    )
  )
)


if not defined error (

  REM - If a Gloves folder exists and is not empty, check that the gloves folder names are correct
  set checkgloves=
  >nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\Gloves\*" && (set checkgloves=1) || (echo ->nul)
  
  if defined checkgloves (
    
    set gloveserror=
    
    REM - For every gloves folder
    for /f "tokens=*" %%C in ('dir /b ".\extracted_exports\!foldername!\Gloves"') do (
      
      set gloveswrong=
      set glovesname=%%C
      
      REM - Check that its name starts with a g, and that it's 4 characters long
      if /i not "!glovesname:~0,1!"=="g" (
        
        set gloveswrong=1
        
      ) else (
        
        call .\Engines\CharLib strlen glovesname len_glovesname
        if not "!len_glovesname!"=="4" set gloveswrong=1
      )
      
      REM - If the gloves folder is named wrongly
      if defined gloveswrong (
        
        REM - Warn about the team having bad gloves folders
        if not defined gloveserror (
          
          set gloveserror=1
          
          @echo - >> memelist.txt
          @echo - !team!'s manager needs to get memed on (wrong glove folder names^) >> memelist.txt
          set memelist=1
          
          @echo -
          @echo - !team!'s manager needs to get memed on (wrong glove folder names^)
        ) 
        
        REM - And skip it
        if not %pass_through%==1 (
          rd /S /Q ".\extracted_exports\!foldername!\Gloves\!glovesname!"
        )
        
        @echo - The glove folder !glovesname! is wrong - Folder discarded  >> memelist.txt
        
        @echo - The glove folder !glovesname! is wrong
      )
      
    )
  
    REM - If the team has bad gloves folders close the previously opened message
    if defined gloveserror (

      @echo - The glove folders mentioned above will be discarded since they're unusable
      @echo - Stopping the script and fixing them is recommended
      @echo -
      
      if not %pause_when_wrong%==0 (
        pause
      )      
    )
    
  ) else (
  
    REM - If the folder exists but is empty, delete it
    if exist ".\extracted_exports\!foldername!\Gloves" (
      rd /S /Q ".\extracted_exports\!foldername!\Gloves" >nul
    )
  )
)


if not defined error (

  REM - If a Other folder exists and is empty, delete it
  if exist ".\extracted_exports\!foldername!\Other" (
  
    set keepother=
    >nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\Other\*" && (set keepother=1) || (echo ->nul)
    
    if not defined keepother (
      rd /S /Q ".\extracted_exports\!foldername!\Other" >nul
    )
  )
)


