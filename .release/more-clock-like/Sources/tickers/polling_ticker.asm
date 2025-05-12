
; Polling Timer

        ;; exports
                XDEF init_polling_timer

        ;; imports
                XREF seconds, minutes, hours

                XREF switch_clock_mode
                XREF toggle_am_pm

                XREF queue_x

        ; Includes
                include 'mc9s12dp256.inc'
                include 'ticker.inc'

        ; Timer Config

        ENTPRELLER_TIMER:              EQU 56250        ;; 340ms

        COUNTER:                       EQU 3


        __isrETC_ADDRESS:               EQU __isrETC0_ADDRESS
        POLLING_TIMER_CH:               EQU TIMER_CH0
        TC:                             EQU TC0

; - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - --

        ;; Assembler Detectives

                ;; CHANGE_MODE_BUTTON
                SW2:    EQU 1

                ; Increment Hours
                SW3:    EQU 2

                ; Increment Minutes
                SW4:    EQU 4

                ; Increment Seconds
                SW5:    EQU 8

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



; ROM: Data
.const: SECTION

.vect: SECTION
        ORG  __isrETC_ADDRESS
        DC.W isrETC

; ROM: Code
.init: SECTION


init_polling_timer:

        init_buttons:

                ;; Data Direction Direction Register
                MOVB #$00, DDRH      ; Configure Port H as input.

                MOVB #0, enabled_buttons

                BSET enabled_buttons, #SW2
                BSET enabled_buttons, #SW7

        ;; Setup Prescale Factor
        BSET TSCR2, #TICKERS_PRESCALE_DIVIDER

        ;; Enable Timer Unit
        MOVB #ENABLE_TIMER_UNIT, TSCR1

        ;; Select Output Compare Mode
        BSET TIOS, #POLLING_TIMER_CH

        ;; Enable Interrupts
        BSET TIE, #POLLING_TIMER_CH

        MOVB #COUNTER, ticker

        BCLR TCTL1, #POLLING_TIMER_CH

        RTS


; - -- - -- - -- - -- - -- - --

isrPolling:
isrETC:

        LDD TC
        ADDD #ENTPRELLER_TIMER
        STD TC

        BSET TFLG1, #POLLING_TIMER_CH

        DEC ticker

        BNE poll
        RTI

poll:
        MOVB #COUNTER, ticker

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

        LDX #toggle_am_pm
        JSR queue_x

check_increment_buttons:

        BRSET buttons_state, #SW3, hour_button
        BRSET buttons_state, #SW4, minute_button
        BRSET buttons_state, #SW5, second_button

        RTI

; - -- - -- - -- - -- - -- - --

second_button:
inc_secondes:

    INC seconds
    LDAB seconds
    CMPB #60

    BLO incremented

    MOVB #0, seconds     ;; overflow

    RTI

; - -- - -- - --

minute_button:
inc_minutes:

    INC minutes
    LDAB minutes
    CMPB #60

    BLO incremented

    MOVB #0, minutes     ;; overflow

incremented:
    RTI

; - -- - -- - --

hour_button:
inc_hours:

    INC hours
    LDAB hours
    CMPB #24

    BLO incremented

    MOVB #0, hours     ;; overflow

    RTI



