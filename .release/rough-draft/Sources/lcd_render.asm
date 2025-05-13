
; Render

        ;; exports
                XDEF init_render

                XDEF render_title

                XDEF toggle_am_pm

                XDEF render_time, render_temperature, render_time_temperature

        ;; imports

                XREF init_render_timer

                XREF seconds, minutes, hours

                XREF temperature

                XREF initLCD, writeLine

                XREF signed_decToASCII
                XREF unsigned_decToASCII

                XREF queue_x
                XREF FINISHED_TASK

        ; Includes
                include 'mc9s12dp256.inc'

; RAM: Data
.data: SECTION
        title_str_ptr:            DS.W 1
        previous_title_str_ptr:   DS.W 1

        time_temperature_str:  DS.B 17  ; Allocate 16 bytes for the structure

                hours_str:                       EQU time_temperature_str
                hm_separator:                    EQU time_temperature_str + 2
                minutes_str:                     EQU time_temperature_str + 3
                ms_separator:                    EQU time_temperature_str + 5
                seconds_str:                     EQU time_temperature_str + 6
                AM_PM_str:                       EQU time_temperature_str + 8
                temperature_str:                 EQU time_temperature_str + 10
                temperature_unit_str:            EQU time_temperature_str + 13
                time_temperature_str_end:        EQU time_temperature_str + 15

        am_pm_mode:             DS.B 1

; ROM: Data
.const: SECTION
        TITLE_STR_1:    DC.B "Clock Template", 0
        TITLE_STR_2:    DC.B "(C) HE Prof. Z", 0

.init: SECTION

init_render:

        MOVW #TITLE_STR_1, title_str_ptr
        MOVW #TITLE_STR_2, previous_title_str_ptr

        MOVB #0, am_pm_mode

        JSR init_time_temperature_line

        JSR initLCD
        JSR init_render_timer

        PSHX
        LDX #render_LCD
        JSR queue_x
        PULX


        RTS

; - -- - -- - -- - -- - -- - --

init_time_temperature_line:

        MOVB #':', hm_separator
        MOVB #':', ms_separator

        MOVB #' ', AM_PM_str
        MOVB #' ', AM_PM_str+1

        MOVB #'°', temperature_unit_str
        MOVB #'C', temperature_unit_str+1

        MOVB #0, time_temperature_str_end              ;; NULL Termination

        ;; rest of the values are volatile

        RTS

; - -- - -- - -- - -- - -- - --

render_title:

        PSHX
        PSHY

        LDX title_str_ptr       ;; swap for next render
        LDY previous_title_str_ptr

        STX previous_title_str_ptr
        STY title_str_ptr

        PSHB

        LDAB #0                 ;; Select Line Number

        JSR writeLine           ; Needs Str Ptr in X register

        PULB

        PULX
        PULY


        JMP FINISHED_TASK

; - -- - -- - -- - -- - -- - --

render_time:
render_temperature:
render_time_temperature:

        CLRA

        LDY #2                  ;; applies for all below

        LDX #hours_str
        JSR represent_hours
        JSR unsigned_decToASCII

        LDX #minutes_str
        LDAB minutes
        JSR unsigned_decToASCII

        LDX #seconds_str
        LDAB seconds
        JSR unsigned_decToASCII

        LDX #temperature_str
        LDD temperature
        JSR signed_decToASCII

        LDX #time_temperature_str
        LDAB #1
        JSR writeLine

        JMP FINISHED_TASK


; - -- - -- - -- - -- - -- - --

render_LCD:

        LDX #render_title
        JSR queue_x

        LDX #render_time
        JSR queue_x

        JMP FINISHED_TASK

; - -- - -- - -- - -- - -- - --

represent_hours:

        ;; returns current hours state in B register and modifies AM-PM

        LDAB hours

        TST am_pm_mode
        BEQ represented_hours

        ;;  assumes it's morning
        MOVB #'A', AM_PM_str
        MOVB #'M', AM_PM_str+1

        ;; unless proven otherwise
        CMPB #12
        BLO still_morning

        SUBB #12
        MOVB #'P', AM_PM_str

still_morning:

        TSTB
        BNE represented_hours
        ;; can't have 00:xx am
        LDAB #12

represented_hours:
        RTS

; - -- - -- - -- - -- - -- - --

toggle_am_pm:

        COM am_pm_mode

        ;; will be overwritten if needed
        MOVB #' ', AM_PM_str
        MOVB #' ', AM_PM_str+1

        JMP FINISHED_TASK
