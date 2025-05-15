


#include "led.h"

#include <hidef.h>                              // Common defines
#include <mc9s12dp256.h>                        // CPU specific defines

#pragma LINK_INFO DERIVATIVE "mc9s12dp256b"

// -----------------------------
/********** exported **********/
// -----------------------------

static void disable_seven_segment(void)
{
    // will flicker otherwise
    DDRP = 0x0F;    // Port P.3..0 as outputs (seven segment display control)
    PTP  = 0x0F;    // Turn off seven segment display

}


void init_LED(void)
{
    DDRJ_DDRJ1  = 1;    // Port J.1 as output
    PTIJ_PTIJ1  = 0;  
    DDRB        = 0xFF;  // Port B as output
    PORTB       = 0x55;
    disable_seven_segment();    // just hide it here. doesn't really have place elsewhere
}

// ----------------------------

void blink_LED(void)
{
    PORTB = ~PORTB;
}

// ----------------------------

void set_LED(unsigned char value)
{
    PORTB = value;
}

// ----------------------------

unsigned char get_LED()
{
    return PORTB;
}

// ----------------------------

void toggle_LED(unsigned char mask)
{
    PORTB ^= mask;
}
