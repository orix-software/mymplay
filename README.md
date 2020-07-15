[![Build Status](https://travis-ci.org/oric-software/mym.svg?branch=master)](https://travis-ci.org/oric-software/mym)

mym

# 01/10/2017

* correcting a bug : mym.csv for ipkg had a return line


Issue : it seems that when when we load with fread the music the code is overlap with the data. 

For example, if we do a "printf("%s",argv[1])"  for example argv1 is corrupted after the fread. I did not have a look with this issue