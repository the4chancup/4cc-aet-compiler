REM - Request for admin permissions

REM - Check for the all_in_one mode and make a blank temp file if enabled
if defined all_in_one (
  type nul > .\temp
)


REM (Check for permissions)
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM (If error flag set, we do not have admin)
if '%errorlevel%' NEQ '0' (
  echo Requesting administrative privileges...
  goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
  echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
  echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

  cscript "%temp%\getadmin.vbs"
  exit /B

:gotAdmin
  if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
  pushd "%CD%"
  CD /D "%~dp0"


REM - Stop from asking for admin permissions again
set admin_enabled=1


REM - Load the all_in_one mode and delete the temp file
if exist .\temp (
  set all_in_one=1
  del .\temp
)
 
REM - Invoke the relevant part of the process
if defined all_in_one (
  ..\1_exports_to_extracted
) else (
  ..\3_content_to_patches
)
