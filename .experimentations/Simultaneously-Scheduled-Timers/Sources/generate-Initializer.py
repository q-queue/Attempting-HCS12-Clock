#!/usr/bin/env python3


CH:list[int] = list(range(7, -1, -1))


initializer_template: str = rf"""

; Timer Initializer

        ;; exports
                XDEF init_timers

        ;; imports


                XREF init_LED

                {
	"\n                ".join(
		f"XREF init_timer_{x}" for x in CH
	)
}

; ROM: Code
.init: SECTION


init_timers:

        JSR init_LED

        {
	"\n        ".join(
		f"JSR init_timer_{x}" for x in CH
	)
}

        RTS

"""

print(
	initializer_template
)
