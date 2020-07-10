REM - Script to check if python is in the PATH and that its version is 3

for /f "tokens=*" %%A in ('python --version 2^>nul') do set python_version=%%A

if not "%python_version:~0,8%"=="Python 3" (
  echo - 
  echo - Python 3.x is missing from your pc, please install it
  echo - 
  echo - If it is already installed, run the installer again, choose Modify, click Next and make
  echo - sure to check the "Add Python to environment variables" checkbox, then click Install
  echo - 
  echo - Press any key to open the Python download webpage...
  echo - 
  pause >nul

  start "" https://www.python.org/downloads/

  timeout /t 5 >nul

  echo - 
  echo - Press any key to resume the compiler after installing or fixing Python...
  echo - 

  pause >nul

  .\Engines\python_check
)


