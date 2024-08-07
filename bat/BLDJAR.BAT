@if /I "%1" == "tron" (echo on) else (echo off)
rem create z390 jar file from sources
rem A single parameter is allowed:
rem - NoDocs specifies to suppress generating javadoc files
rem - Debug  specifies to generate jar with debug enabled
rem --> the default is to generate javadoc and suppress debug info

setlocal
if /I "%1" == "tron" (set z_TraceMode=tron
                      shift /1
              ) else (if /I "%1" == "troff" (set z_TraceMode=troff
                                             shift /1
                                     ) else (set z_TraceMode=)
                      )
set /A z_NestLevel=%z_NestLevel%+1
rem ----- Lvl(%z_NestLevel%) Start %0 %1 %2 %3 %4 %5 %6 %7 %8 %9

pushd %~dps0..
rem both the compiler javac.exe and jar builder jar.exe must be on sdk path
rem note you can use current z390.jar with compatible java runtime with sdk

rem unless suppressed, generate javadoc. Ignore any errors
if /I %1. NEQ Nodocs. (call bat\BLDJVDOC.BAT
               ) else (shift /1
                       )

rem compile java code and create jar file
if not exist ".\jar\" mkdir jar

erase jar\*.java
erase jar\*.class
erase jar\z390.jar
copy  src\*.java   jar
copy  src\z390.man jar
cd jar
rem compile z390 java sources to class vm object code
if /I %1. EQU Debug. (set jvopt=-g) else (set jvopt=-g:none)
java -version
javac.exe %jvopt% *.java
set z_ReturnCode=%ERRORLEVEL%
if %z_ReturnCode% NEQ 0 (echo %0 ERROR: Error compiling z390 java sources
                         goto return
                         )

rem create z390.properties file
call ..\bat\RELVER.BAT %z_TraceMode% %1
set z_ReturnCode=%ERRORLEVEL%
if %z_ReturnCode% NEQ 0 (echo %0 ERROR: Error finding z390 version number
                         goto return
                         )

rem build z390.jar with sdk utility
jar.exe cmf z390.man z390.jar *.class ..\*.properties
set z_ReturnCode=%ERRORLEVEL%
if %z_ReturnCode% NEQ 0 (echo %0 ERROR: Error creating z390.jar file
                         goto return
                         )
if not exist z390.jar   (echo %0 ERROR: Error z390.jar file failed to be created
                         set z_ReturnCode=8
                         goto return
                         )

cd ..
copy jar\z390.jar
dir z390.jar
set z_ReturnCode=0

:return
popd
rem ----- Lvl(%z_NestLevel%)  End %0 %1 %2 %3 %4 %5 %6 %7 %8 %9
exit /b %z_ReturnCode%
