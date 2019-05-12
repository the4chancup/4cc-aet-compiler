REM - Check the export for every kind of errors

REM - Reset the main flags
set error=
set not_root=
set root_found=


REM - Check if the folders are at the root by searching for a note txt, the faces and kit configs folders first
if exist ".\extracted_exports\!foldername!\*.txt" (
  set root_found=1
)
if exist ".\extracted_exports\!foldername!\Faces" (
  set root_found=1
)
if exist ".\extracted_exports\!foldername!\Kit Configs" (
  set root_found=1
)


REM - If the folders aren't at the root
if not defined root_found (
  
  REM - Look in every folder for a faces or kit configs folder
  for /f "tokens=*" %%R in ('dir /a:d /b ".\extracted_exports\!foldername!" 2^>nul') do (
  
    if exist ".\extracted_exports\!foldername!\%%R\*.txt" (
      set root_found=1
    )
    if exist ".\extracted_exports\!foldername!\%%R\Faces" (
      set root_found=1
    )
    if exist ".\extracted_exports\!foldername!\%%R\Kit Configs" (
      set root_found=1
    )
    
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
  
  @echo - >> memelist.txt
  @echo - !team!'s manager needs to get memed on (no files^) - Export discarded. >> memelist.txt
  set memelist=1
  
  if not %pause_when_wrong%==0 (
    
    @echo - 
    @echo - !team!'s manager needs to get memed on (no files^).
    @echo - This export will be discarded.
    @echo - 
    @echo - Closing the script's window and fixing the export is recommended.
    @echo - 
    
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
  
    set check_filename=%%C
    set check_filename_noteless=!check_filename:Note=!
    
    REM - If the file has Note in the filename store its name
    if not "!check_filename_noteless!"=="!check_filename!" (
    
      set note_found=1
      set note_name=%%C
      
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
      if not !team_name! == !team! (
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
    
    @echo - >> memelist.txt
    @echo - !team!'s manager needs to get memed on (unusable team name^) - Export discarded. >> memelist.txt
    set memelist=1
    
    @echo -
    @echo - !team!'s manager needs to get memed on (unusable team name^).
    @echo - (txt files in the unsupported unicode format can cause this too^)
    @echo - This export will be discarded to prevent conflicts.
    @echo - Adding the team name to the teams_list file and restarting the script
    @echo - is recommended.
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

    @echo - >> memelist.txt
    @echo - !team!'s manager needs to get memed on (nested folders^) - Fix Attempted. >> memelist.txt
    set memelist=1
    
    @echo -
    @echo - !team!'s manager needs to get memed on (nested folders^).
    @echo - An attempt to automatically fix those folders has just been done.
    @echo - Nothing has been discarded, though problems may still arise.
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
      set facewrong_num=
      set facewrong_id2=
      set facewrong_noxml=
      set facewrong_edithairxml=
      set facewrong_badtex=
      
      set facename=%%C
      

      REM - Check that the player number is within the 01-23 range
      if "!facename:~3,2!" LSS "01" (
        set facewrong=1
        set facewrong_num=1
      )
      if "!facename:~3,2!" GTR "23" (
        set facewrong=1
        set facewrong_num=1
      )
      
      
      if not defined facewrong (
        
        REM - If the folder has a portrait
        if exist ".\extracted_exports\!foldername!\Faces\!facename!\portrait.dds" (
          
          set faceid=!teamid!!facename:~3,2!
          
          REM - Create a folder for portraits if not present
          if not exist ".\extracted_exports\!foldername!\Portraits" (
            md ".\extracted_exports\!foldername!\Portraits" 2>nul
          )
          
          REM - Rename the portrait with the player id
          set name=player_!faceid!.dds
          rename ".\extracted_exports\!foldername!\Faces\!facename!\portrait.dds" "!name!"
          
          REM - And move it to the portraits folder
          move ".\extracted_exports\!foldername!\Faces\!facename!\!name!" ".\extracted_exports\!foldername!\Portraits" >nul
        )
        
        if not defined fox_mode (
          
          REM - Check that the folder has the essential face.xml and not the unsupported face_edithair.xml file
          if not exist ".\extracted_exports\!foldername!\Faces\!facename!\face.xml" (
            set facewrong=1
            set facewrong_noxml=1
          )
          if exist ".\extracted_exports\!foldername!\Faces\!facename!\face_edithair.xml" (
            set facewrong=1
            set facewrong_edithairxml=1
            set facewrong_noxml=
          )
          
        ) else (
          
          REM - Check that the folder has the essential face.fpk.xml file
          if not exist ".\extracted_exports\!foldername!\Faces\!facename!\face.fpk.xml" (
            set facewrong=1
            set facewrong_nofpkxml=1
          )
          
        )
        
        REM - Check if any dds textures exist
        >nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\Faces\!facename!\*.dds" && (set dds_present=1) || (set dds_present=)
        
        if defined dds_present (
          
          REM - For every dds texture
          for /f "tokens=*" %%D in ('dir /b ".\extracted_exports\!foldername!\Faces\!facename!\*.dds"') do (
            
            set texturename=%%D
            set zlibbed=
            
            REM - Check if it is zlibbed
            for /f "tokens=1-6 usebackq" %%E in (`call .\Engines\hexed ".\extracted_exports\!foldername!\Faces\!facename!\%%D" -d 3 5`) do (
              
              REM - If the file has the WESYS label it's zlibbed
              if "%%F%%G%%H%%I%%J"=="5745535953" (
                
                set zlibbed=1
                
                REM - Unzlib it
                .\Engines\zlibtool ".\extracted_exports\!foldername!\Faces\!facename!\%%C" -d >nul
                
                REM - Set the unzlibbed file as file to check
                set texturename=%%D.unzlib
              )
            )
            
            
            REM - Check if it is a real dds
            for /f "tokens=1-5 usebackq" %%D in (`call .\Engines\hexed ".\extracted_exports\!foldername!\Faces\!facename!\!texturename!" -d 0 4`) do (
              
              if not "%%E%%F%%G"=="444453" (
                set facewrong=1
                set facewrong_badtex=1
                set badtex=%%D
              )
            )
            
            
            if defined zlibbed (
              
              REM - Set the original filename
              set texturename=%%D
              
              if not defined fox_mode (
              
                REM - Delete the extra unzlibbed file
                del ".\extracted_exports\!foldername!\Faces\!facename!\!texturename!.unzlib" >nul
                
              ) else (
                
                REM - Delete the orignal zlibbed file
                del ".\extracted_exports\!foldername!\Faces\!facename!\!texturename!" >nul
                
                REM - Rename the file
                rename ".\extracted_exports\!foldername!\Faces\!facename!\!texturename!.unzlib" "!texturename!" >nul
              )
            )
            
          )
        )
        
      )
      
      
      REM - If the face folder has something wrong
      if defined facewrong (
        
        REM - Warn about the team having bad face folders
        if not defined faceserror (
          
          set faceserror=1
          
          @echo - >> memelist.txt
          @echo - !team!'s manager needs to get memed on (bad face folders^). >> memelist.txt
          set memelist=1
          
          @echo -
          @echo - !team!'s manager needs to get memed on (bad face folders^).
        ) 
        
        REM - And skip the face folder
        if not %pass_through%==1 (
          rd /S /Q ".\extracted_exports\!foldername!\Faces\!facename!"
        )
        
        REM - Give an error depending on the particular problem
        if defined facewrong_num (
          @echo - The face folder !facename! is bad. >> memelist.txt
          @echo - The face folder !facename! is bad.
          @echo (player number !facename:~3,2! out of the 01-23 range^) - Folder discarded >> memelist.txt
          @echo (player number !facename:~3,2! out of the 01-23 range^)
        )
        if defined facewrong_nofpkxml (
          @echo - The face folder !facename! is bad. >> memelist.txt
          @echo - The face folder !facename! is bad.
          @echo (no face.fpk.xml file inside^) - Folder discarded >> memelist.txt
          @echo (no face.fpk.xml file inside^)
        )
        if defined facewrong_noxml (
          @echo - The face folder !facename! is bad. >> memelist.txt
          @echo - The face folder !facename! is bad.
          @echo (no face.xml file inside^) - Folder discarded >> memelist.txt
          @echo (no face.xml file inside^)
        )
        if defined facewrong_edithairxml (
          @echo - The face folder !facename! is bad. >> memelist.txt
          @echo - The face folder !facename! is bad.
          @echo (unsupported edithair face folder, needs updating^) - Folder discarded >> memelist.txt
          @echo (unsupported edithair face folder, needs updating^)
        )
        if defined facewrong_edithairxml (
          @echo - The face folder !facename! is bad. >> memelist.txt
          @echo - The face folder !facename! is bad.
          @echo (!badtex! is not a real dds^) - Folder discarded >> memelist.txt
          @echo (!badtex! is not a real dds^)
        )
        
      )
    
    )
  
    REM - If the team has bad face folders close the previously opened message
    if defined faceserror (

      @echo - The face folders mentioned above will be discarded to avoid problems.
      @echo - Closing the script's window and fixing them is recommended.
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
      
      
      set zlibbed=
    
      REM - Check if it is zlibbed
      for /f "tokens=1-6 usebackq" %%D in (`call .\Engines\hexed ".\extracted_exports\!foldername!\Kit Configs\%%C" -d 3 5`) do (
        
        REM - If the file has the WESYS label it's zlibbed
        if "%%E%%F%%G%%H%%I"=="5745535953" (
          
          set zlibbed=1
        )
      )
      
      REM - If the file is zlibbed
      if defined zlibbed (
      
        REM - Unzlib it
        .\Engines\zlibtool ".\extracted_exports\!foldername!\Kit Configs\%%C" -d >nul
        
        REM - Delete the original file
        del ".\extracted_exports\!foldername!\Kit Configs\%%C" >nul
        
        REM - And change the unzlibbed file's extension
        rename ".\extracted_exports\!foldername!\Kit Configs\%%C.unzlib" "%%C" >nul

      )
    )
    
    REM - If something's wrong
    if defined configerror (
    
      REM - Skip the whole Kit Config folder
      if not %pass_through%==1 (
        rd /S /Q ".\extracted_exports\!foldername!\Kit Configs"
      )
      
      @echo - >> memelist.txt
      @echo - !team!'s manager needs to get memed on (wrong kit config names^). - Kit Configs discarded >> memelist.txt
      set memelist=1
      
      @echo -
      @echo - !team!'s manager needs to get memed on (wrong kit config names^).
      @echo - The Kit Configs folder will be discarded since it's unusable.
      @echo - Closing the script's window and fixing it is recommended.
      @echo -
      
      if not %pause_when_wrong%==0 (
        pause
      )
    
    ) else (
    
      if defined note_found (
      
        REM - Get the amount of proper kit color entries from the txt file
        call .\Engines\txtkits_count
        
        REM - Check that the amount of kit configs and kit color entries in the txt are the same
        if not "!kits!"=="!configs!" (
          
          @echo - >> memelist.txt
          @echo - !team!'s manager needs to get memed on (missing kit configs or txt kit color entries^). - Warning >> memelist.txt
          set memelist=1
          
          @echo - 
          @echo - The amount of !team!'s kit color entries is not equal to
          @echo - the amount of kit config files.
          @echo - Closing the script's window and fixing it is recommended.
          @echo - 
          
          if not %pause_when_wrong%==0 (
            pause
          )
        )
        
      )
    )
    
    
  ) else (
    
    REM - If it doesn't exist or is empty, warn about it
    @echo - >> memelist.txt
    @echo - !team!'s export doesn't have any Kit Configs - Warning. >> memelist.txt
    set memelist=1
    
    REM - If the folder exists but is empty, delete it
    if exist ".\extracted_exports\!foldername!\Kit Configs" (
      rd /S /Q ".\extracted_exports\!foldername!\Kit Configs" >nul
    )
  )
  
)


if not defined error (

  REM - If a Kit Textures folder exists and is not empty, check that the kit textures' filenames and type are correct
  set checktexture=
  >nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\Kit Textures\*" && (set checktexture=1) || (echo ->nul)
  
  if defined checktexture (
    
    set texture_wrongformat_any=
    
    REM - For every texture
    for /f "tokens=*" %%C in ('dir /b ".\extracted_exports\!foldername!\Kit Textures"') do (
      
      if not defined texture_wrongformat_any (
      
        set texture_wrongformat=1
        
        set texturename=%%C
        
        set zlibbed=
        set type_dds=
        set type_ftex=
        
        REM - Check if it is zlibbed
        for /f "tokens=1-6 usebackq" %%D in (`call .\Engines\hexed ".\extracted_exports\!foldername!\Kit Textures\%%C" -d 3 5`) do (
          
          REM - If the file has the WESYS label it's zlibbed
          if "%%E%%F%%G%%H%%I"=="5745535953" (
            
            set zlibbed=1
            
            REM - Unzlib it
            .\Engines\zlibtool ".\extracted_exports\!foldername!\Kit Textures\%%C" -d >nul
            
            REM - Set the unzlibbed file as file to check
            set texturename=%%C.unzlib
          )
        )
        
        
        REM - Check if it is a dds, ftex, or none
        for /f "tokens=1-5 usebackq" %%D in (`call .\Engines\hexed ".\extracted_exports\!foldername!\Kit Textures\!texturename!" -d 0 4`) do (
          
          REM - DDS
          if "%%E%%F%%G"=="444453" (
            set texture_wrongformat=
          )
          
          REM - FTEX
          if "%%E%%F%%G%%H"=="46544558" (
            if defined fox_mode (
              set texture_wrongformat=
            )
          )
        )
        
        
        if defined zlibbed (
          
          REM - Set the original filename
          set texturename=%%C
          
          if not defined fox_mode (
          
            REM - Delete the extra unzlibbed file
            del ".\extracted_exports\!foldername!\Faces\!facename!\!texturename!.unzlib" >nul
            
          ) else (
            
            REM - Delete the orignal zlibbed file
            del ".\extracted_exports\!foldername!\Faces\!facename!\!texturename!" >nul
            
            REM - Rename the file
            rename ".\extracted_exports\!foldername!\Faces\!facename!\!texturename!.unzlib" "!texturename!" >nul
          )
        )
        
        
        if defined texture_wrongformat (
          set texture_wrongformat_any=1
        )
      )
    )
    
    REM - If the folder has a non-dds texture
    if defined texture_wrongformat_any (
    
      REM - Skip the whole Kit Textures folder
      if not %pass_through%==1 (
        rd /S /Q ".\extracted_exports\!foldername!\Kit Textures"
      )
      
      @echo - >> memelist.txt
      @echo - !team!'s manager needs to get memed on (wrong format kit textures^) - Kit Textures discarded. >> memelist.txt
      set memelist=1
      
      @echo -
      @echo - !team!'s manager needs to get memed on (wrong format kit textures^).
      if not defined fox_mode (
        @echo - This is usually caused by png textures renamed to dds instead of saved as dds.
      )
      @echo - First game-crashing texture found: !texturename!
      @echo - The Kit Textures folder will be discarded since it's unusable.
      @echo - Closing the script's window and fixing it is recommended.
      @echo -
      
      if not %pause_when_wrong%==0 (
        pause
      )
    
    
    ) else (
    
      set textureerror=

      REM - For every texture
      for /f "tokens=*" %%C in ('dir /b ".\extracted_exports\!foldername!\Kit Textures"') do (
        
        set texturewrong=
        set texturename=%%C
        
        
        REM - Check that its name starts with u
        if not "!texturename:~0,1!"=="u" set texturewrong=1
        
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
            @echo - !team!'s manager needs to get memed on (wrong kit texture names^). >> memelist.txt
            set memelist=1
            
            @echo -
            @echo - !team!'s manager needs to get memed on (wrong kit texture names^).
          ) 
          
          REM - And skip it
          if not %pass_through%==1 (
            del /F /Q ".\extracted_exports\!foldername!\Kit Textures\!texturename!"
          )
          
          @echo - The kit texture !texturename! is wrong - File discarded. >> memelist.txt
          
          @echo - The kit texture !texturename! is wrong.
        )
      
      )
      
      REM - If the team has bad kit textures close the previously opened message
      if defined textureerror (

        @echo - The kit textures mentioned above will be discarded since they're unusable.
        @echo - Closing the script's window and fixing them is recommended.
        @echo -
        
        if not %pause_when_wrong%==0 (
          pause
        )      
      )
      
    )

  ) else (
  
    REM - If the Kit Textures folder doesn't exist or is empty, warn about it
    @echo - >> memelist.txt
    @echo - !team!'s export doesn't have any Kit Textures - Warning. >> memelist.txt
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
      @echo - !team!'s manager needs to get memed on (wrong logo filenames^). - Logo folder discarded >> memelist.txt
      set memelist=1
      
      @echo -
      @echo - !team!'s manager needs to get memed on (wrong logo filenames^).
      @echo - The Logo folder will be discarded since it's unusable.
      @echo - Closing the script's window and fixing it is recommended.
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
      
      
      REM - Check that its name starts with player_
      if not "!portraitname:~0,7!"=="player_" set portraitwrong=1
      
      REM - Check that the player number is within the 01-23 range
      if "!portraitname:~-6,2!" LSS "01" set portraitwrong=1
      if "!portraitname:~-6,2!" GTR "23" set portraitwrong=1
      
    
      REM - If the portrait is named wrongly
      if defined portraitwrong (
        
        REM - Warn about the team having bad portrait names
        if not defined portraiterror (
          
          set portraiterror=1
          
          @echo - >> memelist.txt
          @echo - !team!'s manager needs to get memed on (wrong portrait names^). >> memelist.txt
          set memelist=1
          
          @echo -
          @echo - !team!'s manager needs to get memed on (wrong portrait names^).
        ) 
        
        REM - And skip it
        if not %pass_through%==1 (
          del /F /Q ".\extracted_exports\!foldername!\Portraits\!portraitname!"
        )
        
        @echo - The portrait !portraitname! is wrong - File discarded. >> memelist.txt
        
        @echo - The portrait !portraitname! is wrong.
      )
    
    )
    
    REM - If the team has bad portraits close the previously opened message
    if defined portraiterror (

      @echo - The portraits mentioned above will be discarded since they're unusable.
      @echo - Closing the script's window and fixing them is recommended.
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
          @echo - !team!'s manager needs to get memed on (wrong boots folder names^). >> memelist.txt
          set memelist=1
          
          @echo -
          @echo - !team!'s manager needs to get memed on (wrong boots folder names^).
        ) 
        
        REM - And skip it
        if not %pass_through%==1 (
          rd /S /Q ".\extracted_exports\!foldername!\Boots\!bootsname!"
        )
        
        @echo - The boots folder !bootsname! is wrong - Folder discarded. >> memelist.txt
        
        @echo - The boots folder !bootsname! is wrong.
      )
      
    )
  
    REM - If the team has bad boots folders close the previously opened message
    if defined bootserror (

      @echo - The boots folders mentioned above will be discarded since they're unusable.
      @echo - Closing the script's window and fixing them is recommended.
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
          @echo - !team!'s manager needs to get memed on (wrong glove folder names^). >> memelist.txt
          set memelist=1
          
          @echo -
          @echo - !team!'s manager needs to get memed on (wrong glove folder names^).
        ) 
        
        REM - And skip it
        if not %pass_through%==1 (
          rd /S /Q ".\extracted_exports\!foldername!\Gloves\!glovesname!"
        )
        
        @echo - The glove folder !glovesname! is wrong - Folder discarded. >> memelist.txt
        
        @echo - The glove folder !glovesname! is wrong.
      )
      
    )
  
    REM - If the team has bad gloves folders close the previously opened message
    if defined gloveserror (

      @echo - The glove folders mentioned above will be discarded since they're unusable.
      @echo - Closing the script's window and fixing them is recommended.
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

  REM - If a Common folder exists and is empty, delete it
  if exist ".\extracted_exports\!foldername!\Common" (
  
    set keepcommon=
    >nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\Common\*" && (set keepcommon=1) || (echo ->nul)
    
    if not defined keepcommon (
      rd /S /Q ".\extracted_exports\!foldername!\Common" >nul
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


