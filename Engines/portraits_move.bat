REM - Move the portraits out of the face folders

REM - If a Faces folder exists and is not empty, check that the face folder names are correct
>nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\Faces\*" && (set checkfaces=1) || (set checkfaces=)

if defined checkfaces (
  
  set tex_name=portrait.dds
  
  REM - For every face folder
  for /f "tokens=*" %%C in ('dir /b /a:d ".\extracted_exports\!foldername!\Faces"') do (
    
    set face_name=%%C
    set face_wrong=1
    
    REM - Check that the player number is within the 01-23 range
    if "!face_name:~3,2!" GEQ "01" (
      if "!face_name:~3,2!" LEQ "23" set face_wrong=
    )
    
    if not defined face_wrong (
      
      REM - If the folder has a portrait
      if exist ".\extracted_exports\!foldername!\Faces\!face_name!\!tex_name!" (
        
        set face_id=!teamid!!face_name:~3,2!
        
        REM - Create a folder for portraits if not present
        if not exist ".\extracted_exports\!foldername!\Portraits" (
          md ".\extracted_exports\!foldername!\Portraits" 2>nul
        )
        
        REM - Rename the portrait with the player id
        set portrait_name=player_!face_id!.dds
        rename ".\extracted_exports\!foldername!\Faces\!face_name!\!tex_name!" "!portrait_name!"
        
        REM - Move the portrait to the portraits folder
        move ".\extracted_exports\!foldername!\Faces\!face_name!\!portrait_name!" ".\extracted_exports\!foldername!\Portraits" >nul
      )
    )

    REM - Check if the folder is now empty
    >nul 2>nul dir /a-d /s ".\extracted_exports\!foldername!\Faces\!face_name!\*" && (set keepfolder=1) || (set keepfolder=)
    
    REM - If empty remove it
    if not defined keepfolder (
       rd /S /Q ".\extracted_exports\!foldername!\Faces\!face_name!"
    )
    
  )
)






        