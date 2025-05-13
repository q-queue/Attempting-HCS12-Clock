
        ;; Simple Scheduler Implementation

        XDEF queue_x                ;; Where interrupts can schedule tasks

        XDEF init_scheduler

        XDEF run_scheduled          ;; Jumping point for the Scheduler loop start

; - -- - -- - -- - -- - -- - --

; RAM: Data          ;; localized global variable #translation-unit
.data: SECTION
        first:  DS.W 1
        last:   DS.W 1

        count:  DS.B 1              ;; current count of queued values

.__queued: SECTION

        __QUEUE_START:      EQU $1200    ;; need to have $XX00 Address to wrap around by overflow

                ORG __QUEUE_START   ;; reserved BYTE   ;; 
__QUEUE:        DS.W 128            ;; Fixed Size Queue

; - -- - -- - -- - -- - -- - --

; ROM: Data
.const: SECTION

; - -- - -- - -- - -- - -- - --

; assembler symbolic constants
SIGN_BIT:     EQU $80

;; one and the same
init_scheduler:
drop_queue:
init_queue:

        MOVB #0, count
        MOVW #__QUEUE_START, first
        MOVW #__QUEUE_START, last

        RTS

; *********************************************************************

        ;; modifies the X register!
        ROTATE_WPTR:   MACRO    ;; rotate word pointer ; increment lower byte LSB by 2.

                PSHD
                        LDD \1
                        ADDB #2 ;; wrap around to reserved address byte start when overflow
                        STD \1
                PULD

        ENDM

; - -- - -- - -- - -- - -- - --

; ROM: Code
.init: SECTION

queue_x:
        ;; Reads value from X to put on the queue

        BRSET count, #SIGN_BIT, return_queue
        ;; keeps last from trampling first!
        ;;  ignore queue! Extreme case alternatives are worse.
        ;; if current count is <= 128 -> stack is full!

        ;;; Update count
        INC count               ;; should work for 8-bit

        PSHY

        LDY last
        STX Y

        ROTATE_WPTR last

        PULY

return_queue:        RTS


; *********************************************************************

        ;; Scheduler

run_scheduled:
dequeue:

        TST count               ;; setup the zero flag in the CCR
        BEQ return       ;; if that the case queue is empty

        DEC count

        PSHX

        LDX first
        LDX X

        JSR X

        ROTATE_WPTR first

        PULX

return:  
        RTS
