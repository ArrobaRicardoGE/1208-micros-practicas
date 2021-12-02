;*******************
; Examen Final Microcontroladores I
;
; Created: 30/11/2021
; Author : Ricardo Antonio Gutiérrez Esparza (21)
;*******************

/* TABLA VALORES PARA PWM
0CR0	| Tiempo en alto	| Ángulo	| Valores
123		| 0.000992			| 0			|  0 -  9		
127		| 0.001024			| 20		| 10 - 29		
131		| 0.001056			| 40		| 30 - 49		
135		| 0.001088			| 60		| 50 - 69		
139		| 0.001120			| 80		| 70 - 89
143		| 0.001152			| 100		| 90 - 99				

*/

.include "m16adef.inc"     
   
;*******************
;Registros (aquí pueden definirse)
.def new=r17		; Guarda el nuevo valor recibido por el teclado
.def temporal1=r30	; Temporales, usos múltpiles
.def temporal2=r31
.def estado=r18		; Guarda el estado en el que se encuentra el sistema. 1, 2 -> leer valor, 3 -> esperando accionar, 4 -> accionado
.def d_low=r19		; Guarda las unidades del valor deseado
.def d_high=r20		; Guarda las decenas del valor deseado

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

; Configuración de PWM
ldi r16, 0b01_10_1_011	; Prescaler 64, modo FastPWM
out TCCR0, r16
ldi r16, 123			; Inicializamos en 0
out OCR0, r16

; Configuración de puertos

ldi r16, 255			; Salidas
out DDRB, r16
out DDRC, r16
out DDRD, r16

ldi r16, 0b0000_1111	; Filas salidas, columnas entradas (respecto al micro)
out DDRA, r16			; Puerto A para teclado matricial
ldi r16, 0b1111_1111	; Teclado con pull up
out PORTA, r16	

ldi estado, 1			; Inicializamos el estado

main:
; Lectura de teclado
ldi new, 10
;Primera fila
ldi r16, 0b1111_1110
out PORTA, r16
nop
nop
nop
sbis PINA, 6 ;#
ldi new, 11
sbis PINA, 5 ;0
ldi new, 0
sbis PINA, 4 ;*
ldi new, 12
cpi new, 10
brne procesar
;Segunda fila
ldi r16, 0b1111_1101
out PORTA, r16
nop
nop
nop
sbis PINA, 6 ;9
ldi new, 9
sbis PINA, 5 ;8
ldi new, 8
sbis PINA, 4 ;7
ldi new, 7
cpi new, 10
brne procesar
;Tercera fila
ldi r16, 0b1111_1011
out PORTA, r16
nop
nop
nop
sbis PINA, 6 ;6
ldi new, 6
sbis PINA, 5 ;5
ldi new, 5
sbis PINA, 4 ;4
ldi new, 4
cpi new, 10
brne procesar
;Cuarta fila
ldi r16, 0b1111_0111
out PORTA, r16
nop
nop
nop
sbis PINA, 6 ;3
ldi new, 3
sbis PINA, 5 ;2
ldi new, 2
sbis PINA, 4 ;1
ldi new, 1
cpi new, 10
brne procesar
rjmp main

procesar:
cpi new, 11			; Clear (#)
breq clear
cpi estado, 4		; Si ya actué, espero clear
breq proc_to_main
cpi estado, 3		; Si ya tengo digitos cargados, espero actuar
brne digitos
cpi new, 12			; Actuar (*) 
breq actuar
rjmp to_main
digitos:
cpi new, 10			; Quitar el asterisco
brge proc_to_main
mov d_high, d_low
mov d_low, new
inc estado
rjmp output
proc_to_main:
rjmp to_main

clear:
ldi d_low, 0
ldi d_high, 0
ldi estado, 1
ldi r16, 123
out OCR0, r16
out PORTC, d_low
out PORTD, d_high
rjmp to_main

output:
; Voltear bits para salida
ldi temporal1, 0
sbrc d_low, 0
inc temporal1
lsl temporal1
sbrc d_low, 1
inc temporal1
lsl temporal1
sbrc d_low, 2
inc temporal1
lsl temporal1
sbrc d_low, 3
inc temporal1
out PORTC, temporal1

ldi temporal1, 0
sbrc d_high, 0
inc temporal1
lsl temporal1
sbrc d_high, 1
inc temporal1
lsl temporal1
sbrc d_high, 2
inc temporal1
lsl temporal1
sbrc d_high, 3
inc temporal1
out PORTD, temporal1
rjmp to_main

actuar:
inc estado
; En lugar de preguntar por el valor completo, solo me fijo en las decenas
; ----
; NOTA: Si se quisiera juntar en un solo registro el valor, aquí es el lugar
; para hacerlo. Habría que sumar 10 veces d_high y una vez d_low. Mi solución
; no lo necesita, por eso no lo implementé.
ldi r16, 0
cp r16, d_high
brge cero
ldi r16, 2
cp r16, d_high
brge veinte
ldi r16, 4
cp r16, d_high
brge cuarenta
ldi r16, 6
cp r16, d_high
brge sesenta
ldi r16, 8
cp r16, d_high
brge ochenta
rjmp cien

; Valores obtenidos en la tabla
cero:
ldi r16, 123
out OCR0, r16
rjmp to_main
veinte:
ldi r16, 127
out OCR0, r16
rjmp to_main
cuarenta:
ldi r16, 131
out OCR0, r16
rjmp to_main
sesenta:
ldi r16, 135
out OCR0, r16
rjmp to_main
ochenta:
ldi r16, 139
out OCR0, r16
rjmp to_main
cien:
ldi r16, 143
out OCR0, r16
rjmp to_main

to_main:
rcall traba
rjmp main

retardo:	
	ldi temporal1, 0xAF
	ciclo1:
		dec temporal1
		breq salir
		ldi temporal2, 0xAF
	ciclo2:
		dec temporal2
		breq ciclo1
		rjmp ciclo2 
salir:
ret

traba:
	;Identificar qué pin es el presionado
	sbis PINA, 6
	rcall traba6
	sbis PINA, 5
	rcall traba5
	sbis PINA, 4
	rcall traba4
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



