REM - Collection of system folders where PES is usually installed
REM - Feel free to add, following the template at the end

if /i "%pes_download_folder_location:~4,7%"=="Program" (
  set admin_mode=1
)
if /i "%pes_download_folder_location:~4,8%"=="Archivos" (
  set admin_mode=1
)
if /i "%pes_download_folder_location:~4,8%"=="Arquivos" (
  set admin_mode=1
)
if /i "%pes_download_folder_location:~4,5%"=="Pliki" (
  set admin_mode=1
)
if /i "%pes_download_folder_location:~4,7%"=="Fisiere" (
  set admin_mode=1
)

REM - Other folder names included in the first check: 
REM - "Programmes", "Programme", "Programfájlok", "Programmi", "Programmer",
REM - "Program", "Program Dosyaları", "Programfiler", "Programas"

REM - The following is a Template, remove the rem parts and fill the missing parts to use it
REM - The 4 indicates the characters to skip, namely the "C:\ part at the beginning (leave it as it is)
REM - The X indicates the length of the word (5 in this case)
REM - asdfg is the folder name (using just the first few characters is fine too)

rem if /i "%pes_download_folder_location:~4,X%"=="asdfg" (
rem   set admin_mode=1
rem )
