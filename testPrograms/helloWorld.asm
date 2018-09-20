; Hello World on GBC
; Evan Gambill - 20 Sep. 2018
; Following GALP example1

INCLUDE "gbhw.inc" ; Hardware defines
INCLUDE "ibmpc1.inc" ; Font macro

SECTION "Org $100", HOME[$100] ; $100 is code execution starting addr.

nop
jp	begin
