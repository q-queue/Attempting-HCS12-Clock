
; LED

        ;; exports
                XDEF init_LED

                XDEF toggle_LED

        ; Includes
                include 'mc9s12dp256.inc'


; ROM: Code
.init: SECTION

init_LED:

        MOVB #$FF, DDRB         ;; Setup port B as an output Port, Data Direction Register
        MOVB #$00, PORTB        ;; initial LED State

        RTS

; - -- - -- - -- - -- - -- - --

    ; TASKS

toggle_LED:

        ;; reads mask from registers B

        EORB PORTB
        STAB PORTB

        RTS

