
REM - Reset the variables
set kits_found=
set kits=0
set stop=


REM - For every line
for /f "tokens=1-10 usebackq" %%A in (".\extracted_exports\!foldername!\!txtname!") do (
  
  REM - Unless the relevant stuff is over
  if not defined stop (
    
    REM - If we're looking at the part about kits
    if defined kits_found (
      
      REM - If we reached the end
      if /i %%A==Player (
        
        REM - Stop looking for stuff in the file
        set stop=1
        
      ) else (
      
        set ok=1
        set hexcoded=
        set check=%%D
        
        REM - Check if the entry is already in hex
        if "!check:~0,1!"=="#" set hexcoded=1
        
        REM - Check if the entry is proper and in range
        if defined hexcoded (
        
          for /l %%O in (1 1 6) do (
              
            set byte=!check:~%%O,1!
            
            if !byte! LSS 0 set ok=
            if !byte! GTR F set ok=
          )
          
        ) else (
        
          if !check! LSS 0 set ok=
          if !check! GTR 255 set ok=
        )
        
        if not defined check set ok=
        
        if defined ok (
        
          REM - Raise the kits counter
          set /a kits+=1 
        ) 
      )
    
    ) else (
      
      REM - If we reached the kit colors part
      if /i %%A==Kit (
        
        REM - Start looking for kit colors
        set kits_found=1
        
      )
    )
  )
  
)

