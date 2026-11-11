// Ashton Tolman
// RCET3373
// Lab10PICpt4Master
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
    RxBuffer      EQU 0x20         ; 24 received UART payload bytes: 0x20-0x37
    TxBuffer      EQU 0x38         ; 24 reply payload bytes: 0x38-0x4F
     
    RxState       EQU 0x50         ; 0=header, 1=command, 2=length, 3=data
    CommandByte   EQU 0x51         ; UART command from the PC
    RequestLength EQU 0x52         ; Number of payload bytes specified by PC
    RequestCount  EQU 0x53         ; Number of payload bytes received
    UARTByte      EQU 0x54         ; Most recent byte received through UART
    DeviceAddress EQU 0x55         ; 7-bit I2C address from PC
    AddressWrite  EQU 0x56         ; Shifted 8-bit write address
    AddressRead   EQU 0x57         ; Shifted 8-bit read address
    BytesLeft     EQU 0x58         ; Bytes still remaining in I2C/reply transfer
    ReplyLength   EQU 0x59         ; Number of bytes in UART reply payload
    I2CError      EQU 0x5A         ; 0=none, 1=NACK, 2=timeout, 3=bus LOW, 4=SCL LOW
    ErrorCategory EQU 0x5B         ; Category byte for UART error reply
    ErrorDetail   EQU 0x5C         ; Detail byte for UART error reply
    SendByte      EQU 0x5D         ; Byte currently being transmitted through UART
    RxByte        EQU 0x5E         ; Last byte received from I2C device
    WaitCount     EQU 0x5F         ; First I2C timeout counter
    WaitOuter     EQU 0x60         ; Second I2C timeout counter

; UART Command Settings
    StartByte     EQU 0x24         ; UART packet header (0x24)
    MaxPayload    EQU 24           ; Maximum accepted UART payload length
    MaxRead       EQU 23           ; Maximum number of I2C bytes read

; Reset Vector
PSECT resetVect,class=CODE,delta=2
ResetVector:
    GOTO Setup

; Interrupt Vector (not used)
PSECT isrVect,class=CODE,delta=2

; Main Code
PSECT code,class=CODE,delta=2

Setup:
    ; Disable analog inputs so the pins work as digital I/O
    BANKSEL ANSEL
    CLRF ANSEL                ; Disable analog inputs AN0-AN7
    CLRF ANSELH               ; Disable remaining analog inputs
    BANKSEL CM1CON0
    CLRF CM1CON0              ; Disable comparator 1
    BANKSEL CM2CON0
    CLRF CM2CON0              ; Disable comparator 2

    ; Set up PORTA diagnostic outputs
    BANKSEL PORTA
    CLRF PORTA                ; Start RA0 and RA1 LOW
    BANKSEL TRISA
    BCF TRISA,0               ; RA0 = I2C error indicator
    BCF TRISA,1               ; RA1 = I2C transaction indicator

    ; Set up I2C and UART communication pins
    BANKSEL TRISC
    BSF TRISC,3             ; RC3 = SCL
    BSF TRISC,4             ; RC4 = SDA
    BSF TRISC,6             ; RC6 = TX controlled by EUSART
    BSF TRISC,7             ; RC7 = RX input

    ; Set up MSSP for 100 kHz I2C Master Mode
    BANKSEL SSPCON
    CLRF SSPCON               ; Clear previous MSSP settings
    BANKSEL SSPCON2
    CLRF SSPCON2              ; Clear I2C control settings
    BANKSEL SSPSTAT
    MOVLW 0x80              ; SMP=1, standard speed
    MOVWF SSPSTAT             ; Set standard-speed I2C operation

    ; Set SCL frequency to 100 kHz with 4 MHz oscillator
    BANKSEL SSPADD
    MOVLW 0x09              ; 4 MHz / [4*(9+1)] = 100 kHz
    MOVWF SSPADD              ; Set the I2C clock speed
    BANKSEL SSPCON
    MOVLW 0x28              ; SSPEN=1, I2C Master mode
    MOVWF SSPCON
    BANKSEL PIR1
    BCF PIR1,3              ; Clear SSPIF

    ; Set up UART communication at 9600 baud (8N1)
    BANKSEL BAUDCTL
    CLRF BAUDCTL            ; BRG16=0, normal polarity
    BANKSEL SPBRG
    MOVLW 25                ; 4 MHz / [16*(25+1)] ~= 9615 baud
    MOVWF SPBRG
    BANKSEL SPBRGH
    CLRF SPBRGH
    BANKSEL TXSTA
    MOVLW 0x24              ; TXEN=1, BRGH=1, SYNC=0
    MOVWF TXSTA               ; Enable UART transmitter
    BANKSEL RCSTA
    MOVLW 0x90              ; SPEN=1, CREN=1, 8-bit receive
    MOVWF RCSTA               ; Enable UART receiver

    ; Set up Timer0 for incomplete UART packet timeout
    BANKSEL OPTION_REG
    MOVLW 0x07              ; Prescaler 1:256 on Timer0
    MOVWF OPTION_REG          ; Set Timer0 prescaler to 1:256
    BANKSEL TMR0
    CLRF TMR0                 ; Start Timer0 at zero
    BCF INTCON,2              ; Clear Timer0 overflow flag

    ; Clear variables before starting the program
    BANKSEL RxState
    CLRF RxState
    CLRF CommandByte
    CLRF RequestLength
    CLRF RequestCount
    CLRF UARTByte
    CLRF DeviceAddress
    CLRF AddressWrite
    CLRF AddressRead
    CLRF BytesLeft
    CLRF ReplyLength
    CLRF I2CError
    CLRF ErrorCategory
    CLRF ErrorDetail
    CLRF SendByte
    CLRF RxByte
    CLRF WaitCount
    CLRF WaitOuter
    BCF STATUS,7            ; IRP=0: indirect buffers are in Bank 0
   
GOTO Main

Main:
    BANKSEL RCSTA
    BTFSC RCSTA,1 ;overrun error?
    GOTO RxRun
    BTFSS PIR1,5 ;new byte revieced?
    GOTO Timeout
    BTFSC RCSTA,2 ;frame error on new byte?
    GOTO Framing
    BANKSEL RCREG
    MOVF RCREG,W
    BANKSEL UARTByte
    MOVWF UARTByte
    CALL ProcessUART
    GOTO Main
   
RxRun:
    CALL ClearUART
    BANKSEL RxState
    CLRF RxState
    MOVLW 0x02
    MOVWF ErrorCategory
    CLRF ErrorDetail
    CALL SendErrorPacket
    GOTO Main

ClearUART:
    BANKSEL RCSTA  
    BCF RCSTA,4
    BSF RCSTA,4 ;reset/clear the reciever
    BANKSEL TMR0
    CLRF TMR0
    BCF INTCON,2

ClearLoop:
    BANKSEL PIR1
    BTFSS PIR1,5
    GOTO ClearLoop
    BANKSEL RCREG,W
    BANKSEL TMR0
    CLRF TMR0
    BCF INTCON,2
    GOTO ClearLoop
 
ClearWait:
    BANKSEL INTCON
    BTFSS INTCON,2
    GOTO ClearUART
    RETURN

UARTsend:
    BANKSEL SendByte
    MOVWF SendByte
   
UARTsendTWO:
    BANKSEL PIR1
    BTFSS PIR1,4
    GOTO UARTsendTWO
    BANKSEL SendByte
    MOVF SendByte,W
    BANKSEL TXREG
    MOVWF TXREG
    RETURN
 
SendErrorPacket:
    ; Send UART/I2C/validation error information to the GUI
    MOVLW StartByte
    CALL UARTSend
    MOVLW 0x45
    CALL UARTSend
    MOVLW 0x02
    CALL UARTSend
    BANKSEL ErrorCategory
    MOVF ErrorCategory,W
    CALL UARTSend
    BANKSEL ErrorDetail
    MOVF ErrorDetail,W
    CALL UARTSend
    RETURN
   
Timeout:
    BANKSEL RxState
    MOVF RxState,F
    BTFSC STATUS,2
    GOTO Main
    BANKSEL INTCON
    BTFSS INTCON,2
    GOTO Main
    BANKSEL RxState
    CLRF RxState
    MOVLW 0x05
    MOVWF ErrorCategory
    MOVLW 0x01
    MOVWF ErrorDetail
    CALL SendErrorPacket
    GOTO Main
   
Framing:
    BANKSEL RCREG
    MOVF RCREG,W ;discard bad byte
    CALL ClearUART
    BANKSEL RxState
    CLRF RxState
    MOVLW 0x01
    MOVWF ErrorCategoy
    CLRF ErrorDetail
    CALL SendErrorPacket
    GOTO Main
   
ProcessUART:
    BANKSEL TMR0
    CLRF TMR0
    BCF INTCON,2
    BANKSEL RxState
    MOVF RxState,W
    XORLW 0
    BTFSC STATUS,2
    GOTO ReceiveHeader
    MOVF RxState,W
    XORLW 1
    BTFSC STATUS,2
    GOTO ReceiveCommand
    MOVF RxState,W
    XORLW 2
    BTFSC STATUS,2
    GOTO ReceiveLength
    GOTO ReceivePayload
   
ReceiveHeader:
    MOVF UARTByte,W
    XORLW 0x24
    BTFSS STATUS,2 ;does the packet start with 24/$?
    RETURN ;no $ we wait
    MOVLW 0x01
    MOVWF RxState ;yes $, now move to command
    RETURN

ReceiveCommand:
    MOVF UARTByte,W
    MOVWF CommandByte ;save what was requested
    MOVLW 0x02
    MOVWF RxState
    RETURN
   
ReceiveLength:
    MOVF UARTByte,W
    MOVWF RequestLength
    CLRF RequestCount
    MOVF RequestLength,F
    BTFSC STATUS,2
    GOTO ProcessRequest
   
    MOVLW 3
    MOVWF RxState
    RETURN
   
ReceivePayload:

   
   

   
   