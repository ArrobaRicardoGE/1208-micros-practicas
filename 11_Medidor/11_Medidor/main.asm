;*******************
; Práctica 11: Medidor
;
; Created: 16 de noviembre de 2021
; Author : Ricardo Gutiérrez
;*******************

.include "m16adef.inc"     
   
;*******************
;Registros (aquí pueden definirse)
.def midiendo=r24
.def d1=r20
.def d2=r21

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

ldi r16, 0b0000_1010	; Prescaler 8, CTC
out TCCR0, r16
ldi r16, 124			; Mediciones de 0.001s
out OCR0, r16
sei
ldi r16, 0b0000_00_10
out TIMSK, r16

ldi r16, 0
out DDRB, r16
out PORTB, r16
ldi r16, 255
out DDRC, r16
out PORTB, r16

main:
sbic PINB, 0
rjmp main
rcall traba0
rjmp medir

medir:
cpi midiendo, 1
breq subir
cpi midiendo, 2
breq bajar
cpi midiendo, 3
breq terminar
sbis PINA, 0	; Espero a que baje
ldi midiendo, 1
rjmp medir
subir:
sbis PINA, 0	; Espero a que suba
rjmp medir
ldi midiendo, 2
ldi d1, 0
ldi d2, 0
rjmp medir
bajar:
sbis PINA, 0	; Espero a que baje
ldi midiendo, 3
rjmp medir
terminar:
sbis PINA, 0	; Espero a que suba
rjmp medir
rcall output
ldi midiendo, 0
rjmp main

output:
mov r16, d2
swap r16
or r16, d1
out PORTC, r16
ret

traba0:
	sbis PINB, 0
	rjmp traba0
	rcall retardo	;esperar a que la señal se estabilice
	sbis PINB, 0	;si el botón sigue suelto, regresar, si no, traba
	rjmp traba0
	ret

retardo:	
	ldi r30, 0xA5
	ciclo1:
		dec r30
		breq salir
		ldi r31, 0xA5
	ciclo2:
		dec r31
		breq ciclo1
		rjmp ciclo2 
salir:
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
in r17, SREG
push r17
inc d1
cpi d1, 10
brne end
ldi d1, 0
inc d2
end:
pop r17
out SREG, r17
reti
SPM_RDY: 
reti ; Store Program Memory Ready Handler



