
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


; RAM: Data
.data: SECTION

        ;; can be toggled at run time! If there were button input
        am_pm_mode:               DS.B 1  ;; binary state of am-pm/24-format


        ;; Alignment Guaranteed!
        LCD_LINE_WIDTH:           EQU 16  ;; change here when using different LCD.

        lcd_time_line:            DS.B LCD_LINE_WIDTH

        ;; Setup Labels to subdivide the time temperature string

                ;; right aligned
                hours_str:                      EQU lcd_time_line
                hm_separator:                   EQU lcd_time_line + 2
                minutes_str:                    EQU lcd_time_line + 3
                ms_separator:                   EQU lcd_time_line + 5
                seconds_str:                    EQU lcd_time_line + 6
                AM_PM_str:                      EQU lcd_time_line + 8

                ;; left aligned
                temperature_str:                EQU lcd_time_line + LCD_LINE_WIDTH - 5
                temperature_unit_str:           EQU lcd_time_line + LCD_LINE_WIDTH - 2
                end_of_time_line:               EQU lcd_time_line + LCD_LINE_WIDTH - 1


        CURRENT_TITLE:          DS.W 1

; ROM: Data
.const: SECTION
        TITLE_STR_1:    DC.B "(C) IT SS2025", 0
        TITLE_STR_2:    DC.B "String 1", 0
        TITLE_STR_3:    DC.B "Zeichenkette 2", 0
        TITLE_STR_4:    DC.B "ONE MORE TITLE!", 0

        MACKERELS:    DC.B "Mackerels!", 0

; --------------------------------------------------
; TITLES REFERENCE TABLE
; --------------------------------------------------
        TITLES_REFERENCE_TABLE:
                DC.W TITLE_STR_1
                DC.W TITLE_STR_2
                DC.W TITLE_STR_3
                DC.W TITLE_STR_4

                ;; add references to a title strings here!

                DC.W MACKERELS

                ;; until there are no more to titles to cycle through!

                ;; The Current Location Counter
                TITLES_REFERENCE_TABLE_BOUNDARY:   EQU * ;; * -> CLC
                ;; Can Also be:
                        ;; something like NULL
                        ;; DC.W    $0000     ;; can't really bring myself to wast one more byte.
                        ;; DC.B    $00       ;; when the value/size doesn't really matters
                        ;; But why even waste a byte!
                ;; A reference where the table ends is enough to setup the boundary
                ;; That what CLC is! Program Code also requires memory and is written in bytes

        ;; Assembler Directives

                ;; to be toggled between true and false using COM am_pm_mode
                INIT_ENABLED_AM_PM_MODE:     EQU   $FF
                INIT_DISABLED_AM_PM_MODE:    EQU   $00

; - -- - -- - -- - -- - -- - --

.init: SECTION

init_render:

        MOVB #INIT_ENABLED_AM_PM_MODE, am_pm_mode

        MOVW #TITLES_REFERENCE_TABLE, CURRENT_TITLE

        JSR init_time_line

        JSR initLCD

        PSHX

        LDX #render_LCD
        JSR queue_x

        PULX

        RTS

; - -- - -- - -- - -- - -- - --


init_time_line:

        ;; initial state of second LCD line

        PSHX
        PSHY

                ;; initialize LCD time line with empty space

                LDY #LCD_LINE_WIDTH     ;; entire line width
                LDX #lcd_time_line

                padding_loop:

                        MOVB #' ', 1, X+

                        DBNE Y, padding_loop

        PULY
        PULX


        ;; constant values on the LCD time line

        MOVB #':', hm_separator
        MOVB #':', ms_separator

        MOVB #'C', temperature_unit_str

        MOVB #0, end_of_time_line              ;; NULL Termination! Over Caution.

        ;; rest of the values are volatile!

        RTS

; - -- - -- - -- - -- - -- - --

toggle_am_pm:

        COM am_pm_mode   ;; must have starting value of $00 bzw. $FF for this to work properly!

        ;; will be overwritten when needed!
        MOVB #' ', AM_PM_str
        MOVB #' ', AM_PM_str+1

        RTS


; - -- - -- - -- - -- - -- - --


render_title:

        PSHX

        LDX CURRENT_TITLE       ; load char**
        LDX X                   ; dereference to char*

        JSR writeLine           ; Needs Str Ptr in X register

        LDX CURRENT_TITLE       ; Fetch next title
        LEAX 2, X

        CPX #TITLES_REFERENCE_TABLE_BOUNDARY

        BLO rendered_title      ; check if within bound

        LDX #TITLES_REFERENCE_TABLE     ;; wrap to start

rendered_title:
done_rendering_title:

        STX CURRENT_TITLE       ; update for next pass through

        PULX

        RTS

; - -- - -- - -- - -- - -- - --

render_time:
render_temperature:
render_time_temperature:

        PSHD
        PSHX
        PSHY

        CLRA           ;; enough to extend B to unsigned into 16-bit across the D register

        ;; Sets number of digits for decToASCII
        ;; Lower two decimal digits is enough in this case
        ;; Will append leading zeros at the start if less 
        LDY #2         ;;  applies for all below

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
        JSR signed_decToASCII           ;; writes number of digits in Y +1 for sign

        LDX #lcd_time_line
        LDAB #1
        JSR writeLine           ;; flush time line

        PULY
        PULX
        PULD

        RTS


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

correct_00_12AM:

        TSTB            ;; update Z flag
        BNE represented_hours   ;; Branch Not Equal. In this case if not 00
        LDAB #12        ;; can't have 00:xx am

represented_hours:
done_representing_hours:
        RTS


; - -- - -- - -- - -- - -- - --

render_LCD:

        LDX #render_title
        JSR queue_x

        LDX #render_time
        JSR queue_x

        RTS
