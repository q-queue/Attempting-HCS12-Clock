
; Clock Buttons

        ;; exports
                XDEF init_buttons

                XDEF poll_clock_mode

                XDEF buttons_mask
                XDEF buttons_increment_mask

        ;; imports

                XREF seconds, minutes, hours

                XREF switch_clock_mode
                XREF run_clock_mode

                XREF toggle_am_pm

                XREF queue_x
                XREF FINISHED_TASK

        ; Includes
                include 'mc9s12dp256.inc'
;
;        ;; Assembler
;                IFDEF  SIMULATOR
;
;                        ;; Branch if not pressed
;                        BR_NOT_PRESSED:  MACRO
;                                BRSET  \1, \2, \3
;                                ENDM
;
;                        ;; Branch if pressed
;                        BR_BUTTON_PRESSED:  MACRO
;                                BRCLR  \1, \2, \3
;                                ENDM
;
;                ELSE
;
;                        ;; Branch if not pressed
;                        BR_NOT_PRESSED:  MACRO
;                                BRCLR  \1, \2, \3
;                                ENDM
;
;                        ;; Branch if pressed
;                        BR_BUTTON_PRESSED:  MACRO
;                                BRSET  \1, \2, \3
;                                ENDM
;
;                ENDIF
;
; - -- - -- - -- - -- - -- - --

; RAM: Data
.data: SECTION
        buttons_mask:       DS.B 1
        buttons_state:      DS.B 1

        ;; CHANGE_MODE_BUTTON
        SW2:    EQU 1

        ; Increment Hours
        SW3:    EQU 2

        ; Increment Minutes
        SW4:    EQU 4

        ; Increment Seconds
        SW5:    EQU 8

        SW7:    EQU 128

        buttons_increment_mask: EQU $E


        IFDEF  SIMULATOR

                POLL_BUTTONS: MACRO
                        LDAB PTH
                        COMB
                        ANDB buttons_mask
                        STAB buttons_state
                        ENDM

        ELSE

                POLL_BUTTONS: MACRO
                        LDAB PTH
                        ANDB buttons_mask
                        STAB buttons_state
                        ENDM

        ENDIF


; ROM: Data
.const: SECTION

.init: SECTION

init_buttons:

        MOVB  #$00, DDRH                ; Port H as inputs

        MOVB  #0, buttons_mask
        BSET buttons_mask, #SW2
        BSET buttons_mask, #SW7

        RTS


; - -- - -- - -- - -- - -- - --

poll_clock_mode:

        ;; two possible outcomes
                ;; no switch mode request -> just run mode
                ;; switch mode first and then run mode

        POLL_BUTTONS

        BRCLR buttons_state, #SW2, poll_hours_mode

        LDX #switch_clock_mode
        JSR queue_x

poll_hours_mode:

        BRCLR buttons_state, #SW7, queue_buttons_polling

        LDX #toggle_am_pm
        JSR queue_x

queue_buttons_polling:

        LDX #poll_buttons
        JSR queue_x

        JMP FINISHED_TASK

; - -- - -- - -- - -- - -- - --

poll_buttons:

        ;; Hours masks minutes masks seconds           1 button at a time

        POLL_BUTTONS

        BRSET buttons_state, #SW3, hour_button
        BRSET buttons_state, #SW4, minute_button
        BRSET buttons_state, #SW5, second_button

        JMP FINISHED_TASK

; - -- - -- - -- - -- - -- - --

second_button:
inc_secondes:

    INC seconds
    LDAB seconds
    CMPB #60

    BLO incremented

    MOVB #0, seconds     ;; overflow

    JMP FINISHED_TASK

; - -- - -- - --

minute_button:
inc_minutes:

    INC minutes
    LDAB minutes
    CMPB #60

    BLO incremented

    MOVB #0, minutes     ;; overflow

incremented:
    JMP FINISHED_TASK

; - -- - -- - --

hour_button:
inc_hours:

    INC hours
    LDAB hours
    CMPB #24

    BLO incremented

    MOVB #0, hours     ;; overflow

    JMP FINISHED_TASK