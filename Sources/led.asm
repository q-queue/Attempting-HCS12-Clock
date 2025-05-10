
; LED

        ;; exports
                XDEF init_LED

                XDEF toggle_LED0

        ;; imports
                XREF FINISHED_TASK

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

toggle_LED0:

        LDAB PORTB
        EORB #1
        STAB PORTB

        JMP FINISHED_TASK

