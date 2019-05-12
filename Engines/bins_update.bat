@echo off
::=========================================================================
::BEGIN DEFINITION OF THE MACRO FOR CONVERTING TO HEXADECIMAL
::
setlocal disableDelayedExpansion
set LF=^


::Above 2 blank lines are required - do not remove
set ^"\n=^^^%LF%%LF%^%LF%%LF%^^"
set "echo=echo("
set macro_Call=for /f "tokens=1-26" %%a in

set macro.Num2Hex=do (%\n%
  setlocal enableDelayedExpansion%\n%
  set /a "dec=(%%~a)"%\n%
  if defined hex set "hex="%\n%
  set "map=0123456789ABCDEF"%\n%
  for /l %%n in (1,1,8) do (%\n%
    set /a "d=dec&15,dec>>=4"%\n%
    for %%d in (!d!) do set "hex=!map:~%%d,1!!hex!"%\n%
  )%\n%
  for %%v in (!hex!) do endlocal^&if "%%~b" neq "" (set "%%~b=%%v") else %echo%%%v%\n%
)
::
::END DEFINITION OF THE MACRO
::==========================================================================

REM - Allow modifying named variables inside parentheses
setlocal EnableDelayedExpansion

@echo -
@echo - Bins Updating is enabled
@echo -
@echo - Adding the color entries to the bin files
@echo - Working on team:

REM - For every export txt file
for /f "tokens=*" %%Z in ('dir /a:-d /b ".\extracted_exports\*.txt" 2^>nul') do (
  
  REM - Reset the variables
  set team_printed=
  set id=
  set id_found=
  set team_found=
  set kits_found=
  set kits=0
  set player=0
  set gk=0
  set stop=
  
  REM - The kit icon numbers are not in the txt files, so until they're added we'll use this for everything
  set icon=03
  
  REM - For every line
  for /f "tokens=1-10 usebackq" %%A in (".\extracted_exports\%%Z") do (
    
    REM - Unless the relevant stuff is over
    if not defined stop (
      
      REM - If we're looking at the part about kits
      if defined kits_found (
        
        REM - If we reached the end
        if %%A==Player (
          
          REM - Stop looking for stuff in the file
          set stop=1
          
          if !kits! GEQ 10 set kits=a
          
          REM - Write the number of kits to the UniColor file
          .\Engines\hexed ".\other_stuff\Bin Files\UniColor.bin" -e !position! 0!kits!
          
        ) else (
        
          set ok=1
          set hexcoded=
          set check=%%D
          
          REM - Check if the entry is already in hex
          if "!check:~0,1!"=="#" set hexcoded=1
          
          REM - Check if the entry is proper and in range
          if defined hexcoded (
          
            if "!check:~1,1!" LSS "0" set ok=
            if "!check:~1,1!" GTR "F" set ok=
            
          ) else (
          
            if "!check!" LSS "000" set ok=
            if "!check!" GTR "255" set ok=
          )
          
          if defined ok (
          
            REM - If the entry is already in hex
            if defined hexcoded (
              
              REM - Get the second value
              set check2=%%F
              
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
            
            REM - Prepare the kit's type
            if not %%C==GK: (
              
              set type=0!player!
              set /a player+=1
              
            ) else (
              
              set type=1!gk!
              set /a gk+=1
            )
            
            
            REM - Write the number the kit color entry to the UniColor file
            set hex=!type! !icon! !kits_r1! !kits_g1! !kits_b1! !kits_r2! !kits_g2! !kits_b2!
            .\Engines\hexed ".\other_stuff\Bin Files\UniColor.bin" -e !position_kit! !hex!
            

            REM - Raise the kits counter
            set /a kits+=1
            
            REM - Set the position of the next kit
            set /a position_kit=0x!position_kit!+8
            %macro_Call% ("position_kit position_kit") %macro.Num2Hex%
          )
          
        )
      
      ) else (
        
        REM - If we're looking at the part about team colors
        if defined team_found (
        
          REM - If we reached the end
          if %%A==Kit (
            
            REM - Start looking for kit colors
            set kits_found=1
            
            REM - Write the team color entries to the TeamColor file
            .\Engines\hexed ".\other_stuff\Bin Files\TeamColor.bin" -e !position! !hex!
            
            REM - Clear the buffer
            set hex=
            
            REM - Set the position in the UniColor file to write to
            set /a id=0x!id!*85
            set /a position=!id!+4
            %macro_Call% ("position position") %macro.Num2Hex%
            
            REM - Set the position in the UniColor file to write to for the first kit
            set /a position_kit=!id!+5
            %macro_Call% ("position_kit position_kit") %macro.Num2Hex%

          ) else (
            
            set ok=1
            set hexcoded=
            set check=%%C
            
            REM - Check if the entry is already in hex
            if "!check:~0,1!"=="#" set hexcoded=1
            
            REM - Check if the entry is proper and in range
            if defined hexcoded (
            
              if "!check:~1,1!" LSS "0" set ok=
              if "!check:~1,1!" GTR "F" set ok=
              
            ) else (
            
              if "!check!" LSS "000" set ok=
              if "!check!" GTR "255" set ok=
            )
            
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
              if not defined hex (
                set hex=!team_r! !team_g! !team_b!
              ) else (
                set hex=!hex! !team_r! !team_g! !team_b!
              )
            )
          )
        
        ) else (
          
          REM - If we're looking at the part about the team ID
          if defined id_found (
            
            REM - If we reached the end
            if %%A==Team (
              
              REM - Start looking for kit colors
              set team_found=1
              
              REM - Clear the buffer
              set hex=
              
              REM - Set the position in the TeamColor file to write to
              %macro_Call% ("id id") %macro.Num2Hex%
              set position=!id!4
            )

          ) else (
            
            REM - If we just started output the team name or ID to screen
            if not defined team_printed (
              if not "%%B"=="" (
                set team=%%B
              ) else (
                set team=%%A
              )
              
              @echo - !team!
              set team_printed=1
            )
          
            REM - If we've found the team ID
            if "%%A"=="ID:" (
              
              REM - We can move on
              set id_found=1
              
              set id_orig=%%B
              set /a id=%%B-701
              
              REM - Check that the team ID is in the range 701-892
              if %%B LSS 701 set stop=1
              if %%B GTR 892 set stop=1
            )
            
            REM - If the txt file only has the ID in it
            if "%%B"=="" (
              
              REM - We can move on
              set id_found=1
              
              set id_orig=%%A
              set /a id=%%A-701
              
              REM - But only if the team ID is in the range 701-892, otherwise keep looking
              if %%A LSS 701 set id_found=
              if %%A GTR 892 set id_found=
            )
          )
        )
      )
    )
  )
    
)

@echo - Done
@echo - 
