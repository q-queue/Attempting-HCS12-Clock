
#show heading.where(level: 1): it => { pagebreak(weak: true); it }

#show link: it => {underline(it); set text(blue)}

#align(center)[
  #v(1fr)
  #box(height: auto, width: auto )[
    #text(3em)[*CA Lab2 Report*]
    #line()
    #text(2em)[Q, Queue] \
    #text(2em)[Mackerels!]
  ]
  #v(1fr)
]

#set heading(numbering: "I. 1.1 .a")
#set page(numbering: " 1 / 1 ")

#outline()

= Modules Overview


#align(center)[
  #v(1fr)
  #box(height: auto, width: auto )[
  #image("diagrams/Modules-Overview.png")
  ]
  #v(1fr)
]

= Program Main Function

- This clock implementation model can accommodate and recover from tasks up to `2550ms` with losing track of time.
  - As long as the long running task allow for some time afterwards 
  - In that case the rendering of the title will be effected! And time between switching will be longer than `10s`

```C
#include <hidef.h>                          // Common defines

#include "clock.h"
#include "timer.h"

void main(void) 
{
    volatile unsigned char timer_ticks = 0;
    unsigned char clock_event = 1;
    EnableInterrupts;                       // Global interrupt enable

    init_clock();

    init_ticker(&timer_ticks,polling_task); // towards semaphore-ish behavior.

    for(;;)                                 // Endless loop
    {
        // this loop doesn't have a fixed run time!
        // need to use semaphore to synchronies with the system clock
        // even that nothing is running in parallel!

        while (timer_ticks > 0)             // catch-up loop
        {
            timer_ticks--;                  // synchronize with timer clock
            ticking_task();
            clock_event = 1;                // one or more clock went by
        }

        if (clock_event)                    // allowed to skip a beat
        {
            // need to give ticking_task time to recover
            clock_event = 0;                 // event handled
            rendering_task();
            // if multiple ticks went by only to render screen/poll thermometer once
        }
    }
}
```

#pagebreak()

== Main Loop

#align(center)[
  #v(1fr)
  #box(height: auto, width: auto )[
  #image("diagrams/Main-Loop.png")
  ]
  #v(1fr)
]

#include "clock.typ"

#include "clock-display.typ"

#include "timer.typ"

#include "counter.typ"

#include "buttons.typ"

#include "LCD-Driver.typ"

#include "LED-Driver.typ"

#include "thermometer.typ"

