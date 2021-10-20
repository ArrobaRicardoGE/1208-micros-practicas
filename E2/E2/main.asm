;*******************
; Parcial 2
;
; Created: 19/10/2021
; Author : Ricardo Gutierrez
;*******************

.include "m16adef.inc"     
   
;*******************
;Registros (aquí pueden definirse)
.def input=r25		; valor recibido en teclado
.def operacion=r26	; 11 si es resta, 12 si es suma
.def estado=r27		; estados del 0 al 5, ver en la rutina "procesar"
.def primero=r28	; informacion del primer DISPLAY
.def segundo=r29	; informacion del segundo DISPLAY
.def temporal1=r30	; temporales para rebote
.def temporal2=r31
; Se guardan los digitos de las decenas y unidades de ambos numeros. Solo se
; usan en la rutina "decodificar", cuando ya se va a efectuar la operacion.
; El resultado final esta partido en d1 y u1. Cuando se muestra en el display,
; se unen en r16 (ver rutina "output").
.def d1=r24
.def d2=r23
.def u1=r22
.def u2=r21

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

; Configuracion del teclado + reset
ldi r16, 0b0000_0111 ; Iterar sobre las columnas
out DDRA, r16
ldi r16, 0b1111_1000 ; Con pullup
out PORTA, r16

; Configuracion displays
ldi r16, 255		; Salidas
out DDRB, r16
out DDRC, r16
out DDRD, r16
ldi r16, 0			; 0 inicial
out PORTB, r16
out PORTC, r16
out PORTD, r16

rjmp reset_calc

main:

; Para el reset
sbis PINA, 7
rjmp reset_calc_button

; Logica del teclado
; Nota: el debounce se lleva a cabo en "procesar"

ldi input, 10
ldi r16, 0b1111_1_110 ; Columna 3
out PORTA, r16
nop
nop
nop
sbis PINA, 3 ; 3
ldi input, 3
sbis PINA, 4 ; 6
ldi input, 6
sbis PINA, 5 ; 9
ldi input, 9
sbis PINA, 6 ; # (-)
ldi input, 11
cpi input, 10
brne procesar

ldi input, 10
ldi r16, 0b1111_1_101 ; Columna 2
out PORTA, r16
nop
nop
nop
sbis PINA, 3 ; 2
ldi input, 2
sbis PINA, 4 ; 5
ldi input, 5
sbis PINA, 5 ; 8
ldi input, 8
sbis PINA, 6 ; 0
ldi input, 0
cpi input, 10
brne procesar

ldi input, 10
ldi r16, 0b1111_1_011 ; Columna 3
out PORTA, r16
nop
nop
nop
sbis PINA, 3 ; 1
ldi input, 1
sbis PINA, 4 ; 4
ldi input, 4
sbis PINA, 5 ; 7
ldi input, 7
sbis PINA, 6 ; * (+)
ldi input, 12
cpi input, 10
brne procesar

rjmp main

procesar:
; Contra el rebote: verificamos si hay algun pin activo despues del retardo
rcall retardo
sbis PINA, 3
rjmp pin_activo
sbis PINA, 4
rjmp pin_activo
sbis PINA, 5
rjmp pin_activo
sbis PINA, 6
rjmp pin_activo
rjmp main		; Si no hubo pin activo, fue rebote y regresamos
pin_activo:
cpi estado, 0	; Esperando el primer digito del primer numero
breq primero1
cpi estado, 1	; Esperando el segundo digito del primer numero
breq primero2
cpi estado, 2	; Esperando operacion
breq obtener_operacion
cpi estado, 3	;  Esperando el primer digito del segundo numero
breq segundo1
cpi estado, 4	; Esperando el segundo digito del segundo numero
breq segundo2
rjmp ret_to_main

primero1:
cpi input, 10		; Checamos si el input es mayor a 10 (si presiono # o *)
brsh salir_p1 
swap input
or primero, input
out PORTC, primero
ldi estado, 1
salir_p1:
rjmp ret_to_main

primero2: 
cpi input, 10		; Checamos si el input es mayor a 10 (si presiono # o *)
brsh salir_p2 
or primero, input
out PORTC, primero
ldi estado, 2
salir_p2:
rjmp ret_to_main

obtener_operacion:
cpi input, 11
breq es_valido
cpi input, 12
breq es_valido
rjmp ret_to_main
es_valido:			; Validamos si se tecleo # o *
mov operacion, input
ldi estado, 3
rjmp ret_to_main

segundo1:
cpi input, 10		; Checamos si el input es mayor a 10 (si presiono # o *)
brsh salir_s1 
swap input
or segundo, input
out PORTD, segundo
ldi estado, 4
salir_s1:
rjmp ret_to_main

segundo2: 
cpi input, 10		; Checamos si el input es mayor a 10 (si presiono # o *)
brsh ret_to_main 
or segundo, input
out PORTD, segundo
ldi estado, 5		; Estado muerto, no hara nada hasta reset
cpi operacion, 11	; -
breq resta
cpi operacion, 12	; +
breq suma
rjmp ret_to_main	; En teoría nunca toca esta línea

resta:
rcall decodificar
cp u1, u2
brlo carry_resta
rjmp acabar_resta
carry_resta:		; Simulamos un carry para resta
dec d1
ldi r16, 10
add u1, r16
acabar_resta:
sub u1, u2
sub d1, d2
rjmp output

suma:
rcall decodificar
add u1, u2
cpi u1, 10
brge carry_suma
rjmp acabar_suma
carry_suma:
subi u1, 10			; si hubo carry, a fuerzas es un 1
inc d1
acabar_suma:
add d1, d2
rjmp output

decodificar:
; Decodificamos el primero
ldi d1, 0b1111_0000	; mascara de bits (decenas)
and d1, primero
swap d1
ldi u1, 0b0000_1111	; mascara de bits (undidades)
and u1, primero
; Decodificamos el segundo
ldi d2, 0b1111_0000	; mascara de bits (decenas)
and d2, segundo
swap d2
ldi u2, 0b0000_1111	; mascara de bits (undidades)
and u2, segundo
ret

output:
mov r16, d1
swap r16
or r16, u1
out PORTB, r16
rjmp ret_to_main

reset_calc_button:
rcall retardo			; Quitar rebote
sbic PINA, 7			; Si no esta presionado, fue bounce
rjmp main
rjmp reset_calc			; Incluye traba

reset_calc:
ldi estado, 0
ldi primero, 0
ldi segundo, 0
out PORTB, primero		; Respuesta a 0
out PORTC, primero
out PORTD, segundo
ldi r16, 0b1111_1111	; Limpiar las entradas
out PORTA, r16
rjmp ret_to_main

ret_to_main:			; regresar a main despues de la traba
rcall traba
rjmp main

traba:
	;Identificar que pin es el presionado
	sbis PINA, 3
	rcall traba3
	sbis PINA, 4
	rcall traba4
	sbis PINA, 5
	rcall traba5
	sbis PINA, 6
	rcall traba6
	sbis PINA, 7
	rcall traba7
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

traba7:
	sbis PINA, 7
	rjmp traba7
	rcall retardo
	sbis PINA, 7
	rjmp traba7
	ret

retardo:				; Para el rebote (los valores parecen funcionar para 8Mhz)
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