;*******************
; Contador
;
; Created: 21-09-2021
; Author : Ricardo Gutierrez
;*******************

.include "m16adef.inc"     
   
;*******************
;Registros (aquí pueden definirse)
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
;*********************************

ldi r16, 0
out DDRA, r16	;Puerto A como entrada
ldi r16, 255
out PORTA, r16	;Puerto A con  Pull Up

ldi r16, 255
out DDRD, r16	;Puerto D como salida
ldi r16, 0
out PORTD, r16	;Lleno de 0s

main:
sbis PINA, 0
rjmp incrementar
rjmp main

incrementar:
rcall retardo	; esperar a que la señal se estabilice
sbic PINA, 0	; si el botón sigue presionado, NO volver a main (sí cambió de estado)
rjmp main
inc r16
cpi r16, 10
breq zero
rjmp output

zero:
ldi r16, 0
rjmp output

output:
out PORTD, r16
rcall traba		; no incrementar hasta que se suelte el botón
rjmp main

retardo:	
	ldi temporal1, 0xA0
	ciclo1:
		dec temporal1
		breq salir
		ldi temporal2, 0xA0
	ciclo2:
		dec temporal2
		breq ciclo1
		rjmp ciclo2 
salir:
ret

traba:
	sbis PINA, 0
	rjmp traba
	rcall retardo	; esperar a que la señal se estabilice
	sbis PINA, 0	; si el botón sigue suelto, regresar, si no, traba
	rjmp traba
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



