// Ashton Tolman
// RCET3373
// Lab5PICpt1
// https://github.com/Ashton-Tolman/Semester-5-Lab-5.git
// linker code:-Wl,-presetVect=0000h,-pisrVect=0004h,-pcode=0008h

; PIC16F883 Configuration Bit Settings

; Assembly source line config statements

; CONFIG1
  CONFIG  FOSC = XT             ; Oscillator Selection bits (XT oscillator: Crystal/resonator on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = ON            ; RE3/MCLR pin function select bit (RE3/MCLR pin function is MCLR)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = OFF             ; Low Voltage Programming Enable bit (RB3 pin has digital I/O, HV on MCLR must be used for programming)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

// config statements should precede project file includes.
#include <xc.inc>

W_TEMP EQU 0x70		; Temporary W register in global GR
STATUS_TEMP EQU 0x71	; Temporary Status register in global GR
 
; Reset Vector at 000h. Execution starts here after reset 
PSECT resetVect,class=CODE,delta=2
ResetVector:
    goto Setup
    
    
; Interrupt Vector at 0004h. Execution starts here after an interrupt.
PSECT isrVect,class=CODE,delta=2
InterruptVector:
    goto ISRHandler
    
; Main code section starts at 0008h. User code goes here
PSECT code,class=CODE,delta=2

Setup:
    ; add device setup here
    BSF  0x03, 06    ;
    BSF  0x03, 05    ; Set bank 3 active
    CLRF 0x189	    ; ANSELH analog/digital select portB pins as digital
    CLRF 0x188	    ; ANSEL analog/digital select portA pins as digital
    
    BSF  0x03, 06    ;
    BCF  0x03, 5    ; Set bank 2 active
    BSF  0x09, 1    ; Turn T1G-not function off
    
    BCF  0x03, 06    ;
    BSF  0x03, 05    ; Set bank 1 active 
    CLRF 0x85	    ; TrisA sets all portA pins as outputs
    MOVLW 0x01	    ; Make W all highs
    MOVWF 0x86	    ; Move W to TrisB
    CLRF 0x87	    ; TrisC sets all portC pins as outputs
    BCF 0x81, 6	    ; Make interrupts trigger on falling edges
    BCF 0x81, 7	    ; Give PortB weak pull ups

		    
    BCF  0x03, 06    ;
    BCF  0x03, 05    ; Set bank 0 active
    CLRF 0x06	    ; clear port B
    CLRF 0x05	    ; clear port A
    CLRF 0x07	    ; Clear portC
		 
		    
    ;Interrupt setup
    CLRF 0x0B	    ; Clear INTCON to disable all interrupts by default
    BSF 0x0B,4	    ; Enable External interrupts
    BSF 0x0B,7	    ; Enable Global interrups
    goto Main
    

Main:
    MOVLW 0x01		; Put bit 0 high in W
    XORWF 0x05		; Toggle bit 0 in PortA
    goto Main
    
ISRHandler:
    MOVWF W_TEMP	;Copy W to TEMP register
    SWAPF STATUS,0	;Swap status to be saved into W
			;Swaps are used because they dont change the status bits
    MOVWF STATUS_TEMP	;Save status to bank zero STATUS_TEMP register
    goto InterruptChecks
    
InterruptChecks:
    INCF 0x07,1		; Incremetns PortC
    BCF 0x0B,1		; Clear the INT flag bit
    goto LeaveHandler
    
LeaveHandler:
    SWAPF STATUS_TEMP,0	;Swap STATUS_TEMP register into W
			;(sets bank to original state)
    MOVWF STATUS	;Move W into STATUS register
    SWAPF W_TEMP,1	;Swap W_TEMP
    SWAPF W_TEMP,0	;Swap W_TEMP into W
    RETFIE		;Return from interupt at point of interruption+1
End