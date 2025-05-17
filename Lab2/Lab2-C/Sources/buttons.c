
#include "buttons.h"

#include <hidef.h>                              // Common defines
#include <mc9s12dp256.h>                        // CPU specific defines

#pragma LINK_INFO DERIVATIVE "mc9s12dp256b"

static unsigned char enabled = 0x00;

#ifndef SIMULATOR
    // inlined
    #define poll_buttons_state() (~PTH & enabled)
#else
    #define poll_buttons_state() (PTH & enabled)
#endif

// -------------------------------------------------------------

static void UNMAPPED(void) { }

// -----------------------------
/********** exported **********/
// -----------------------------

void (*BUTTONS_CALLBACK_REGISTRAR[BUTTONS_COUNT])(void);

void init_buttons(unsigned char enable_initial_state)
{
    unsigned char i;

    for (i = 0; i < BUTTONS_COUNT; i++)
        BUTTONS_CALLBACK_REGISTRAR[i] = UNMAPPED;

    DDRH = 0x00;    // Configure Port H as input register

    enabled = enable_initial_state;
}

// -----------------------------

void toggle_enable_buttons(unsigned char mask)
{
    enabled ^= mask;
}

// -----------------------------

void poll_buttons(void)
{
    unsigned char buttons = poll_buttons_state();

    unsigned char mask = 1;

    unsigned char i;

    for (i = 0; i < BUTTONS_COUNT; i++)
    {
        if (mask & buttons)
            BUTTONS_CALLBACK_REGISTRAR[i]();

        mask = mask << 1;
    }
}
