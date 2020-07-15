@echo off

SET ORICUTRON="..\..\..\..\oricutron-iss2-debug\"

SET RELEASE="30"
SET UNITTEST="NO"

SET ORIGIN_PATH=%CD%

For /f "tokens=1-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%b-%%a)
For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a:%%b)


SET MYDATE=%mydate% %mytime%

echo %MYDATE%

%OSDK%\bin\xa.exe -v -R -cc src\mymDbug.s -o src\mymplayer.o -DTARGET_FILEFORMAT_O65 -DTARGET_ORIX
co65  src\mymplayer.o -o src\mymcc65.s

cl65 -ttelestrat src/mym.c src\mymcc65.s -o build\bin\mym


IF "%1"=="NORUN" GOTO End


copy mym %ORICUTRON%\sdcard\bin\a > NUL




cd %ORICUTRON%
oricutron -mt 


:End
cd %ORIGIN_PATH%
rem %OSDK%\bin\MemMap "%ORIGIN_PATH%\src\xa_labels.txt" docs/memmap.html Telemon docs/telemon.css
