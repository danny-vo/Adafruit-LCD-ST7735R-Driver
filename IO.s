; IO.s
; Student names: change this to your names or look very silly
; Last modification date: change this to the last modification date or look very silly
; Runs on LM4F120/TM4C123

; EE319K lab 7 device driver for the switch and LED.
; You are allowed to use any switch and any LED,
; although the Lab suggests the SW1 switch PF4 and Red LED PF1

; As part of Lab 7, students need to implement these three functions

; negative logic SW2 connected to PF0 on the Launchpad
; red LED connected to PF1 on the Launchpad
; blue LED connected to PF2 on the Launchpad
; green LED connected to PF3 on the Launchpad
; negative logic SW1 connected to PF4 on the Launchpad

        EXPORT   IO_Init
        EXPORT   IO_Touch
        EXPORT   IO_HeartBeat

GPIO_PORTF_DATA_R  EQU 0x400253FC
GPIO_PORTF_DIR_R   EQU 0x40025400
GPIO_PORTF_AFSEL_R EQU 0x40025420
GPIO_PORTF_PUR_R   EQU 0x40025510
GPIO_PORTF_DEN_R   EQU 0x4002551C
GPIO_PORTF_LOCK_R  EQU 0x40025520
GPIO_PORTF_CR_R    EQU 0x40025524
GPIO_PORTF_AMSEL_R EQU 0x40025528
GPIO_PORTF_PCTL_R  EQU 0x4002552C
GPIO_LOCK_KEY      EQU 0x4C4F434B  ; Unlocks the GPIO_CR register
PF0       EQU 0x40025004
PF1       EQU 0x40025008
PF2       EQU 0x40025010
PF3       EQU 0x40025020
PF4       EQU 0x40025040
LEDS      EQU 0x40025038
RED       EQU 0x02
BLUE      EQU 0x04
GREEN     EQU 0x08
SWITCHES  EQU 0x40025044
SW1       EQU 0x10                 ; on the left side of the Launchpad board
SW2       EQU 0x01                 ; on the right side of the Launchpad board
SYSCTL_RCGCGPIO_R  EQU 0x400FE608
COUNT	  EQU 20000
    
        AREA    |.text|, CODE, READONLY, ALIGN=2
        THUMB



;------------IO_Init------------
; Initialize GPIO Port for a switch and an LED
; Input: none
; Output: none
; This is a public function
; Invariables: This function must not permanently modify registers R4 to R11
IO_Init
    LDR	R0, =SYSCTL_RCGCGPIO_R			;Load the memory address of SYSCTL_RCGCGPIO_R
	LDR	R1, [R0]						;Read the contents of SYSCTL_RCGCGPIO_R
	ORR	R1, R1, #0x20					;Turn on the system clock for Port F
	STR	R1, [R0]						;Implement clock activation
	NOP									;Allow system clocks to settle
	NOP
    LDR R0, =GPIO_PORTF_DIR_R			;Load the memory address of GPIO_PORTF_DIR_R
	LDR	R1, [R0]						;Read the contents of GPIO_PORTF_DIR_R
	ORR	R1, R1, #0x04					;Set PF2 as the output bit
	BIC	R1, #0x10						;Set PF4 as input bit
	STR	R1, [R0]						;Implement direction assignment
	LDR	R0, =GPIO_PORTF_AFSEL_R			;Load the memory address of GPIO_PORTF_AFSEL_R
	LDR	R1, [R0]						;Read the contents of SYSCTL_RCGCGPIO_R
	BIC	R1, #0x14						;Disable alternate functions on PF2 and PF4
	STR	R1, [R0]						;Inmplement alternate disabling function
	LDR	R0, =GPIO_PORTF_DEN_R			;Load the memory address of GPIO_PORTF_DEN_R
	LDR	R1, [R0]						;Read the contents of GPIO_PORTF_DEN_R
	ORR	R1, #0x14						;Enable digital inputs on PF2 and PF4
	STR	R1, [R0]						;Activate enabling function
	LDR	R0, =GPIO_PORTF_PUR_R			;Load the memory address of GPIO_PORTF_PUR_R
	LDR	R1, [R0]						;Read the contents of GPIO_PORTF_PUR_R
	ORR	R1, #0x10						;Enable the pullup register
	STR	R1, [R0]						;Implement pullup activation function
    BX  LR
;* * * * * * * * End of IO_Init * * * * * * * *

;------------IO_HeartBeat------------
; Toggle the output state of the LED.
; Input: none
; Output: none
; This is a public function
; Invariables: This function must not permanently modify registers R4 to R11
IO_HeartBeat
    LDR	R0, =GPIO_PORTF_DATA_R			;Load the memory address of GPIO_PORTF_DATA_R
	LDR	R1, [R0]						;Read the contents of GPIO_PORTF_DATA_R
	EOR	R1, R1, #0x04					;Toggle the heartbeat
	STR	R1, [R0]						;Inplement the heartbeat toggle
    BX  LR                          ; return
;* * * * * * * * End of IO_HeartBeat * * * * * * * *

;------------IO_Touch------------
; First: wait for the of the release of the switch
; and then: wait for the touch of the switch ////////use counting down delay
; Input: none
; Input: none
; Output: none
; This is a public function
; Invariables: This function must not permanently modify registers R4 to R11
IO_Touch
			LDR R0, =GPIO_PORTF_DATA_R			;Load the memory address of GPIO_PORTF_DATA_R
Release		LDR	R1, [R0]						;Read GPIO_PORTF_DATA_R
			AND	R1, R1, #0x10					;Mask to check for the switch
			CMP	R1, #16
			BNE	Release							;If switch is not released check again
			PUSH	{LR}
			BL	Delay							;Delay to avoid bouncing
			POP {LR}
Touch		LDR	R1, [R0]						;Read GPIO_PORTF_DATA_R
			AND	R1, R1, #0x10					;Mask to check for the switch
			CMP	R1, #0
			BNE	Touch							;If LED is not pressed recheckbouncing
			PUSH {LR}
			BL	Delay							;Delay to account for 
			POP {LR}
			BX  LR  	                        ; return
;-------------Delay---------------
Delay	LDR		R2, =COUNT
		LDR		R3, [R2]
		MOV		R2, R3
		MOV		R2, #4000						;Load the value of the counter
Rep		SUBS	R2, R2, #0x01					;Decrement the delay counter
		BNE		Rep								;If counter is not entirely decremented, rerun delay subroutine
		BX		LR								;Return to loop
;* * * * * * * * End of IO_Touch * * * * * * * *


    ALIGN                           ; make sure the end of this section is aligned
    END                             ; end of file