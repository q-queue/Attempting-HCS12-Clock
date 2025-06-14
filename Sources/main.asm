;
;   Labor 1 - Test program for LCD driver
;
;   SS2024 Jonas Ehmele (TIB4), Christian Schiefele (TIB4)
;
;   Computerarchitektur
;   (C) 2019-2022 J. Friedrich, W. Zimmermann, R. Keller
;   Hochschule Esslingen
;
;   Author:      J.Friedrich, W. Zimmermann
;   Last Modified: R. Keller, August 2022

; Export symbols
        XDEF Entry, main

; Import symbols
        XREF __SEG_END_SSTACK                        ; End of stack
        XREF initLCD, writeLine, delay_10ms          ; LCD functions


        XREF delay_O_5sec                            ;; defined in delay.asm
        XREF initLED, setLED, getLED, toggleLED      ;; LED Subroutines defined in led.asm

        XREF hexToASCII                              ;; defined in hexToASCII.asm
        XREF decToASCII                              ;; defined in decToASCII.asm

; Include derivative specific macros
        INCLUDE 'mc9s12dp256.inc'

;; ************************************************************************

; Defines

; RAM: Variable data section
.data:  SECTION

i: DS.W 1

dec_buffer: DS.B 17
hex_buffer: DS.B 17

; ROM: Constant data
.const: SECTION
MSG1:   dc.b " Mach mal eine",0
MSG2:   dc.b " kleine Pause", 0


msgA:   DC.B "ABCDEFGHIJKLMnopqrstuvwxyz1234567890", 0
msgB:   DC.B "is this OK?", 0 
msgC:   DC.B "Keep texts short!", 0 
msgD:   DC.B "Oh yeah!", 0


;; ************************************************************************

        ;; Assembler Directives

      IFNDEF _HCS12_SERIALMON  ;; Idempotence. If it didn't help, it wont hurt!
            IFNDEF SIMULATOR
                  SIMULATOR: EQU 1
            ENDIF
      ENDIF

        IFDEF SIMULATOR        ;; branch if button pressed
                BR_BUTTONS_PRESSED:     MACRO   ;; depends on polarity. ; Active High
                        BRSET \1, \2, \3
                ENDM
        ELSE
                BR_BUTTONS_PRESSED:     MACRO                           ; Active Low
                        BRCLR \1, \2, \3
                ENDM
        ENDIF

        PH_0:   EQU  $01
        PH_1:   EQU  $02
        PH_2:   EQU  $04
        PH_3:   EQU  $08

;; ************************************************************************

.init:  SECTION

main:
Entry:
        LDS  #__SEG_END_SSTACK          ; Initialize stack pointer
        CLI                             ; Enable interrupts, needed for debugger

        JSR  delay_10ms                 ; Delay 20ms during power up
        JSR  delay_10ms                 ; by Jump-Subroutine (use step-over)

        JSR  initLCD                    ; Initialize the LCD

        JSR initLED                     ; also inti_7_Segments/disable it.



        STARTING_VALUE:         EQU $7FF5

        MOVW #STARTING_VALUE, i


main_loop:

        LDD i

        JSR setLED

        LDX #dec_buffer
        JSR decToASCII ; X Still holds #dec_buffer afterwards

        LDAB #0  ;; LCD writeline ;; row 0
        JSR writeLine   ;; reads String Start from Register X.

        LDD i
        LDX #hex_buffer
        JSR hexToASCII ; X Still holds #hex_buffer

        LDAB #1  ;; LCD writeline ;; row 1
        JSR writeLine

        LDD i

        JSR delay_O_5sec

        BR_BUTTONS_PRESSED PTH, #PH_0, branch_PH0      ; Branch to ButtonPH0 when the first button is pressed
        BR_BUTTONS_PRESSED PTH, #PH_1, branch_PH1      ; Branch to ButtonPH1 when the second button is pressed
        BR_BUTTONS_PRESSED PTH, #PH_2, branch_PH2      ; Branch to ButtonPH2 when the third button is pressed
        BR_BUTTONS_PRESSED PTH, #PH_3, branch_PH3      ; Branch to ButtonPH3 when the fourth button is pressed

        ;; BR_BUTTONS_PRESSED PTH, #$00, branch_No_button_pressed        ; normal program flow

branch_No_button_pressed:      ; Increment 'i' when no Button is pressed
        ADDD #1
        STD i
        BRA main_loop

branch_PH0:
ButtonPH0:                     ; Increment 'i' by 16 when Button PH0 is pressed
        ADDD #16
        STD i
        BRA main_loop

branch_PH1:
ButtonPH1:                     ; Increment 'i' by 10 when Button PH1 is pressed
        ADDD #10
        STD i
        BRA main_loop

branch_PH2:
ButtonPH2:                     ; Decrement 'i' by 16 when Button PH2 is pressed
        SUBD #16
        STD i
        BRA main_loop

branch_PH3:
ButtonPH3:                     ; Decrement 'i' by 10 when Button PH3 is pressed
        SUBD #10
        STD i
        BRA main_loop
