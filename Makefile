AS=xa
CC=cl65
CFLAGS=-ttelestrat
LDFILES=
PROGRAM=mym
LDFILES=src/eeprom.s src/_display_signature_bank.s src/loadfile.s


ifdef TRAVIS_BRANCH
ifeq ($(TRAVIS_BRANCH), master)
RELEASE:=$(shell cat VERSION)
else
RELEASE=alpha
endif
endif


all : srccode code
.PHONY : all

HOMEDIR=/home/travis/bin/

SOURCE=src/$(PROGRAM).c




MYDATE = $(shell date +"%Y-%m-%d %H:%m")

code: $(SOURCE)
	mkdir -p build/bin/
	xa -v -R -cc src/mymDbug.s -o src/mymplayer.o -DTARGET_FILEFORMAT_O65 -DTARGET_ORIX
	co65  src/mymplayer.o -o src/mymcc65.s
	$(CC) -ttelestrat src/mym.c src/mymcc65.s -o build/bin/mymplay

srccode: $(SOURCE)
	mkdir -p build/usr/src/$(PROGRAM)/
	mkdir -p build/usr/src/$(PROGRAM)/src/
	cp configure build/usr/src/$(PROGRAM)/
	cp Makefile build/usr/src/$(PROGRAM)/
	cp README.md build/usr/src/$(PROGRAM)/
	cp -adpR src/* build/usr/src/$(PROGRAM)/src/

test:
	mkdir -p build/usr/share/$(PROGRAM)/
	mkdir -p build/usr/share/ipkg/
	mkdir -p build/usr/share/man/
	mkdir -p build/usr/share/doc/$(PROGRAM)/

	mkdir -p build/usr/src/$(PROGRAM)/src/

	mkdir -p build/bin/
	#cp $(PROGRAM) build/bin/
	cp Makefile build/usr/src/$(PROGRAM)/
	cp configure build/usr/src/$(PROGRAM)/
	cp data/* build/usr/share/$(PROGRAM)/	 -adpR
	cp README.md build/usr/src/$(PROGRAM)/
	cp src/* build/usr/src/$(PROGRAM)/src/ -adpR
	cd build && tar -c * > ../$(PROGRAM).tar &&	cd ..



