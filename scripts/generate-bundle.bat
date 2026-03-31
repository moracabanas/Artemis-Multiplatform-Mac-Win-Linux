@echo off
echo Deprecated: use scripts\legacy\windows\generate-bundle.bat or scripts\windows\generate-artemis-bundle.bat.
set SCRIPT_DIR=%~dp0
call "%SCRIPT_DIR%legacy\windows\generate-bundle.bat" %*
exit /b %ERRORLEVEL%
