
#include "buttons.h"

#include <hidef.h>                              // Common defines
#include <mc9s12dp256.h>                        // CPU specific defines

#pragma LINK_INFO DERIVATIVE "mc9s12dp256b"

unsigned char enabled = 0x00;

static unsigned char get_buttons()
{
    #ifndef SIMULATOR
        return ~PTH & enabled;
    #else
        return PTH & enabled;
    #endif
}

// -------------------------------------------------------------

static void UNMAPPED(void) { }

// -----------------------------
/********** exported **********/
// -----------------------------

void (*BUTTONS_ENTRIES_TABLE[BUTTONS_COUNT])(void);

void init_buttons(unsigned char enable_initial_state)
{
    unsigned char i;

    for (i = 0; i < BUTTONS_COUNT; i++)
        BUTTONS_ENTRIES_TABLE[i] = UNMAPPED;

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
    unsigned char i, mask, buttons;

    buttons = get_buttons();

    mask = 1;

    for (i = 0; i < BUTTONS_COUNT; i++)
    {
        if (mask & buttons)
            BUTTONS_ENTRIES_TABLE[i]();

        mask = mask << 1;
    }
}
