AS=xa
CC=cl65
CFLAGS=-ttelestrat
LDFILES=
PROGRAM=mymplay
LDFILES=src/eeprom.s src/_display_signature_bank.s src/loadfile.s


MAN_PATH = $(BUILD_PATH)/usr/share/man
MD2HLP_PATH = ../../md2hlp/src/
MD2HLP = $(MD2HLP_PATH)/md2hlp.py


all : srccode code
.PHONY : all


SOURCE=src/$(PROGRAM).c

code: $(SOURCE)
	mkdir -p build/bin/
	bin/xa -v -R -cc src/mymDbug.s -o src/mymplayer.o -DTARGET_FILEFORMAT_O65 -DTARGET_ORIX
	co65  src/mymplayer.o -o src/mymcc65.s
	$(CC) -ttelestrat src/mym.c src/mymcc65.s -o build/bin/mymplay
	mkdir build/usr/share/mymplay -p
	cp data/* build/usr/share/mymplay -r
	@echo "Create .hlp"
	cat docs/mymplay.md | ../md2hlp/src/md2hlp.py3  > build/usr/share/man/mymplay.hlp



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



