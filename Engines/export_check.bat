REM - Checks the export for all kinds of errors

REM - Check for nested folders with repeating names
set nestederror=

for /f "tokens=*" %%D in ('dir /a:d /b ".\extracted_exports\!foldername!" 2^>nul') do (
  
  for  /f "tokens=*" %%E in ('dir /a:d /b ".\extracted_exports\!foldername!\%%D" 2^>nul') do (
    
    REM - If the folder has the same name as its parent folder
    if /i "%%E"=="%%D" (
      
      REM - Try to fix it, but warn about it later
      set nestederror=1
      
      REM - Unless it's the Other or Common folders
      if /i "%%E"=="Other" set nestederror=
      if /i "%%E"=="Common" set nestederror=
      
    )
      
    if defined nestederror (
    
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

  echo - >> memelist.txt
  echo - !team!'s manager needs to get memed on (nested folders^) - Fix Attempted. >> memelist.txt
  set memelist=1
  
  echo -
  echo - !team!'s manager needs to get memed on (nested folders^).
  echo - An attempt to automatically fix those folders has just been done.
  echo - Nothing has been discarded, though problems may still arise.
  echo -
  
  if not %pause_when_wrong%==0 (
    pause
  )
)


REM - If a Faces folder exists and is not empty, check that the face folder names are correct
>nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\Faces\*" && (set checkfaces=1) || (set checkfaces=)

if defined checkfaces (
  
  set face_wrong_any=
  
  REM - For every face folder
  for /f "tokens=*" %%C in ('dir /b /a:d ".\extracted_exports\!foldername!\Faces"') do (
    
    set face_name=%%C
    
    set face_wrong=
    set face_wrong_num=
    set face_wrong_id2=
    set face_wrong_noxml=
    set face_wrong_edithairxml=
    set face_wrong_badtex=
    
    
    REM - Check that the player number is within the 01-23 range
    if "!face_name:~3,2!" LSS "01" (
      set face_wrong=1
      set face_wrong_num=1
    )
    if "!face_name:~3,2!" GTR "23" (
      set face_wrong=1
      set face_wrong_num=1
    )
    
    
    if not defined face_wrong (
      
      if %fox_mode%==0 (
        
        REM - Check that the folder has the essential face.xml and not the unsupported face_edithair.xml file
        if exist ".\extracted_exports\!foldername!\Faces\!face_name!\face_edithair.xml" (
        
          set face_wrong=1
          set face_wrong_edithairxml=1
          
        ) else (
          
          if not exist ".\extracted_exports\!foldername!\Faces\!face_name!\face.xml" (
          
            set face_wrong=1
            set face_wrong_noxml=1
            
          )
        )
        
      ) else (
        
        REM - Check that the folder has the essential face.fpk.xml file
        if not exist ".\extracted_exports\!foldername!\Faces\!face_name!\face.fpk.xml" (
        
          set face_wrong=1
          set face_wrong_nofpkxml=1
          
        )
      )
      
      
      set "tex_path=extracted_exports\!foldername!\Faces\!face_name!"
      set tex_wrongformat_any=
      
      REM - For every dds texture
      for /f "tokens=*" %%C in ('dir /b ".\!tex_path!\*.dds" 2^>nul') do (
        
        if not defined tex_wrongformat_any (
          
          set tex_name=%%C
          
          call .\Engines\texture_check "!tex_path!" !tex_name! "tex_wrongformat"
          
          if defined tex_wrongformat (
            set tex_wrongformat_any=1
          )
          
        )
      )
      
      REM - If the folder has a non-dds texture
      if defined tex_wrongformat_any (

        set face_wrong=1
        set face_wrong_badtex=1
      )
      
    )
    
    
    REM - If the face folder has something wrong
    if defined face_wrong (
      
      REM - Warn about the team having bad face folders
      if not defined face_wrong_any (
        
        set face_wrong_any=1
        
        echo - >> memelist.txt
        echo - !team!'s manager needs to get memed on (bad face folders^). >> memelist.txt
        set memelist=1
        
        echo -
        echo - !team!'s manager needs to get memed on (bad face folders^).
      ) 
      
      REM - Give an error depending on the particular problem
      echo - The face folder !face_name! is bad. >> memelist.txt
      echo - The face folder !face_name! is bad.

      if defined face_wrong_num (
        echo - (player number !face_name:~3,2! out of the 01-23 range^) - Folder discarded >> memelist.txt
        echo - (player number !face_name:~3,2! out of the 01-23 range^)
      )
      if defined face_wrong_nofpkxml (
        echo - (no face.fpk.xml file inside^) - Folder discarded >> memelist.txt
        echo - (no face.fpk.xml file inside^)
      )
      if defined face_wrong_noxml (
        echo - (no face.xml file inside^) - Folder discarded >> memelist.txt
        echo - (no face.xml file inside^)
      )
      if defined face_wrong_edithairxml (
        echo - (unsupported edithair face folder, needs updating^) - Folder discarded >> memelist.txt
        echo - (unsupported edithair face folder, needs updating^)
      )
      if defined face_wrong_badtex (
        echo - (!tex_name! is not a real dds^) - Folder discarded >> memelist.txt
        echo - (!tex_name! is not a real dds^)
      )
      
      
      REM - And skip it
      if %pass_through%==0 (
        rd /S /Q ".\extracted_exports\!foldername!\Faces\!face_name!"
      )
      
    )
  
  )

  REM - If the team has bad face folders close the previously opened message
  if defined face_wrong_any (

    echo - The face folders mentioned above will be discarded to avoid problems.
    echo - Closing the script's window and fixing them is recommended.
    echo -
    
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


REM - If a Kit Configs folder exists and is not empty, check that the amount of kit config files is correct
>nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\Kit Configs\*" && (set checkconfig=1) || (set checkconfig=)

if defined checkconfig (

  set config_error=
  
  REM - Check if the files are in an inner folder
  for /f "tokens=*" %%C in ('dir /b /a:d ".\extracted_exports\!foldername!\Kit Configs" 2^>nul') do (
    
    REM - If a folder was found move its contents to the root folder
    for /f "tokens=*" %%D in ('dir /b ".\extracted_exports\!foldername!\Kit Configs\%%C"') do (
    
      move ".\extracted_exports\!foldername!\Kit Configs\%%C\%%D" ".\extracted_exports\!foldername!\Kit Configs" >nul
    )
    
    REM - And delete the now empty folder
    rd /S /Q ".\extracted_exports\!foldername!\Kit Configs\%%C"
  )
  
  set config_amount=0

  REM - For every kit config file
  for /f "tokens=*" %%C in ('dir /b ".\extracted_exports\!foldername!\Kit Configs"') do (
    
    set /a config_amount+=1
    
    set config_name=%%C
    
    
    REM - Check the DEF part of the name
    if /i not "!config_name:~3,5!"=="_DEF_" set config_error=1
    
    REM - Check the realUni part
    if /i not "!config_name:~-12!"=="_realUni.bin" set config_error=1
    
    
    set config_zlibbed=
  
    REM - Check if it is zlibbed
    for /f "tokens=1-6 usebackq" %%D in (`call .\Engines\hexed ".\extracted_exports\!foldername!\Kit Configs\%%C" -d 3 5`) do (
      
      REM - If the file has the WESYS label it's zlibbed
      if "%%E%%F%%G%%H%%I"=="5745535953" (
        
        set config_zlibbed=1
      )
    )
    
    REM - If the file is zlibbed
    if defined config_zlibbed (
    
      REM - Unzlib it
      call .\Engines\zlibtool ".\extracted_exports\!foldername!\Kit Configs\%%C" -d >nul
      
      REM - Delete the original file
      del ".\extracted_exports\!foldername!\Kit Configs\%%C" >nul
      
      REM - And change the unzlibbed file's extension
      rename ".\extracted_exports\!foldername!\Kit Configs\%%C.unzlib" "%%C" >nul

    )
  )
  
  REM - If something's wrong
  if defined config_error (
  
    REM - Skip the whole Kit Config folder
    if %pass_through%==0 (
      rd /S /Q ".\extracted_exports\!foldername!\Kit Configs"
    )
    
    echo - >> memelist.txt
    echo - !team!'s manager needs to get memed on (wrong kit config names^). - Kit Configs discarded >> memelist.txt
    set memelist=1
    
    echo -
    echo - !team!'s manager needs to get memed on (wrong kit config names^).
    echo - The Kit Configs folder will be discarded since it's unusable.
    echo - Closing the script's window and fixing it is recommended.
    echo -
    
    if not %pause_when_wrong%==0 (
      pause
    )
  
  ) else (
  
    if defined note_found (
    
      REM - Get the amount of proper kit color entries from the txt file
      call .\Engines\txtkits_count
      
      REM - Check that the amount of kit configs and kit color entries in the txt are the same
      if not "!kits!"=="!config_amount!" (
        
        echo - >> memelist.txt
        echo - !team!'s manager needs to get memed on (missing kit configs or txt kit color entries^). - Warning >> memelist.txt
        set memelist=1
        
        echo - 
        echo - The amount of !team!'s kit color entries is not equal to
        echo - the amount of kit config files in the Note txt file.
        echo - Closing the script's window and fixing this is recommended.
        echo - 
        
        if not %pause_when_wrong%==0 (
          pause
        )
      )
      
    )
  )
  
  
) else (
  
  REM - If it doesn't exist or is empty, warn about it
  echo - >> memelist.txt
  echo - !team!'s export doesn't have any Kit Configs - Warning >> memelist.txt
  set memelist=1
  
  REM - If the folder exists but is empty, delete it
  if exist ".\extracted_exports\!foldername!\Kit Configs" (
    rd /S /Q ".\extracted_exports\!foldername!\Kit Configs" >nul
  )
)


REM - If a Kit Textures folder exists and is not empty, check that the kit textures' filenames and type are correct
>nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\Kit Textures\*" && (set checktexture=1) || (set checktexture=)

if defined checktexture (
  
  set "tex_path=extracted_exports\!foldername!\Kit Textures"
  set tex_wrongformat_any=
  
  REM - For every texture
  for /f "tokens=*" %%C in ('dir /b ".\!tex_path!"') do (
    
    if not defined tex_wrongformat_any (
      
      set tex_name=%%C
      
      call .\Engines\texture_check "!tex_path!" !tex_name! "tex_wrongformat"
      
      if defined tex_wrongformat (
        set tex_wrongformat_any=1
      )
      
    )
  )
  
  REM - If the folder has a non-dds texture
  if defined tex_wrongformat_any (
  
    REM - Skip the whole Kit Textures folder
    if %pass_through%==0 (
      rd /S /Q ".\extracted_exports\!foldername!\Kit Textures"
    )
    
    echo - >> memelist.txt
    echo - !team!'s manager needs to get memed on (wrong format kit textures^) - Kit Textures discarded. >> memelist.txt
    set memelist=1
    
    echo -
    echo - !team!'s manager needs to get memed on (wrong format kit textures^).
    if %fox_mode%==0 (
      echo - This is usually caused by png textures renamed to dds instead of saved as dds.
    ) else (
      echo - This is usually caused by missing mipmaps.
    )
    echo - First game-crashing texture found: !tex_name!
    echo - The Kit Textures folder will be discarded since it's unusable.
    echo - Closing the script's window and fixing it is recommended.
    echo -
    
    if not %pause_when_wrong%==0 (
      pause
    )
  
  
  ) else (
  
    set textureerror=

    REM - For every texture
    for /f "tokens=*" %%C in ('dir /b ".\extracted_exports\!foldername!\Kit Textures"') do (
      
      set texturewrong=
      set tex_name=%%C
      
      
      REM - Check that its name starts with u
      if not "!tex_name:~0,1!"=="u" set texturewrong=1
      
      if not defined texturewrong (
      
        set texturewrong=1
      
        REM - Check that its name has p or g in the correct position
        if /i "!tex_name:~5,1!"=="p" set texturewrong=
        if /i "!tex_name:~5,1!"=="g" set texturewrong=
      )
      
    
      REM - If the texture is named wrongly
      if defined texturewrong (
        
        REM - Warn about the team having bad texture names
        if not defined textureerror (
          
          set textureerror=1
          
          echo - >> memelist.txt
          echo - !team!'s manager needs to get memed on (wrong kit texture names^). >> memelist.txt
          set memelist=1
          
          echo -
          echo - !team!'s manager needs to get memed on (wrong kit texture names^).
        ) 
        
        REM - And skip it
        if %pass_through%==0 (
          del /F /Q ".\extracted_exports\!foldername!\Kit Textures\!tex_name!"
        )
        
        echo - The kit texture !tex_name! is wrong - File discarded. >> memelist.txt
        
        echo - The kit texture !tex_name! is wrong.
      )
    
    )
    
    REM - If the team has bad kit textures close the previously opened message
    if defined textureerror (

      echo - The kit textures mentioned above will be discarded since they're unusable.
      echo - Closing the script's window and fixing them is recommended.
      echo -
      
      if not %pause_when_wrong%==0 (
        pause
      )      
    )
    
  )

) else (

  REM - If the Kit Textures folder doesn't exist or is empty, warn about it
  echo - >> memelist.txt
  echo - !team!'s export doesn't have any Kit Textures - Warning >> memelist.txt
  set memelist=1
  
  REM - If the folder exists but is empty, delete it
  if exist ".\extracted_exports\!foldername!\Kit Textures" (
    rd /S /Q ".\extracted_exports\!foldername!\Kit Textures" >nul
  )
  
)


REM - If a Logo folder exists and is not empty, check that the three logo images' filenames are correct
>nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\Logo\*" && (set checklogo=1) || (set checklogo=)

if defined checklogo (
  
  set logo_wrong_any=
  
  set logo_amount=0
  set logo_amount_good=0

  REM - For every image
  for /f "tokens=*" %%C in ('dir /b ".\extracted_exports\!foldername!\Logo"') do (
    
    set logo_wrong=
    set logo_name=%%C
    set /a logo_amount+=1
    
    
    REM - Check that its name starts with emblem_
    if /i not "!logo_name:~0,7!"=="emblem_" set logo_wrong=1
    
    
    REM - Check the suffix and increase the plus counter if present and correct
    REM - Real teams
    if /i "!logo_name:~11!"=="_r.png" set /a logo_amount_good+=1
    if /i "!logo_name:~11!"=="_r_l.png" set /a logo_amount_good+=1
    if /i "!logo_name:~11!"=="_r_ll.png" set /a logo_amount_good+=1
    REM - Fake teams
    if /i "!logo_name:~11!"=="_f.png" set /a logo_amount_good+=1
    if /i "!logo_name:~11!"=="_f_l.png" set /a logo_amount_good+=1
    if /i "!logo_name:~11!"=="_f_ll.png" set /a logo_amount_good+=1
    
    
    if defined logo_wrong (
      set logo_wrong_any=1
    )
  
  )
  
  REM - Check that there are three total images, each with a correct suffix
  if not "!logo_amount!"=="3" set logo_wrong_any=1
  if not "!logo_amount_good!"=="3" set logo_wrong_any=1
  
  REM - If something's wrong
  if defined logo_wrong_any (
  
    REM - Skip the whole Logo folder
    if %pass_through%==0 (
      rd /S /Q ".\extracted_exports\!foldername!\Logo"
    )
    
    echo - >> memelist.txt
    echo - !team!'s manager needs to get memed on (wrong logo filenames^). - Logo folder discarded >> memelist.txt
    set memelist=1
    
    echo -
    echo - !team!'s manager needs to get memed on (wrong logo filenames^).
    echo - The Logo folder will be discarded since it's unusable.
    echo - Closing the script's window and fixing it is recommended.
    echo -
    
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


REM - If a Portraits folder exists and is not empty, check that the portraits' filenames are correct
>nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\Portraits\*" && (set checkportraits=1) || (set checkportraits=)

if defined checkportraits (
  
  set "portrait_path=extracted_exports\!foldername!\Portraits"
  set portrait_wrong_any=

  REM - For every portrait
  for /f "tokens=*" %%C in ('dir /b ".\!portrait_path!"') do (
    
    set portrait_name=%%C
    set portrait_wrong=
    set portrait_id_bad=1
    
    REM - Check that the player number is within the 01-23 range
    set portrait_id_temp=!portrait_name:~3,2!
    if "!portrait_id_temp!" GEQ "01" (
      if "!portrait_id_temp!" LEQ "23" set portrait_id_bad=
    )
    set portrait_id_temp=!portrait_name:~-6,2!
    if "!portrait_id_temp!" GEQ "01" (
      if "!portrait_id_temp!" LEQ "23" set portrait_id_bad=
    )
    
    if defined portrait_id_bad set portrait_wrong=1
    
    call .\Engines\texture_check "!portrait_path!" !portrait_name! "portrait_wrong"
    
    
    REM - If the portrait is named wrongly
    if defined portrait_wrong (
      
      REM - Warn about the team having bad portrait names
      if not defined portrait_wrong_any (
        
        set portrait_wrong_any=1
        
        echo - >> memelist.txt
        echo - !team!'s manager needs to get memed on (bad portraits^). >> memelist.txt
        set memelist=1
        
        echo -
        echo - !team!'s manager needs to get memed on (bad portraits^).
      ) 
      
      REM - And skip it
      if %pass_through%==0 (
        del /F /Q ".\extracted_exports\!foldername!\Portraits\!portrait_name!"
      )
      
      REM - Give an error depending on the particular problem
      echo - The portrait !portrait_name! is bad. >> memelist.txt
      echo - The portrait !portrait_name! is bad.

      if defined portrait_id_bad (
        echo - (player number !portrait_name:~-6,2! out of the 01-23 range^) - File discarded >> memelist.txt
        echo - (player number !portrait_name:~-6,2! out of the 01-23 range^)
      )
      if defined portrait_wrongformat (
        echo - (not a real dds^) - File discarded >> memelist.txt
        echo - (not a real dds^)
      )
      
    )
  
  )
  
  REM - If the team has bad portraits close the previously opened message
  if defined portrait_wrong_any (

    echo - The portraits mentioned above will be discarded since they're unusable.
    echo - Closing the script's window and fixing them is recommended.
    echo -
    
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


REM - If a Boots folder exists and is not empty, check that the boots folder names are correct
>nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\Boots\*" && (set checkboots=1) || (set checkboots=)

if defined checkboots (
  
  set boots_wrong_any=
  
  REM - For every boots folder
  for /f "tokens=*" %%C in ('dir /b ".\extracted_exports\!foldername!\Boots"') do (
    
    set boots_name=%%C
    
    set boots_wrong=
    set boots_wrong_name=
    set boots_wrong_nofpkxml=
    
    REM - Check that its name starts with a k
    if /i not "!boots_name:~0,1!"=="k" (
      
      set boots_wrong=1
      set boots_wrong_name=1
    )
    
    if %fox_mode%==1 (
      
      REM - Check that the folder has the essential boots.fpk.xml file
      if not exist ".\extracted_exports\!foldername!\Boots\!boots_name!\boots.fpk.xml" (
      
        set boots_wrong=1
        set boots_wrong_nofpkxml=1
      )
    )
    
    REM - If the boots folder is named wrongly
    if defined boots_wrong (
      
      REM - Warn about the team having bad boots folders
      if not defined boots_wrong_any (
        
        set boots_wrong_any=1
        
        echo - >> memelist.txt
        echo - !team!'s manager needs to get memed on. >> memelist.txt
        set memelist=1
        
        echo -
        echo - !team!'s manager needs to get memed on.
      )
      
      REM - Give an error depending on the particular problem
      echo - The boots folder !boots_name! is bad. >> memelist.txt
      echo - The boots folder !boots_name! is bad.
      
      if defined boots_wrong_name (
        echo - (wrong boots folder name^) - Folder discarded >> memelist.txt
        echo - (wrong boots folder name^)
      )
      
      if defined boots_wrong_nofpkxml (
        echo - (no boots.fpk.xml file inside^) - Folder discarded >> memelist.txt
        echo - (no boots.fpk.xml file inside^)
      )
      
      
      REM - And skip it
      if %pass_through%==0 (
        rd /S /Q ".\extracted_exports\!foldername!\Boots\!boots_name!"
      )
      
    )
    
  )

  REM - If the team has bad boots folders close the previously opened message
  if defined boots_wrong_any (

    echo - The boots folders mentioned above will be discarded since they're unusable.
    echo - Closing the script's window and fixing them is recommended.
    echo -
    
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


REM - If a Gloves folder exists and is not empty, check that the gloves folder names are correct
>nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\Gloves\*" && (set checkgloves=1) || (set checkgloves=)

if defined checkgloves (
  
  set glove_wrong_any=
  
  REM - For every gloves folder
  for /f "tokens=*" %%C in ('dir /b ".\extracted_exports\!foldername!\Gloves"') do (
    
    set glove_wrong=
    set glove_name=%%C
    
    REM - Check that its name starts with a g
    if /i not "!glove_name:~0,1!"=="g" (
      
      set glove_wrong=1
      set glove_wrong_name=1
    )
    
    if %fox_mode%==1 (
      
      REM - Check that the folder has the essential glove.fpk.xml file
      if not exist ".\extracted_exports\!foldername!\Gloves\!glove_name!\glove.fpk.xml" (
      
        set glove_wrong=1
        set glove_wrong_nofpkxml=1
        
      )
    )
    
    REM - If the gloves folder is named wrongly
    if defined glove_wrong (
      
      REM - Warn about the team having bad gloves folders
      if not defined glove_wrong_any (
        
        set glove_wrong_any=1
        
        echo - >> memelist.txt
        echo - !team!'s manager needs to get memed on. >> memelist.txt
        set memelist=1
        
        echo -
        echo - !team!'s manager needs to get memed on.
      ) 
      
      REM - Give an error depending on the particular problem
      echo - The glove folder !glove_name! is bad. >> memelist.txt
      echo - The glove folder !glove_name! is bad.

      if defined glove_wrong_name (
        echo - (wrong glove folder name^) - Folder discarded >> memelist.txt
        echo - (wrong glove folder name^)
      )
      
      if defined glove_wrong_nofpkxml (
        echo - (no glove.fpk.xml file inside^) - Folder discarded >> memelist.txt
        echo - (no glove.fpk.xml file inside^)
      )
      

      REM - And skip it
      if %pass_through%==0 (
        rd /S /Q ".\extracted_exports\!foldername!\Gloves\!glove_name!"
      )
      
    )
    
  )

  REM - If the team has bad gloves folders close the previously opened message
  if defined glove_wrong_any (

    echo - The glove folders mentioned above will be discarded since they're unusable.
    echo - Closing the script's window and fixing them is recommended.
    echo -
    
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


REM - If a Common folder exists and is empty, delete it
if exist ".\extracted_exports\!foldername!\Common" (

  >nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\Common\*" && (set keepcommon=1) || (set keepcommon=)
  
  if not defined keepcommon (
    rd /S /Q ".\extracted_exports\!foldername!\Common" >nul
  )
)


REM - If a Other folder exists and is empty, delete it
if exist ".\extracted_exports\!foldername!\Other" (

  >nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\Other\*" && (set keepother=1) || (set keepother=)
  
  if not defined keepother (
    rd /S /Q ".\extracted_exports\!foldername!\Other" >nul
  )
)


