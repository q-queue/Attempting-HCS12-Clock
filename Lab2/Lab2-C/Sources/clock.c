
#include "clock.h"

#include "thermometer.h"
#include "buttons.h"
#include "render.h"
#include "ticker.h"
#include "counter.h"
#include "lcd.h"
#include "led.h"

// -----------------------------
/****** Global variables ******/
// -----------------------------

#define CLOCK_TICKING_RATE       100
#define BUTTONS_POLLING_RATE     30
#define THERMOMETER_POLLING_RATE 150

#define LCD_TIME_RENDING_RATE    25
#define LCD_TITLE_RENDING_RATE   40
    // Title refresh rate is a multiple of Time one!

unsigned char hours   = 23;
unsigned char minutes = 59;
unsigned char seconds = 45;

int temperature;    // doesn't make much sense to initialize

// -----------------------------

// Time Keeper / External Cock / should be in 10ms tact!

unsigned char timer_ticks = 0;

Counter clock;

Counter buttons_polling;

Counter thermometer_polling;

Counter time_rending, title_rending;

// -----------------------------
/*** Local Bound Functions ****/
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

static void init_ticking_mode(void)
{
    set_LED(0x00);  // turn off LED
    // reset clock ticker to start at the start of the second
    clock.ticker = clock.reset;
}

// ------------

static void set_mode(void) {}   // do nothing just poll buttons

#define SET_MODE_LED_STATE 0x80

static void init_set_mode(void)
{
    set_LED(SET_MODE_LED_STATE);
}

// ------------


void (*CLOCK_MODE)(void) = ticking_mode;
void (*NEXT_CLOCK_MODE)(void) = set_mode;

void (*INIT_CLOCK_MODE)(void) = init_ticking_mode;
void (*INIT_NEXT_CLOCK_MODE)(void) = init_set_mode;


// ------------

static void switch_clock_mode(void)
{
    void (*T)(void) = INIT_NEXT_CLOCK_MODE;
    INIT_NEXT_CLOCK_MODE = INIT_CLOCK_MODE;
    INIT_CLOCK_MODE = T;

    INIT_CLOCK_MODE();

    T = NEXT_CLOCK_MODE;
    NEXT_CLOCK_MODE = CLOCK_MODE;
    CLOCK_MODE = T;

    clock.callback = T; // for the next clock event!

    toggle_enable_buttons(ENABLE_PTH0 | ENABLE_PTH1 | ENABLE_PTH2);
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

    BUTTONS_ENTRIES_TABLE[PTH3_TABLE_ENTRY] = switch_clock_mode;
    BUTTONS_ENTRIES_TABLE[PTH7_TABLE_ENTRY] = toggle_am_pm;

    BUTTONS_ENTRIES_TABLE[PTH2_TABLE_ENTRY] = inc_hours;
    BUTTONS_ENTRIES_TABLE[PTH1_TABLE_ENTRY] = inc_minutes;
    BUTTONS_ENTRIES_TABLE[PTH0_TABLE_ENTRY] = inc_seconds;
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

// -----------------------------

char* TITLES[] = {
    "Clock Template",
    "(C) HE Prof. Z",
    "(C) IT SS2025",
    "String 1",
    "Zeichenkette 2",
    "ONE MORE TITLE!",
    "Mackerels!"
};

#define SIZEOF(Array) (sizeof(Array) / sizeof(Array[0]))

// -----------------------------

void init_clock(void)
{
    init_LED();
    init_LCD();
    init_clock_buttons();
    init_thermometer();

    init_time_render();
    init_title_render(TITLES, SIZEOF(TITLES));

    init_counter(&clock, CLOCK_TICKING_RATE, CLOCK_MODE);
    INIT_CLOCK_MODE();  // no point in dereferencing

    init_counter(&buttons_polling, BUTTONS_POLLING_RATE, poll_buttons);

    init_counter(&thermometer_polling, THERMOMETER_POLLING_RATE, poll_temperature);

    init_counter(&time_rending, LCD_TIME_RENDING_RATE, lcd_rendering_callback);

    // triggered on the nth time the time_reding resets!
    init_counter(&title_rending, LCD_TITLE_RENDING_RATE, render_title);
}

void start_clock_loop(void)
{

    init_ticker(&timer_ticks);   // towards semaphore-ish behaviour.

    for(;;)                      // Endless loop
    {
        while (timer_ticks != 0) // catch up if more than one tick went by!
        {
          timer_ticks--;

          countdown(&buttons_polling);
          countdown(&clock);
          countdown(&thermometer_polling);
          countdown(&time_rending);
        }
    }
}