
; Timer

        ;; exports
                XDEF init_clock_timer
                XDEF toggle_clock_timer

        ;; imports
                XREF tick_clock

                XREF queue_x
                XREF FINISHED_TASK

        ; Includes
                include 'mc9s12dp256.inc'
                include 'ticker.inc'


        ;; Timer Config
        CLOCK_COUNTER:                 EQU 100

        __isrETC_ADDRESS:              EQU __isrETC7_ADDRESS
        CLOCK_TIMER_CH:                EQU TIMER_CH7
        TC:                            EQU TC7


; RAM: Data
.data: SECTION

        clock_ticker:        DS.B 1

; ROM: Data
.const: SECTION

.vect: SECTION
        ORG  __isrETC_ADDRESS
        DC.W isrETC

; ROM: Code
.init: SECTION


init_clock_timer:

        ;; Setup Prescale Factor
        BSET TSCR2, #TICKERS_PRESCALE_DIVIDER

        ;; Enable Timer Unit
        MOVB #ENABLE_TIMER_UNIT, TSCR1

        ;; Select Output Compare Mode
        BSET TIOS, #CLOCK_TIMER_CH

        ;; Enable Interrupts
        BSET TIE, #CLOCK_TIMER_CH

        MOVB #CLOCK_COUNTER, clock_ticker

        ;; Start Timer
        BCLR TCTL1, #CLOCK_TIMER_CH

        RTS

; - -- - -- - -- - -- - -- - --


toggle_clock_timer:
        ;; Switch timer off/on

        PSHD

        LDAB TIE
        EORA #CLOCK_TIMER_CH            ;; Disable/Enable Interrupts
        STAB TIE

        LDD TC
        ADDD #TEN_MS
        STD TC

        PULD

        RTS

; - -- - -- - -- - -- - -- - --

isrClock:
isrETC:

        LDD TC
        ADDD #TEN_MS
        STD TC

        BSET TFLG1, #CLOCK_TIMER_CH

        DEC clock_ticker

        BNE return_interrupt

        MOVB #CLOCK_COUNTER, clock_ticker                   ;; reset timer multiplier

        LDX #tick_clock
        JSR queue_x

return_interrupt        RTI

