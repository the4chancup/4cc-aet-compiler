REM - Move the portraits out of the face folders

REM - If a Faces folder exists and is not empty, check that the face folder names are correct
>nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\Faces\*" && (set checkfaces=1) || (set checkfaces=)

if defined checkfaces (
  
  set faceserror=
  
  REM - For every face folder
  for /f "tokens=*" %%C in ('dir /b /a:d ".\extracted_exports\!foldername!\Faces"') do (
    
    set facename=%%C
    
    set facewrong=1
    
    REM - Check that the player number is within the 01-23 range
    if "!facename:~3,2!" GEQ "01" (
      if "!facename:~3,2!" LEQ "23" set facewrong=
    )
    
    if not defined facewrong (
      
      REM - If the folder has a portrait
      if exist ".\extracted_exports\!foldername!\Faces\!facename!\portrait.dds" (
        
        set faceid=!teamid!!facename:~3,2!
        
        REM - Create a folder for portraits if not present
        if not exist ".\extracted_exports\!foldername!\Portraits" (
          md ".\extracted_exports\!foldername!\Portraits" 2>nul
        )
        
        REM - Rename the portrait with the player id
        set portrait_name=player_!faceid!.dds
        rename ".\extracted_exports\!foldername!\Faces\!facename!\portrait.dds" "!portrait_name!"
        
        REM - And move it to the portraits folder
        move ".\extracted_exports\!foldername!\Faces\!facename!\!portrait_name!" ".\extracted_exports\!foldername!\Portraits" >nul
      )
    )

    REM - Check if the folder is now empty
    >nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\Faces\!facename!\*" && (set keepfolder=1) || (set keepfolder=)
    
    REM - If empty remove it
    if not defined keepfolder (
       rd /S /Q ".\extracted_exports\!foldername!\Faces\!facename!"
    )
    
  )
)