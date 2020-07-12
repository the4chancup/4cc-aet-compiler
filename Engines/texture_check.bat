REM - Check if the texture is a proper dds or ftex and unzlibs if needed

set self_tex_path=%~1
set self_tex_name=%2

set self_tex_zlibbed=

set self_tex_wrongformat=
set self_tex_mips_none=


REM - Check the type
if /i "!self_tex_name:~-3,3!"=="dds" set self_tex_type=dds
if /i "!self_tex_name:~-4,4!"=="ftex" set self_tex_type=ftex

REM - Check if it is zlibbed
for /f "tokens=1-6 usebackq" %%E in (`call .\Engines\hexed ".\!self_tex_path!\!self_tex_name!" -d 3 5`) do (
  
  REM - If the file has the WESYS label it's zlibbed
  if "%%F%%G%%H%%I%%J"=="5745535953" (
    
    set self_tex_zlibbed=1
    
    REM - Unzlib it
    call .\Engines\zlibtool ".\!self_tex_path!\!self_tex_name!" -d >nul
    
    REM - Store the original filename and set the unzlibbed file as file to check
    set self_tex_name_orig=!self_tex_name!
    set self_tex_name=!self_tex_name!.unzlib
  )
)

REM - Check if it is a dds, ftex, or none
for /f "tokens=1-5 usebackq" %%D in (`call .\Engines\hexed ".\!self_tex_path!\!self_tex_name!" -d 0 4`) do (
  
  REM - DDS
  if /i !self_tex_type!==dds (

    if not "%%E%%F%%G"=="444453" (
      
      rem echo - Texture .\!self_tex_path!\!self_tex_name! is not a real !self_tex_type!
      rem echo - The file will be deleted, please save it properly

      set self_tex_wrongformat=1
    )
  )
    
  
  REM - FTEX
  if /i !self_tex_type!==ftex (
    
    if %fox_mode%==0 (
      
      echo - Texture .\!self_tex_path!\!self_tex_name! is a !self_tex_type! file
      echo - !self_tex_type! textures are not supported on the chosen PES version

      set self_tex_wrongformat=1

    ) else (
      
      if not "%%E%%F%%G%%H"=="46544558" (

        rem echo - Texture .\!self_tex_path!\!self_tex_name! is not a real !self_tex_type!
        rem echo - The file will be deleted, please save it properly

        set self_tex_wrongformat=1
      )
    )
       
  )
)

REM - If it's an ftex and fox mode is enabled
if defined self_tex_type_ftex (
  if %fox_mode%==1 (
    
    REM - Check if it has mipmaps
    for /f "tokens=1-2 usebackq" %%D in (`call .\Engines\hexed ".\!self_tex_path!\!self_tex_name!" -w 1 -d 10 1`) do (
      
      REM - Mipmaps count byte different from 0
      set byte=%%E
      
      if !byte!==00 (

        echo - Texture .\!self_tex_path!\!self_tex_name! is missing mimaps
        echo - The file will be deleted, please save it properly

        set self_tex_mips_none=1
      )
      
    )
    
    if defined self_tex_mips_none (
      set self_tex_wrongformat=1
    )
    
  )
)

if defined self_tex_zlibbed (
  
  if %fox_mode%==0 (
  
    REM - Delete the extra unzlibbed file
    del ".\!self_tex_path!\!self_tex_name!" >nul
    
  ) else (
    
    REM - Delete the original zlibbed file
    del ".\!self_tex_path!\!self_tex_name_orig!" >nul
    
    REM - Rename the file
    rename ".\!self_tex_path!\!self_tex_name!" "!self_tex_name_orig!" >nul
  )
)

REM - Copy the result to the third parameter
if defined self_tex_wrongformat set "%~3=1"
