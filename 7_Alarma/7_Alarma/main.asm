;*******************
; Alarma
;
; Created: 16-10-2021
; Author : Ricardo Gutierrez
;*******************

.include "m16adef.inc"     
   
;*******************
;Registros (aquí pueden definirse)
.def temporal1=r30
.def temporal2=r31
.def new=r28
.def estado=r29
.def vala=r26
.def valb=r25
.def valc=r24
.def vald=r23
.def strokes=r22

;Palabras claves (aquí pueden definirse)
;.equ LCD_DAT=DDRC
;********************
.equ RESET_VAL=11

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

ldi r16, 0b0000_1111	;Columnas salidas, filas entradas (respecto al micro)
out DDRA, r16			;Puerto A para teclado matricial
ldi r16, 0b1111_1111	;Teclado con pull up
out PORTA, r16			

ldi r16, 255
out DDRD, r16	;Puerto D como salida
ldi r16, 0
out PORTD, r16	;Lleno de 0s

ldi r16, 255
out DDRC, r16

ldi estado, 0
ldi strokes, 0

main:
ldi new, 10
;Lógica del teclado

;Primera columna
ldi r16, 0b1111_1110
out PORTA, r16
nop
nop
sbis PINA, 7 ;reset
ldi new, RESET_VAL
sbis PINA, 6 ;1
ldi new, 1
sbis PINA, 5 ;4
ldi new, 4
sbis PINA, 4 ;7
ldi new, 7
cpi new, 10
brne output

;Segunda columna
ldi r16, 0b1111_1101
out PORTA, r16
nop
nop
sbis PINA, 7 ;0
ldi new, 0
sbis PINA, 6 ;2
ldi new, 2
sbis PINA, 5 ;5
ldi new, 5
sbis PINA, 4 ;8
ldi new, 8
cpi new, 10
brne output

;Tercera columna
ldi r16, 0b1111_1011
out PORTA, r16
nop
nop
sbis PINA, 6 ;3
ldi new, 3
sbis PINA, 5 ;6
ldi new, 6
sbis PINA, 4 ;9
ldi new, 9
cpi new, 10
brne output

rjmp main

output:
cpi new, RESET_VAL
breq verify_not_alarm
mov vald, valc
mov valc, valb
mov valb, vala
mov vala, new
cpi estado, 0 ; cerrada
breq cerrado
cpi estado, 1 ; abierta
breq abierto
cpi estado, 2 ; alarma
breq alarma

verify_not_alarm:
cpi estado, 2
brne reset_state
rjmp ret_to_main
reset_state:
ldi estado, 0
ldi r16, 0
out PORTD, r16
out PORTC, estado
ldi strokes, 0
rjmp ret_to_main

cerrado:
	inc strokes
	cpi strokes, 4
	breq rev_a
	rjmp ret_to_main
rev_a:
	cpi vala, 9
	breq rev_b
	rjmp alarm_off
	rjmp ret_to_main
rev_b:
	cpi valb, 7
	breq rev_c
	rjmp alarm_off
	rjmp ret_to_main
rev_c:
	cpi valc, 5
	breq rev_d
	rjmp alarm_off
	rjmp ret_to_main
rev_d:
	cpi vald, 1
	breq unlock
	rjmp alarm_off
	rjmp ret_to_main
unlock:
	ldi r16, 1
	out PORTD, r16
	ldi estado, 1
	out PORTC, estado
	rjmp ret_to_main
alarm_off:
	ldi estado, 2
	out PORTC, estado
	ldi r16, 128
	out PORTD, r16
	ldi vala, 10
	ldi valb, 10
	rjmp ret_to_main

abierto:
	ldi r16, 0
	out PORTD, r16
	ldi estado, 0
	out PORTC, estado
	ldi strokes, 0
	rjmp ret_to_main

alarma:
	rjmp rev_aa
rev_aa:
	cpi vala, 3
	breq rev_ba
	rjmp ret_to_main
rev_ba:
	cpi valb, 2
	breq turn_off
	rjmp ret_to_main

turn_off:
	ldi r16, 0
	out PORTD, r16
	ldi estado, 0
	out PORTC, estado
	ldi strokes, 0
	rjmp ret_to_main

ret_to_main:
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



