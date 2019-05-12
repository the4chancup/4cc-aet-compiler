@echo off
REM ^ Don't write everything to screen

REM - Set the working folder
cd /D "%~dp0"


REM - Set all_in_one mode, so that admin mode is requested from the beginning if needed
set all_in_one=1

@echo - 
@echo - 
@echo - 4cc aet compiler - Full mode
@echo - 
@echo - 

REM - Invoke the first part of the process
call .\1_exports_to_extracted

REM - Invoke the second part of the process
call .\2_extracted_to_content

REM - Invoke the third part of the process
call .\3_content_to_patches
