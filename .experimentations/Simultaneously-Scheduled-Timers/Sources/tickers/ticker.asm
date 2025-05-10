

; Timer Initializer

        ;; exports
                XDEF init_timers

        ;; imports
        
                XREF init_LED

                XREF init_timer_7
                XREF init_timer_6
                XREF init_timer_5
                XREF init_timer_4
                XREF init_timer_3
                XREF init_timer_2
                XREF init_timer_1
                XREF init_timer_0

; ROM: Code
.init: SECTION

init_timers:

        JSR init_LED

        JSR init_timer_7
        JSR init_timer_6
        JSR init_timer_5
        JSR init_timer_4
        JSR init_timer_3
        JSR init_timer_2
        JSR init_timer_1
        JSR init_timer_0

        RTS


