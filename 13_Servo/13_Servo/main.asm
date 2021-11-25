;*******************
; Práctica 11: PWM y LEDs
;
; Created: 24/11/2021
; Author : Ricardo Gutiérrez
;*******************

.include "m16adef.inc"     
   
;*******************
;Registros (aquí pueden definirse)
.def new=r20
.def temporal1=r30
.def temporal2=r31

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
;********************************

; Configuracion del timer
ldi r16, 0b01_10_1_011	; Prescaler 64, modo FastPWM
out TCCR0, r16

ldi r16, 0b0000_1111	;Columnas salidas, filas entradas (respecto al micro)
out DDRA, r16			;Puerto A para teclado matricial
ldi r16, 0b1111_1111	;Teclado con pull up
out PORTA, r16			

ldi r16, 255
out DDRD, r16	;Puerto D como salida
out DDRB, r16
ldi r16, 0
out PORTD, r16	;Lleno de 0s

ldi r17, 21
out OCR0, r17
ldi r16, 3
out PORTD, r16

main:
ldi new, 10
;Lógica del teclado

;Primera columna
ldi r16, 0b1111_1110
out PORTA, r16
nop
nop
sbis PINA, 6 ;1
ldi new, 1
sbis PINA, 5 ;4
ldi new, 4
cpi new, 10
brne output

;Segunda columna
ldi r16, 0b1111_1101
out PORTA, r16
nop
nop
sbis PINA, 6 ;2
ldi new, 2
sbis PINA, 5 ;5
ldi new, 5
cpi new, 10
brne output

;Tercera columna
ldi r16, 0b1111_1011
out PORTA, r16
nop
nop
sbis PINA, 6 ;3
ldi new, 3
cpi new, 10
brne output

rjmp main

output:
cpi new, 1
breq uno
cpi new, 2
breq dos
cpi new, 3
breq tres
cpi new, 4
breq cuatro
cpi new, 5
breq cinco
rjmp fin
uno:
ldi r16, 36
out OCR0, r16
rjmp fin
dos:
ldi r16, 29
out OCR0, r16
rjmp fin
tres:
ldi r16, 21
out OCR0, r16
rjmp fin
cuatro:
ldi r16, 13
out OCR0, r16
rjmp fin
cinco:
ldi r16, 6
out OCR0, r16
rjmp fin
fin:
out PORTD, new
rcall traba
rjmp main


retardo:	
	ldi temporal1, 0xAA
	ciclo1:
		dec temporal1
		breq salir
		ldi temporal2, 0xAA
	ciclo2:
		dec temporal2
		breq ciclo1
		rjmp ciclo2 
salir:
ret

traba:
	;Identificar qué pin es el presionado
	sbis PINA, 7
	rcall traba7
	sbis PINA, 6
	rcall traba6
	sbis PINA, 5
	rcall traba5
	sbis PINA, 4
	rcall traba4
	ret

traba7:
	sbis PINA, 7
	rjmp traba7
	rcall retardo	;esperar a que la señal se estabilice
	sbis PINA, 7	;si el botón sigue suelto, regresar, si no, traba
	rjmp traba7
	ret

traba6:
	sbis PINA, 6
	rjmp traba6
	rcall retardo
	sbis PINA, 6
	rjmp traba6
	ret

traba5:
	sbis PINA, 5
	rjmp traba5
	rcall retardo
	sbis PINA, 5
	rjmp traba5
	ret

traba4:
	sbis PINA, 4
	rjmp traba4
	rcall retardo
	sbis PINA, 4
	rjmp traba4
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



