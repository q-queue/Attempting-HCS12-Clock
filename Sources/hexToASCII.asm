
; export symbols
        XDEF hexToASCII

; Defines

; RAM: Variable data section
.data: SECTION

; ROM: Constant data
.const: SECTION

HEX_SPEAK:    DC.B  "0123456789ABCDEF", 0

; ROM: Code section
.init: SECTION

;; - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - --

a_split:
        ;; Reads from A
        ;; Tramples B!
        ;; Splits the A register across A and B with 4 bits each
        ;; A is upper 4 bits
        ;; B is lower 4

        ;; Transfer A to B
        TAB  ;; B = A;

        ;; Bitwise AND on B
        ANDB #$0F               ;; Masks upper 4 bits in B -> Sets to zeros

        ;; Logical Shift Right on A
        LSRA                    ;; discard lower 4 bits in A
        LSRA
        LSRA
        LSRA                    ;; No A >> 4!

        RTS             ;; could've been a macro

write_a_digit:
        ;; reads from A
        ;; tramples B!
        ;; modifies X!
        ;; offset into Y!

        TAB
        LDAB A, Y       ;; Y holds ASCII Numbers Representation DIctionary
        STAB 1, X+

        RTS             ;; could've been a macro

;; - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - --

hexToASCII:

        ;; writes number in D register to a String in X register as hex representation

        PSHX                            ;; preserve the stack
        PSHD
        PSHY

        MOVB #'0', 1, X+                ;; prefix
        MOVB #'x', 1, X+                ;; write and shift

        LDY #HEX_SPEAK

        PSHB                            ;; pushed on B

                JSR a_split             ;; split upper bit into upper, lower 4 bits int A, B

                PSHB

                        JSR write_a_digit     ;; write upper 4 bits of the MSB. ; Most Significant Byte

                PULA

                JSR write_a_digit             ;; write lower 4 bits from the upper byte.

        PULA                            ;; pulled on A

        JSR a_split

        PSHB

                JSR write_a_digit     ;; write upper 4 bits from LSB. ; Least Significant Byte

        PULA

        JSR write_a_digit             ;; write remaining 4 bits from the LSB

        MOVB #0, X  ;; null terminate

        ;; EACH PUSH MUST HAVE CORRESPONDING PULL!
                ;; This of course never happened to my. Just saying!
        PULY
        PULD
        PULX                            ;; restore the stack

        RTS
