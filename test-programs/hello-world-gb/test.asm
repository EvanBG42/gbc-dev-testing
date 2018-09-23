; Evan Gambill
; Hello World
; From https://eldred.fr/gb-asm-tutorial/hello-world.html
; 21 Sep 2018 

INCLUDE "hardware.inc"

SECTION "Header",ROM0[$100]

EntryPoint:
	di ; disable interrupts
	jp Start

REPT $150 - $104 ; blank space for header (rgbfix handles this)
    db 0
ENDR 

	; Code goes here
SECTION "Game code", ROM0

Start:
	nop
	ld sp, $E000 ; stack pointer init, not needed here but good prac.
	
	; turn off LCD
.waitVBlank
	ld a, [rLY]
	cp 144 ; check if LCD is past vblank
	jr c, .waitVBlank ; if not, repeat this

	; reset a val at bit 7 (overkill)
	xor a ; ld a, 0 [eq command] 
	ld [rLCDC], a  
	
	ld hl, $9000 
	ld de, FontTiles
	ld bc, FontTilesEnd - FontTiles

.copyFontByte
	ld a, [de] ; Grab byte 1 from source
	ld [hli], a ; place at destination, increment hl
	inc de ; Move to next byte
	dec bc ; decrement count
	ld a, b ; Check if count == 0
	or c
	jr nz, .copyFontByte

	ld hl, _SCRN0 ; Print string @ top left
	ld de, HelloWorldStr
.copyString
	ld a, [de]
	inc de
	; *Don't* print non-printing characters.
	and a
	jr z, .stringPrinted
	cp $0A
	jr z, .newline
	ld [hli], a
	jr .copyString

.newline
	ld a, l
	and -SCRN_VX_B ; -$20 = $E0
	add SCRN_VX_B ; $20
	ld l, a
	jr nc, .copyString
	inc h
	jr .copyString

.stringPrinted
	
.displayLines ; diplays lines
	; Init display regs
	ld a, %11100100
	ld [rBGP], a

	xor a ; ld a, 0
	ld [rSCY], a
	ld [rSCX], a

	; shut down sound
	ld [rNR52], a

	; Turn on screen
	;ld a, %10000001
	ld      a, LCDCF_ON|LCDCF_BG8800|LCDCF_WIN9C00|LCDCF_BGON|LCDCF_WINOFF|LCDCF_OBJOFF|LCDCF_OBJ8
	ld [rLCDC], a

	; Lock up
.lockup
	halt
	jr .lockup
	
SECTION "Font", ROM0

FontTiles:
INCBIN "font.chr" ; copies data directly into rom (thanks rgbasm!)
FontTilesEnd:

SECTION "Hello World string", ROM0

HelloWorldStr:
	db "This is an example", $0A
	db "of a linewrap.", $0A, $0A
	db "0123456789ABCDEF012345", $0A, $0A
	db "Blinkhorn can suck", $0A
	db "my nuts.", 0 

