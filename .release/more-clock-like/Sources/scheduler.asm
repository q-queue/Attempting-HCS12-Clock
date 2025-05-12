
        ;; Simple Scheduler Implementation

        XDEF queue_x                   ;; Where interrupts can schedule tasks

        XDEF init_scheduler

        XDEF RUN_SCHEDULED             ;; Jumping point for the Scheduler loop start
        XDEF FINISHED_TASK             ;; Jumping point when a task is done

        XDEF drop_queue

; - -- - -- - -- - -- - -- - --

TASK_REGISTRAR: SECTION

; RAM: Data          ;; localized global variable #translation-unit
.data: SECTION
        first:        DS.W 1
        last:         DS.W 1

        count:        DS.B 1           ;; current count of queued values

.queue: SECTION
        __QUEUE_START: EQU $CA00
                      ORG __QUEUE_START         ;; reserved BYTE
__QUEUE:              DS.W 128

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

        ;; we need to keep last from trampling first
        ;; if current count is <= 128 -> stack is full! ignore :/
        BRSET count, #SIGN_BIT, return_queue

        ;;; Update count
        INC count               ;; should work for 8-bit

        ;;; write to queue with offset of last

        
        LDY last
        STX Y

        LDD last
        ;;; seek next free spot
        ADDB #2            ;; NOT a BUG but a FEATURE!
        STD last

return_queue:        RTS

; *********************************************************************

        ;; Scheduler

RUN_SCHEDULED:
FINISHED_TASK:
dequeue:
; A rose by any other name would smell as sweet

        ;; pop value of the queue and runs appropriate task

        ;; if queue is empty which be the idling state
        ;; -> just keep pulling from the queue until something turns up

        TST count               ;; setup the zero flag in the CCR
        BEQ FINISHED_TASK       ;; if that the case queue is empty

        DEC count

        LDY first

        LDD first          ;; seek next task
        ADDB #2            ;; NOT a BUG but a FEATURE!
        STD first

        LDX Y
        ;;; run task. -> when finished the task should jump back to FINISHED_TASK
        JMP X


