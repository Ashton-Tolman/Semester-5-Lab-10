// Ashton Tolman
// RCET3373
// Lab10PICpt2
// https://github.com/Ashton-Tolman/Semester-5-Lab-10.git
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

 
; Reset Vector at 000h. Execution starts here after reset 
PSECT resetVect,class=CODE,delta=2
ResetVector:
    goto Setup
    
    
; Interrupt Vector at 0004h. Execution starts here after an interrupt.
PSECT isrVect,class=CODE,delta=2
InterruptVector:
    RETFIE
    
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
    BCF TRISA,0        ; RA0 = NACK indicator
    BCF TRISA,1        ; RA1 = Timer diagnostic
    BSF TRISC,3        ; RC3 = SCL
    BSF TRISC,4        ; RC4 = SDA
    CLRF SSPCON2
    BSF SSPSTAT,7      ; Standard Speed (100 kHz)
    
    ;I2C clock set to 100kHz
    MOVLW 0x09         ; 4 MHz / (4 x (9 + 1))
    MOVWF SSPADD
    MOVLW 0x07       
    MOVWF OPTION_REG
    BCF OPTION_REG,3
		    
    BCF  0x03, 06    ;
    BCF  0x03, 05    ; Set bank 0 active
    CLRF SSPCON
    CLRF 0x05	    ; clear port A
    CLRF 0x07	    ; Clear portC
    MOVLW 0x28         ; Enable MSSP, I2C Master Mode
    MOVWF SSPCON	 
    CLRF TMR0
    BCF INTCON,2       ; Clear TMR0 overflow flag
		    
    goto Main
    

Main:
    ; Start a new timer interval
    BANKSEL TMR0
    MOVLW 0xB2
    MOVWF TMR0
    BCF INTCON,2

TimerWait:
    ; Wait for a Timer0 overflow
    BTFSS INTCON,2
    goto $-1
    BCF INTCON,2	; Clear overflow flag

    ; Timer event starts new I2C transaction
    BANKSEL PORTA
    BSF PORTA,1		; RA1 HIGH
    CALL AddressProbe
    BANKSEL PORTA
    BCF PORTA,1		; RA1 LOW after STOP
    goto Main

AddressProbe:
    ; Clear NACK indicator before each probe
    BANKSEL PORTA
    BCF PORTA,0		; RA0 LOW

    ; Generate START condition
    BANKSEL PIR1
    BCF PIR1,3		; Clear SSPIF
    BANKSEL SSPCON2
    BSF SSPCON2,0	; SEN = 1, start I2C

    BTFSC SSPCON2,0	; Wait until START finishes
    goto $-1

    ; Send 7-bit address 0x20 with R/W = 0
    BANKSEL PIR1
    BCF PIR1,3		; Clear SSPIF
    MOVLW 0x40		; Address = 0x20, Write = 0
    BANKSEL SSPBUF	; The address is moved left once making 0x20 -> 0x40
    MOVWF SSPBUF	; Send address byte

    BANKSEL PIR1
    BTFSS PIR1,3	; Wait for transmission
    goto $-1

    ; Check ACK or NACK
    BANKSEL SSPCON2
    BTFSS SSPCON2,6	; ACKSTAT = 1 means NACK
    goto SendStop	; ACK received
    BANKSEL PORTA
    BSF PORTA,0		; NACK received, RA0 HIGH

SendStop:
    ; Generate STOP condition
    BANKSEL PIR1
    BCF PIR1,3
    BANKSEL SSPCON2
    BSF SSPCON2,2	; PEN = 1, generate STOP

    BTFSC SSPCON2,2	; Wait until STOP finishes
    goto $-1
    RETURN

End