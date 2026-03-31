@echo off
set SCRIPT_DIR=%~dp0
call "%SCRIPT_DIR%windows\build-artemis-arch.bat" %*
exit /b %ERRORLEVEL%
