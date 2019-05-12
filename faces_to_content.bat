cd /D "%~dp0"

md .\\faces_to_add
md .\\faces_in_folders
md .\\patch_contents


for /f %%a IN ('dir /b faces_to_add') do md .\\faces_in_folders\\%%a\\common\\character0\\model\\character\\face\\real\\%%a
for /f %%a IN ('dir /b faces_to_add') do copy .\\faces_to_add\\%%a .\\faces_in_folders\\%%a\\common\\character0\\model\\character\\face\\real\\%%a

for /f %%a IN ('dir /b faces_to_add') do cpkmakec .\\faces_in_folders\\%%a .\\patch_contents\\common\\character0\\model\\character\\face\\real\\%%a.cpk -align=2048 -mode=FILENAME -mask


rd /S /Q .\\faces_in_folders


@Echo -
@Echo -
@Echo -  CPK Files have been created, Suat CAGDAS 'sxsxsx' modded by Clerish
@Echo -
@Echo -

timeout /t 2