
; Timer

        ;; exports
                XDEF init_render_timer

        ;; imports

                XREF render_time

                XREF render_title

                XREF poll_thermometer

                XREF queue_x
                XREF FINISHED_TASK

        ; Includes
                include 'mc9s12dp256.inc'
                include 'ticker.inc'

        ; Timer Config

        LCD_TIME_COUNTER:     EQU 50

        LCD_TITLE_COUNTER:    EQU 10                    ;; n * LCD_TIME_COUNTER

        Thermometer_COUNTER:  EQU 1                   ;; should be less frequent


        __isrETC_ADDRESS:              EQU __isrETC6_ADDRESS
        LCD_TIMER_CH:                  EQU TIMER_CH6
        TC:                            EQU TC6

; RAM: Data
.data: SECTION

        lcd_time_ticker:       DS.B 1
        lcd_title_ticker:      DS.B 1

        thermometer_ticker:    DS.B 1

; ROM: Data
.const: SECTION

.vect: SECTION
        ORG __isrETC_ADDRESS
        DC.W isrETC

; ROM: Code
.init: SECTION

init_render_timer:

        ;; Setup Prescale Factor
        BSET TSCR2, #TICKERS_PRESCALE_DIVIDER

        ;; Enable Timer Unit
        MOVB #ENABLE_TIMER_UNIT, TSCR1

        ;; Select Output Compare Mode
        BSET TIOS, #LCD_TIMER_CH

        ;; Enable Interrupts
        BSET TIE, #LCD_TIMER_CH

        MOVB #LCD_TIME_COUNTER, lcd_time_ticker

        MOVB #LCD_TITLE_COUNTER, lcd_title_ticker
        
        MOVB #Thermometer_COUNTER, thermometer_ticker

        ;; Start Timer
        BCLR TCTL1, #LCD_TIMER_CH

        RTS

; - -- - -- - -- - -- - -- - --

isrLCD_TIME:
isrETC:

        LDD TC
        ADDD #TEN_MS
        STD TC

        BSET TFLG1, #LCD_TIMER_CH

        DEC lcd_time_ticker
        BNE return_interrupt

        MOVB #LCD_TIME_COUNTER, lcd_time_ticker                   ;; reset timer multiplier

        LDX #render_time
        JSR queue_x

        DEC lcd_title_ticker
        BNE return_interrupt

        MOVB #LCD_TITLE_COUNTER, lcd_title_ticker                   ;; reset timer multiplier

        LDX #render_title
        JSR queue_x

        DEC thermometer_ticker
        BNE return_interrupt

        MOVB #Thermometer_COUNTER, thermometer_ticker

        LDX #poll_thermometer
        JSR queue_x

return_interrupt        RTI
