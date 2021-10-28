;*******************
; Practica 8: Dado
;
; Created: 26/10/2021
; Author : Ricardo Gutiérrez
;*******************

.include "m16adef.inc"     
   
;*******************
;Registros (aquí pueden definirse)
;.def temporal=r19

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

; Configurar interrupción 0
sei
ldi r16, 0b0000_0010
out MCUCR, r16
ldi r16, 0b1110_0000
out GIFR, r16
ldi r16, 0b0100_0000
out GICR, r16

; Configurar puertos
ldi r16, 255
out DDRA, r16
ldi r16, 0
out PORTA, r16
ldi r16, 0 
out DDRD, r16
ldi r16, 255
out PORTD, r16

; Programa
ldi r16, 1

main:
inc r18
cpi r18, 8
brne main
ldi r18, 1
rjmp main

uno:
ldi r16, 0b0000_1000
out PORTA, r16
ret
dos:
ldi r16, 0b0010_0010
out PORTA, r16
ret
tres:
ldi r16, 0b0100_1001
out PORTA, r16
ret
cuatro:
ldi r16, 0b0101_0101
out PORTA, r16
ret
cinco:
ldi r16, 0b0101_1101
out PORTA, r16
ret
seis:
ldi r16, 0b0111_0111
out PORTA, r16
ret
siete:
ldi r16, 0b0111_1111
out PORTA, r16
ret

retardo:	
	ldi r30, 0xA0
	ciclo1:
		dec r30
		breq salir
		ldi r31, 0xA0
	ciclo2:
		dec r31
		breq ciclo1
		rjmp ciclo2 
salir:
ret

traba:
	sbis PIND, 2
	rjmp traba
	rcall retardo	; esperar a que la señal se estabilice
	sbis PIND, 2	; si el botón sigue suelto, regresar, si no, traba
	rjmp traba
	ret

;*********************************
;Aquí está el manejo de las interrupciones concretas
;*********************************
EXT_INT0: ; IRQ0 Handler
in r17, SREG
push r17
; Rebote
rcall retardo
sbic PIND, 2
reti
cpi r18, 1
breq call1
cpi r18, 2
breq call2
cpi r18, 3
breq call3
cpi r18, 4
breq call4
cpi r18, 5
breq call5
cpi r18, 6
breq call6
cpi r18, 7
breq call7
rcall uno
rjmp exit
call1:
rcall uno
rjmp exit
call2:
rcall dos
rjmp exit
call3:
rcall tres 
rjmp exit
call4:
rcall cuatro
rjmp exit
call5:
rcall cinco
rjmp exit
call6:
rcall seis
rjmp exit
call7:
rcall siete
rjmp exit
exit:
rcall traba
pop r17
out SREG, r17
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