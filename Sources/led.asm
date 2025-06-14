
;
;  LED subroutines
;    - initLED
;    - setLED
;    - getLED
;    - toggleLED
;
;

; export symbols

        XDEF initLED

        XDEF setLED
        XDEF getLED
        XDEF toggleLED

; include derivative specific macros
        INCLUDE 'mc9s12dp256.inc'

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

; - -- - -- - -- - -- - --

setLED:
        ;; Overwrites PORTB with the value from register B
        STAB PORTB
        RTS

; - -- - -- - -- - -- - --

getLED:
        ;; Load the state of PORTB into register B
        LDAB PORTB
        RTS

; - -- - -- - -- - -- - --

toggleLED:

        ;; Turns the LED on/off using register B as Bit Select MASK
        ;; The MASK select which LED will be affected by setting the desired bit to 1 in the MASK

                ;; XOR is used here for bitwise negation
                ;; considering an operation with two bits:        ; e.g. 1 ^ b; 0 ^ b
                        ;; 1 negate a bit using the XOR operator        -> toggle bit
                        ;; 0 is neutral in regard to the XOR operator   -> leave as is

        PSHB

        EORB PORTB                          ;; B = B ^ PORTB;

        STAB PORTB

        PULB

        RTS


