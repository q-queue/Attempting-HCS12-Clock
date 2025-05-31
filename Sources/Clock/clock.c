
#include "clock.h"

#include "thermometer.h"
#include "buttons.h"
#include "render.h"
#include "counter.h"
#include "lcd.h"
#include "led.h"

// -----------------------------
/****** Global variables ******/
// -----------------------------

// values assumes 10ms tact.

static unsigned char hours   = CLOCK_INITIALIZED_HOURS;
static unsigned char minutes = CLOCK_INITIALIZED_MINUTES;
static unsigned char seconds = CLOCK_INITIALIZED_SECONDS;

static int temperature;    // doesn't make much sense to initialize

// ------------

// Time Keeper / External Clock / should be in 10ms tact!

static Counter clock;

static Counter buttons_polling;

static Counter thermometer_polling;

static Counter time_rending, title_rending;

// -----------------------------
/*** Local Bound Functions ****/
// -----------------------------

// defines a pointer to a void function(void) as a type
typedef void (*Callback)(void);

// defines a pointer to a function that returns a function pointer
typedef Callback (*CallbackInitializer)(void);

// Yes we can! Static Cyclical Reference!! Not in Python
static Callback init_set_mode(void);

// self mutating/mutilating references
// // changes actual subroutine after each call!
static volatile CallbackInitializer INIT_NEXT_CLOCK_MODE = init_set_mode;

// -----------------------------

#define TICKING_MODE_LED_MASK 0x01

static void ticking_mode(void)
{
    toggle_LED(TICKING_MODE_LED_MASK);

    seconds++;
    if (seconds >= 60)
    {
        seconds = 0;
        minutes++;
        if (minutes >= 60)
        {
            minutes = 0;
            hours++;
            if (hours >= 24)
            {
                hours = 0;
            }
        }
    }
}

#define TICKING_MODE_LED_MASK 0x00

static Callback init_ticking_mode(void)
{
    INIT_NEXT_CLOCK_MODE = init_set_mode;

    disable_buttons(ENABLE_PTH0 | ENABLE_PTH1 | ENABLE_PTH2);

    set_LED(TICKING_MODE_LED_MASK);  // turn off LED

    rewind(&clock);
        // reset clock ticker to start at the start of the second

    return ticking_mode;
}

// ------------

static void set_mode(void) {}   // do nothing just poll buttons

#define SET_MODE_LED_MASK 0x80

static Callback init_set_mode(void)
{
    INIT_NEXT_CLOCK_MODE = init_ticking_mode;
    enable_buttons(ENABLE_PTH0 | ENABLE_PTH1 | ENABLE_PTH2);
    set_LED(SET_MODE_LED_MASK);
    return set_mode;
}


// ------------

static void switch_clock_mode(void)
{
    // for the next clock event!
    clock.callback = INIT_NEXT_CLOCK_MODE();
}

// -----------------------------

static void inc_hours(void)
{
    hours++;
    if (hours >= 24)
        hours = 0;
}

// ------------

static void inc_minutes(void)
{
    minutes++;
    if (minutes >= 60)
        minutes = 0;
}

// ------------

static void inc_seconds(void)
{
    seconds++;
    if (seconds >= 60)
        seconds = 0;
}

// ------------

static void init_clock_buttons(void)
{
    init_buttons(ENABLE_PTH3 | ENABLE_PTH7);

    BUTTONS_CALLBACK_REGISTRAR[PTH3_TABLE_ENTRY] = switch_clock_mode;
    BUTTONS_CALLBACK_REGISTRAR[PTH7_TABLE_ENTRY] = toggle_am_pm;

    BUTTONS_CALLBACK_REGISTRAR[PTH2_TABLE_ENTRY] = inc_hours;
    BUTTONS_CALLBACK_REGISTRAR[PTH1_TABLE_ENTRY] = inc_minutes;
    BUTTONS_CALLBACK_REGISTRAR[PTH0_TABLE_ENTRY] = inc_seconds;
}

// -----------------------------

static void poll_temperature(void)
{
    temperature = poll_thermometer();
}

// -----------------------------

static void lcd_rendering_callback(void)
{
    render_time(
        hours,
        minutes,
        seconds,
        temperature
    );
    // dependent countdown
    countdown(&title_rending);  // and tick down title counter
}

// -------------------------------------------------------------

// -----------------------------
/********** exported **********/
// -----------------------------

void polling_task(void)
{
    // must be done in regular intervals -> called from within the interrupt
    countdown(&buttons_polling);
}

// ------------

void ticking_task(void)
{
    // allowed to lag a bit behind. But need to catch up eventually!
    countdown(&clock);
}

// ------------

void rendering_task(void)
{
    countdown(&thermometer_polling);
    countdown(&time_rending);
}

// -----------------------------

void init_clock(void)
{
    // -------------
    /** Init IO ***/
    // -------------

    init_LED();
    init_LCD();
    init_clock_buttons();
    init_thermometer();

    // ------------

    init_render();

    // ------------

    init_counter(&clock, CLOCK_TICKING_RATE, init_ticking_mode());

    init_counter(&buttons_polling, BUTTONS_POLLING_RATE, poll_buttons);

    init_counter(&thermometer_polling, THERMOMETER_POLLING_RATE, poll_temperature);

    init_counter(&time_rending, LCD_TIME_RENDING_RATE, lcd_rendering_callback);

    // triggered on the nth time the time_reding resets!
    init_counter(&title_rending, LCD_TITLE_RENDING_RATE, render_title);
}

