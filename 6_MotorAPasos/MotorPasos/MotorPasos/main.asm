;*******************
; motor a Pasos
;
; Created: 12-10-2021
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

ldi r16, 0xFF
out DDRA, r16
ldi r16, 0x00	
out PORTA, r16			

ldi r16, 0
out DDRB, r16
ldi r16, 255	;Con pullup
out PORTB, r16

main:
sbis PINB, 0
rjmp wise
sbis PINB, 1
rjmp counter
rjmp main

counter:
ldi r16, 0x01
out PORTA, r16
rcall retardo_motor
lsl r16
out PORTA, r16
rcall retardo_motor
lsl r16
out PORTA, r16
rcall retardo_motor
lsl r16
out PORTA, r16
rcall retardo_motor
rjmp main

wise:
ldi r16, 0b0000_1000
out PORTA, r16
rcall retardo_motor
lsr r16
out PORTA, r16
rcall retardo_motor
lsr r16
out PORTA, r16
rcall retardo_motor
lsr r16
out PORTA, r16
rcall retardo_motor
rjmp main 


retardo_motor:
	; ============================= 
	;    delay loop generator 
	;     3000 cycles:
	; ----------------------------- 
	; delaying 2997 cycles:
			  ldi  temporal1, $A9
	WGLOOP0:  ldi  temporal2, $6E
	WGLOOP1:  dec  temporal2
			  brne WGLOOP1
			  dec  temporal1
			  brne WGLOOP0
	; ----------------------------- 
	; delaying 3 cycles:
			  ldi  temporal1, $01
	WGLOOP2:  dec  temporal1
			  brne WGLOOP2
	; ============================= 

	/*ret*/



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



