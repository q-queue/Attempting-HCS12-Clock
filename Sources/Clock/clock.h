
#ifndef CLOCK_H_

#define CLOCK_H_

#include "timer.h"

// Clock Initial Starting Time

#define CLOCK_INITIALIZED_HOURS     11
#define CLOCK_INITIALIZED_MINUTES   59
#define CLOCK_INITIALIZED_SECONDS   45

// -----------------------------
/******** Clock Config ********/
// -----------------------------

// values of counter is multiple of SYSTEM_CLOCK_INTERVALS defined in timer.h as 10ms

#define CLOCK_TICKING_RATE       100


#define BUTTONS_POLLING_RATE     30

#define THERMOMETER_POLLING_RATE 20

#define LCD_TIME_RENDING_RATE    20
#define LCD_TITLE_RENDING_RATE   50
    // Title refresh rate is a multiple of Time one!

#define ENABLED_AM_PM_MODE 1

// -----------------------------

void polling_task(void);
void ticking_task(void);
void rendering_task(void);

// -----------------------------

void init_clock(void);

#endif // CLOCK_H_
