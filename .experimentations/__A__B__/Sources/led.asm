
; LED

        ;; exports
                XDEF initLED

                XDEF toggle_LED

        ;; imports

        ; Includes
                include 'mc9s12dp256.inc'

; ROM: Code
.init: SECTION

initLED:

inti_7_Segments:

        MOVB #$0F, DDRP        ; Port P.3..0 as outputs (seven segment display control)
        MOVB #$0F, PTP         ; Turn off seven segment display

        ;; Data Direction Registry
        BSET    DDRJ, #2       ; Turns LED on for the Board
        BCLR    PTJ,  #2

        MOVB #$FF, DDRB        ;; Setup port B as an output Port
        MOVB #$00, PORTB       ;; initial LED State

        RTS

; - -- - -- - -- - -- - -- - --

toggle_LED:

        ;; Toggles LED with BIT Select Mask in B register

        LDAB PORTB
        EORB #1
        STAB PORTB

        RTS

