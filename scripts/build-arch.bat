@echo off
echo Deprecated: use scripts\legacy\windows\build-arch.bat or the current Artemis build scripts under scripts\windows\.
set SCRIPT_DIR=%~dp0
call "%SCRIPT_DIR%legacy\windows\build-arch.bat" %*
exit /b %ERRORLEVEL%
