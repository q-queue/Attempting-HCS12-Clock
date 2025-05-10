
; Blinking Lights LED Timer Example


        ; Exports
                XDEF main, Entry

        ; Imports
                XREF __SEG_END_SSTACK

                XREF RUN_SCHEDULED

                XREF init_scheduler
                XREF init_timers

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
        JSR init_timers

        CLI                                     ; enable interrupts


        JMP RUN_SCHEDULED

