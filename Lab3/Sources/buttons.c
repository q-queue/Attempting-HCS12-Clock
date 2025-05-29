
#include "buttons.h"

#include <hidef.h>                              // Common defines
#include <mc9s12dp256.h>                        // CPU specific defines

#pragma LINK_INFO DERIVATIVE "mc9s12dp256b"

static volatile unsigned char enabled = 0x00;

void (*BUTTONS_CALLBACK_REGISTRAR[BUTTONS_COUNT])(void);

// -------------------------------------------------------------

#ifdef SIMULATOR
    // inlined
        #define poll_buttons_state() (PTH)
    #else
        #define poll_buttons_state() (~PTH)
#endif

// -------------------------------------------------------------

static void UNMAPPED(void) { }

// -----------------------------
/********** exported **********/
// -----------------------------


void init_buttons(unsigned char enable_initial_state)
{
    unsigned char i;

    for (i = 0; i < BUTTONS_COUNT; i++)
        BUTTONS_CALLBACK_REGISTRAR[i] = UNMAPPED;

    DDRH = 0x00;    // Configure Port H as input register

    enabled = enable_initial_state;
}

// -----------------------------

void poll_buttons(void)
{
    static char counter = 0;

    static char i, mask, buttons;

    if (counter-- != 0) return;

    counter = BUTTONS_POLLING_RATE;

     mask = 1;
        // shifted to test the buttons register at a specific bit

     buttons = poll_buttons_state();
        // current buttons state normalized to be true if pressed independet from compilation target
        // buttons state is masked by enabled buttons!

    for (i = 0; i < BUTTONS_COUNT ; i++)
    {   // loops over all registered callbacks and call the ones with active button state
        if (mask & buttons & enabled)
            BUTTONS_CALLBACK_REGISTRAR[i]();

        mask = mask << 1;
    }
}

// -------------------------------------------------------------

void enable_buttons(unsigned char mask)
{
    // enable buttons at bit position specified by a bit-select-mask 
    enabled |= mask;
}

// -----------------------------

void disable_buttons(unsigned char mask)
{
    // disable buttons at bit position specified by a bit-select-mask 
    enabled &= (~mask);
}

// -----------------------------

void toggle_enabled_buttons(unsigned char mask)
{
    // toggles bits specify in the bit-select mask
    enabled ^= mask;
}
