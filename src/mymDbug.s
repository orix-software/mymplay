

#define _DecodedByte $00
#define _DecodeBitCounter $01
#define _DecodedResult $02
#define _CurrentAYRegister $03

#define _RegisterBufferHigh $0c

#define _RegisterBufferLow $04

#define _BufferFrameOffset	$0d		; From 0 to 127, used when filling the decoded register buffer

#define _MusicResetCounter	$0e ; 2 bytes		; Contains the number of rows to play before reseting

#define _CurrentFrame		$10		; From 0 to 255 and then cycles... the index of the frame to play this vbl

#define _PlayerVbl			$11
#define _MusicLooped		$12

#define _FrameLoadBalancer	$13		; We depack a new frame every 9 VBLs, this way the 14 registers are evenly depacked over 128 frames


	.zero

/*

_DecodedByte		.dsb 1		; Byte being currently decoded from the MYM stream
_DecodeBitCounter	.dsb 1		; Number of bits we can read in the current byte
_DecodedResult		.dsb 1		; What is returned by the 'read bits' function

_CurrentAYRegister	.dsb 1		; Contains the number of the register being decoded	

_RegisterBufferHigh	.dsb 1		; Points to the high byte of the decoded register buffer, increment to move to the next register	
_BufferFrameOffset	.dsb 1		; From 0 to 127, used when filling the decoded register buffer

_MusicResetCounter	.dsb 2		; Contains the number of rows to play before reseting

_CurrentFrame		.dsb 1		; From 0 to 255 and then cycles... the index of the frame to play this vbl

_PlayerVbl			.dsb 1
_MusicLooped		.dsb 1

_FrameLoadBalancer	.dsb 1		; We depack a new frame every 9 VBLs, this way the 14 registers are evenly depacked over 128 frames
*/

	.text

#define VIA_1				$30f
#define VIA_2				$30c

                         ; Actual start address of the player
#define	VIA_PORTB		$0300
#define	VIA_PORTAH	$0301
#define	VIA_DDRB		$0302
#define	VIA_DDRA		$0303
#define	VIA_T1CL		$0304
#define	VIA_T1CH            $0305
#define	VIA_T1LL            $0306
#define	VIA_T1LH            $0307
#define	VIA_T2LL            $0308
#define	VIA_T2CH            $0309
#define	VIA_PCR             $030C
#define	VIA_IFR		$030D
#define	VIA_IER		$030E
#define	VIA_PORTA           $030F	

#define VIA_1				$30f
#define VIA_2				$30c

						 
#define _PlayerBufferEnd	$7600

;#include "../orix/src/include/orix.h"





	
_play_mym	
/*
  #define PTR_READ_DEST $2c
	lda #>_MusicData
	sta PTR_READ_DEST+1
	lda #<_MusicData
	sta PTR_READ_DEST
	lda #<16000
	ldy #>16000
	BRK_TELEMON(XFREAD) ; FREAD
  .dsb 256-(*&255)
  */
	;PRINT(str_warning)
	sei
	lda #<10000
	sta VIA_T1CL
	sta VIA_T1LL
	lda #>10000
	sta VIA_T1CH
	sta VIA_T1LH

; Switch off via2
; Switch off via2
	lda #0+32
	sta $30e
	lda #0+32+64
	sta $32e
	cli
  jmp StartMusic

	


MymPlayerStart
	jmp StartMusic			; Call #6500 to start the music
	jmp EndMusic 			; Call #6503 to stop the music

StartMusic
	php
	pha
	sei

    clc
	lda $fffe
	adc #1
	sta __auto_1+1
	sta __auto_3+1
	sta __auto_5+1
	lda $ffff
	adc #0
	sta __auto_1+2
	sta __auto_3+2
	sta __auto_5+2

    clc
	lda $fffe
	adc #2
	sta __auto_2+1
	sta __auto_4+1
	sta __auto_6+1
	lda $ffff
	adc #0
	sta __auto_2+2
	sta __auto_4+2
	sta __auto_6+2

    
	; Save the old handler value
__auto_1
	lda $245
	sta jmp_old_handler+1
__auto_2
	lda $246
	sta jmp_old_handler+2

	; Install our own handler
	lda #<irq_handler
__auto_3
	sta $245
	lda #>irq_handler
__auto_4
	sta $246

	jsr _Mym_Initialize

	pla
	plp
	
loop
  jmp loop
#define BRK_TELEMON(value)\
	.byt 00,value;


#ifdef TARGET_ORIX

wait_key
	lda #<10000
	sta VIA_T1CL
	sta VIA_T1LL
	lda #>10000
	sta VIA_T1CH
	sta VIA_T1LH
	BRK_TELEMON($08) ; Read keyboard
	cmp #27 ; EST ?
	;bne wait_space  
  beq endme
	jmp wait_key
  ;jmp endme
#endif
	
  
endme	
  sei
  lda jmp_old_handler+1
  sta $2fb
  lda jmp_old_handler+2
  sta $2fc
  cli
	rts


EndMusic
	php
	pha
	sei

	; Restore the old handler value
	lda jmp_old_handler+1
__auto_5
	sta $245
	lda jmp_old_handler+2
__auto_6
	sta $246

	; Stop the sound
	lda #8
	ldx #0
	jsr WriteRegister

	lda #9
	ldx #0
	jsr WriteRegister

	lda #10
	ldx #0
	jsr WriteRegister

	pla
	plp

	rts	


_50hzFlipFlop	.byt 0

irq_handler
#ifdef TARGET_TELEMON

	lda VIA_T2LL
	lda VIA_T1CL
#endif

#ifdef TARGET_ORIX

 ; sta $13
 ; php 
;  PLA ; pull P (flag register)

	;AND #%00010000 ; test B flag B flag means an that we reach a brk commands
	;Beq BRK_SENT ; is it a break ?
  ;pha
#endif  

	pha
	txa
	pha
	tya
	pha

	; This handler runs at 100hz if comming from the BASIC, 
	; but the music should play at 50hz, so we need to call the playing code
	; only every second frame
	lda _50hzFlipFlop
	eor #1
	sta _50hzFlipFlop
	beq skipFrame

	jsr _Mym_PlayFrame

skipFrame

	pla
	tay
	pla
	tax
	pla
	;cli
	;rti


#ifdef TARGET_ORIX
BRK_SENT
  ;pha
  ;lda $13
	;rti
#else

#endif	
jmp_old_handler
	jmp 0000



; http://www.defence-force.org/ftp/oric/documentation/v1.1_rom_disassembly.pdf
;
; Oric Atmos ROM function W8912
; Originally called with JSR F590
; F590  08  PHP  WRITE X TO REGISTER A 0F 8912.
; F591  78  SEI
; F592  8D 0F 03  STA $030F  Send A to port A of 6522.
; F595  A8  TAY
; F596  8A  TXA
; F597  C0 07  CPY #$07  If writing to register 7, set
; F599  D0 02  BNE $F59D  1/0 port to output.
; F59B  09 40  ORA #$40
; F59D  48  PHA
; F59E  AD 0C 03  LDA $030C  Set CA2 (BC1 of 8912) to 1,
; F5A1  09 EE  ORA #$EE  set CB2 (BDIR of 8912) to 1.
; F5A3  8D 0C 03  STA $030C  8912 latches the address.
; F5A6  29 11  AND #$11  Set CA2 and CB2 to 0, BC1 and
; F5A8  09 CC  ORA #$CC  BDIR in inactive state.
; F5AA  8D 0C 03  STA $030C
; F5AD  AA  TAX
; F5AE  68  PLA
; F5AF  8D 0F 03  STA $030F  Send data to 8912 register.
; F5B2  8A  TXA
; F5B3  09 EC  ORA #$EC  Set CA2 to 0 and CB2 to 1,
; F5B5  8D 0C 03  STA $030C  8912 latches data.
; F5B8  29 11  AND #$11  Set CA2 and CB2 to 0, BC1 and
; F5BA  09 CC  ORA #$CC  BDIR in inactive state.
; F5BC  8D 0C 03  STA $030C
; F5BF  28  PLP
; F5C0  60  RTS

WriteRegister
.(
	PHP  			; WRITE X TO REGISTER A 0F 8912.
	SEI
	STA $030F  		; Send A to port A of 6522.
	TAY
	TXA
	CPY #$07  		; If writing to register 7, set
	BNE skip  		; 1/0 port to output.
	ORA #$40
skip	
	PHA
	LDA $030C  		; Set CA2 (BC1 of 8912) to 1,
	ORA #$EE  		; set CB2 (BDIR of 8912) to 1.
	STA $030C  		; 8912 latches the address.
	AND #$11  		; Set CA2 and CB2 to 0, BC1 and
	ORA #$CC  		; BDIR in inactive state.
	STA $030C
	TAX
	PLA
	STA $030F  		; Send data to 8912 register.
	TXA
	ORA #$EC  		; Set CA2 to 0 and CB2 to 1,
	STA $030C  		; 8912 latches data.
	AND #$11  		; Set CA2 and CB2 to 0, BC1 and
	ORA #$CC 		; BDIR in inactive state.
	STA $030C
	PLP
	RTS
.)



_PlayerCount		.byt 0


;
; Current PSG values during unpacking
;
_PlayerRegValues		
_RegisterChanAFrequency
	; Chanel A Frequency
	.byt 8
	.byt 4

_RegisterChanBFrequency
	; Chanel B Frequency
	.byt 8
	.byt 4 

_RegisterChanCFrequency
	; Chanel C Frequency
	.byt 8
	.byt 4

_RegisterChanNoiseFrequency
	; Chanel sound generator
	.byt 5

	; select
	.byt 8 

	; Volume A,B,C
_RegisterChanAVolume
	.byt 5
_RegisterChanBVolume
	.byt 5
_RegisterChanCVolume
	.byt 5

	; Wave period
	.byt 8 
	.byt 8

	; Wave form
	.byt 8

_PlayerRegCurrentValue	.byt 0


_Mym_ReInitialize
.(
	sei
	lda #0
	sta _MusicLooped
	jsr _Mym_Initialize
	cli 
	rts
.)

_Mym_Initialize
.(
	; The two first bytes of the MYM music is the number of rows in the music
	; We decrement that at each frame, and when we reach zero, time to start again.
	ldx _MusicData+0
	stx _MusicResetCounter+0
	ldx _MusicData+1
	inx
	stx _MusicResetCounter+1
		
	.(
	; Initialize the read bit counter
	lda #<(_MusicData+2)
	sta __auto_music_ptr+1
	lda #>(_MusicData+2)
	sta __auto_music_ptr+2

	lda #1
	sta _DecodeBitCounter

	; Clear all data
	lda #0
	sta _DecodedResult
	sta _DecodedByte
	sta _PlayerVbl
	sta _PlayerRegCurrentValue
	sta _BufferFrameOffset
	sta _PlayerCount
	sta _CurrentAYRegister
	sta _CurrentFrame

	ldx #14
loop_init
	dex
	sta _PlayerRegValues,x
	bne loop_init
	.)

	;
	; Unpack the 128 first register frames
	;
	.(
	lda #>_PlayerBuffer
	sta _RegisterBufferHigh
  
  lda #<_PlayerBuffer ; Jede
  sta _RegisterBufferLow  ; Jede
  
  
	ldx #0
unpack_block_loop
	stx _CurrentAYRegister
	
	; Unpack that register
	jsr _PlayerUnpackRegister2

	; Next register
	ldx _CurrentAYRegister
	inx
	cpx #14
	bne unpack_block_loop
	.)

	lda #128
	sta _PlayerVbl+0

	lda #0
	sta _PlayerCount
	sta _CurrentAYRegister
	sta _CurrentFrame

	lda #9
	sta _FrameLoadBalancer
	rts
.)



_Mym_PlayFrame
.(
	;
	; Check for end of music
	; CountZero: $81,$0d
	dec _MusicResetCounter+0
	bne music_contines
	dec _MusicResetCounter+1
	bne music_contines
music_resets
	lda #1
	sta _MusicLooped
	jsr _Mym_Initialize
	
music_contines	

	;
	; Play a frame of 14 registers
	;
	.(
	/*
  lda _CurrentFrame
	sta _auto_psg_play_read+1
	 
  
  lda #>_PlayerBuffer
	sta _auto_psg_play_read+2
  */

  lda #>_PlayerBuffer
	sta _auto_psg_play_read+2
  
  lda #<_PlayerBuffer
	sta _auto_psg_play_read+1
  
  lda _CurrentFrame
  clc
	adc _auto_psg_play_read+1
  bcc next3
  inc _auto_psg_play_read+2
next3  
 sta _auto_psg_play_read+1
	 
  

  
  

	ldy #0
register_loop

_auto_psg_play_read
	ldx	_PlayerBuffer

	; W8912
	; jsr $f590
	; a=register
	; x=value
	pha
	tya
	pha
	jsr WriteRegister
	pla
	tay
	pla

	/*
	sty	VIA_1
	txa

	pha
	lda	VIA_2
	ora	#$EE		; $EE	238	11101110
	sta	VIA_2

	and	#$11		; $11	17	00010001
	ora	#$CC		; $CC	204	11001100
	sta	VIA_2

	tax
	pla
	sta	VIA_1
	txa
	ora	#$EC		; $EC	236	11101100
	sta	VIA_2

	and	#$11		; $11	17	00010001
	ora	#$CC		; $CC	204	11001100
	sta	VIA_2
	*/

	inc _auto_psg_play_read+2 
	iny
	cpy #14
	bne register_loop
	.)


	inc _CurrentFrame
	inc _PlayerCount

	lda _CurrentAYRegister
	cmp #14
	bcs end_reg

	.(
	dec _FrameLoadBalancer
	bne end

	jsr _PlayerUnpackRegister
	inc _CurrentAYRegister
	lda #9
	sta _FrameLoadBalancer
end	
	rts
	.)

end_reg
	.(
	lda _PlayerCount
	cmp #128
	bcc skip

	lda #0
	sta _CurrentAYRegister
	sta _PlayerCount
	lda #9
	sta _FrameLoadBalancer
	
	clc
	lda _PlayerVbl+0
	adc #128
	sta _PlayerVbl+0
skip
	.)

	rts
.)

#ifdef TARGET_TELEMON
str_warning
.asc "Music never stop, keyboard is not handled in this version. You have to reset, to get keyboard",0
#endif

;
; Initialise X with the number of bits to read
; Y is not modifier
; A is saved and restored..
;
_ReadBits
	pha

	lda #0
	sta _DecodedResult

	; Will iterate X times (number of bits to read)
loop_read_bits

	dec _DecodeBitCounter
	bne end_reload

	; reset mask
	lda #8
	sta _DecodeBitCounter

	; fetch a new byte, and increment the adress.
__auto_music_ptr
	lda _MusicData+2
	sta _DecodedByte

	inc __auto_music_ptr+1
	bne end_reload
	inc __auto_music_ptr+2
end_reload

	asl _DecodedByte
	rol _DecodedResult

	dex
	bne loop_read_bits
	
	pla
	rts





_PlayerUnpackRegister
	lda #>_PlayerBuffer
	clc
	adc _CurrentAYRegister
	; FIXME JEDE
	bcc next2
	inc _RegisterBufferLow
next2	



	sta _RegisterBufferHigh
_PlayerUnpackRegister2
	;
	; Init register bit count and current value
	;	 
	ldx _CurrentAYRegister
	lda _PlayerRegValues,x
	sta _PlayerRegCurrentValue  
	

	;
	; Check if it's packed or not
	; and call adequate routine...
	;
	ldx #1
	jsr _ReadBits
	ldx _DecodedResult
	bne DecompressFragment

	
UnchangedFragment	
.(
	;
	; No change at all, just repeat '_PlayerRegCurrentValue' 128 times 
	;
	lda _RegisterBufferHigh				; highpart of buffer adress + register number
	sta __auto_copy_unchanged_write+2

;  lda _RegisterBufferLow				; Jede 
	;sta __auto_copy_unchanged_write+1 ; Jede
  
	ldx #128							; 128 iterations
	lda _PlayerRegCurrentValue			; Value to write

	ldy _PlayerVbl
	
repeat_loop
__auto_copy_unchanged_write
	sta _PlayerBuffer,y
	iny	
	dex
	bne repeat_loop
.)

	jmp player_main_return

	
player_main_return
	; Write back register current value
	ldx _CurrentAYRegister
	lda _PlayerRegCurrentValue  
	sta _PlayerRegValues,x

	; Move to the next register buffer
	inc _RegisterBufferHigh
	rts




DecompressFragment
	lda _PlayerVbl						; Either 0 or 128 at this point else we have a problem...
	sta _BufferFrameOffset

decompressFragmentLoop	
	
player_copy_packed_loop
	; Check packing method
	ldx #1
	jsr _ReadBits

	ldx _DecodedResult
	bne PlayerNotCopyLast

UnchangedRegister
.(	
	; We just copy the current value 128 times
	lda _RegisterBufferHigh				; highpart of buffer adress + register number
	sta player_copy_last+2

  ;lda _RegisterBufferLow
	;sta player_copy_last+1
  
	ldx _BufferFrameOffset				; Value between 00 and 7f
	lda _PlayerRegCurrentValue			; Value to copy
player_copy_last
	sta _PlayerBuffer,x

	inc _BufferFrameOffset
.)


player_return

	; Check end of loop
	lda _BufferFrameOffset
	and #127
	bne decompressFragmentLoop

	jmp player_main_return


PlayerNotCopyLast
	; Check packing method
	ldx #1
	jsr _ReadBits

	ldx _DecodedResult
	beq DecompressWithOffset

ReadNewRegisterValue
	; Read new register value (variable bit count)
	ldx _CurrentAYRegister
	lda _PlayerRegBits,x
	tax
	jsr _ReadBits
	ldx _DecodedResult
	stx _PlayerRegCurrentValue

	; Copy to stream
	lda _RegisterBufferHigh				; highpart of buffer adress + register number
	sta player_read_new+2

	ldx _BufferFrameOffset					; Value between 00 and 7f
	lda _PlayerRegCurrentValue			; New value to write
player_read_new
	sta _PlayerBuffer,x

	inc _BufferFrameOffset
	jmp player_return




DecompressWithOffset
.(
	; Read Offset (0 to 127)
	ldx #7
	jsr _ReadBits					

	lda _RegisterBufferHigh			; highpart of buffer adress + register number
	sta __auto_write+2				; Write adress
	sta __auto_read+2				; Read adress

	; Compute wrap around offset...
	lda _BufferFrameOffset					; between 0 and 255
	clc
	adc _DecodedResult					; + Offset Between 00 and 7f
	sec
	sbc #128							; -128
	tay

	; Read count (7 bits)
	ldx #7
	jsr _ReadBits
	
	inc	_DecodedResult					; 1 to 129


	ldx _BufferFrameOffset
	
player_copy_offset_loop

__auto_read
	lda _PlayerBuffer,y				; Y for reading
	iny

__auto_write
	sta _PlayerBuffer,x				; X for writing

	inc _BufferFrameOffset

	inx
	dec _DecodedResult
	bne player_copy_offset_loop 

	sta _PlayerRegCurrentValue

	jmp player_return
.)



;
; Size in bits of each PSG register
;
_PlayerRegBits
	; Chanel A Frequency
	.byt 8
	.byt 4

	; Chanel B Frequency
	.byt 8
	.byt 4 

	; Chanel C Frequency
	.byt 8
	.byt 4

	; Chanel sound generator
	.byt 5

	; select
	.byt 8 

	; Volume A,B,C
	.byt 5
	.byt 5
	.byt 5

	; Wave period
	.byt 8 
	.byt 8

	; Wave form
	.byt 8

	


.dsb 256-(*&255)

_PlayerBuffer
	 .dsb 256*14 ;(About 3.5 kilobytes)


_MusicData
.dsb 17000
end_adress





