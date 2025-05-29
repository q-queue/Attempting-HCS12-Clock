
; Blinking Lights LED Timer Example


        ; Exports
                XDEF main, Entry

        ; Imports

                XREF initLCD
                XREF initLED
                XREF init_scheduler, queue_task_b

                XREF writeLine

; import symbols
        XREF __SEG_END_SSTACK           ; End of stack

; include derivative specific macros
        INCLUDE 'mc9s12dp256.inc'           

; RAM: Data
.data: SECTION

; ROM: Data
.const: SECTION

__A__:  DC.B "                                  A", 0

__A_END:    EQU *

__A:       EQU     __A_END - 2

__B__:  DC.B "                                  B", 0

__B_END:    EQU *

__B:       EQU     __B_END - 2

; ROM: Code
.init: SECTION

main:
Entry:

        LDS #__SEG_END_SSTACK

        JSR initLED
        JSR initLCD


        CLI                    ; enable interrupts


        LDX #task_b
        JSR queue_task_b

        JSR init_scheduler

        BRA task_a

mained_loop:
        ORCC  #$0F        
        LDD #$00FF
        LDX #2
        LDY #3

        
        BRA mained_loop
         
        

        BRA task_c             ;; why not
        BRA task_b             ;; why not
        BRA task_a             ;; why not


; - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - --

delay_x:          EQU 500
delay_y:          EQU 4000

delay:

        PSHX
        PSHY

        LDX #delay_x

        y_delay:
                LDY #delay_y

                stay:       DBNE Y, stay

                DBNE X, y_delay

        PULY
        PULX

        RTS

; - -- - -- - -- - -- - -- - -- - 

A_LCD_LINE:     EQU 0

task_a:

        LDAB #A_LCD_LINE
        LDAA #0         ;; offset index of A
        LDX #__A

render_a:

        CMPA #16
        BHI task_a      ;; reset

        JSR writeLine

        JSR delay

        LEAX 1, -X
        INCA

        BRA render_a


; - -- - -- - -- - -- - -- - -- - 

B_LCD_LINE:     EQU 1

task_b:

        LDAB #B_LCD_LINE
        LDAA #0         ;; offset index of A
        LDX #__B

render_b:

        CMPA #16
        BHI task_b      ;; reset
        JSR writeLine
        JSR delay
        LEAX 1, -X
        INCA

        BRA render_b


; - -- - -- - -- - -- - -- - -- - 

task_c:

        LDAB #0

blink:

        STAB PORTB

        INCB

        LDX #500

        c_y_delay:
                LDY #4000

                c_stay:       DBNE Y, c_stay

                DBNE X, c_y_delay

        BRA blink
