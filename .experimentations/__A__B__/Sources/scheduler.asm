
; Timer

        ;; exports
                XDEF init_scheduler
                XDEF queue_task_b

        ; Includes
                include 'mc9s12dp256.inc'

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

        DEFINE_COUNTER: MACRO
                \1_countdown:      EQU    \2
                \1_ticker:         DS.B    1
        ENDM

        ;; e.g. DEFINE_COUNTER clock

; - -- - -- - -- - -- - -- - --

        RESET_COUNTER: MACRO
                MOVB #\1_countdown, \1_ticker
        ENDM

; - -- - -- - -- - -- - -- - --

        DEC_RESET: MACRO 
                DEC \1_ticker
                BNE \2
                RESET_COUNTER \1
        ENDM

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

        DEFINE_COUNTER scheduled, 200

        STACK_SIZE:     EQU 256
                b_stack: DS.B   STACK_SIZE

        STACK_POINTER:  EQU *

next_stack_fall:    DS.W 1

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

init_scheduler:

        ;; Setup Prescale Factor
        BSET TSCR2, #TICKERS_PRESCALE_DIVIDER

        ;; Enable Timer Unit
        MOVB #ENABLE_TIMER_UNIT, TSCR1

        ;; Select Output Compare Mode
        BSET TIOS, #CLOCK_TIMER_CH

        ;; Enable Interrupts
        BSET TIE, #CLOCK_TIMER_CH


        RESET_COUNTER scheduled

       ;; Start Timer
        BCLR TCTL, #TCTL_MODE

        RTS

; - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - --

        FALL_INTO_ADDRESS: EQU STACK_POINTER -2
        FALL_FROM_ISR:     EQU STACK_POINTER -9

queue_task_b:

        STX FALL_INTO_ADDRESS

        MOVB #$C0, FALL_FROM_ISR
        MOVW #FALL_FROM_ISR, next_stack_fall

        RTS

; - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - --

;; Interrupt Service Routine

isrClock:
isrETC:

        LDD TC
        ADDD #NEXT_TIMER_TRIGGER
        STD TC

        BSET TFLG1, #CLOCK_TIMER_CH

        DEC_RESET scheduled, return_interrupt

context_switch:

        LDY next_stack_fall

        TSX
        STX next_stack_fall

        TFR Y, X
        TXS

return_interrupt        RTI
