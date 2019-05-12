REM - Request for admin permissions

REM - Check and store the all_in_one mode in a temp file
if defined all_in_one (
  @echo set all_in_one=1 > .\Engines\temp.bat
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
if exist .\temp.bat (
  call .\temp.bat
  del .\temp.bat
)
 
REM - Invoke the relevant part of the process
if defined all_in_one (
  ..\exports_to_extracted
) else (
  ..\content_to_patches
)
