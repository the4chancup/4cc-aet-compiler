REM -Set the path to PES' download folder in the line below-

set pes_download_folder_location="C:\Program Files (x86)\Pro Evolution Soccer 2016\download"


REM -Ignore the rest-

IF NOT EXIST %pes_download_folder_location%\ (
@Echo -
@Echo -
@Echo -  Please right click on this script file, click on Edit and set the path
@Echo -  to PES' download folder in the beginning of the file to use this tool
@Echo -
@Echo -
pause
EXIT
)


cd /D "%~dp0"

cpkmakec patch_contents test_patch.cpk -align=2048 -mode=FILENAME -mask

copy test_patch.cpk %pes_download_folder_location%

del test_patch.cpk
del cpkmaker.out.csv


@Echo -
@Echo -
@Echo -  CPK Files have been created, Suat CAGDAS 'sxsxsx' modded by Clerish
@Echo -
@Echo -

timeout /t 2