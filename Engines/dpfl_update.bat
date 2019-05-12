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
@echo - DpFileList editing is enabled
@echo -

REM - First check if appending is needed
@echo - Checking if appending is needed
@echo -
<nul set /p =- 

REM - Get the number of entries in the bin file
set end=
set entries=0
set position=16

for /l %%Z in (1,1,60) do (
  if not defined end (
    
    %macro_Call% ("position position_hex") %macro.Num2Hex%
    
    for /f "tokens=1-2" %%X in ('call .\Engines\hexed .\Engines\DpFileList.bin -d !position_hex! 1') do set value=%%Y
    
    if not !value!==00 (
      
      set /a entries+=1
      set /a position+=48
    
    ) else (
      
      set end=1
    )
  )
)


REM - Get the hex and length of the name of the faces cpk
set faces_name=%cpk_name%_faces.cpk
call .\Engines\CharLib str2hex faces_name faces_hex
call .\Engines\CharLib strlen faces_name faces_len

REM - Prepare a doubled name for displaying the compared character
set faces_name2=

for /l %%E in (0 1 %faces_len%) do (
  set faces_name2=!faces_name2!!faces_name:~%%E,1!!faces_name:~%%E,1!
)

REM - Set the position pointer to the start of the cpk name of the second to last entry
set /a position-=96

set ok=1

REM - Set the amount of characters to compare, all except the last 2
set /a end=(%faces_len%-3)*2

REM - Compare the characters one by one
for /l %%A in (0 2 %end%) do (
  
  if defined ok (
    
    %macro_Call% ("position position_hex") %macro.Num2Hex%
    
    for /f "tokens=1-2" %%X in ('call .\Engines\hexed .\Engines\DpFileList.bin -d !position_hex! 1') do set char=%%Y

    if /i "!char!"=="!faces_hex:~%%A,2!" (
    
      <nul set /p =!faces_name2:~%%A,1!
      
      set /a position+=1

    ) else (
    
      set ok=
    
    )
  )
)


REM - If appending is not needed get out
if defined ok (
  
  @echo(
  @echo -
  @echo - Not needed
  @echo -
  
  exit /b 1
)


REM - If appending is needed
@echo(
@echo -
@echo - Needed
@echo -
@echo - Appending the cpk entries
@echo - It's the final countdown^^!

REM - Prepare the priority number of the first entry
set /a priority=%entries%+2

REM - Set the position pointer to the priority number of the first entry
set position=4


REM - Raise all the priority numbers by 2
for /l %%B in (1 1 %entries%) do (
  
  @echo - !priority!
  
  %macro_Call% ("priority priority_hex") %macro.Num2Hex%
  %macro_Call% ("position position_hex") %macro.Num2Hex%
  
  .\Engines\hexed .\Engines\DpFileList.bin -e !position_hex! !priority_hex!
  
  set /a priority-=1
  set /a position+=48
)


REM - Get the hex and length of the name of the uniform cpk
set uniform_name=%cpk_name%_uniform.cpk
call .\Engines\CharLib str2hex uniform_name uniform_hex
call .\Engines\CharLib strlen uniform_name uniform_len

REM - Put a space before each character of the hex names, for using with hexed
set faces_hexspc=

set /a end=%faces_len%*2-2

for /l %%C in (0 2 %end%) do (
  set faces_hexspc=!faces_hexspc! !faces_hex:~%%C,2!
)

set uniform_hexspc=

set /a end=%uniform_len%*2-2

for /l %%D in (0 2 %end%) do (
  set uniform_hexspc=!uniform_hexspc! !uniform_hex:~%%D,2!
)


REM - Prepare the default part of the entries
set hex2=64 00 00 00 02 00 00 00 64 00 00 00 D8 27 00 00
set hex1=64 00 00 00 01 00 00 00 64 00 00 00 D8 27 00 00

REM - Add the two last entries to the DpFileList file
@echo - 2

set /a position=%entries%*48
%macro_Call% ("position position_hex") %macro.Num2Hex%

.\Engines\hexed .\Engines\DpFileList.bin -e !position_hex! !hex2!!faces_hexspc!

@echo - 1

set /a position+=48
%macro_Call% ("position position_hex") %macro.Num2Hex%

.\Engines\hexed .\Engines\DpFileList.bin -e !position_hex! !hex1!!uniform_hexspc!

@echo - Finished
@echo -

