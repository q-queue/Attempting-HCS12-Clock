
; export symbols
        XDEF signed_decToASCII
        XDEF unsigned_decToASCII

; Defines

; RAM: Variable data section
.data: SECTION

; ROM: Code section
.init: SECTION

;; - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - --

unsigned_decToASCII:

        ;; Writes number in D register to a String in X register as decimal representation
        ;; And number digits in Y
        ;; Don't include NULL Termination

        PSHD
        PSHX
        PSHY


write_digit:

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

                DECB

                STAA B, X      ;; write into X the value of A with offset of B; X[B] = A;

                TFR Y, D       ;; write back the whole part of division

                PULY           ;; restore Y

        DBNE Y, write_digit


        PULY
        PULX
        PULD

        RTS

;; - -- - -- - -- - -- - -- - -- - -- -

signed_decToASCII:

        ;; Requires One Extra Space for the sign bit!
        ;; Writes number in D register to a String in X register as decimal representation
        ;; And number digits in Y
        ;; Don't include NULL Termination

        PSHD    ;; must be consistent with unsigned to use common pull use
        PSHX
        PSHY

        MOVB #' ', X                    ;; assume positive

        TSTA                            ;; check if negative
        BPL positive                    ;; skip if indeed positive
        MOVB #'-', X

        COMA              ;; negate MSB
        COMB              ;; negate LSB
        ADDD #1                          ;; two's complement D = ~D +1;

positive:

        INX                             ;; extra space for sign or not

        BRA write_digit                 ;; Just a small jump nothing will go wrong

