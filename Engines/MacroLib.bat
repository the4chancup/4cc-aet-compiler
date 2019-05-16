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

REM - Returning to the script that called this one
%1
