; Hello World on GBC
; Evan Gambill - 20 Sep. 2018
; Following GALP example1

INCLUDE "gbhw.inc" ; Hardware defines
INCLUDE "ibmpc1.inc" ; Font macro

SECTION "Org $100", ROM0[$100]	; $100 is code execution starting addr.

nop
jp	begin

;ROM_HEADER	ROM_NOMBC, ROM_SIZE_32KBYTE, RAM_SIZE_0KBYTE

INCLUDE "memory.asm"

TileData:
	chr_IBMPC1	1,8

begin:
	di	; disable interrupts
	ld	sp,$ffff	; sp = stack pointer
	
	call StopLCD	; calls fn to turn off screen

	ld	a,$e4	; $e4 is val written to bg palatte at $ff47 
	ld	[rBGP],a	; Setup default backround palatte
	; rBGP defined in included gbhw.inc

	ld	a,0	; Setting scroll registers to 0,0
	ld	[rSCX],a	; upper left corner visible
	ld	[rSCY],a

	; drawing text, uses mem_CopyMono from 'memory.asm'
	ld	hl,TileData	; 16bit HL register as source for tiledata
	ld	de,$8000
	ld	bc,8*256	; length = 8bytes per tile * 256 tiles
	call	mem_CopyMono	; copy tile data to memory

	; set canvas to all white
	; ascii char $20 (whitespace)
	ld	a,$20
	ld	hl,$9800
	ld	bc,SCRN_VX_B * SCRN_VY_B
	call mem_Set

	; now to paint hello world
	ld	hl,Title	; draw title
	ld	de,$9800+3+(SCRN_VY_B*7)
	ld	bc,13
	call mem_Copy

	; turn on LCD screen
	ld a,LCDCF_ON|LCDCF_BG8000|LCDCF_BG9800|LCDCF_BGON|LCDCF_OBJ16|LCDCF_OBJOFF	
	; not a fan of line lenght here, idk how change
	ld [rLCDC],a	; turn screen on

.wait:
	jp	.wait

Title:
	DB	"Hello World!"

; *** Turn off LCD ***
StopLCD:
	ld	a,[rLCDC]
	rlca	; Put high bit of LCDC into carry flag
	ret	nc	; screen off already, exit

;loop until in VBlank

.wait:
	ld a,[rLY]
	cp 145	; Display on scanline 145 yet?
	jr	nz,.wait	; if no, keep waiting

; Turn off LCD
	ld	a,[rLCDC]
	res	7,a	; reset bit 7 of LCDC
	ld	[rLCDC],a

	ret
; * EOF *
