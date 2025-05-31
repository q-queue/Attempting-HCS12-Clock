/*  Lab 2 - Main C file for Clock program

    Computerarchitektur 3
    (C) 2018 J. Friedrich, W. Zimmermann
    Hochschule Esslingen

    Author:  W.Zimmermann, July 19, 2017
*/

// Compiler Known Include PATHs
#include <hidef.h>                              // Common defines

#include "clock.h"
#include "timer.h"

// -----------------------------

void main(void) 
{
    volatile unsigned char timer_ticks = 0;

    unsigned char clock_event = 1;

    EnableInterrupts;        // Global interrupt enable

    init_clock();

    init_ticker(             // towards semaphore-ish behaviour.
        &timer_ticks,
        polling_task
    );

    for(;;)                  // Endless loop
    {
        // this loop doesn't have a fixed run time!
        // need to use semaphore to synchronies with the system clock
        // even that nothing is running in parallel!

        while (timer_ticks > 0)
        {
            // catch-up loop
            // synchronize with timer clock
            timer_ticks--;

            ticking_task();

            clock_event = 1;    // flanke erkannt
        }

        if (clock_event)
        {
            // allowed to skip a beat
            // need to give ticking_task time to recover
            // if multiple ticks went by only to render screen/poll thermometer once
            clock_event = 0;    // flanke gelöcht
            rendering_task();
        }
    }
}
