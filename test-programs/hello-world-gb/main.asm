; Evan Gambill
; Hello World
; From https://eldred.fr/gb-asm-tutorial/hello-world.html
; 21 Sep 2018 

INCLUDE "hardware.inc"

SECTION "Header",ROM0[$100]

	; Code goes here
EntryPoint:
	di ; disable interrupts
	jp Start

REPT $150 - $104 ; blank space for header (rgbfix handles this)
	db 0
ENDR 

SECTION "Game code", ROM0

Start:
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

.copyFont
	ld a, [de] ; Grab byte 1 from source
	ld [hli], a ; place at destination, increment hl
	inc de ; Move to next byte
	dec bc ; decrement count
	ld a, b ; Check if count == 0
	or c
	jr nz, .copyFont

	ld hl, $9800 ; Print string @ top left
	ld de, HelloWorldStr

.copyString ; copies until finds byte == 0
	ld a, [de]
	ld [hli], a
	inc de
	and a ; check if byte just copied == 0
	jr nz, .copyString ; if not, loop this

	; Init display regs
	ld a, %11100100
	ld [rBGP], a

	xor a ; ld a, 0
	ld [rSCY], a
	ld [rSCX], a

	; shut down sound
	ld [rNR52], a

	; Turn on screen
	ld a, %10000001
	ld [rLCDC], a

	; Lock up
.lockup
	jr .lockup

SECTION "Font", ROM0

FontTiles:
INCBIN "font.chr" ; copies data directly into rom (thanks rgbasm!)
FontTilesEnd:

SECTION "Hello World string", ROM0

HelloWorldStr:
	db "It's ya boi, uh, skinny penis.", 0

