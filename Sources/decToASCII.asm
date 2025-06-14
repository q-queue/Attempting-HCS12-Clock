
; export symbols
        XDEF decToASCII

; Defines

; RAM: Variable data section
.data: SECTION

; ROM: Code section
.init: SECTION

;; - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - --

write_digit:

        ;; Reads number stored in D
        ;; Writes at index X with offset Y
        ;; Writes D with the result of the integer division by 10
        ;; only modifies D!

        PSHY
        PSHX

        LDX #10

        IDIV           ;; X = D / X; with remainder in D.

        ;; we want offset in B and digit in A

        TBA            ;; transfer the rest B to A; B is needed for to hold lower byte of Y; A is zero; remainder is less than 10.

        ADDA #'0'      ;; shift remainder by ASCII value of '0'

        TFR Y, B       ;; lower byte for the offset

        TFR X, Y       ;; Y should hold the whole part of division to be transferred into D later

        PULX           ;; restore X to point back to the string

        STAA B, X      ;; write into X the value of A with offset of B; X[B] = A;

        TFR Y, D       ;; write back the whole part of division

        PULY           ;; restore Y

        RTS

;; - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - --

decToASCII:

        ;; writes number in D register to a String in X register as decimal representation

        PSHX                            ;; preserve the stack
        PSHD
        PSHY

        MOVB #' ', X                    ;; assume positive

        TSTA                            ;; check if negative
        BPL positive                    ;; skip if indeed positive
        MOVB #'-', X                    ;; assume positive

        COMA           ;; negate
        COMB
        ADDD #1                          ;; two's complement D = ~D +1;

positive:

        LDY #5

        loop:
                JSR write_digit
                DBNE Y, loop

        MOVB #0, 6, X  ;; null termination

        PULY
        PULD
        PULX                            ;; restore the stack
        

        RTS
