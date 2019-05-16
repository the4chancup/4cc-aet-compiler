REM - Adds the filename provided to the dpfilelist if missing

REM - Check if the macro for converting to hexadecimal is defined, run the library otherwise
if not defined macro.Num2Hex (
  .\Engines\MacroLib "%~f0"
)

REM - Allow reading variables modified inside statements
setlocal EnableDelayedExpansion


<nul set /p =- Appending cpk %cpk_name%... 

REM - First check if appending is needed
set stop=
set ok=

REM - Get the hex and length of the name of the cpk
set cpk_name=%cpk_name%.cpk
call .\Engines\CharLib str2hex cpk_name name_hex
call .\Engines\CharLib strlen cpk_name name_len

REM - Set the amount of characters to compare, all except the first 4 and last 3
set /a name_end=(%name_len%-7)*2

REM - For every line in the dpfl
for /l %%Z in (0,1,59) do (

  if not defined stop (
    
    REM - Check if it has a filename
    set /a position=16+%%Z*48
    
    %macro_Call% ("position position_hex") %macro.Num2Hex%
    
    for /f "tokens=1-2" %%X in ('call .\Engines\hexed .\Engines\DpFileList.bin -d !position_hex! 1') do (
      set char=%%Y
    )
    
    REM - If the first character is null stop the check
    if !char!==00 (
    
      set /a entries=%%Z+1
      set stop=1
      
    ) else (
    
      REM - We'll compare the name
      set ok=
      set skip=
      
      set /a position+=4
      
      REM - Compare the characters one by one
      for /l %%A in (8 2 %name_end%) do (
        
        if not defined skip (
          
          %macro_Call% ("position position_hex") %macro.Num2Hex%
          
          for /f "tokens=1-2" %%X in ('call .\Engines\hexed .\Engines\DpFileList.bin -d !position_hex! 1') do (
            set char=%%Y
          )
          
          REM - If the character coincides go on, otherwise stop the check
          if /i "!char!"=="!name_hex:~%%A,2!" (
            
            if %%A==%name_end% (
            
              set ok=1            
              
            ) else (
            
              set /a position+=1
              
            )
            
          ) else (
          
            set skip=1
            
          )
          
        )
      )
      
      REM - If all the characters are equal stop the check
      if defined ok ( 
        set stop=1
      )

    )
  )
)


REM - If appending is not needed get out
if defined ok (
   
  @echo Not needed
  
  exit /b 1
)


REM - If appending is needed


REM - Update the entries count byte
%macro_Call% ("entries entries_hex") %macro.Num2Hex%

.\Engines\hexed .\Engines\DpFileList.bin -e 4 !entries_hex!


REM - Put a space before each character of the hex name, for using with hexed
set name_hexspc=

set /a end=%name_len%*2-2

for /l %%C in (0 2 %end%) do (
  
  if not defined name_hexspc (
    set name_hexspc=!name_hex:~%%C,2!
  ) else (
    set name_hexspc=!name_hexspc! !name_hex:~%%C,2!
  )
)


REM - Add the entry to the dpfl
set /a entries-=1

set /a position=16+%entries%*48

%macro_Call% ("position position_hex") %macro.Num2Hex%

.\Engines\hexed .\Engines\DpFileList.bin -e !position_hex! !name_hexspc! 00


@echo Done

