
; Timers Common Definitions

      IFNDEF SWAP
            SWAP:  MACRO              ;; keeps first operand in X!
                        LDX  \1
                        MOVW \2, \1
                        STX  \2
                  ENDM
      ENDIF

      IFNDEF _HCS12_SERIALMON
            IFNDEF SIMULATOR
                  SIMULATOR: EQU 1
            ENDIF
      ENDIF
