@echo off
set "INPUT=%~1"
set "OUTPUT=%~dpn1.md"
"G:\EffCorp_Products\markitdown\.venv\Scripts\markitdown.exe" "%INPUT%" -o "%OUTPUT%"
if %ERRORLEVEL% == 0 (
    echo Done! Saved to: %OUTPUT%
) else (
    echo Conversion failed.
)
pause
