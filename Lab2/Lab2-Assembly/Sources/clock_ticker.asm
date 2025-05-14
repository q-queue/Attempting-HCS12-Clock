
; Timer

        ;; exports
                XDEF init_clock_timer
                XDEF toggle_clock_timer

        ;; imports
                XREF CLOCK_MODE

                XREF render_time

                XREF render_title

                XREF poll_buttons

                XREF poll_thermometer

                XREF queue_x


        ; Includes
                include 'mc9s12dp256.inc'
                include 'ticker.inc'


        ;; Timer Config
                __isrETC_ADDRESS:              EQU __isrETC4_ADDRESS
                CLOCK_TIMER_CH:                EQU TIMER_CH4
                TC:                            EQU TC4
                NEXT_TIMER_TRIGGER:            EQU TEN_MS

                TCTL:                          EQU TCTL1      ;; Timer Control Logic Register 1 for CH4
                TCTL_MODE:                     EQU $03        ;; Lower two bits are specific for CH4

; - -- - -- - -- - -- - -- - -- - -- - --

; RAM: Data
.data: SECTION

        ;; Counter Config

                ;; MACROS defined in ticker.inc

        ;; no UPPER letters in the counter name!
                ;; Seems to breakdown MACROS!

        ;; A Counter Definition:
                ;; A counter ticks down to zero from a staring value
                ;; A counter is being decremented by calling DEC_RESET on it
                ;; If no rest is triggered the counter skips to a pre defined label
                ;; On rests the counter goes back to staring value
                ;; An action is triggered on reset



        ;; Independent Counters: n * NEXT_TIMER_TRIGGER

                DEFINE_COUNTER clock,            100

                DEFINE_COUNTER polling,          20

                DEFINE_COUNTER lcd_time_line,    20     ;; 5 FPS

                DEFINE_COUNTER thermometer,      50

        ;; Dependent Counters: n * dependency ticks
                ;; should be less frequent

                ;; build on top of lcd_time_line.
                DEFINE_COUNTER lcd_title,        50
                ;; e.g. lcd_title timer will be: 20 * 50 * 10ms = 10_000ms

        ;; Counter dependency behavior is defined in the interrupt service routine!

; - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - --

; ROM: Data
.const: SECTION

; ROM: Interrupt Vector Table Entry
.vect: SECTION
        ORG  __isrETC_ADDRESS
        DC.W isrETC

; - -- - -- - -- - -- - -- - -- - -- - --

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

        RESET_COUNTER clock

        RESET_COUNTER lcd_time_line
        RESET_COUNTER lcd_title
        RESET_COUNTER thermometer

        RESET_COUNTER polling

        ;; Start Timer
        BCLR TCTL, #TCTL_MODE

        RTS

; - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - --

toggle_clock_timer:

        ;; Just resets the clock to start of the second

        RESET_COUNTER clock

        RTS

; - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - --

;; Interrupt Service Routine

isrClock:
isrETC:

        LDD TC
        ADDD #NEXT_TIMER_TRIGGER
        STD TC

        BSET TFLG1, #CLOCK_TIMER_CH

polling_trigger:

        DEC_RESET polling, clock_trigger

        JSR poll_buttons 

clock_trigger:

        DEC_RESET clock, thermometer_trigger

        LDX CLOCK_MODE
        JSR X

thermometer_trigger:

        DEC_RESET thermometer, render_time_trigger

        LDX #poll_thermometer
        JSR queue_x

render_time_trigger:

        DEC_RESET lcd_time_line, return_interrupt ;; Chained Counter!
        ;; Skips whats below without Reset!!

        LDX #render_time
        JSR queue_x

        render_title_trigger:

                ;; ticks once when lcd_time_line resets.
                        ;; actual timer is n * lcd_time_line
                        ;; dependent counter!

                DEC_RESET lcd_title, return_interrupt

                LDX #render_title
                JSR queue_x

return_interrupt        RTI

