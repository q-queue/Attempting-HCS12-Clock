#!/usr/bin/env python3


CH:list[int] = list(range(7, -1, -1))

header_file:str = fr"""


; Timers Common Definitions

        TICKERS_PRESCALE_DIVIDER:       EQU $07
        ENABLE_TIMER_UNIT:              EQU $80

        TEN_MS:       EQU 1875

        ;; extreme case testing!
        Simultaneous_TIME:              EQU 50

        {
	"\n        ".join(
		f"TIMER_CH{x}:    EQU {2**x}" for x in CH
	)
}

        __TIMER_INTERRUPT_VECTOR_TABLE_BASE_ADDRESS: EQU $FFE0

                {
	"\n                ".join(
		f"__isrETC{x}_ADDRESS:    EQU __TIMER_INTERRUPT_VECTOR_TABLE_BASE_ADDRESS + {2*y}" for x, y in zip(CH, CH[::-1])
	)
}



"""


print(
	header_file
)
