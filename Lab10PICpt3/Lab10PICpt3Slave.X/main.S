// Ashton Tolman
// RCET3373
// Lab10PICpt3Slave
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
    ErrorFlags EQU 0x73
    RxByte EQU 0x74
    DataH EQU 0x75
    DataL EQU 0x76
    ConfigureFlag EQU 0x77
    RegisterPointer EQU 0x78
    
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
    CLRF ErrorFlags
    CLRF RxByte
    CLRF ConfigureFlag
		    
    goto Main
    

Main:
    ; Start a new timer interval
    BANKSEL TMR0
    MOVLW 0xE4
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
    ; CALL StepTwo
    ; CALL StepThree
    CALL StepFive
    CALL StepFour
    BANKSEL PORTA
    BCF PORTA,1		; RA1 LOW after STOP
    goto Main

Halt:
    BANKSEL PORTA
    BCF PORTA,1
    MOVF ErrorFlags,F
    BTFSS STATUS,2
    BSF PORTA,0        ; any error keeps RA0 high
    goto Halt
    
StepOne:
    MOVLW 0x92
    MOVWF ADSWriter
    CALL AddressProbe
    RETURN
    
StepTwo:
    MOVLW 0x01
    MOVWF RegisterPointer
    CALL SelectRegister
    CALL ReadRegister
    goto Halt
    
StepThree:
    MOVLW 0x40
    MOVWF DataH
    MOVLW 0x83
    MOVWF DataL
    MOVLW 0x01
    MOVWF RegisterPointer
    CALL ConfigureADS
    MOVF ErrorFlags,F
    BTFSS STATUS,2
    goto Halt
    CALL ReadRegister
    goto Halt
    
StepFour:
    BSF ConfigureFlag,1
    BTFSS ConfigureFlag,0
    goto OneTimeConfig
    MOVF ErrorFlags,F
    BTFSS STATUS,2
    goto Halt
    CLRF RegisterPointer
    CALL SelectRegister
    MOVF ErrorFlags,F
    BTFSS STATUS,2
    goto Halt
    CALL ReadRegister
    RETURN
    
StepFive:
    BCF ConfigureFlag,1
    BTFSS ConfigureFlag,0
    goto OneTimeConfig
    RETURN
    
OneTimeConfig:
    
    BTFSS ConfigureFlag,1
    goto StepFiveConfig
    
    StepFourConfig:
    MOVLW 0x40
    MOVWF DataH
    MOVLW 0x83
    MOVWF DataL
    MOVLW 0x01
    MOVWF RegisterPointer
    CALL ConfigureADS
    MOVF ErrorFlags,F
    BTFSS STATUS,2
    goto Halt
    CALL ReadRegister
    MOVF ErrorFlags,F
    BTFSS STATUS,2
    goto Halt
    BSF ConfigureFlag,0
    goto StepFour
    
    StepFiveConfig:
    ;Configure Low threshold
    MOVLW 0x02
    MOVWF RegisterPointer
    CLRF DataH
    CLRF DataL
    CALL ConfigureADS
    MOVF ErrorFlags,F
    BTFSS STATUS,2
    goto Halt
    
    ;Configure High threshold
    MOVLW 0x03
    MOVWF RegisterPointer
    MOVLW 0x80
    MOVWF DataH
    CLRF DataL
    CALL ConfigureADS
    MOVF ErrorFlags,F
    BTFSS STATUS,2
    goto Halt
    
    MOVLW 0x40
    MOVWF DataH
    MOVLW 0x80
    MOVWF DataL
    MOVLW 0x01
    MOVWF RegisterPointer
    CALL ConfigureADS
    MOVF ErrorFlags,F
    BTFSS STATUS,2
    goto Halt
    BSF ConfigureFlag,0
    goto StepFive
    
ConfigureADS:
    ; Clear NACK indicator before each probe
    BANKSEL PORTA
    BCF PORTA,0		; RA0 LOW
    
;Select Config 
    CALL SendStart
    MOVF ErrorFlags,F
    BTFSS STATUS,2
    RETURN
    ;Send address with Write
    MOVLW 0x92
    MOVWF ADSWriter
    CALL SendByte
    MOVF ErrorFlags,F
    BTFSS STATUS,2
    RETURN
        
    ;Send Config pointer
    MOVF RegisterPointer,W
    MOVWF ADSWriter
    CALL SendByte
    MOVF ErrorFlags,F
    BTFSS STATUS,2
    RETURN
    
    ;Send high config byte
    MOVF DataH,W
    MOVWF ADSWriter
    CALL SendByte
    MOVF ErrorFlags,F
    BTFSS STATUS,2
    RETURN
    
    ;Send low config byte
    MOVF DataL,W
    MOVWF ADSWriter
    CALL SendByte
    MOVF ErrorFlags,F
    BTFSS STATUS,2
    RETURN

    ;Leave
    CALL SendStop
    RETURN
    
SelectRegister:
    ; Clear NACK indicator before each probe
    BANKSEL PORTA
    BCF PORTA,0		; RA0 LOW
    
;Select Config to be read
    CALL SendStart
    MOVF ErrorFlags,F
    BTFSS STATUS,2
    RETURN
    ;Send address with Write
    MOVLW 0x92
    MOVWF ADSWriter
    CALL SendByte
    MOVF ErrorFlags,F
    BTFSS STATUS,2
    RETURN
        
    ;Send Config Byte
    MOVF RegisterPointer,W
    MOVWF ADSWriter
    CALL SendByte
    MOVF ErrorFlags,F
    BTFSS STATUS,2
    RETURN
    ;Leave
    CALL SendStop
    RETURN
    
ReadRegister:
;Read Config that is selected
    CALL SendStart
    MOVF ErrorFlags,F
    BTFSS STATUS,2
    RETURN
    
    ;Send address with Read
    MOVLW 0x93
    MOVWF ADSWriter
    CALL SendByte
    MOVF ErrorFlags,F
    BTFSS STATUS,2
    RETURN
   
    ;Receive high byte
    CALL SendReceive
    MOVF ErrorFlags,F
    BTFSS STATUS,2
    RETURN
    MOVF RxByte,W
    MOVWF DataH
    ;Acknolege from PIC
    CALL SendACK
    MOVF ErrorFlags,F
    BTFSS STATUS,2
    RETURN
    
    ;Receive low byte
    CALL SendReceive
    MOVF ErrorFlags,F
    BTFSS STATUS,2
    RETURN
    MOVF RxByte,W
    MOVWF DataL
    ;Non acknolege from PIC
    CALL SendNACK
    MOVF ErrorFlags,F
    BTFSS STATUS,2
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
    ; Check that SCL and SDA are HIGH
    BANKSEL PORTC
    BTFSS PORTC,3
    goto BusLow
    BTFSS PORTC,4
    goto BusLow

    ; Generate START condition
    BANKSEL PIR1
    BCF PIR1,3		; Clear SSPIF
    BANKSEL SSPCON2
    BSF SSPCON2,0	; SEN = 1, start I2C
    CALL WaitFlag
    RETURN

    BusLow:
    BSF ErrorFlags,1
    BANKSEL PORTA
    BSF PORTA,0        ; RA0 HIGH
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
    BTFSC ErrorFlags,2
    RETURN
    
    ; Check ACK or NACK
    BANKSEL SSPCON2
    BTFSS SSPCON2,6
    RETURN             ; ACK received

    ; NACK received
    BSF ErrorFlags,0
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
    BSF ErrorFlags,2	; When count ends, throw error
    RETURN
    
    FlagDone:
    BCF PIR1,3
    RETURN
    
 
Delay10us:
    ; Delay loop is equal to 14 Tcy when count is 3
    MOVLW 0x03             ; 1 Tcy move W=3 to count
    MOVWF Count10us        ; 1 Tcy make count equal 3
    DECFSZ Count10us,F     ; 1 Tcy if not zero, 2 Tcy if zero
    goto $-1               ; 2 Tcy delay runs 15 times before skipping
    RETURN

End