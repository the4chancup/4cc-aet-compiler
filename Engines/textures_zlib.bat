REM - Zlib any texture not in the storage, and replace all the unzlibbed textures with the zlibbed textures in the storage

echo - Zlibbing every texture

REM - Create storage folder just in case
md ".\stored_zlibbed" 2>nul


REM - Check the length of the working folder's path
set working_folder=!script_folder!extracted_exports\!foldername!\

call .\Engines\CharLib strlen working_folder working_folder_len


REM - For each folder in the export folder
for  /f "tokens=*" %%A in ('dir /a:d /b /s ".\extracted_exports\!foldername!\"') do (
  
  REM - For each DDS file
  for  /f "tokens=*" %%B in ('dir /a:-d /b "%%A\*.dds" 2^>nul') do (
    
    set zlibbed=1
    
    REM - Check if it is zlibbed
    for /f "tokens=1-4 usebackq" %%C in (`call .\Engines\hexed "%%A\%%B" -d 0 3`) do (
      
      REM - If the file starts with DDS it's not zlibbed
      if "%%D%%E%%F"=="444453" (
        
        set zlibbed=
      )
    )
    
    REM - If the texture is not zlibbed
    if not defined zlibbed (
    
      REM - Get a short path to its folder from the extracted_exports folder
      set folder=%%A
      set folder_short=!folder:~%working_folder_len%!
      
      
      REM - Check if there's already a zlibbed version of the texture
      if not exist ".\stored_zlibbed\!foldername!\!folder_short!\%%B" (
        
        REM - If there is none create it and store in the stored_zlibbed folder
        echo - !folder_short!\%%B
        
        .\Engines\zlibtool ".\extracted_exports\!foldername!\!folder_short!\%%B" >nul
        
        REM - Create a specular folder if not present
        if not exist ".\stored_zlibbed\!foldername!\!folder_short!\" (
          md  ".\stored_zlibbed\!foldername!\!folder_short!" >nul
        )
        
        REM - Move the zlibbed texture to the storage
        move ".\extracted_exports\!foldername!\!folder_short!\%%B.zlib" ".\stored_zlibbed\!foldername!\!folder_short!" >nul
        
        REM - And change its extension
        rename ".\stored_zlibbed\!foldername!\!folder_short!\%%B.zlib" "%%B" >nul
      )
      

      REM - Copy the zlibbed version to the texture's folder
      copy ".\stored_zlibbed\!foldername!\!folder_short!\%%B" ".\extracted_exports\!foldername!\!folder_short!" >nul
    )
    
  )
)

echo - 


