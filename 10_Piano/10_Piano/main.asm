;*******************
; Práctica 09: Cronómetro
;
; Created: 09/11/2021
; Author : Ricardo Gutiérrez
;*******************

.include "m16adef.inc"     
   
;*******************
;Registros (aquí pueden definirse)
.def s=r19
.def m=r20
.def h=r21
.def counting=r22

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

; Configuracion de los puertos
ldi r16, 0
out DDRA, r16
ldi r16, 255
out PORTA, r16
out DDRB, r16

main:
sbis PINA, 0
rjmp do
sbis PINA, 1 
rjmp re
sbis PINA, 2
rjmp mi
sbis PINA, 3
rjmp fa
sbis PINA, 4
rjmp sol
sbis PINA, 5
rjmp la
sbis PINA, 6
rjmp si
rjmp main

sound_on:
ldi r16, 0b0001_1011	; Prescaler 64, modo CTC, toggle
out TCCR0, r16
ret

sound_off:
ldi r16, 0
out TCCR0, r16
ret

do:
rcall sound_on
ldi r16, 29
out OCR0, r16
rcall traba0
rcall sound_off
rjmp main
re:
rcall sound_on
ldi r16, 26
out OCR0, r16
rcall traba1
rcall sound_off
rjmp main
mi:
rcall sound_on
ldi r16, 23
out OCR0, r16
rcall traba2
rcall sound_off
rjmp main
fa:
rcall sound_on
ldi r16, 21 
out OCR0, r16
rcall traba3
rcall sound_off
rjmp main
sol:
rcall sound_on
ldi r16, 19 
out OCR0, r16
rcall traba4
rcall sound_off
rjmp main
la:
rcall sound_on
ldi r16, 17
out OCR0, r16
rcall traba5
rcall sound_off
rjmp main
si:
rcall sound_on
ldi r16, 15
out OCR0, r16
rcall traba6
rcall sound_off
rjmp main

retardo:	
	ldi r30, 0x05
	ciclo1:
		dec r30
		breq salir
		ldi r31, 0x05
	ciclo2:
		dec r31
		breq ciclo1
		rjmp ciclo2 
salir:
ret

traba0:
	sbis PINA, 0
	rjmp traba0
	rcall retardo	;esperar a que la señal se estabilice
	sbis PINA, 0	;si el botón sigue suelto, regresar, si no, traba
	rjmp traba0
	ret

traba1:
	sbis PINA, 1
	rjmp traba1
	rcall retardo
	sbis PINA, 1
	rjmp traba1
	ret

traba2:
	sbis PINA, 2
	rjmp traba2
	rcall retardo
	sbis PINA, 2
	rjmp traba2
	ret

traba3:
	sbis PINA, 3
	rjmp traba3
	rcall retardo
	sbis PINA, 3
	rjmp traba3
	ret

traba4:
	sbis PINA, 4
	rjmp traba4
	rcall retardo
	sbis PINA, 4
	rjmp traba4
	ret

traba5:
	sbis PINA, 5
	rjmp traba5
	rcall retardo
	sbis PINA, 5
	rjmp traba5
	ret

traba6:
	sbis PINA, 6
	rjmp traba6
	rcall retardo
	sbis PINA, 6
	rjmp traba6
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



