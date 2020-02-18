REM - Script for loading the settings file, or some default settings if the file is missing

if exist settings.txt (
  
  rename settings.txt settings.cmd
  call settings
  rename settings.cmd settings.txt
  
) else (
  
  @echo - Warning:
  @echo - The settings.txt file is missing.
  @echo - The compiler will run with the default settings.
  @echo - 
  @echo - Getting a settings file from the zip this compiler came from is recommended.
  @echo - 
  
  set fox_mode=1
  set fox_portraits=1
  set cpk_name=4cc_90_test
  set move_cpks=1
  set pes_download_folder_location="C:\Program Files (x86)\Pro Evolution Soccer 2018\download"
  set dpfl_updating=1
  set bins_updating=1
  set multicpk_mode=0
  set fmdl_id_editing=1
  set compression=0
  set pause_when_wrong=1
  set pass_through=0
  set admin_mode=0
  
)