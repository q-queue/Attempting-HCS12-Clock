
; Timers Common Definitions

        TICKERS_PRESCALE_DIVIDER:       EQU $07
        ENABLE_TIMER_UNIT:              EQU $80

        TIMER_CH7:    EQU 128
        TIMER_CH6:    EQU 64
        TIMER_CH5:    EQU 32
        TIMER_CH4:    EQU 16
        TIMER_CH3:    EQU 8
        TIMER_CH2:    EQU 4
        TIMER_CH1:    EQU 2
        TIMER_CH0:    EQU 1

        TEN_MS:       EQU 1875

        __TIMER_INTERRUPT_VECTOR_TABLE_BASE_ADDRESS: EQU $FFE0

                __isrETC7_ADDRESS:    EQU __TIMER_INTERRUPT_VECTOR_TABLE_BASE_ADDRESS + 0
                __isrETC6_ADDRESS:    EQU __TIMER_INTERRUPT_VECTOR_TABLE_BASE_ADDRESS + 2
                __isrETC5_ADDRESS:    EQU __TIMER_INTERRUPT_VECTOR_TABLE_BASE_ADDRESS + 4
                __isrETC4_ADDRESS:    EQU __TIMER_INTERRUPT_VECTOR_TABLE_BASE_ADDRESS + 6
                __isrETC3_ADDRESS:    EQU __TIMER_INTERRUPT_VECTOR_TABLE_BASE_ADDRESS + 8
                __isrETC2_ADDRESS:    EQU __TIMER_INTERRUPT_VECTOR_TABLE_BASE_ADDRESS + 10
                __isrETC1_ADDRESS:    EQU __TIMER_INTERRUPT_VECTOR_TABLE_BASE_ADDRESS + 12
                __isrETC0_ADDRESS:    EQU __TIMER_INTERRUPT_VECTOR_TABLE_BASE_ADDRESS + 14
