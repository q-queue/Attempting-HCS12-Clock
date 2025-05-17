
#include "render.h"
#include "clock.h"
#include "lcd.h"

// -----------------------------
/****** Global variables ******/
// -----------------------------

static unsigned char AM_PM_MODE = 1;   // initial state

static char TIME_LINE[LCD_LINE_WIDTH];

// right aligned
    #define hours_str             (TIME_LINE)
    #define hm_separator          (TIME_LINE + 2)
    #define minutes_str           (TIME_LINE + 3)
    #define ms_separator          (TIME_LINE + 5)
    #define seconds_str           (TIME_LINE + 6)
    #define AM_PM_str             (TIME_LINE + 8)

// left aligned
    #define temperature_str       (TIME_LINE + LCD_LINE_WIDTH - 5)
    #define temperature_unit_str  (TIME_LINE + LCD_LINE_WIDTH - 2)

// -----------------------------
/*** Local Bound Functions ****/
// -----------------------------

static void unsigned_decToASCII(unsigned int number, char* at, unsigned char digits)
{
    unsigned int rest;

    while (digits-- > 0)
    {
        rest = number % 10;
        at[digits] = rest + '0';    // fill with zeros
        number /= 10;
    }
}

static void signed_decToASCII(int number, char* at, unsigned char digits)
{
    // requires one extra space for the sign

    at[0] = ' ';

    if (number < 0)
    {
        at[0] = '-';
        number = -number; // ~number +1
    }

    unsigned_decToASCII(number, ++at, digits);
}

// ----------------------------

static void fill(char* str, char c, unsigned char length)
{
    while (length--) *str++ = c; // countdown loop
}

// -------------------------------------------------------------

void init_time_render()
{
    fill(TIME_LINE, ' ', LCD_LINE_WIDTH);   // initialize buffer line

    hm_separator[0] = ':';
    ms_separator[0] = ':';

    #ifdef SIMULATOR
        temperature_unit_str[0] = 0xB0;
    #else
        temperature_unit_str[0] = 0xDF;
    #endif

    temperature_unit_str[1] = 'C';
}

// ----------------------------

void toggle_am_pm(void)
{
    AM_PM_str[0] = ' ';
    AM_PM_str[1] = ' ';

    AM_PM_MODE = !AM_PM_MODE;
}

// ----------------------------

static unsigned char represent_hours(unsigned char hours)
{
    if (!AM_PM_MODE) return hours;

    // side effect!
    AM_PM_str[0] = 'A';
    AM_PM_str[1] = 'M';      // assumes morning

    if (hours < 13)
    {
        if (hours == 0) return 12U;
        return hours;
    }
    AM_PM_str[0] = 'P';
    return hours - 12;
}

// ----------------------------

void render_time(
    unsigned char hours,
    unsigned char minutes,
    unsigned char seconds,
    int temperature
){
    unsigned_decToASCII(
        represent_hours(hours),
        hours_str,
        2
    );

    unsigned_decToASCII(
        minutes,
        minutes_str,
        2
    );

    unsigned_decToASCII(
        seconds,
        seconds_str,
        2
    );

    signed_decToASCII(
        temperature,
        temperature_str,
        2
    );

    write_line(TIME_LINE, 1);
}
