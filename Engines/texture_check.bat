REM - Check if the texture is a proper dds or ftex and unzlibs if needed

set texture_path=%~1
set texture_name=%2

set texture_zlibbed=

set texture_wrongformat=
set texture_mips_none=


REM - Check the type
if /i !texture_name:~-3,3!==dds set texture_type=dds
if /i !texture_name:~-4,4!==ftex set texture_type=ftex

REM - Check if it is zlibbed
for /f "tokens=1-6 usebackq" %%E in (`call .\Engines\hexed ".\!texture_path!\!texture_name!" -d 3 5`) do (
  
  REM - If the file has the WESYS label it's zlibbed
  if "%%F%%G%%H%%I%%J"=="5745535953" (
    
    set texture_zlibbed=1
    
    REM - Unzlib it
    call .\Engines\zlibtool ".\!texture_path!\!texture_name!" -d >nul
    
    REM - Store the original filename and set the unzlibbed file as file to check
    set texture_name_orig=!texture_name!
    set texture_name=!texture_name!.unzlib
  )
)

REM - Check if it is a dds, ftex, or none
for /f "tokens=1-5 usebackq" %%D in (`call .\Engines\hexed ".\!texture_path!\!texture_name!" -d 0 4`) do (
  
  REM - DDS
  if /i !texture_type!==dds (

    if not "%%E%%F%%G"=="444453" (
      
      echo - Texture .\!texture_path!\!texture_name! is not a real !texture_type!
      echo - The file will be deleted, please save it properly

      set texture_wrongformat=1
    )
  )
    
  
  REM - FTEX
  if /i !texture_type!==ftex (
    
    if %fox_mode%==0 (
      
      echo - Texture .\!texture_path!\!texture_name! is an !texture_type! file
      echo - !texture_type! textures are not supported on the chosen PES version

      set texture_wrongformat=1

    ) else (
      
      if not "%%E%%F%%G%%H"=="46544558" (

        echo - Texture .\!texture_path!\!texture_name! is not a real !texture_type!
        echo - The file will be deleted, please save it properly

        set texture_wrongformat=1
      )
    )
       
  )
)

REM - If it's an ftex and fox mode is enabled
if defined texture_type_ftex (
  if %fox_mode%==1 (
    
    REM - Check if it has mipmaps
    for /f "tokens=1-2 usebackq" %%D in (`call .\Engines\hexed ".\!texture_path!\!texture_name!" -w 1 -d 10 1`) do (
      
      REM - Mipmaps count byte different from 0
      set byte=%%E
      
      if !byte!==00 (
        set texture_mips_none=1
      )
      
    )
    
    if defined texture_mips_none (
      set texture_wrongformat=1
    )
    
  )
)

if defined texture_wrongformat (

  del ".\!texture_path!\!texture_name!" >nul

) else (

  if defined texture_zlibbed (
    
    if %fox_mode%==0 (
    
      REM - Delete the extra unzlibbed file
      del ".\!texture_path!\!texture_name!" >nul
      
    ) else (
      
      REM - Delete the orignal zlibbed file
      del ".\!texture_path!\!texture_name_orig!" >nul
      
      REM - Rename the file
      rename ".\!texture_path!\!texture_name!" "!texture_name_orig!" >nul
    )
  )

)

