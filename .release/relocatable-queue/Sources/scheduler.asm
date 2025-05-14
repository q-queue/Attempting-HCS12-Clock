
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


__QUEUE:        DS.W 128            ;; Fixed Size Queue

        __QUEUE_BOUNDARY:      EQU * ;; CLC

        __QUEUE_START:         EQU __QUEUE

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


        ;; increment word pointer

        LDY last

        LEAY 2, Y

        CPY #__QUEUE_BOUNDARY
        
        BLO incremented_last

               LDY #__QUEUE_START          ;; wrap around

        incremented_last:

        STY last


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

        ;; increment word pointer

        LDX first

        LEAX 2, X

        CPX #__QUEUE_BOUNDARY

        BLO incremented_first

               LDX #__QUEUE_START          ;; wrap around

        incremented_first:

        STX first

        PULX

return:
        RTS
