
; Clock

        ;; exports

                XDEF init_clock

                XDEF tick_clock              ; defined in clock_buttons as poll_clock_mode

                XDEF switch_clock_mode

                XDEF seconds, minutes, hours          ;; recipe for disaster

        ;; imports

                XREF init_LED
                XREF init_clock_timer
                XREF init_thermometer
                XREF init_render
                XREF init_polling_timer

                XREF toggle_clock_timer

                XREF render_LCD

                XREF queue_x
                XREF FINISHED_TASK

        ; Includes
                include 'mc9s12dp256.inc'


; RAM: Data
.data: SECTION

seconds:       DS.B 1
minutes:       DS.B 1
hours:         DS.B 1


CLOCK_MODE:         DS.W 1
NEXT_MODE:          DS.W 1

INIT_CLOCK_MODE:    DS.W 1
INIT_NEXT_MODE:     DS.W 1



; - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - --

; ROM: Data
.const: SECTION

STARING_SECONDS:        EQU 58
STARING_MINUTES:        EQU 59
STARING_HOURS:          EQU 23

.init: SECTION

init_clock:

        MOVB #STARING_SECONDS, seconds
        MOVB #STARING_MINUTES, minutes
        MOVB #STARING_HOURS, hours

        MOVW #ticking_mode, CLOCK_MODE
        MOVW #polling_mode, NEXT_MODE

        MOVW #init_ticking_mode, INIT_CLOCK_MODE
        MOVW #init_polling_mode, INIT_NEXT_MODE

        JSR init_LED
        JSR init_thermometer
        JSR init_polling_timer
        JSR init_render
        JSR init_clock_timer

        PSHX

        LDX INIT_CLOCK_MODE
        JSR queue_x

        LDX CLOCK_MODE
        JSR queue_x

        PULX

        RTS


; - -- - -- - -- - -- - --

switch_clock_mode:

        JSR toggle_clock_timer          ;; only reset timer of the start of 1 second

        LDX INIT_NEXT_MODE
        MOVW INIT_CLOCK_MODE, INIT_NEXT_MODE

        STX INIT_CLOCK_MODE

        JSR queue_x

        LDX NEXT_MODE
        MOVW CLOCK_MODE, NEXT_MODE

        STX CLOCK_MODE

        JSR queue_x

        RTS

; - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - --

init_ticking_mode:

        MOVB #$00, PORTB

        JMP FINISHED_TASK

ticking_mode:
        ;; toggle LED 0 on/off
        LDAB PORTB
        EORB #1
        STAB PORTB

        inc_secondes:

                INC seconds
                LDAB seconds
                CMPB #60

                BLO incremented

                MOVB #0, seconds     ;; overflow

        inc_minutes:

                INC minutes
                LDAB minutes
                CMPB #60

                BLO incremented

                MOVB #0, minutes     ;; overflow

        inc_hours:

                INC hours
                LDAB hours
                CMPB #24

                BLO incremented

                MOVB #0, hours     ;; overflow

        incremented:
                JMP FINISHED_TASK

; - -- - -- - -- - -- - --

init_polling_mode:

        MOVB #$80, PORTB

        JMP FINISHED_TASK

polling_mode:                   ;; polling is done elsewhere
        JMP FINISHED_TASK

; - -- - -- - -- - -- - --

tick_clock:
run_clock_mode:
        LDX CLOCK_MODE
        JMP X
