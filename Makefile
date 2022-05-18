AS=xa
CC=cl65
CFLAGS=-ttelestrat
LDFILES=
PROGRAM=mymplay
LDFILES=src/eeprom.s src/_display_signature_bank.s src/loadfile.s
MAN_PATH = $(BUILD_PATH)/usr/share/man
MD2HLP_PATH = ../../md2hlp/src/
MD2HLP = $(MD2HLP_PATH)/md2hlp.py


ifeq ($(CC65_HOME),)
        CC = cl65
        AS = ca65
        LD = ld65
        AR = ar65
else
        CC = $(CC65_HOME)/bin/cl65
        AS = $(CC65_HOME)/bin/ca65
        LD = $(CC65_HOME)/bin/ld65
        AR = $(CC65_HOME)/bin/ar65
endif

all : code
.PHONY : all

SOURCE=src/$(PROGRAM).c

code: $(SOURCE)
	mkdir -p build/bin/
	chmod +x bin/xa
	bin/xa -v -R -cc src/mymDbug.s -o src/mymplayer.o -DTARGET_FILEFORMAT_O65 -DTARGET_ORIX
	co65  src/mymplayer.o -o src/mymcc65.s
	$(CC) -ttelestrat src/mymplay.c src/mymcc65.s -o build/bin/mymplay
	mkdir build/usr/share/mymplay -p
	cp data/* build/usr/share/mymplay -r
	@echo "Create .hlp"
	cat docs/mymplay.md | ../md2hlp/src/md2hlp.py3  > build/usr/share/man/mymplay.hlp




