
; Polling Timer

        ;; exports
                XDEF init_polling_timer

        ;; imports
                XREF poll_clock_mode

                XREF queue_x
                XREF FINISHED_TASK

        ; Includes
                include 'mc9s12dp256.inc'
                include 'ticker.inc'

        ; Timer Config

        POLLING_COUNTER:                EQU 50

        __isrETC_ADDRESS:               EQU __isrETC0_ADDRESS
        POLLING_TIMER_CH:               EQU TIMER_CH0
        TC:                             EQU TC0


; RAM: Data
.data: SECTION

        polling_ticker:        DS.B 1

; ROM: Data
.const: SECTION

.vect: SECTION
        ORG  __isrETC_ADDRESS
        DC.W isrETC

; ROM: Code
.init: SECTION


init_polling_timer:

        ;; Setup Prescale Factor
        BSET TSCR2, #TICKERS_PRESCALE_DIVIDER

        ;; Enable Timer Unit
        MOVB #ENABLE_TIMER_UNIT, TSCR1

        ;; Select Output Compare Mode
        BSET TIOS, #POLLING_TIMER_CH

        ;; Enable Interrupts
        BSET TIE, #POLLING_TIMER_CH

        MOVB #POLLING_COUNTER, polling_ticker

        ;; Start Timer
        BCLR TCTL1, #POLLING_TIMER_CH

        RTS


; - -- - -- - -- - -- - -- - --

isrPolling:
isrETC:

        LDD TC
        ADDD #TEN_MS
        STD TC

        BSET TFLG1, #POLLING_TIMER_CH

        DEC polling_ticker

        BNE return_interrupt

        MOVB #POLLING_COUNTER, polling_ticker                   ;; reset timer multiplier

        LDX #poll_clock_mode
        JSR queue_x

return_interrupt        RTI

