
;
;
;    Busy Loop Delay
;
;    All function preserve the used registers
;
;
;

; export symbols

        XDEF delay_O_5sec


; Assembler Constants

DELAY_0_5_MS:   EQU 500
CYCLES_PER_MS:  EQU 8000

.init: SECTION                          ;; defines a relocatable code section ; must be called .init

;; - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - --

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;; Delay Subroutine ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


delay_O_5sec:

;; Fixed time delay function

        PSHX                            ;; save register to stack
        PSHY

        LDX #DELAY_0_5_MS

        delay_x:
                LDY #CYCLES_PER_MS

                delay_y:
                        DBNE Y, delay_y

                DBNE X, delay_x

        PULY
        PULX                            ;; restore stack

        RTS
