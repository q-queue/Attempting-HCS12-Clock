
; Timer

        ;; exports
                XDEF init_clock_timer
                XDEF toggle_clock_timer

        ;; imports
                XREF CLOCK_MODE

                XREF render_time

                XREF render_title
                
                XREF init_buttons
                XREF poll_buttons

                XREF poll_thermometer

                XREF queue_x
                XREF FINISHED_TASK

        ; Includes
                include 'mc9s12dp256.inc'
                include 'ticker.inc'


        ;; Timer Config
        CLOCK_COUNTER:                 EQU 100

        LCD_TIME_COUNTER:              EQU 25

        LCD_TITLE_COUNTER:             EQU 5                   ;; n * LCD_TIME_COUNTER

        Thermometer_COUNTER:           EQU 1                   ;; should be less frequent
        
        Polling_COUNTER:               EQU 20

        __isrETC_ADDRESS:              EQU __isrETC7_ADDRESS
        CLOCK_TIMER_CH:                EQU TIMER_CH7
        TC:                            EQU TC7


; RAM: Data
.data: SECTION

        polling_ticker:        DS.B 1

        clock_ticker:          DS.B 1

        lcd_time_ticker:       DS.B 1
        lcd_title_ticker:      DS.B 1

        thermometer_ticker:    DS.B 1

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

        MOVB #LCD_TIME_COUNTER, lcd_time_ticker
        MOVB #LCD_TITLE_COUNTER, lcd_title_ticker
        MOVB #Thermometer_COUNTER, thermometer_ticker
        
        MOVB #Polling_COUNTER, polling_ticker
        JSR init_buttons

        ;; Start Timer
        BCLR TCTL1, #CLOCK_TIMER_CH

        RTS

; - -- - -- - -- - -- - -- - --


toggle_clock_timer:
        ;; Just resets the clock to the 10

        PSHD

        MOVB #0, clock_ticker

        PULD

        RTS

; - -- - -- - -- - -- - -- - --

isrClock:
isrETC:

        LDD TC
        ADDD #TEN_MS
        STD TC
        
        BSET TFLG1, #CLOCK_TIMER_CH

polling_time_countdown:

        DEC polling_ticker
        
        BNE ticking_clock
        
        MOVB #Polling_COUNTER, polling_ticker
        
        JSR poll_buttons 

ticking_clock:

        DEC clock_ticker

        BNE render_screen_time_countdown

        MOVB #CLOCK_COUNTER, clock_ticker                   ;; reset timer multiplier

        LDX CLOCK_MODE
        JSR queue_x


render_screen_time_countdown:

        DEC lcd_time_ticker
        BNE return_interrupt

        MOVB #LCD_TIME_COUNTER, lcd_time_ticker                   ;; reset timer multiplier

        LDX #render_time
        JSR queue_x

render_screen_title_countdown:

        DEC lcd_title_ticker
        BNE return_interrupt

        MOVB #LCD_TITLE_COUNTER, lcd_title_ticker                   ;; reset timer multiplier

        LDX #render_title
        JSR queue_x

poll_thermometer_countdown:   ;; multiplied by the title timer ; ;; in sequence with render_screen_title_countdown

        DEC thermometer_ticker
        BNE return_interrupt

        MOVB #Thermometer_COUNTER, thermometer_ticker

        LDX #poll_thermometer
        JSR queue_x

return_interrupt        RTI

