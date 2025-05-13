
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
                __isrETC_ADDRESS:              EQU __isrETC7_ADDRESS
                CLOCK_TIMER_CH:                EQU TIMER_CH7
                TC:                            EQU TC7
                NEXT_TIMER_TRIGGER:            EQU TEN_MS

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

                DEFINE_COUNTER polling,          30

                DEFINE_COUNTER lcd_time_line,    50     ;; 2 FPS

        ;; Dependent Counters: n * dependency ticks
                ;; should be less frequent

                ;; build on top of lcd_time_line.
                DEFINE_COUNTER lcd_title,        20
                ;; e.g. lcd_title timer will be: 20 * 50 * 10ms = 10_000ms

                ;; build on top of lcd_title.   ; in prod should be even less frequent
                DEFINE_COUNTER thermometer,      1

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
        BCLR TCTL1, #CLOCK_TIMER_CH

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

polling_time_countdown:

        DEC_RESET polling, ticking_clock

        JSR poll_buttons 

ticking_clock:

        DEC_RESET clock, render_screen_time_countdown

        LDX CLOCK_MODE
        JSR X


render_screen_time_countdown:

        DEC_RESET lcd_time_line, return_interrupt ;; Chained Counter!
        ;; Skips whats below without Reset!!

        QUEUE_TASK render_time

render_screen_title_countdown:

        ;; ticks once when lcd_time_line resets.
                ;; actual timer is n * lcd_time_line
                ;; dependent counter!

        DEC_RESET lcd_title, return_interrupt

        QUEUE_TASK render_title

poll_thermometer_countdown:

        ;; ticks only once when lcd_title resets
        ;; multiplied by the title timer ; ;; in sequence with render_screen_title_countdown

        DEC_RESET thermometer, return_interrupt

        QUEUE_TASK poll_thermometer

return_interrupt        RTI

