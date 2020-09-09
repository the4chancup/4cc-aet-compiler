REM - Copies the kit 1 textures to the common folder, replacing the dummy kit textures

set team_commonfolder_path=.\extracted_exports\Common\!teamid!

REM - Call the function at the bottom for each file
set kittexture_filename=u0!teamid!p1.ftex
set dummytexture_filename=dummy_kit.ftex

call :dummy_replace


set kittexture_filename=u0!teamid!p1_back.ftex
set dummytexture_filename=dummy_kit_back.ftex

call :dummy_replace


set kittexture_filename=u0!teamid!p1_chest.ftex
set dummytexture_filename=dummy_kit_chest.ftex

call :dummy_replace


set kittexture_filename=u0!teamid!p1_leg.ftex
set dummytexture_filename=dummy_kit_leg.ftex

call :dummy_replace


set kittexture_filename=u0!teamid!p1_name.ftex
set dummytexture_filename=dummy_kit_name.ftex

call :dummy_replace


set kittexture_filename=u0!teamid!p1_nrm.ftex
set dummytexture_filename=dummy_kit_nrm.ftex

call :dummy_replace


set kittexture_filename=u0!teamid!p1_srm.ftex
set dummytexture_filename=dummy_kit_srm.ftex

call :dummy_replace


exit /B 0


REM - Check the existence of each dummy texture and replace it if existing
:dummy_replace
if exist "!team_commonfolder_path!\!dummytexture_filename!" (
  
  if exist ".\extracted_exports\Kit Textures\!kittexture_filename!" (
    
    del "!team_commonfolder_path!\!dummytexture_filename!" >nul
    
    copy ".\extracted_exports\Kit Textures\!kittexture_filename!" "!team_commonfolder_path!" >nul
    
    ren "!team_commonfolder_path!\!kittexture_filename!" "!dummytexture_filename!" >nul
    
  ) else (
    
    echo - 
    echo - Team !team! has a !dummytexture_filename! texture in their common folder but their kit 1 does not have a
    echo - corresponding !kittexture_filename! texture. This dummy texture will not be replaced.
    echo - 
    
  )
)
exit /B 0
