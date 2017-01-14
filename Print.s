; Print.s
; Student names: change this to your names or look very silly
; Last modification date: change this to the last modification date or look very silly
; Runs on LM4F120 or TM4C123
; EE319K lab 7 device driver for any LCD
;
; As part of Lab 7, students need to implement these LCD_OutDec and LCD_OutFix
; This driver assumes two low-level LCD functions
; ST7735_OutChar   outputs a single 8-bit ASCII character
; ST7735_OutString outputs a null-terminated string 

    IMPORT   ST7735_OutChar
    IMPORT   ST7735_OutString
    EXPORT   LCD_OutDec
    EXPORT   LCD_OutFix
;----------------Bind our local variables------------------
FP1		EQU	0				;Set variable for uint32 imput
FP2		EQU	0x04				;Set variable for desired outchar
FP3		EQU	0x08				;Set variable for counter
FP4		EQU	0x0C				;Set variable for next
FP5		EQU	0x10				;Set variable for next counter
FIn		EQU	0x14
N	EQU	0					;Initialize stack and variables
    AREA    |.text|, CODE, READONLY, ALIGN=2
    THUMB
	PRESERVE8
  

;-----------------------LCD_OutDec-----------------------;
; Output a 32-bit number in unsigned decimal format
; Input: R0 (call by value) 32-bit unsigned number
; Output: none
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutDec
		SUB	SP, SP, #4
		CMP	R0, #10					;Test for base case n < 10
		BCC	ENDR
		STR	R0, [SP, #N]			;Save to stack
		PUSH {LR}
		MOV	R3, #10
		UDIV R0, R0, R3				;Call to self with input N/10
		BL	LCD_OutDec
		POP	{LR}					;Grab link register
		LDR	R0, [SP, #N]			;Grab N
		MOV	R3, #10
		UDIV R1, R0, R3				;Input to outchar is N%10
		MUL	R1, R1, R3
		SUB R0, R0, R1
		ADD	R0, R0, #0x30			;Convert to ASCII
		PUSH	{LR}
		BL	ST7735_OutChar
		POP {LR}
		ADD	SP, SP, #4				;Deallocate the stack
		BX 	LR						;Return to caller
;---------------------Base Case Exit----------------------
ENDR	ADD	R0, R0, #0x30			;Convert to ASCII
		PUSH {LR}
		BL	ST7735_OutChar			;Print
		POP {LR}
		ADD	SP, SP, #4				;Deallocate the stack
		BX  LR
;* * * * * * * * End of LCD_OutDec * * * * * * * *

; -----------------------LCD _OutFix----------------------
; Output characters to LCD display in fixed-point format
; unsigned decimal, resolution 0.001, range 0.000 to 9.999
; Inputs:  R0 is an unsigned 32-bit number
; Outputs: none
; outchar char R0, ends with \0
; add 0x30 to whatever number you get to convert to ascii
; udiv q, divider, divisor //remainder =divider - q*divisor
; E.g., R0=0,    then output "0.000 "
;       R0=3,    then output "0.003 "
;       R0=89,   then output "0.089 "
;       R0=123,  then output "0.123 "
;       R0=9999, then output "9.999 "
;       R0>9999, then output "*.*** "
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutFix
		PUSH {LR}
;---------------------Check for high-----------------------
		MOV	R1, #10000				;Move check value into a register
		CMP	R0, R1					;Check to see if uint32 input is > limit
		BCS	Aster					;If it is greater, print astericks

;-------------Setup the stack and variables----------------
		SUB SP, SP, #24				;Allocate space
		MOV R1, #0x2E				;Place the dot into the stack
		STR	R1, [SP, #FP2]			
		STR	R0, [SP, #FIn]			;Place input into variable holder
		MOV	R12, #10
;-------------Grab the last to be outputted---------------
		MOV	R1, R0					;Move into R1 for manipulation
		UDIV R1, R1, R12			;Modulo
		STR	R1, [SP, #FIn]			;Save next value
		MUL	R1, R1, R12				;Modulo
		SUB	R0, R0, R1				;Modulo
		ADD	R0, R0, #0x30
		STR	R0, [SP, #FP5]			;Save first output number
;-------------Grab the fourth to be outputted---------------
		LDR	R0, [SP, #FIn]
		MOV	R1, R0					;Move into R1 for manipulation
		UDIV R1, R1, R12			;Modulo
		STR	R1, [SP, #FIn]			;Save next value
		MUL	R1, R1, R12				;Modulo
		SUB	R0, R0, R1				;Modulo
		ADD	R0, R0, #0x30
		STR	R0, [SP, #FP4]			;Save first output number
;-------------Grab the third to be outputted---------------
		LDR	R0, [SP, #FIn]
		MOV	R1, R0					;Move into R1 for manipulation
		UDIV R1, R1, R12			;Modulo
		STR	R1, [SP, #FIn]			;Save next value
		MUL	R1, R1, R12				;Modulo
		SUB	R0, R0, R1				;Modulo
		ADD	R0, R0, #0x30
		STR	R0, [SP, #FP3]			;Save first output number
;-------------Grab the first to be outputted---------------
		LDR	R0, [SP, #FIn]
		MOV	R1, R0					;Move into R1 for manipulation
		UDIV R1, R1, R12			;Modulo
		STR	R1, [SP, #FIn]			;Save next value
		MUL	R1, R1, R12				;Modulo
		SUB	R0, R0, R1				;Modulo
		ADD	R0, R0, #0x30
		STR	R0, [SP, #FP1]			;Save first output number
;---------------Print stuff--------------------------------
		LDR R0, [SP, #FP1]
		BL	ST7735_OutChar			;Print
		LDR R0, [SP, #FP2]
		BL	ST7735_OutChar			;Print
		LDR R0, [SP, #FP3]
		BL	ST7735_OutChar			;Print
		LDR R0, [SP, #FP4]
		BL	ST7735_OutChar			;Print
		LDR R0, [SP, #FP5]
		BL	ST7735_OutChar			;Print
		B	FFin
		
		
		
;------------------Astericks, ending seq--------------------
Aster	MOV	R0, #0x2A               ;Print *          
        BL	ST7735_OutChar				
        MOV R0, #0x2E				;Print dot                            
        BL	ST7735_OutChar
        MOV	R0, #0x2A               ;Print 3 astericks            
        BL	ST7735_OutChar       
		MOV	R0, #0x2A 
        BL	ST7735_OutChar
		MOV	R0, #0x2A 
        BL	ST7735_OutChar
		MOV	R0, #0x20				;Print ending space
        BL	ST7735_OutChar
		MOV	R0, #0					;Print null ending 
		BL	ST7735_OutChar	
		B	AltFin
FFin    MOV	R0, #0x20				;Print ending space
        BL	ST7735_OutChar
		MOV	R0, #0					;Print null ending 
		BL	ST7735_OutChar				
;------------------------CLeanup----------------------------
		ADD	SP, SP, #24				;Deallocate the stack
AltFin	POP {LR}
		BX   LR
 
	ALIGN
;* * * * * * * * End of LCD_OutFix * * * * * * * *

     ALIGN                           ; make sure the end of this section is aligned
     END                             ; end of file
