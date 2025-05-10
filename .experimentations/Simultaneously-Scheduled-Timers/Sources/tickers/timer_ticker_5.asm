

; Timer

        ;; exports
                XDEF init_timer_5

        ;; imports

                XREF toggle_LED

                XREF queue_x
                XREF FINISHED_TASK

        ; Includes
                include 'mc9s12dp256.inc'
                include 'ticker.inc'

        ;; Timer Config
        CLOCK_COUNTER:                 EQU Simultaneous_TIME

        __isrETC_ADDRESS:              EQU __isrETC5_ADDRESS
        CLOCK_TIMER_CH:                EQU TIMER_CH5
        TC:                            EQU TC5


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


init_timer_5:

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

; - -- - -- - -- - -- - -- - --

tick_clock:

        LDAB #CLOCK_TIMER_CH
        JSR toggle_LED

        JMP FINISHED_TASK


