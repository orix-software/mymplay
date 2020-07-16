
@echo off


SET BINARYFILE=mym

::
echo %osdk%
          
mkdir build\usr\bin
mkdir build\usr\share\doc\
mkdir build\usr\share\doc\%BINARYFILE%
mkdir build\usr\share\%BINARYFILE%
mkdir build\usr\share\%BINARYFILE%\games\
mkdir build\usr\share\%BINARYFILE%\4mat\
mkdir build\usr\share\%BINARYFILE%\bigalec\
mkdir build\usr\share\%BINARYFILE%\factor6\
mkdir build\usr\share\man

SET YM2MYM=%osdk%\Bin\ym2mym.exe -h0 -m16000 -t0
SET YM2MYM_ATARI=%osdk%\Bin\ym2mym.exe -h0 -m15872 -t1
SET PATH_RELEASE=build\usr\share\mym\

SET PATH_ATARI=data\atari\
SET PATH_CPC=data\cpc\

echo Generating Numbers

%YM2MYM% "%PATH_ATARI%\4-mat\Beastbusters 1.ym"                %PATH_RELEASE%\4mat\beastbus.mym

echo Generating B Letter
%YM2MYM% "%PATH_ATARI%\Bubble Bobble 1.ym"               %PATH_RELEASE%\games\bubblebo.mym
%YM2MYM% "%PATH_ATARI%\big-alec\bouncy.ym"               %PATH_RELEASE%\bigalec\bouncy.mym
%YM2MYM_ATARI% "%PATH_ATARI%\big-alec\orion.ym"               %PATH_RELEASE%\bigalec\orion.mym
%YM2MYM_ATARI% "%PATH_ATARI%\big-alec\traffic.ym"               %PATH_RELEASE%\bigalec\traffic.mym
%YM2MYM_ATARI% "%PATH_ATARI%\big-alec\Reality.ym"               %PATH_RELEASE%\bigalec\reality.mym
%YM2MYM_ATARI% "%PATH_ATARI%\big-alec\feardrop.ym"               %PATH_RELEASE%\bigalec\feardrop.mym

%YM2MYM% "%PATH_CPC%\factor6\BatmanForever.ym"               %PATH_RELEASE%\factor6\batman.mym
%YM2MYM% "%PATH_CPC%\factor6\BatmanForeverEnd.ym"               %PATH_RELEASE%\factor6\batmanen.mym

rem too long
rem %YM2MYM% "data\big-alec\Judgement day.ym"               %PATH_RELEASE%\bigalec\judgemen.mym



echo Generating C Letter
%YM2MYM_ATARI% "%PATH_ATARI%\Commando.ym"                     %PATH_RELEASE%\games\commando.mym                         

echo Generating G Letter
%YM2MYM_ATARI% "%PATH_ATARI%\The Real Ghostbusters 1.ym"       %PATH_RELEASE%\games\ghostbus.mym      
%YM2MYM% "%PATH_ATARI%\Great Giana Sisters 1 - title.ym" %PATH_RELEASE%\games\gianatit.mym 

echo Generating N Letter
%YM2MYM% "%PATH_ATARI%\Nebulus.ym"                       %PATH_RELEASE%\games\nebulus.mym

echo Generating O Letter
%YM2MYM% "%PATH_ATARI%\Outrun 1.ym"                      %PATH_RELEASE%\games\outrun.mym                           

echo Generating P Letter
%YM2MYM% "%PATH_ATARI%\Pacmania 1.ym"                    %PATH_RELEASE%\games\pacmania.mym

echo Generating R Letter
%YM2MYM% "%PATH_ATARI%\Rainbow Island  1.ym"             %PATH_RELEASE%\games\rainbowi.mym           

echo Generating S Letter
%YM2MYM% "%PATH_ATARI%\Speedball 1.ym"                   %PATH_RELEASE%\games\speedbal.mym                     
%YM2MYM% "%PATH_ATARI%\Supercars 1.ym"                   %PATH_RELEASE%\games\supercar.mym           

echo Generating T Letter
%YM2MYM% "%PATH_ATARI%\Tetris title.ym"                  %PATH_RELEASE%\games\tetris.mym   





