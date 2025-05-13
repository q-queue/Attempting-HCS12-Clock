
; Timers Common Definitions

          SWAP:  MACRO
                      LDX  \1
                      MOVW \2, \1
                      STX  \2
                ENDM
