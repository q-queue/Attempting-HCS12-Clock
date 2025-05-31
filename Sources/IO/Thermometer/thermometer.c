
#include "thermometer.h"

#include <hidef.h>                              // Common defines
#include <mc9s12dp256.h>                        // CPU specific defines

#pragma LINK_INFO DERIVATIVE "mc9s12dp256b"

// -----------------------------
/********** exported **********/
// -----------------------------

void init_thermometer(void)
{
    ATD0CTL2 = 0xC0;        // Enable ATD
    ATD0CTL3 = 0x08;        // Single conversion only
    ATD0CTL4 = 0x05;
}

// -----------------------------

#define CONVERTING_CHANNEL      0x87
#define AC_DC_CONVERTING_BIT    0x80

int poll_thermometer(void)
{
    // start converting
    ATD0CTL5 = CONVERTING_CHANNEL;

    // wait until hardware flag resets when the AC-DC converting finishes
    while (ATD0STAT0 & AC_DC_CONVERTING_BIT != 0);

    // convert result as human readable unsigned temperature value
    return (ATD0DR0 * 50) / 511 - 30;
}


