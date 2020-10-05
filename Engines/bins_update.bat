REM - Reads the team and kit color entries in the Note files and adds them to the bin files

REM - Check if the macro for converting to hexadecimal is defined, run the library otherwise
if not defined macro.Num2Hex (
  .\Engines\MacroLib "%~f0"
)

REM - Allow reading variables modified inside statements
setlocal EnableDelayedExpansion


echo -
echo - Bins Updating is enabled
echo -
echo - Adding the color entries to the bin files
echo - Working on team:

REM - For every export txt file
for /f "tokens=*" %%Z in ('dir /a:-d /b ".\extracted_exports\*.txt" 2^>nul') do (
  
  REM - Reset the variables
  set stop=
  set team_printed=
  set id_found=
  set team_found=
  set kits_found=
  
  set id=
  set kit_amount=0
  set team_colors=0
  set player=0
  set gk=0
  
  set team_hex=
  set kit_hex=
  
  REM - For every line
  for /f "tokens=1-12 usebackq" %%A in (".\extracted_exports\%%Z") do (
    
    REM - Unless the relevant stuff is over
    if not defined stop (
      
      REM - If we just started output the team name or ID to screen
      if not defined team_printed (
        
        if not "%%B"=="" (
          set team=%%B
        ) else (
          set team=%%A
        )
        
        REM - Search for the team ID in the list of team names
        for /f "tokens=1,* skip=1 usebackq" %%U in (".\teams_list.txt") do (
          if not defined id_found (
            if /i "!team!"=="%%V" (
              
              set teamid=%%U
              set /a id=!teamid!-100
              set id_found=1
            )
          )
        )
        
        echo - !team! (ID: !teamid!^)
        set team_printed=1
      )
      
      REM - If the team ID is set, continue
      if defined id_found (
        
        set test=%%A%%B
        
        REM - If we've reached the team color section
        if /i "!test:~0,7!"=="TeamCol" (
          
          REM - Start looking for kit colors
          set team_found=1
          set kits_found=
          
          REM - Set the position in the TeamColor file to write to
          %macro_Call% ("id team_position") %macro.Num2Hex%
          set team_position=!team_position!4
        )
        
        REM - If we've reached the kit color section
        if /i "!test:~0,6!"=="KitCol" (
          
          REM - Start looking for kit colors
          set kits_found=1
          set team_found=
          
          REM - Set the positions in the UniColor file to write to
          set /a kit_position=!id!*85
          set /a kit_position=!kit_position!+4
          set /a kit_position_entry=!kit_position!+1
          
          %macro_Call% ("kit_position kit_position") %macro.Num2Hex%
          %macro_Call% ("kit_position_entry kit_position_entry") %macro.Num2Hex%
        )
        
        REM - If we've reached the Player section
        if /i "!test:~0,6!"=="Player" (
          
          REM - Stop looking for stuff in the file
          set stop=1
        )
        
        REM - If we've reached the Other section
        if /i "!test:~0,5!"=="Other" (
          
          REM - Stop looking for stuff in the file
          set stop=1
        )
        
        
        REM - If we're looking at the part about team colors
        if defined team_found (
        
          set ok=1
          set hexcoded=
          set check=%%C
          
          REM - Check if the entry is already in hex
          if "!check:~0,1!"=="#" set hexcoded=1
          
          REM - Check if the entry is proper and in range
          if defined hexcoded (
            
            for /l %%O in (1 1 6) do (
              
              set byte=!check:~%%O,1!
              
              if !byte! LSS 0 set ok=
              if !byte! GTR F set ok=
            )
            
          ) else (
          
            if !check! LSS 0 set ok=
            if !check! GTR 255 set ok=
          )
          
          if not defined check set ok=
          
          if defined ok (
          
            REM - If the entry is already in hex
            if defined hexcoded (
              
              REM - Get the team color directly
              set team_r=!check:~1,2!
              set team_g=!check:~3,2!
              set team_b=!check:~5,2!
            
            REM - If it's not
            ) else (
            
              REM - Get the team color
              set team_r=%%C
              set team_g=%%D
              set team_b=%%E
              
              REM - Remove any leading zeros
              for /l %%Y in (1,1,2) do (
                if "!team_r:~0,1!"=="0" (set team_r=!team_r:~1!)
                if "!team_g:~0,1!"=="0" (set team_g=!team_g:~1!)
                if "!team_b:~0,1!"=="0" (set team_b=!team_b:~1!)
              )
              
              REM - Convert to hex
              %macro_Call% ("team_r team_r") %macro.Num2Hex%
              %macro_Call% ("team_g team_g") %macro.Num2Hex%
              %macro_Call% ("team_b team_b") %macro.Num2Hex%
              
              REM - Truncate to two digits
              set "team_r=!team_r:~-2!"
              set "team_g=!team_g:~-2!"
              set "team_b=!team_b:~-2!"
            )

            REM - Add the entry to the buffer
            if not defined team_hex (
              set team_hex=!team_r! !team_g! !team_b!
            ) else (
              set team_hex=!team_hex! !team_r! !team_g! !team_b!
            )
            
            REM - Raise the colors counter
            set /a team_colors+=1
          )
        )
        
        
        REM - If we're looking at the part about kits
        if defined kits_found (
        
          set ok=1
          set hexcoded=
          set check=%%D
          
          REM - Check if the entry is already in hex
          if "!check:~0,1!"=="#" set hexcoded=1
          
          REM - Check if the entry is proper and in range
          if defined hexcoded (
            
            for /l %%O in (1 1 6) do (
              
              set byte=!check:~%%O,1!
              
              if !byte! LSS 0 set ok=
              if !byte! GTR F set ok=
            )
            
          ) else (
          
            if !check! LSS 0 set ok=
            if !check! GTR 255 set ok=
          )
          
          if not defined check set ok=
          
          if defined ok (
          
            REM - If the entry is already in hex
            if defined hexcoded (
              
              REM - Get the second value
              set check2=%%F
              
              REM - Get the custom icon value
              set checkicon=%%H
              
              REM - Get the kit's colors directly
              set kits_r1=!check:~1,2!
              set kits_g1=!check:~3,2!
              set kits_b1=!check:~5,2!
              set kits_r2=!check2:~1,2!
              set kits_g2=!check2:~3,2!
              set kits_b2=!check2:~5,2!
            
            REM - If it's not
            ) else (
        
              REM - Get the kit's colors
              set kits_r1=%%D
              set kits_g1=%%E
              set kits_b1=%%F
              set kits_r2=%%H
              set kits_g2=%%I
              set kits_b2=%%J
              
              REM - Get the custom icon value
              set checkicon=%%L
              
              REM - Remove any leading zeros
              for /l %%Y in (1,1,2) do (
                if "!kits_r1:~0,1!"=="0" (set kits_r1=!kits_r1:~1!)
                if "!kits_g1:~0,1!"=="0" (set kits_g1=!kits_g1:~1!)
                if "!kits_b1:~0,1!"=="0" (set kits_b1=!kits_b1:~1!)
                if "!kits_r2:~0,1!"=="0" (set kits_r2=!kits_r2:~1!)
                if "!kits_g2:~0,1!"=="0" (set kits_g2=!kits_g2:~1!)
                if "!kits_b2:~0,1!"=="0" (set kits_b2=!kits_b2:~1!)
              )
              
              REM - Convert to hex
              %macro_Call% ("kits_r1 kits_r1") %macro.Num2Hex%
              %macro_Call% ("kits_g1 kits_g1") %macro.Num2Hex%
              %macro_Call% ("kits_b1 kits_b1") %macro.Num2Hex%
              %macro_Call% ("kits_r2 kits_r2") %macro.Num2Hex%
              %macro_Call% ("kits_g2 kits_g2") %macro.Num2Hex%
              %macro_Call% ("kits_b2 kits_b2") %macro.Num2Hex%
              
              REM - Truncate to two digits
              set "kits_r1=!kits_r1:~-2!"
              set "kits_g1=!kits_g1:~-2!"
              set "kits_b1=!kits_b1:~-2!"
              set "kits_r2=!kits_r2:~-2!"
              set "kits_g2=!kits_g2:~-2!"
              set "kits_b2=!kits_b2:~-2!"              
            )
            
            REM - Check if the custom icon number exists and is in range
            set okicon=1
            
            if !checkicon! LSS 0 set okicon=
            if !checkicon! GTR 23 set okicon=
            if not defined checkicon set okicon=
            
            if defined okicon (
            
              if "!checkicon:~-2,1!"=="0" (
                set checkicon=!checkicon:~-1!
              )
              
              REM - Convert to hex
              %macro_Call% ("checkicon checkicon") %macro.Num2Hex%

              set icon=!checkicon!
            
            ) else (
            
              set icon=3
            )
            
            REM - Prepare the kit's type
            if not %%C==GK: (
              
              set type=0!player!
              set /a player+=1
              
            ) else (
              
              set type=1!gk!
              set /a gk+=1
            )
            
            
            REM - Write the kit color entry to the UniColor file
            set kit_hex=!type! !icon! !kits_r1! !kits_g1! !kits_b1! !kits_r2! !kits_g2! !kits_b2!
            .\Engines\hexed ".\Bin Files\UniColor.bin" -e !kit_position_entry! !kit_hex!
            
            REM - Raise the kits counter
            set /a kit_amount+=1
            
            REM - Set the position of the next kit
            set /a kit_position_entry=0x!kit_position_entry!+8
            %macro_Call% ("kit_position_entry kit_position_entry") %macro.Num2Hex%
          )
        )
        
      )
    )
  )
  
  REM - When the file is over, if there were team color entries
  if not !team_colors!==0 (
    
    REM - Write the team color entries to the TeamColor file
    .\Engines\hexed ".\Bin Files\TeamColor.bin" -e !team_position! !team_hex!
  )
  
  REM - When the file is over, if there were kit color entries
  if defined kits_found (
    
    REM - Check how many kit entries must be left blank
    set /a kits_blank=10-!kit_amount!
    set kit_hex=FF 00 00 00 00 00 00 00
    
    for /l %%T in (1,1,!kits_blank!) do (
    
      REM - Write a blank kit color entry to the UniColor file
      .\Engines\hexed ".\Bin Files\UniColor.bin" -e !kit_position_entry! !kit_hex!
      
      REM - Set the position of the next kit
      set /a kit_position_entry=0x!kit_position_entry!+8
      %macro_Call% ("kit_position_entry kit_position_entry") %macro.Num2Hex%
    )
    
    if !kit_amount! GEQ 10 (
      set kit_amount_hex=a
    ) else (
      set kit_amount_hex=!kit_amount!
    )
    
    REM - Write the number of kits to the UniColor file
    .\Engines\hexed ".\Bin Files\UniColor.bin" -e !kit_position! 0!kit_amount_hex!
    
    
    if exist ".\extracted_exports\Kit Configs\!teamid!\" (

      REM - Check that the amount of kits found is equal to the aomunt of kit config files
      set kit_configs=0
      
      for /f "tokens=*" %%O in ('dir /a:-d /b ".\extracted_exports\Kit Configs\!teamid!" 2^>nul') do (
        
        set /a kit_configs+=1
      )
      
      if not "!kit_configs!"=="!kit_amount!" (
      
        echo - Warning -
        echo -
        if defined team (
          echo - The amount of !team!'s kit color entries is not
        ) else (
          echo - The amount of !teamid!'s kit color entries is not
        )
        echo - equal to the amount of kit config files
        echo - Stopping the script and fixing it is recommended
        echo -
        
        if not %pause_when_wrong%==0 (
          pause
        )
      )
    
    )
  )
  
  echo - Team colors: !team_colors! - Kits: !kit_amount!
  
)

echo - Done
echo - 
