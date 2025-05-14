
; Timers Common Definitions

        TICKERS_PRESCALE_DIVIDER:        EQU $07
        ENABLE_TIMER_UNIT:               EQU $80

        TIMER_CH7:    EQU 128
        TIMER_CH6:    EQU 64
        TIMER_CH5:    EQU 32
        TIMER_CH4:    EQU 16
        TIMER_CH3:    EQU 8
        TIMER_CH2:    EQU 4
        TIMER_CH1:    EQU 2
        TIMER_CH0:    EQU 1

        TEN_MS:                          EQU 1875

        __TIMER_INTERRUPT_VECTOR_TABLE_BASE_ADDRESS: EQU $FFE0

                __isrETC7_ADDRESS:    EQU __TIMER_INTERRUPT_VECTOR_TABLE_BASE_ADDRESS + 0
                __isrETC6_ADDRESS:    EQU __TIMER_INTERRUPT_VECTOR_TABLE_BASE_ADDRESS + 2
                __isrETC5_ADDRESS:    EQU __TIMER_INTERRUPT_VECTOR_TABLE_BASE_ADDRESS + 4
                __isrETC4_ADDRESS:    EQU __TIMER_INTERRUPT_VECTOR_TABLE_BASE_ADDRESS + 6
                __isrETC3_ADDRESS:    EQU __TIMER_INTERRUPT_VECTOR_TABLE_BASE_ADDRESS + 8
                __isrETC2_ADDRESS:    EQU __TIMER_INTERRUPT_VECTOR_TABLE_BASE_ADDRESS + 10
                __isrETC1_ADDRESS:    EQU __TIMER_INTERRUPT_VECTOR_TABLE_BASE_ADDRESS + 12
                __isrETC0_ADDRESS:    EQU __TIMER_INTERRUPT_VECTOR_TABLE_BASE_ADDRESS + 14
                
       ;; Need to specify TCTL Register and Mode!

; - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - --

        ;; Counters Assembly Helper Mackerels

        ;; DISCLAIMER!
                ;; There more than few MACROS!
                ;; But still can be useful as a template
                ;; Provides a single failure point which could mean fix at one spot fix everywhere!

        ;; MACROS is expanded in the assembler lexical analysis phase
                ;; just strings concatenation and pattern matching

        DEFINE_COUNTER: MACRO
                ;; this needs to be inside a SECTION!
                ;; \1 must only be written in lower case letters! ; some assembler quirks
                ;; \2 must be 
                \1_countdown:      EQU    \2
                \1_ticker:         DS.B    1
                ;; to achieve even slower ticking behavior
                ;; tickers can triggered by other tickers
                        ;; most importantly this means shorter isr!
                        ;; by skipping a couple of counters.
                        ;; tickers are 1 Byte each! longer ticking time requires more BYTES.
        ENDM

        ;; e.g. DEFINE_COUNTER clock

; - -- - -- - -- - -- - -- - --

        RESET_COUNTER: MACRO
                MOVB #\1_countdown, \1_ticker
        ENDM

; - -- - -- - -- - -- - -- - --

        ;; each counter timer must have _ticker and _countdown defined!

        ;; expects a labeled timer \1 and a *relative jump label \2.
        DEC_RESET: MACRO 

                ;; triggers action on rest otherwise skips to label.
                ;; rests when tickers hits zero.
                ;; can counts down in interval of NEXT_TIMER_TRIGGER.
                ;; or by other counters if masked by another jump label above.

                DEC \1_ticker
                BNE \2
                ;; BEWARE OF LONG JUMPS! this is just 128 Byte ahead/back
                RESET_COUNTER \1
                ;; Mackerels calling Mackerels
        ENDM



