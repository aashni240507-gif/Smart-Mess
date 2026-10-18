@REM ----------------------------------------------------------------------------
@REM SmartMess Maven Wrapper Script for Windows
@REM ----------------------------------------------------------------------------
@echo off
setlocal

set "MAVEN_HOME=%USERPROFILE%\apache-maven-3.9.6"
if exist "%MAVEN_HOME%\bin\mvn.cmd" (
    call "%MAVEN_HOME%\bin\mvn.cmd" %*
) else (
    where mvn >nul 2>nul
    if %ERRORLEVEL% equ 0 (
        call mvn %*
    ) else (
        echo [ERROR] Maven not found. Please install Maven or check MAVEN_HOME.
        exit /b 1
    )
)
