;*******************
; Proyecto Brazo
;
; Created: 21/11/21
; Author : Ricardo Gutiérrez
;*******************

.include "m16adef.inc"     
   
;*******************
;Registros (aquí pueden definirse)
.def motor=r17
.def temp1=r30
.def temp2=r31
.def i=r18
.def dir=r19

;Palabras claves (aquí pueden definirse)
;.equ LCD_DAT=DDRC
;********************

.org 0x0000
;Comienza el vector de interrupciones...
jmp RESET ; Reset Handler
jmp EXT_INT0 ; IRQ0 Handler
jmp EXT_INT1 ; IRQ1 Handler
jmp TIM2_COMP ; Timer2 Compare Handler
jmp TIM2_OVF ; Timer2 Overflow Handler
jmp TIM1_CAPT ; Timer1 Capture Handler
jmp TIM1_COMPA ; Timer1 CompareA Handler
jmp TIM1_COMPB ; Timer1 CompareB Handler
jmp TIM1_OVF ; Timer1 Overflow Handler
jmp TIM0_OVF ; Timer0 Overflow Handler
jmp SPI_STC ; SPI Transfer Complete Handler
jmp USART_RXC ; USART RX Complete Handler
jmp USART_UDRE ; UDR Empty Handler
jmp USART_TXC ; USART TX Complete Handler
jmp ADC_COMP ; ADC Conversion Complete Handler
jmp EE_RDY ; EEPROM Ready Handler
jmp ANA_COMP ; Analog Comparator Handler
jmp TWSI ; Two-wire Serial Interface Handler
jmp EXT_INT2 ; IRQ2 Handler
jmp TIM0_COMP ; Timer0 Compare Handler
jmp SPM_RDY ; Store Program Memory Ready Handler

;**************
;Inicializar el Stack Pointer
;**************
Reset:
ldi r16, high(RAMEND)
out SPH, r16
ldi r16, low(RAMEND)
out SPL, r16 


;*********************************
;Aquí comienza el programa...
;No olvides configurar al inicio todo lo que utilizarás
;*********************************

; Puerto A -> entradas
; Puerto B -> giro y descenso (descenso_giro)
; Puerto D -> garra
ldi r16, 0
out DDRA, r16
ldi r16, 255
out DDRB, r16
out DDRD, r16

; PIN0 -> botón: pullup
ldi r16, 0b1000_0000
out PORTA, r16

main:
sbis PINA, 7 
rjmp secuencia
rjmp main

secuencia:
ldi r16, 0
ldi dir, 0		; Blanco, izquierda
sbis PINA, 1	; Identificar color
ldi dir, 1
rcall bajar
out PORTB, r16
rcall agarrar
out PORTD, r16
rcall subir 
out PORTB, r16
cpi dir, 0
breq izq
rcall gira_der
out PORTB, r16
rjmp fin
izq:
rcall gira_izq
out PORTB, r16
rjmp fin
fin:
rcall bajar
out PORTB, r16
rcall soltar
out PORTD, r16
rcall subir
out PORTB, r16
cpi dir, 0
breq izq_v
rcall gira_izq
out PORTB, r16
rjmp main
izq_v:
rcall gira_der
out PORTB, r16
rjmp main

bajar:
ldi i, 30
loop_b:
ldi motor, 0b0000_1100
out PORTB, motor
rcall retardo_motor
ldi motor, 0b0000_0110
out PORTB, motor
rcall retardo_motor
ldi motor, 0b0000_0011
out PORTB, motor
rcall retardo_motor
ldi motor, 0b0000_1001
out PORTB, motor
rcall retardo_motor
dec i
brne loop_b
ret

subir:
ldi i, 30
loop_s:
ldi motor, 0b0000_1001
out PORTB, motor
rcall retardo_motor
ldi motor, 0b0000_0011
out PORTB, motor
rcall retardo_motor
ldi motor, 0b0000_0110
out PORTB, motor
rcall retardo_motor
ldi motor, 0b0000_1100
out PORTB, motor
rcall retardo_motor
dec i
brne loop_s
ret

gira_izq:
ldi i, 115
loop_gi:
ldi motor, 0b1100_0000
out PORTB, motor
rcall retardo_motor
ldi motor, 0b0110_0000
out PORTB, motor
rcall retardo_motor
ldi motor, 0b0011_0000
out PORTB, motor
rcall retardo_motor
ldi motor, 0b1001_0000
out PORTB, motor
rcall retardo_motor
dec i
brne loop_gi
ret

gira_der:
ldi i, 115
loop_gd:
ldi motor, 0b1001_0000
out PORTB, motor
rcall retardo_motor
ldi motor, 0b0011_0000
out PORTB, motor
rcall retardo_motor
ldi motor, 0b0110_0000
out PORTB, motor
rcall retardo_motor
ldi motor, 0b1100_0000
out PORTB, motor
rcall retardo_motor
dec i
brne loop_gd
ret

soltar:
ldi i, 130
loop_ba:
ldi motor, 0b0000_1100
out PORTD, motor
rcall retardo_motor
ldi motor, 0b0000_0110
out PORTD, motor
rcall retardo_motor
ldi motor, 0b0000_0011
out PORTD, motor
rcall retardo_motor
ldi motor, 0b0000_1001
out PORTD, motor
rcall retardo_motor
dec i
brne loop_ba
ret

agarrar:
ldi i, 130
loop_ss:
ldi motor, 0b0000_1001
out PORTD, motor
rcall retardo_motor
ldi motor, 0b0000_0011
out PORTD, motor
rcall retardo_motor
ldi motor, 0b0000_0110
out PORTD, motor
rcall retardo_motor
ldi motor, 0b0000_1100
out PORTD, motor
rcall retardo_motor
dec i
brne loop_ss
ret

retardo_motor:
; ============================= 
;    delay loop generator 
;     2500 cycles:
; ----------------------------- 
; delaying 2499 cycles:
          ldi  temp1, $07
WGLOOP0:  ldi  temp2, $76
WGLOOP1:  dec  temp2
          brne WGLOOP1
          dec  temp1
          brne WGLOOP0
; ----------------------------- 
; delaying 1 cycle:
          nop
; ============================= 
ret



;*********************************
;Aquí está el manejo de las interrupciones concretas
;*********************************
EXT_INT0: ; IRQ0 Handler
reti
EXT_INT1: 
reti ; IRQ1 Handler
TIM2_COMP: 
reti ; Timer2 Compare Handler
TIM2_OVF: 
reti ; Timer2 Overflow Handler
TIM1_CAPT: 
reti ; Timer1 Capture Handler
TIM1_COMPA: 
reti ; Timer1 CompareA Handler
TIM1_COMPB: 
reti ; Timer1 CompareB Handler
TIM1_OVF: 
reti ; Timer1 Overflow Handler
TIM0_OVF: 
reti ; Timer0 Overflow Handler
SPI_STC: 
reti ; SPI Transfer Complete Handler
USART_RXC: 
reti ; USART RX Complete Handler
USART_UDRE: 
reti ; UDR Empty Handler
USART_TXC: 
reti ; USART TX Complete Handler
ADC_COMP: 
reti ; ADC Conversion Complete Handler
EE_RDY: 
reti ; EEPROM Ready Handler
ANA_COMP: 
reti ; Analog Comparator Handler
TWSI: 
reti ; Two-wire Serial Interface Handler
EXT_INT2: 
reti ; IRQ2 Handler
TIM0_COMP: 
reti
SPM_RDY: 
reti ; Store Program Memory Ready Handler



