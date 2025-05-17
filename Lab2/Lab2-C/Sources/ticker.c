
#include "ticker.h"

#include <hidef.h>                  // Common defines
#include <mc9s12dp256.h>            // CPU specific defines

#pragma LINK_INFO DERIVATIVE "mc9s12dp256b"

// -------------------------------------------------------------
/************************** Globals ***************************/
// -------------------------------------------------------------

// value will be incremented on each timer trigger
static unsigned char* ticker;
    // external reference to be captured at initialization

static void (*in_sync_callback) (void);

// -------------------------------------------------------------


// ticker.c translation unit bound function
// not exported!

#define ENABLE_TIMER_UNT       0x80

// commenting in code form!
#define TIMER_CH4              0x10
#define TIMER_CH               TIMER_CH4

#define PRESCALE_FACTOR        0x07

#define TCTL_REGISTER          TCTL1

// needs two mask to sets the mode properly!
#define TCTL_MODE_AND_MASKING  0xFC   // set lower two bits to 0 and leaves the rest!
#define TCTL_MODE_OR_MASKING   0x00   // don't set any bits to 1!

// -----------------------------
/********* localized **********/
// -----------------------------

static void init_timer_uint()
{
    TSCR1 = ENABLE_TIMER_UNT;

    TSCR2 |= PRESCALE_FACTOR;

    TIOS  |= TIMER_CH;    // set as ouput capture mode on the timer channel used

    TIE   |= TIMER_CH;    // enables interrupt on the timer channel

    // sets bits to zero where there are zeros in the mask
    TCTL_REGISTER = TCTL_REGISTER & TCTL_MODE_AND_MASKING;

    // sets bits to one where there are ones in the mask
    TCTL_REGISTER = TCTL_REGISTER | TCTL_MODE_AND_MASKING;
}

// ----------------------------

#define TEN_MS                 1875
#define NEXT_TIMER_TRIGGER     TEN_MS
#define ENABLE_TIMER_UNT       0x80

#define TC                     TC4

// not exported as a definition but referenced in the interrupt table

interrupt 12 void TimerISR(void)
{
    TC += NEXT_TIMER_TRIGGER;    // setup next interrupt timer
    TFLG1 |= TIMER_CH;       // clears the interrupt flag

    *ticker += 1;         // indicates how many NEXT_TIMER_TRIGGER have passed

    in_sync_callback();  // hard real time tasks
}

// -------------------------------------------------------------

// -----------------------------
/********** exported **********/
// -----------------------------

void init_ticker(
    unsigned char* referenced_ticker,
    void (*hard_real_time_task) (void)
){
    // capture reference
    ticker = referenced_ticker;
    init_timer_uint();
    in_sync_callback = hard_real_time_task;
}