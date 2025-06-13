/*  Radio signal clock - Free running clock

    Computerarchitektur 3
    (C) 2018 J. Friedrich, W. Zimmermann Hochschule Esslingen

    Author:   W.Zimmermann, Jun  10, 2016
    Modified: -
*/

#include <stdio.h>

#include "clock.h"
#include "lcd.h"
#include "led.h"
#include "dcf77.h"


#include <hidef.h>                              // Common defines
#include <mc9s12dp256.h>                        // CPU specific defines

#pragma LINK_INFO DERIVATIVE "mc9s12dp256b"



// Defines
#define ONESEC  (1000/10)                       // 10ms ticks per second
#define MSEC200 (200/10)

// Global variable holding the last clock event
CLOCKEVENT clockEvent = NOCLOCKEVENT;

// Modul internal global variables
static int uptime = 0;
static int ticks = 0;

static char hrs, mins, secs;

static char day, month;
static int year;

static char weekday;

// -----------------------------

// UTC Offset
// Somer Time Zones
#define DE_TIME_ZONE +2
#define US_TIME_ZONE -4

#define CLOCK_INITIAL_TIME_ZONE DE_TIME_ZONE

// ------------

typedef enum {
    DE_TIME_ENTRY,
    US_TIME_ENTRY
} LABELED_TIME_ZONES;

static char CURRENT_TIME_ZONES[] = {
    DE_TIME_ZONE,
    US_TIME_ZONE
};


#define SIZEOF(Array) (sizeof((Array)) / sizeof((Array)[0]))

static const unsigned char KNOWN_TIME_ZONES_COUNT = SIZEOF(CURRENT_TIME_ZONES);

// ------------

static char CLOCK_TIME_ZONE = CLOCK_INITIAL_TIME_ZONE;

static char LAST_REFRENCED_CLOCK_TIME_ZONE = +2;

// ------------

static void toggle_de_time_zone(void);

static volatile void (*toggle_time_zone)(void) = toggle_de_time_zone;

// ------------

static const char* TIME_ZONE_REPRESENTATION; // initlized in initClock by toggling de time zone

static const char* WEEK_DAY_REPRESENTATION[] = {
    "",     // offset
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun"
};

// ****************************************************************************
//  Initialize clock module
//  Called once before using the module
void initClock(void)
{
    toggle_time_zone();

    displayTimeClock();
    displayDateDcf77();
}


// -------------------------------------------------------------

#define BUTTONS_POLLING_RATE   50         // once in n * 10ms

#ifdef SIMULATOR
// inlined
  #define poll_buttons_state() (PTH)
#else
  #define poll_buttons_state() (~PTH)
#endif

#define PH3                      0x08U

#define TOGGLE_TIME_ZONE_BUTTON  PH3

void poll_buttons(void)
{
    static char counter = BUTTONS_POLLING_RATE;

    if (counter-- != 0) return;

    counter = BUTTONS_POLLING_RATE;

    if (poll_buttons_state() & TOGGLE_TIME_ZONE_BUTTON)
    {
        toggle_time_zone();
            
        displayTimeClock();
        displayDateDcf77();
    }


}

// ****************************************************************************
// This function is called periodically every 10ms by the ticker interrupt.
// Keep processing short in this function, run time must not exceed 10ms!
// Callback function, never called by user directly.
void tick10ms(void)
{   if (++ticks >= ONESEC)                      // Check if one second has elapsed
    {   clockEvent = SECONDTICK;                // ... if yes, set clock event
        ticks=0;
        setLED(0x01);                           // ... and turn on LED on port B.0 for 200msec
    } else if (ticks == MSEC200)
    {   clrLED(0x01);
    }
    uptime = uptime + 10;                       // Update CPU time base

    dcf77Event = sampleSignalDCF77(uptime);     // Sample the DCF77 signal

    poll_buttons();
}

// ****************************************************************************
// Process the clock events
// This function is called every second and will update the internal time values.
// Parameter:   clock event, normally SECONDTICK
// Returns:     -
void processEventsClock(CLOCKEVENT event)
{   if (event==NOCLOCKEVENT)
        return;

    if (++secs >= 60)
    {   secs = 0;
        if (++mins >= 60)
        {   mins = 0;
            if (++hrs >= 24)
            {   hrs = 0;
            }
        }
     }
}

// ****************************************************************************

#define is_leap_year(year) (((year) % 4 == 0 && (year) % 100 != 0) || ((year) % 400 == 0))

static char days_in_month(char month, int year)
{
    static const char months_days[] = {
        0,  // offset : month is used as an index!
        31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
    };

    if (month == 2 && is_leap_year(year))
        return 29;

    return months_days[month];
}

static void adjust_to_timezone(char reference_clock_time_zone)
{
    hrs = hrs + (reference_clock_time_zone - CLOCK_TIME_ZONE);

    if (hrs < 0)
    {
        // adjust hours
        hrs += 24;

        // adjust day
        day--;

        if (day == 0)
        {
            month--;

            if (month == 0)
            {
                month = 12;
                year--;
            }
            day = days_in_month(month, year); // ask for adjusted values!
        }

        // adjust weekday
        weekday--;
        if (weekday == 0) weekday = 7;

    } else if (hrs >= 24) {

        hrs -= 24;

        day++;

        if (day > days_in_month(month, year))
        {
            day = 1;

            month++;

            if (month > 12)
            {
                month = 1;
                year++;
            }
        }

        // adjust weekday
        weekday++;
        if (weekday == 8) weekday = 1;

    }

    // change clock time zone
    CLOCK_TIME_ZONE = reference_clock_time_zone;
}

// ****************************************************************************
// Allow other modules, e.g. DCF77, so set the time
// Parameters:  char hours, char minutes, char seconds, char _day, char _month, int _year, , char _weekday, char referenced_time_zone
// Returns:     -
void setClock(char hours, char minutes, char seconds, char _day, char _month, int _year, char _weekday, char referenced_time_zone)
{
    char clock_time_zone, i;

    day   = _day;
    month = _month;
    year  = _year;

    hrs   = hours;
    mins  = minutes;
    secs  = seconds;

    weekday = _weekday;

    ticks = 0;
    
    if (referenced_time_zone != LAST_REFRENCED_CLOCK_TIME_ZONE)
    {
        // time zone change needs to stay relative to the reference // somer/winter time
        
        clock_time_zone += (referenced_time_zone - LAST_REFRENCED_CLOCK_TIME_ZONE);
        
        for (i = 0; i < KNOWN_TIME_ZONES_COUNT; i++)
            CURRENT_TIME_ZONES[i] = CURRENT_TIME_ZONES[i] + (referenced_time_zone - LAST_REFRENCED_CLOCK_TIME_ZONE);

        LAST_REFRENCED_CLOCK_TIME_ZONE = referenced_time_zone;
        // untested code!
    }

    clock_time_zone = CLOCK_TIME_ZONE;

    CLOCK_TIME_ZONE = referenced_time_zone;

    adjust_to_timezone(clock_time_zone);    // adjust back to current clock time zone
}

// ****************************************************************************
// Display the time derived from the clock module on the LCD display, line 0
// Parameter:   -
// Returns:     -
void displayTimeClock(void)
{
    static char uhrzeit[32] = "00:00:00";
    (void) sprintf(
        uhrzeit, "%3s %02d:%02d:%02d",
        TIME_ZONE_REPRESENTATION,
        hrs, mins, secs
    );
    writeLine(uhrzeit, 0);
}

// ***************************************************************************
// This function is called to get the CPU time base
// Parameters:  -
// Returns:     CPU time base in milliseconds
int time(void)
{   return uptime;
}

// ****************************************************************************
// Display the date derived from the DCF77 signal on the LCD display, line 1
// Parameter:   -
// Returns:     -
// ;; moved from dcf77.c to format time zone
void displayDateDcf77(void)
{
    static char datum[32];

    (void) sprintf(
        datum, "%3s %02d.%02d.%04d",
        WEEK_DAY_REPRESENTATION[weekday],
        day, month, year
    );

    writeLine(datum, 1);
}

// ****************************************************************************
// toggle_US_DE: on buttons press switch time zone between US and DE
// Parameter:   -
// Returns:     -
// ;; moved from dcf77.c to format time zone


static void toggle_us_time_zone(void)
{
    static const char* US = "US";

    TIME_ZONE_REPRESENTATION = US;

    toggle_time_zone = toggle_de_time_zone;  // next toggle
    
    adjust_to_timezone(CURRENT_TIME_ZONES[US_TIME_ENTRY]);
}


// -----------------------------

static void toggle_de_time_zone(void)
{
    static const char* DE = "DE";

    TIME_ZONE_REPRESENTATION = DE;

    toggle_time_zone = toggle_us_time_zone;  // next toggle
    
    adjust_to_timezone(CURRENT_TIME_ZONES[DE_TIME_ENTRY]);
}
