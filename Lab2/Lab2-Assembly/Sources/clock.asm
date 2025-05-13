
; Clock

        ;; exports

                XDEF init_clock

                XDEF CLOCK_MODE

                XDEF switch_clock_mode

                XDEF seconds, minutes, hours          ;; recipe for disaster

        ;; imports

                XREF init_LED
                XREF init_render
                XREF init_buttons
                XREF init_clock_timer
                XREF init_thermometer

                XREF toggle_clock_timer

                XREF render_LCD

                XREF queue_x

        ; Includes
                include 'mc9s12dp256.inc'
                include 'mackerel.inc'


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

STARING_SECONDS:        EQU 45
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
        JSR init_render
        JSR init_buttons
        JSR init_clock_timer

        PSHX

        LDX INIT_CLOCK_MODE
        JSR X

        LDX CLOCK_MODE
        JSR queue_x

        PULX

        RTS


; - -- - -- - -- - -- - --

switch_clock_mode:

        PSHX

        JSR toggle_clock_timer          ;; only reset timer of the start of 1 second

        SWAP INIT_NEXT_MODE, INIT_CLOCK_MODE

        JSR X   ;; runs X which holds INIT_NEXT_MODE after swap!

        SWAP NEXT_MODE, CLOCK_MODE

        PULX

        RTS

; - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - --

init_ticking_mode:

        MOVB #$00, PORTB

        RTS

; - -- - -- - -- - -- - -- -

ticking_mode:

        ;; toggle LED 0 on/off
        LDAB PORTB
        EORB #1
        STAB PORTB


        ;; trickle down increment operation

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
        done_incrementing:
                RTS

; - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - --

init_polling_mode:

        MOVB #$80, PORTB

        RTS

; - -- - -- - -- - -- - -- -

polling_mode:
        ;; polling is done elsewhere
        ;; just place holder for CLOCK_MODE
        RTS


