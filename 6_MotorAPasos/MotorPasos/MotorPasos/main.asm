;*******************
; motor a Pasos
;
; Created: 12-10-2021
; Author : Ricardo Gutierrez
;*******************

.include "m16adef.inc"     
   
;*******************
;Registros (aqu� pueden definirse)
.def temporal1=r30
.def temporal2=r31

;Palabras claves (aqu� pueden definirse)
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
;Aqu� comienza el programa...
;No olvides configurar al inicio todo lo que utilizar�s
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
ldi r16, 0
out PORTA, r16
sbis PINB, 0
rjmp turn_wise
sbis PINB, 1
rjmp turn_counter
rjmp main

turn_counter:
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

turn_wise:
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
;     2500 cycles:
; ----------------------------- 
; delaying 2499 cycles:
          ldi  R17, $07
WGLOOP0:  ldi  R18, $76
WGLOOP1:  dec  R18
          brne WGLOOP1
          dec  R17
          brne WGLOOP0
; ----------------------------- 
; delaying 1 cycle:
          nop
; ============================= 
ret

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
	;Identificar qu� pin es el presionado
	sbis PINA, 0
	rcall traba0
	sbis PINA, 1
	rcall traba1
	ret

traba0:
	sbis PINA, 0
	rjmp traba0
	rcall retardo	;esperar a que la se�al se estabilice
	sbis PINA, 0	;si el bot�n sigue suelto, regresar, si no, traba
	rjmp traba0
	ret

traba1:
	sbis PINA, 1
	rjmp traba1
	rcall retardo	;esperar a que la se�al se estabilice
	sbis PINA, 1	;si el bot�n sigue suelto, regresar, si no, traba
	rjmp traba1
	ret


;*********************************
;Aqu� est� el manejo de las interrupciones concretas
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



