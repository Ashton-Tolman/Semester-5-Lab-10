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
    Count10us EQU 0x70 ; delay counter 10us
    FlagCount EQU 0x71
    ADSWriter EQU 0x72
    ErrorFlag EQU 0x73
    RxByte EQU 0x74
    DataH EQU 0x75
    DataL EQU 0x76
 
    ConfigPointer EQU 0x01
    Lo_threshPointer EQU 0x10
    Hi_threshPointer EQU 0x11
 
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
    BSF  0x03, 06	;
    BSF  0x03, 05	; Set bank 3 active
    CLRF 0x89		; ANSELH analog/digital select portB pins as digital
    CLRF 0x88		; ANSEL analog/digital select portA pins as digital
    
    BSF  0x03, 06	;
    BCF  0x03, 5	; Set bank 2 active
    BSF  0x09, 1	; Turn T1G-not function off
    
    BCF  0x03, 06	;
    BSF  0x03, 05	; Set bank 1 active 
    BCF TRISA,0		; RA0 = NACK indicator
    BCF TRISA,1		; RA1 = Timer diagnostic
    BSF TRISC,3		; RC3 = SCL
    BSF TRISC,4		; RC4 = SDA
    CLRF SSPCON2
    BSF SSPSTAT,7	; Standard Speed (100 kHz)
    
    ;I2C clock set to 100kHz
    MOVLW 0x09		; 4 MHz / (4 x (9 + 1))
    MOVWF SSPADD
    MOVLW 0x07       
    MOVWF OPTION_REG
    BCF OPTION_REG,3
		    
    BCF  0x03, 06	;
    BCF  0x03, 05	; Set bank 0 active
    CLRF SSPCON
    CLRF 0x05		; clear port A
    CLRF 0x07		; Clear portC
    MOVLW 0x28		; Enable MSSP, I2C Master Mode
    MOVWF SSPCON	     
    CLRF TMR0
    BCF INTCON,2	; Clear TMR0 overflow flag
    
    CLRF ADSWriter
    CLRF ErrorFlag
    CLRF RxByte
		    
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
    ; CALL StepOne
    CALL StepTwo
    BANKSEL PORTA
    BCF PORTA,1		; RA1 LOW after STOP
    goto Main

StepOne:
    MOVLW 0x92
    MOVWF ADSWriter
    CALL AddressProbe
    RETURN
    
StepTwo:
    CALL ConfigRegisters
    Halt:
    BANKSEL PORTA
    BCF PORTA,1
    goto $-1
    
ConfigRegisters:
    ; Clear NACK indicator before each probe
    BANKSEL PORTA
    BCF PORTA,0		; RA0 LOW
    
;Select Config to be read
    CALL SendStart
    BTFSC ErrorFlag,0
    RETURN
    ;Send address with Write
    MOVLW 0x92
    MOVWF ADSWriter
    CALL SendByte
    BTFSC ErrorFlag,0
    RETURN
        
    ;Send Config Byte
    MOVLW 0x01
    MOVWF ADSWriter
    CALL SendByte
    BTFSC ErrorFlag,0
    RETURN
    ;Leave
    CALL SendStop
    
;Read Config that is selected
    CALL SendStart
    BTFSC ErrorFlag,0
    RETURN
    
    ;Send address with Read
    MOVLW 0x93
    MOVWF ADSWriter
    CALL SendByte
    BTFSC ErrorFlag,0
    RETURN
   
    ;Receive high byte
    CALL SendReceive
    BTFSC ErrorFlag,0
    RETURN
    MOVF RxByte,W
    MOVWF DataH
    ;Acknolege from PIC
    CALL SendACK
    BTFSC ErrorFlag,0
    RETURN
    
    ;Receive low byte
    CALL SendReceive
    BTFSC ErrorFlag,0
    RETURN
    MOVF RxByte,W
    MOVWF DataL
    ;Non acknolege from PIC
    CALL SendNACK
    BTFSC ErrorFlag,0
    RETURN
    
    ;Leave
    CALL SendStop
    RETURN
    
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

    ; Send 7-bit address with R/W
    BANKSEL PIR1
    BCF PIR1,3		; Clear SSPIF
    MOVF ADSWriter,W	; Put Shifted address into buffer
    BANKSEL SSPBUF	; The address is moved left once, LSB = R/W bit
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
    CALL SendStop
    RETURN
    
SendStart:
    ; Generate START condition
    BANKSEL PIR1
    BCF PIR1,3		; Clear SSPIF
    BANKSEL SSPCON2
    BSF SSPCON2,0	; SEN = 1, start I2C
    CALL WaitFlag
    RETURN

SendByte:
    ; Send One I2C Byte
    ; Clear SSPIF
    BANKSEL PIR1
    BCF PIR1,3

    ; Send byte
    BANKSEL SSPBUF
    MOVF ADSWriter,W
    MOVWF SSPBUF
    CALL WaitFlag
    
    ; Check ACK or NACK
    BANKSEL SSPCON2
    BTFSS SSPCON2,6
    RETURN             ; ACK received

    ; NACK received
    BANKSEL ErrorFlag
    BSF ErrorFlag,0
    BANKSEL PORTA
    BSF PORTA,0        ; RA0 HIGH
    
    ; Attempt STOP after NACK
    CALL SendStop
    RETURN 
    
SendStop:
    ; Generate STOP condition
    BANKSEL PIR1
    BCF PIR1,3
    BANKSEL SSPCON2
    BSF SSPCON2,2	; PEN = 1, generate STOP
    CALL WaitFlag
    RETURN
    
SendReceive:
    ; Receive One I2C Byte
    ; Clear SSPIF
    BANKSEL PIR1
    BCF PIR1,3

    ; Enable receive
    BANKSEL SSPCON2
    BSF SSPCON2,3      ; RCEN = 1
    CALL WaitFlag

    ; Save received byte
    BANKSEL SSPBUF
    MOVF SSPBUF,W
    MOVWF RxByte
    RETURN
  
SendACK:
    ; PIC Sends ACK
    BANKSEL PIR1
    BCF PIR1,3
    BANKSEL SSPCON2
    BCF SSPCON2,5      ; ACKDT = 0
    BSF SSPCON2,4      ; ACKEN = 1
    CALL WaitFlag
    RETURN
    
SendNACK:
    ; PIC Sends NACK 
    BANKSEL PIR1
    BCF PIR1,3
    BANKSEL SSPCON2
    BSF SSPCON2,5      ; ACKDT = 1
    BSF SSPCON2,4      ; ACKEN = 1
    CALL WaitFlag
    RETURN
    
WaitFlag:
    BANKSEL PIR1	
    MOVLW 0x0A		; Load waiting counters
    MOVWF FlagCount
    Waiting:
    BTFSC PIR1,3	; Wait until START finishes
    goto FlagDone	; Flag Detected, Return
    CALL Delay10us	
    DECFSZ FlagCount,F	; Count down from 10
    goto Waiting	; Check again
    BSF ErrorFlag,0	; When count ends, throw error
    RETURN
    
    FlagDone:
    BCF PIR1,3
    RETURN
    
 
Delay10us:
    ; Delay loop is equal to 44 Tcy when count is 15
    MOVLW 0x03             ; 1 Tcy move W=3 to count
    MOVWF Count10us        ; 1 Tcy make count equal 15
    DECFSZ Count10us,F     ; 1 Tcy if not zero, 2 Tcy if zero
    goto $-1               ; 2 Tcy delay runs 15 times before skipping
    RETURN

End