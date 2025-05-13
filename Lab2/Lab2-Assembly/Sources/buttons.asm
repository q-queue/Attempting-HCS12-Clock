
; Polling Timer

        ;; exports
                XDEF init_buttons
                XDEF poll_buttons

        ;; imports
                XREF seconds, minutes, hours

                XREF switch_clock_mode
                XREF toggle_am_pm

        ; Includes
                include 'mc9s12dp256.inc'
                include 'mackerel.inc'

        ;; Assembler Detectives

        ;; Buttons Mapping
                ;; CHANGE_MODE_BUTTON
                SW2:    EQU $08

                ; Increment Hours
                SW3:    EQU $04

                ; Increment Minutes
                SW4:    EQU $02

                ; Increment Seconds
                SW5:    EQU $01

                SW7:    EQU $80

                        ;; just looks right in HEX

                ;; Masks buttons using assembler bitwise pre-processing

                ;; to be toggled on/off when switch mode comes up
                buttons_increment_mask:        EQU   SW3 | SW4 | SW5

                ;; needed for enabled buttons initial state.
                enabled_buttons_initial_state: EQU   SW2 | SW7

.data: SECTION

        enabled_buttons:     DS.B 1
        buttons_state:       DS.B 1


.init: SECTION

init_buttons:

        ;; Data Direction Direction Register
        MOVB #$00, DDRH      ; Configure Port H as input.

        MOVB #enabled_buttons_initial_state, enabled_buttons

        RTS

; - -- - -- - -- - -- - -- - -- - -- - --

poll_buttons:

        PSHB

        LDAB PTH

        IFNDEF SIMULATOR        ;; not a simulation! Reversed polarity.
                COMB
        ENDIF

        ANDB enabled_buttons    ;; pressing more button at once should still mask the disabled ones
        STAB buttons_state      ;; just convenient

check_switch_mode:

        BRCLR buttons_state, #SW2, check_am_pm

        LDAB enabled_buttons
        EORB #buttons_increment_mask
        STAB enabled_buttons

        JSR switch_clock_mode

check_am_pm:

        BRCLR buttons_state, #SW7, check_increment_buttons

        JSR toggle_am_pm

check_increment_buttons:

        BRSET buttons_state, #SW3, hour_button
        BRSET buttons_state, #SW4, minute_button
        BRSET buttons_state, #SW5, second_button

done_incrementing:

        PULB

        RTS

; - -- - -- - -- - -- - -- - --

second_button:
inc_secondes:

    INC seconds
    LDAB seconds
    CMPB #60

    BLO done_incrementing

    MOVB #0, seconds     ;; overflow

    BRA done_incrementing

; - -- - -- - --

minute_button:
inc_minutes:

    INC minutes
    LDAB minutes
    CMPB #60

    BLO done_incrementing

    MOVB #0, minutes     ;; overflow

    BRA done_incrementing

; - -- - -- - --

hour_button:
inc_hours:

    INC hours
    LDAB hours
    CMPB #24

    BLO done_incrementing

    MOVB #0, hours     ;; overflow

    BRA done_incrementing



