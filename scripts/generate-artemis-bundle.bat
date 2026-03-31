@echo off
set SCRIPT_DIR=%~dp0
call "%SCRIPT_DIR%windows\generate-artemis-bundle.bat" %*
exit /b %ERRORLEVEL%
