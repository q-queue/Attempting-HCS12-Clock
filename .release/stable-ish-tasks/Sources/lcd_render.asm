
; Render

        ;; exports
                XDEF init_render

                XDEF render_title

                XDEF toggle_am_pm

                XDEF render_time, render_temperature, render_time_temperature

        ;; imports

                XREF seconds, minutes, hours

                XREF temperature

                XREF initLCD, writeLine

                XREF signed_decToASCII
                XREF unsigned_decToASCII

                XREF queue_x
                XREF FINISHED_TASK
                
        ; Includes
                include 'mc9s12dp256.inc'
                include 'mackerel.inc'



; RAM: Data
.data: SECTION
        title_str_ptr:            DS.W 1
        previous_title_str_ptr:   DS.W 1


        LCD_LINE_WIDTH:           EQU 16
  
        lcd_time_line:            DS.B LCD_LINE_WIDTH
        

         ; Allocate 16 bytes for the structure

                hours_str:                       EQU lcd_time_line
                hm_separator:                    EQU lcd_time_line + 2
                minutes_str:                     EQU lcd_time_line + 3
                ms_separator:                    EQU lcd_time_line + 5
                seconds_str:                     EQU lcd_time_line + 6
                AM_PM_str:                       EQU lcd_time_line + 8



                temperature_str:                 EQU lcd_time_line + LCD_LINE_WIDTH - 5
                temperature_unit_str:            EQU lcd_time_line + LCD_LINE_WIDTH - 2
                time_temperature_str_end:        EQU lcd_time_line + LCD_LINE_WIDTH - 1


        am_pm_mode:             DS.B 1

; ROM: Data
.const: SECTION
        TITLE_STR_1:    DC.B "Mackerel!", 0
        TITLE_STR_2:    DC.B "(C) HE Prof. Z", 0

.init: SECTION

init_render:

        MOVW #TITLE_STR_1, title_str_ptr
        MOVW #TITLE_STR_2, previous_title_str_ptr

        MOVB #1, am_pm_mode

        JSR init_time_temperature_line
        

        JSR initLCD

        PSHX
        


        LDX #render_LCD
        JSR queue_x

        PULX

        RTS

; - -- - -- - -- - -- - -- - --


init_time_temperature_line:


        PSHX
        PSHY

          LDY #LCD_LINE_WIDTH
          LDX #lcd_time_line
          
          padding_loop:

                  MOVB #' ', 1, X+
                  
                  DBNE Y, padding_loop     


        PULY
        PULX

                       

        MOVB #':', hm_separator
        MOVB #':', ms_separator

        MOVB #' ', AM_PM_str
        MOVB #' ', AM_PM_str+1

        MOVB #'C', temperature_unit_str

        MOVB #0, time_temperature_str_end              ;; NULL Termination

        ;; rest of the values are volatile

        RTS

; - -- - -- - -- - -- - -- - --


render_title:

        PSHX


        ;; save first oprand to X
        SWAP title_str_ptr, previous_title_str_ptr


        PSHB

        LDAB #0                 ;; Select Line Number

        JSR writeLine           ; Needs Str Ptr in X register

        PULB

        PULX


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

        LDX #lcd_time_line
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

        RTS
