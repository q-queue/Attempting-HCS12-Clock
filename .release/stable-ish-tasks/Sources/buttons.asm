
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

        ;; Assembler Detectives

        ;; Assembler Detectives

                ;; CHANGE_MODE_BUTTON
                SW2:    EQU 8

                ; Increment Hours
                SW3:    EQU 4

                ; Increment Minutes
                SW4:    EQU 2

                ; Increment Seconds
                SW5:    EQU 1



                SW7:    EQU 128

                buttons_increment_mask:        EQU   SW3 | SW4 | SW5


.data: SECTION

        ticker:             DS.B 1

        enabled_buttons:    DS.B 1
        buttons_state:      DS.B 1

        BLOCK_INPUT: MACRO
                        MOVB PIEH, enabled_buttons
                        MOVB #0, PIEH
                ENDM


.init: SECTION

init_buttons:

        ;; Data Direction Direction Register
        MOVB #$00, DDRH      ; Configure Port H as input.

        MOVB #0, enabled_buttons

        BSET enabled_buttons, #SW2
        BSET enabled_buttons, #SW7
        

        RTS

poll_buttons:


        LDAB PTH

        IFDEF _HCS12_SERIALMON
                COMB
        ENDIF

        ANDB enabled_buttons    ;; pressing more button at once should still mask the disabled ones
        STAB buttons_state      ;; just convenient

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

        RTS

; - -- - -- - -- - -- - -- - --

second_button:
inc_secondes:

    INC seconds
    LDAB seconds
    CMPB #60

    BLO incremented

    MOVB #0, seconds     ;; overflow

    RTS

; - -- - -- - --

minute_button:
inc_minutes:

    INC minutes
    LDAB minutes
    CMPB #60

    BLO incremented

    MOVB #0, minutes     ;; overflow

incremented:
    RTS

; - -- - -- - --

hour_button:
inc_hours:

    INC hours
    LDAB hours
    CMPB #24

    BLO incremented

    MOVB #0, hours     ;; overflow

    RTS



