

        ; Thermometer

        ; exports
                XDEF init_thermometer

                XDEF temperature

                XDEF poll_thermometer

                XREF queue_x
                XREF FINISHED_TASK

        ; inlcudes
                INCLUDE 'mc9s12dp256.inc'



.data: SECTION

temperature:            DS.W 1

.init: SECTION

init_thermometer:

        MOVB #$C0, ATD0CTL2        ; Enable ATD
        MOVB #$08, ATD0CTL3        ; Single conversion only
        MOVB #$05, ATD0CTL4

        PSHX

        LDX #poll_thermometer
        JSR queue_x

        PULX

        RTS


;; - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - --

        CONVERTING_CHANNEL:             EQU $87
        AC_DC_CONVERTING_BIT:           EQU $80

poll_thermometer:

        MOVB #CONVERTING_CHANNEL, ATD0CTL5

        converting:
                BRCLR ATD0STAT0, #AC_DC_CONVERTING_BIT, converting

        MOVW ATD0DR0, temperature

        JMP FINISHED_TASK

