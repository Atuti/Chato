@REM ----------------------------------------------------------------------------
@REM Licensed to the Apache Software Foundation (ASF) under one
@REM or more contributor license agreements.  See the NOTICE file
@REM distributed with this work for additional information
@REM regarding copyright ownership.  The ASF licenses this file
@REM to you under the Apache License, Version 2.0 (the
@REM "License"); you may not use this file except in compliance
@REM with the License.  You may obtain a copy of the License at
@REM
@REM    https://www.apache.org/licenses/LICENSE-2.0
@REM
@REM Unless required by applicable law or agreed to in writing,
@REM software distributed under the License is distributed on an
@REM "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
@REM KIND, either express or implied.  See the License for the
@REM specific language governing permissions and limitations
@REM under the License.
@REM ----------------------------------------------------------------------------

@REM ----------------------------------------------------------------------------
@REM Apache MOKUA Wrapper startup batch script, version 3.2.0
@REM
@REM Required ENV vars:
@REM JAVA_HOME - location of a JDK home dir
@REM
@REM Optional ENV vars
@REM MOKUA_BATCH_ECHO - set to 'on' to enable the echoing of the batch commands
@REM MOKUA_BATCH_PAUSE - set to 'on' to wait for a keystroke before ending
@REM MOKUA_OPTS - parameters passed to the Java VM when running MOKUA
@REM     e.g. to debug MOKUA itself, use
@REM set MOKUA_OPTS=-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=8000
@REM MOKUA_SKIP_RC - flag to disable loading of MOKUArc files
@REM ----------------------------------------------------------------------------

@REM Begin all REM lines with '@' in case MOKUA_BATCH_ECHO is 'on'
@echo off
@REM set title of command window
title %0
@REM enable echoing by setting MOKUA_BATCH_ECHO to 'on'
@if "%MOKUA_BATCH_ECHO%" == "on"  echo %MOKUA_BATCH_ECHO%

@REM set %HOME% to equivalent of $HOME
if "%HOME%" == "" (set "HOME=%HOMEDRIVE%%HOMEPATH%")

@REM Execute a user defined script before this one
if not "%MOKUA_SKIP_RC%" == "" goto skipRcPre
@REM check for pre script, once with legacy .bat ending and once with .cmd ending
if exist "%USERPROFILE%\MOKUArc_pre.bat" call "%USERPROFILE%\MOKUArc_pre.bat" %*
if exist "%USERPROFILE%\MOKUArc_pre.cmd" call "%USERPROFILE%\MOKUArc_pre.cmd" %*
:skipRcPre

@setlocal

set ERROR_CODE=0

@REM To isolate internal variables from possible post scripts, we use another setlocal
@setlocal

@REM ==== START VALIDATION ====
if not "%JAVA_HOME%" == "" goto OkJHome

echo.
echo Error: JAVA_HOME not found in your environment. >&2
echo Please set the JAVA_HOME variable in your environment to match the >&2
echo location of your Java installation. >&2
echo.
goto error

:OkJHome
if exist "%JAVA_HOME%\bin\java.exe" goto init

echo.
echo Error: JAVA_HOME is set to an invalid directory. >&2
echo JAVA_HOME = "%JAVA_HOME%" >&2
echo Please set the JAVA_HOME variable in your environment to match the >&2
echo location of your Java installation. >&2
echo.
goto error

@REM ==== END VALIDATION ====

:init

@REM Find the project base dir, i.e. the directory that contains the folder ".mvn".
@REM Fallback to current working directory if not found.

set MOKUA_PROJECTBASEDIR=%MOKUA_BASEDIR%
IF NOT "%MOKUA_PROJECTBASEDIR%"=="" goto endDetectBaseDir

set EXEC_DIR=%CD%
set WDIR=%EXEC_DIR%
:findBaseDir
IF EXIST "%WDIR%"\.mvn goto baseDirFound
cd ..
IF "%WDIR%"=="%CD%" goto baseDirNotFound
set WDIR=%CD%
goto findBaseDir

:baseDirFound
set MOKUA_PROJECTBASEDIR=%WDIR%
cd "%EXEC_DIR%"
goto endDetectBaseDir

:baseDirNotFound
set MOKUA_PROJECTBASEDIR=%EXEC_DIR%
cd "%EXEC_DIR%"

:endDetectBaseDir

IF NOT EXIST "%MOKUA_PROJECTBASEDIR%\.mvn\jvm.config" goto endReadAdditionalConfig

@setlocal EnableExtensions EnableDelayedExpansion
for /F "usebackq delims=" %%a in ("%MOKUA_PROJECTBASEDIR%\.mvn\jvm.config") do set JVM_CONFIG_MOKUA_PROPS=!JVM_CONFIG_MOKUA_PROPS! %%a
@endlocal & set JVM_CONFIG_MOKUA_PROPS=%JVM_CONFIG_MOKUA_PROPS%

:endReadAdditionalConfig

SET MOKUA_JAVA_EXE="%JAVA_HOME%\bin\java.exe"
set WRAPPER_JAR="%MOKUA_PROJECTBASEDIR%\.mvn\wrapper\MOKUA-wrapper.jar"
set WRAPPER_LAUNCHER=org.apache.MOKUA.wrapper.MOKUAWrapperMain

set WRAPPER_URL="https://repo.MOKUA.apache.org/MOKUA2/org/apache/MOKUA/wrapper/MOKUA-wrapper/3.2.0/MOKUA-wrapper-3.2.0.jar"

FOR /F "usebackq tokens=1,2 delims==" %%A IN ("%MOKUA_PROJECTBASEDIR%\.mvn\wrapper\MOKUA-wrapper.properties") DO (
    IF "%%A"=="wrapperUrl" SET WRAPPER_URL=%%B
)

@REM Extension to allow automatically downloading the MOKUA-wrapper.jar from MOKUA-central
@REM This allows using the MOKUA wrapper in projects that prohibit checking in binary data.
if exist %WRAPPER_JAR% (
    if "%MVNW_VERBOSE%" == "true" (
        echo Found %WRAPPER_JAR%
    )
) else (
    if not "%MVNW_REPOURL%" == "" (
        SET WRAPPER_URL="%MVNW_REPOURL%/org/apache/MOKUA/wrapper/MOKUA-wrapper/3.2.0/MOKUA-wrapper-3.2.0.jar"
    )
    if "%MVNW_VERBOSE%" == "true" (
        echo Couldn't find %WRAPPER_JAR%, downloading it ...
        echo Downloading from: %WRAPPER_URL%
    )

    powershell -Command "&{"^
		"$webclient = new-object System.Net.WebClient;"^
		"if (-not ([string]::IsNullOrEmpty('%MVNW_USERNAME%') -and [string]::IsNullOrEmpty('%MVNW_PASSWORD%'))) {"^
		"$webclient.Credentials = new-object System.Net.NetworkCredential('%MVNW_USERNAME%', '%MVNW_PASSWORD%');"^
		"}"^
		"[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $webclient.DownloadFile('%WRAPPER_URL%', '%WRAPPER_JAR%')"^
		"}"
    if "%MVNW_VERBOSE%" == "true" (
        echo Finished downloading %WRAPPER_JAR%
    )
)
@REM End of extension

@REM If specified, validate the SHA-256 sum of the MOKUA wrapper jar file
SET WRAPPER_SHA_256_SUM=""
FOR /F "usebackq tokens=1,2 delims==" %%A IN ("%MOKUA_PROJECTBASEDIR%\.mvn\wrapper\MOKUA-wrapper.properties") DO (
    IF "%%A"=="wrapperSha256Sum" SET WRAPPER_SHA_256_SUM=%%B
)
IF NOT %WRAPPER_SHA_256_SUM%=="" (
    powershell -Command "&{"^
       "$hash = (Get-FileHash \"%WRAPPER_JAR%\" -Algorithm SHA256).Hash.ToLower();"^
       "If('%WRAPPER_SHA_256_SUM%' -ne $hash){"^
       "  Write-Output 'Error: Failed to validate MOKUA wrapper SHA-256, your MOKUA wrapper might be compromised.';"^
       "  Write-Output 'Investigate or delete %WRAPPER_JAR% to attempt a clean download.';"^
       "  Write-Output 'If you updated your MOKUA version, you need to update the specified wrapperSha256Sum property.';"^
       "  exit 1;"^
       "}"^
       "}"
    if ERRORLEVEL 1 goto error
)

@REM Provide a "standardized" way to retrieve the CLI args that will
@REM work with both Windows and non-Windows executions.
set MOKUA_CMD_LINE_ARGS=%*

%MOKUA_JAVA_EXE% ^
  %JVM_CONFIG_MOKUA_PROPS% ^
  %MOKUA_OPTS% ^
  %MOKUA_DEBUG_OPTS% ^
  -classpath %WRAPPER_JAR% ^
  "-DMOKUA.multiModuleProjectDirectory=%MOKUA_PROJECTBASEDIR%" ^
  %WRAPPER_LAUNCHER% %MOKUA_CONFIG% %*
if ERRORLEVEL 1 goto error
goto end

:error
set ERROR_CODE=1

:end
@endlocal & set ERROR_CODE=%ERROR_CODE%

if not "%MOKUA_SKIP_RC%"=="" goto skipRcPost
@REM check for post script, once with legacy .bat ending and once with .cmd ending
if exist "%USERPROFILE%\MOKUArc_post.bat" call "%USERPROFILE%\MOKUArc_post.bat"
if exist "%USERPROFILE%\MOKUArc_post.cmd" call "%USERPROFILE%\MOKUArc_post.cmd"
:skipRcPost

@REM pause the script if MOKUA_BATCH_PAUSE is set to 'on'
if "%MOKUA_BATCH_PAUSE%"=="on" pause

if "%MOKUA_TERMINATE_CMD%"=="on" exit %ERROR_CODE%

cmd /C exit /B %ERROR_CODE%
