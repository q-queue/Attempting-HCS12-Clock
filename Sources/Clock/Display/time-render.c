
#include "render.h"
#include "ASCII-Utils.h"
#include "lcd.h"

// -----------------------------
/****** Global variables ******/
// -----------------------------

static unsigned char AM_PM_MODE = ENABLED_AM_PM_MODE;

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

// -------------------------------------------------------------


void init_render()
{
    repeat_char(TIME_LINE, ' ', LCD_LINE_WIDTH);   // initialize buffer line

    hm_separator[0] = ':';
    ms_separator[0] = ':';

    temperature_unit_str[0] = TEMPERATURE_GRADE_ENCODING; // defined in lcd.h

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
    AM_PM_str[0] = hours < 12 ? 'A' : 'P';
    AM_PM_str[1] = 'M';      // assumes morning

    if (hours < 13)
    {
        if (hours == 0) return 12U;

        return hours;
    }

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
