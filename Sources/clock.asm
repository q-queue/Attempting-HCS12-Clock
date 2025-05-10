
; Clock

        ;; exports

                XDEF init_clock

                XDEF tick_clock              ; defined in clock_buttons as poll_clock_mode

                XDEF run_clock_mode
                XDEF switch_clock_mode

                XDEF seconds, minutes, hours          ;; recipe for disaster

        ;; imports

                XREF init_LED
                XREF init_clock_timer
                XREF init_polling_timer
                XREF init_thermometer
                XREF init_render
                XREF init_buttons

                XREF toggle_clock_timer

                XREF buttons_mask
                XREF buttons_increment_mask

                XREF render_LCD

                XREF drop_queue
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
        JSR init_buttons
        JSR init_render
        JSR init_clock_timer
        JSR init_polling_timer

        PSHX

        LDX INIT_CLOCK_MODE
        JSR queue_x

        LDX CLOCK_MODE
        JSR queue_x

        PULX

        RTS


; - -- - -- - -- - -- - --

switch_clock_mode:

        SEI

        JSR toggle_clock_timer
        JSR drop_queue

        LDX INIT_NEXT_MODE
        LDY INIT_CLOCK_MODE

        STX INIT_CLOCK_MODE
        STY INIT_NEXT_MODE

        JSR queue_x

        LDX NEXT_MODE
        LDY CLOCK_MODE

        STX CLOCK_MODE
        STY NEXT_MODE

        JSR queue_x

        CLI

        JMP FINISHED_TASK

; - -- - -- - -- - -- - --

init_ticking_mode:

        MOVB #$00, PORTB

        BCLR buttons_mask, #buttons_increment_mask

        JMP FINISHED_TASK

ticking_mode:
        ;; toggle LED 0
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

        BSET buttons_mask, #buttons_increment_mask

        JMP FINISHED_TASK

polling_mode:                   ;; polling is done elsewhere
        JMP FINISHED_TASK

; - -- - -- - -- - -- - --

tick_clock:
run_clock_mode:
        LDX CLOCK_MODE
        JMP X
