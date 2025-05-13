
; Blinking Lights LED Timer Example


        ; Exports
                XDEF main, Entry

        ; Imports

                XREF init_scheduler
                XREF init_clock

                XREF RUN_SCHEDULED

; import symbols
        XREF __SEG_END_SSTACK           ; End of stack

; include derivative specific macros
        INCLUDE 'mc9s12dp256.inc'           

; RAM: Data
.data: SECTION

; ROM: Data
.const: SECTION

; ROM: Code
.init: SECTION

main:
Entry:

        LDS #__SEG_END_SSTACK

        JSR init_scheduler

        JSR init_clock

        CLI                                     ; enable interrupts

        JMP RUN_SCHEDULED

