
; Definiciones de bits para las bombas
AGUA      BIT P2.0
NITROGENO BIT P2.1
FOSFORO   BIT P2.2
POTASIO   BIT P2.3

ORG 0000H
    LJMP INICIO

ORG 0030H
;----------------------------------------------
; Subrutina de retardo de 50 ms usando Timer 0
;----------------------------------------------
DELAY_50MIL:        
    CLR TF0
    MOV TMOD, #00000001B   ; Timer0, modo 1 (16 bits)
    MOV TH0, #3CH          ; Valores para 50 ms con 11.0592 MHz
    MOV TL0, #0B0H
    SETB TR0
ESPERAR_50MIL:
    JNB TF0, ESPERAR_50MIL
    CLR TR0
    CLR TF0
    RET

;----------------------------------------------
; Subrutina de retardo de 1 segundo (20 ciclos de 50ms)
;----------------------------------------------
DELAY_1SEG:
    MOV R7, #20
LOOP_1SEG:
    ACALL DELAY_50MIL
    DJNZ R7, LOOP_1SEG
    RET

;----------------------------------------------
; Subrutina de retardo variable en minutos
; Entrada: A = minutos a esperar
;----------------------------------------------
DELAY_MINUTOS:
    MOV R6, A            ; Guarda minutos en R6
LOOP_MINUTOS:
    MOV R5, #60          ; 60 segundos por minuto
LOOP_SEGUNDOS:
    ACALL DELAY_1SEG
    DJNZ R5, LOOP_SEGUNDOS
    DJNZ R6, LOOP_MINUTOS
    RET

;----------------------------------------------
; Programa principal
;----------------------------------------------
INICIO:
    MOV SP, #7FH
    MOV R0, #0           ; Receta actual (0, 1, 2)
    MOV P1, #01H         ; Enciende LED receta 0 (P1.0=1)
    CLR P2.0             ; Bombas apagadas
    CLR P2.1
    CLR P2.2
    CLR P2.3

;----------------------------------------------
; Bucle principal: Verifica cambio de receta y ejecuta riego
;----------------------------------------------
BUCLE_PRINCIPAL:
    ; Verificar si hay cambio de receta
    JNB P3.2, CAMBIAR_RECETA
    
    ; Ejecutar ciclo de riego según receta actual
    MOV A, R0
    CJNE A, #0, CHECK_RECETA1
    ACALL EJECUTAR_RECETA0
    SJMP ESPERAR_PROXIMA_FRECUENCIA
    
CHECK_RECETA1:
    CJNE A, #1, CHECK_RECETA2
    ACALL EJECUTAR_RECETA1
    SJMP ESPERAR_PROXIMA_FRECUENCIA
    
CHECK_RECETA2:
    ACALL EJECUTAR_RECETA2

ESPERAR_PROXIMA_FRECUENCIA:
    ; Esperar según la frecuencia de la receta actual
    MOV A, R0
    CJNE A, #0, FREQ_RECETA1
    MOV A, #30           ; Receta 0: cada 30 minutos
    SJMP APLICAR_FRECUENCIA

FREQ_RECETA1:
    CJNE A, #1, FREQ_RECETA2
    MOV A, #45           ; Receta 1: cada 45 minutos
    SJMP APLICAR_FRECUENCIA

FREQ_RECETA2:
    MOV A, #60           ; Receta 2: cada 60 minutos

APLICAR_FRECUENCIA:
    ACALL DELAY_MINUTOS
    SJMP BUCLE_PRINCIPAL

;----------------------------------------------
; Cambio de receta
;----------------------------------------------
CAMBIAR_RECETA:
    ; Esperar a que se suelte el botón (antirrebote)
    JB P3.2, CAMBIAR_RECETA
    
    ; Retardo antirrebote
    MOV R7, #200
DELAY_ANTIRREBOTE:
    DJNZ R7, DELAY_ANTIRREBOTE
    
    ; Cambiar receta
    INC R0
    CJNE R0, #3, ACTUALIZAR_LED
    MOV R0, #0

ACTUALIZAR_LED:
    MOV A, R0
    CJNE A, #0, LED_RECETA1
    MOV P1, #01H         ; LED receta 0 (P1.0=1)
    SJMP BUCLE_PRINCIPAL

LED_RECETA1:
    CJNE A, #1, LED_RECETA2
    MOV P1, #02H         ; LED receta 1 (P1.1=1)
    SJMP BUCLE_PRINCIPAL

LED_RECETA2:
    MOV P1, #04H         ; LED receta 2 (P1.2=1)
    SJMP BUCLE_PRINCIPAL

;----------------------------------------------
; Subrutinas de ejecución de recetas
;----------------------------------------------
EJECUTAR_RECETA0:
    ;-------------------- RECETA 0 -----------------------
    ; Frecuencia: cada 30 minutos
    ; Agua: 3s, Nitrógeno: 2s, Fósforo: 2s, Potasio: 1s
    
    ; Agua: 3s (60 ciclos)
    MOV R1, #60
    SETB AGUA
AGUA_LOOP0:
    ACALL DELAY_50MIL
    DJNZ R1, AGUA_LOOP0
    CLR AGUA

    ; Nitrógeno: 2s (40 ciclos)
    MOV R2, #40
    SETB NITROGENO
NITROGENO_LOOP0:
    ACALL DELAY_50MIL
    DJNZ R2, NITROGENO_LOOP0
    CLR NITROGENO

    ; Fósforo: 2s (40 ciclos)
    MOV R3, #40
    SETB FOSFORO
FOSFORO_LOOP0:
    ACALL DELAY_50MIL
    DJNZ R3, FOSFORO_LOOP0
    CLR FOSFORO

    ; Potasio: 1s (20 ciclos)
    MOV R4, #20
    SETB POTASIO
POTASIO_LOOP0:
    ACALL DELAY_50MIL
    DJNZ R4, POTASIO_LOOP0
    CLR POTASIO
    RET

EJECUTAR_RECETA1:
    ;-------------------- RECETA 1 -----------------------
    ; Frecuencia: cada 45 minutos
    ; Agua: 4s, Nitrógeno: 3s, Fósforo: 2s, Potasio: 2s
    
    ; Agua: 4s (80 ciclos)
    MOV R1, #80
    SETB AGUA
AGUA_LOOP1:
    ACALL DELAY_50MIL
    DJNZ R1, AGUA_LOOP1
    CLR AGUA

    ; Nitrógeno: 3s (60 ciclos)
    MOV R2, #60
    SETB NITROGENO
NITROGENO_LOOP1:
    ACALL DELAY_50MIL
    DJNZ R2, NITROGENO_LOOP1
    CLR NITROGENO

    ; Fósforo: 2s (40 ciclos)
    MOV R3, #40
    SETB FOSFORO
FOSFORO_LOOP1:
    ACALL DELAY_50MIL
    DJNZ R3, FOSFORO_LOOP1
    CLR FOSFORO

    ; Potasio: 2s (40 ciclos)
    MOV R4, #40
    SETB POTASIO
POTASIO_LOOP1:
    ACALL DELAY_50MIL
    DJNZ R4, POTASIO_LOOP1
    CLR POTASIO
    RET

EJECUTAR_RECETA2:
    ;-------------------- RECETA 2 -----------------------
    ; Frecuencia: cada 60 minutos
    ; Agua: 5s, Nitrógeno: 2s, Fósforo: 3s, Potasio: 3s
    
    ; Agua: 5s (100 ciclos)
    MOV R1, #100
    SETB AGUA
AGUA_LOOP2:
    ACALL DELAY_50MIL
    DJNZ R1, AGUA_LOOP2
    CLR AGUA

    ; Nitrógeno: 2s (40 ciclos)
    MOV R2, #40
    SETB NITROGENO
NITROGENO_LOOP2:
    ACALL DELAY_50MIL
    DJNZ R2, NITROGENO_LOOP2
    CLR NITROGENO

    ; Fósforo: 3s (60 ciclos)
    MOV R3, #60
    SETB FOSFORO
FOSFORO_LOOP2:
    ACALL DELAY_50MIL
    DJNZ R3, FOSFORO_LOOP2
    CLR FOSFORO

    ; Potasio: 3s (60 ciclos)
    MOV R4, #60
    SETB POTASIO
POTASIO_LOOP2:
    ACALL DELAY_50MIL
    DJNZ R4, POTASIO_LOOP2
    CLR POTASIO
    RET

END