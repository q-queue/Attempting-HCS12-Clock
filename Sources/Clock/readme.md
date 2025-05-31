# Clock Implementation

## [Clock Configuration Header](clock.h)

Specify Clock internal configuration like:

- Clock Starting Time
  - `CLOCK_INITIALIZED_HOURS`
  - `CLOCK_INITIALIZED_MINUTES`
  - `CLOCK_INITIALIZED_SECONDS`

- Clock AM-PM mode initialized state which should be enabled by default
  - `ENABLED_AM_PM_MODE`
  - This functionality can be changed in runtime
  - In SIMULATOR the `PTH7` is used as a button binding to toggle this state on/off

- Ticking/Polling/Rending rates as multiple of `SYSTEM_CLOCK_INTERVALS` which is `10ms`
  - `CLOCK_TICKING_RATE`
  - `BUTTONS_POLLING_RATE`
  - `THERMOMETER_POLLING_RATE`
  - `LCD_TIME_RENDING_RATE`
  - `LCD_TITLE_RENDING_RATE`

- To achieve longer waiting time than what a 8-bit value can account for the `LCD_TITLE_RENDING_RATE` builds on the `LCD_TIME_RENDING_RATE`
  - In this case on the `50th` time rendering trigger the title will change
  - time is updated once every `200ms` which is `10ms * 20 = 200ms`
  - title is changed every `10 S` which is `10ms * 20 * 50 = 10000ms`

```C
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
```

- Tasks Declaration
  - `polling_task` buttons polling task to be done with the interrupt.
  - `ticking_task` runs once per second and adjusted depending on clock mode.
  - `rendering_task` update LCD display and also poll temperature with a countdown

```C
void polling_task(void);
void ticking_task(void);
void rendering_task(void);

// -----------------------------

void init_clock(void);
```

## [Clock Code Implementation](clock.c)

### Clock Global Variables

All global variables defined in `clock.c` are only accessible only from within the translation unit and are not exported to the other modules.

- The clock needs to keep track current time for which three global variable `hours`, `minutes`, `seconds` and `temperature`.

- The time is saved in `24-Hours` format regardless from the AM-PM Display Mode. The value of the hours will be adjusted accordingly when in the `time-render.c` module.

- Software Counters
  - `clock` ticks clock once per second if in [ticking mode](#ticking-mode)
  - `buttons_polling` triggers the buttons polling callback specified in [poll_buttons](/Sources/IO/Buttons/readme.md#buttons-polling)
  - `thermometer_polling` update the temperature [poll_thermometer](#temperature-polling)
  - `time_rending` update the time and temperature on the second LCD line
    - `title_rending` update the title once every 10 Seconds

```C
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

```

### Clock Operating Modes

#### Ticking Mode

In this mode the seconds are incremented on the 100th countdown tick `10ms` intervals.

- When overflow occurs will trickle down to the increment the `minutes` and eventually the `hours` variable.

```C
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
```

#### Set Mode

In the set mode the clock will not be doing anything. The buttons polling is done from within the interrupt to guarantee consistent polling time.

#### Switching Clock Modes

An initialization callback is triggered each time a clock switch modes

- A Mutating Function Pointer is used!
  - `INIT_NEXT_CLOCK_MODE` is a function pointer that changes after each call!
  - Each clock mode also defines a init function where the next `INIT_NEXT_CLOCK_MODE` is reassigned.

- The enabled buttons is toggled to mask/unmask the increment buttons.
  - This assumes that the initial clock mode is the ticking mode
    - If the clock is to be initialized in set mode, need to change the enabled buttons in [init_buttons](#clock-buttons-initialization)!

```C
// defines a pointer to a void function(void) as a type
typedef void (*Callback)(void);

// defines a pointer to a function that returns a function pointer
typedef Callback (*CallbackInitializer)(void);

// self mutating/mutilating references
// // changes actual subroutine after each call!
static volatile CallbackInitializer INIT_NEXT_CLOCK_MODE;

static void switch_clock_mode(void)
{
    clock.callback = INIT_NEXT_CLOCK_MODE(); // for the next clock event!
}
```

##### Initialize Ticking Mode

- Sets the next initialization function.
- Sets the LED state
- Rewind the clock ticker to start of the second
- Returns the corresponding mode callback to update the counter callback `clock.callback`

```C
// function declaration
// needed for cyclical reference
static Callback init_set_mode(void);

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

```

##### Initialize Set Mode

- Sets the next initialization function.
- Sets the LED state
- Returns the corresponding mode callback to update the counter callback `clock.callback`

```C
#define SET_MODE_LED_STATE 0x80

static Callback init_set_mode(void)
{
    INIT_NEXT_CLOCK_MODE = init_ticking_mode;
    enable_buttons(ENABLE_PTH0 | ENABLE_PTH1 | ENABLE_PTH2);
    set_LED(SET_MODE_LED_STATE);
    return set_mode;
}

```

### Clock Initialization

The clock need to:

- Initialize the Input/Output Peripherals
  - `init_LED`
  - `init_LCD`
  - `init_thermometer`
  - `init_clock_buttons` initialize the buttons register and bind corresponding callbacks

- Initialize the Display render
  - Initialize the second LCD line internal buffer for time/temperature representation

- Initialize the counter with the callback binding and the reset values as configured in the `clock.h`

```C
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
```

#### Clock Buttons Initialization

- `init_buttons` must be called first before binding callback in the `BUTTONS_CALLBACK_REGISTRAR`
  - By default `PTH3` is used to switch clock mode should never be masked
  - The `PTH7` toggles the AM-PM state by calling `toggle_am_pm` which is defined in [time-render.c](Display/readme.md#toggle-am-pm)
    - There is no corresponding physical buttons on the board this is only useable in the SIMULATOR

```C
static void init_clock_buttons(void)
{
    init_buttons(ENABLE_PTH3 | ENABLE_PTH7);

    BUTTONS_CALLBACK_REGISTRAR[PTH3_TABLE_ENTRY] = switch_clock_mode;
    BUTTONS_CALLBACK_REGISTRAR[PTH7_TABLE_ENTRY] = toggle_am_pm;

    BUTTONS_CALLBACK_REGISTRAR[PTH2_TABLE_ENTRY] = inc_hours;
    BUTTONS_CALLBACK_REGISTRAR[PTH1_TABLE_ENTRY] = inc_minutes;
    BUTTONS_CALLBACK_REGISTRAR[PTH0_TABLE_ENTRY] = inc_seconds;
}
```

#### Increment Buttons Definitions

- The increment doesn't carries over.
- A reference to the callbacks registered in the `BUTTONS_CALLBACK_REGISTRAR`
- Masked in ticking mode and will be ignored except in set mode

```C
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
```

### Counter Callbacks

#### Temperature Polling

- Update the global variable `temperature`
- Wrapped the in a callback to be be passed to a software counter

```C
static void poll_temperature(void)
{
    temperature = poll_thermometer();
}
```

#### Display rendering Countdown

The clock interface with `time-render.c` by calling `render_time` and passes required values as parameter to avoid exporting global variables.

- The title rending counter piggy-back on the time rendering so that on the $n_{th}$ the time is updated the title changes
  - set to be $50$ times the time rending rate which is once per `200ms`

```C
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
```

- In the clock init function the callback and the reset value are set.

```C
init_counter(&time_rending, LCD_TIME_RENDING_RATE, lcd_rendering_callback);

// triggered on the nth time the time_reding resets!
init_counter(&title_rending, LCD_TITLE_RENDING_RATE, render_title);

```

## Clock Tasks

Tasks are called from the `main.c` modules which tries to synchronizes with the timer interrupt.

### Polling Task

Noticeable by the end user if not done with exact timing.

Need to be done from inside the interrupt.

```C
void polling_task(void)
{
    // must be done in regular intervals -> called from within the interrupt
    countdown(&buttons_polling);
}
```

### Ticking Task

Must catch up to the interrupt clock and callback changes depending on clock mode.

```C
void ticking_task(void)
{
    // allowed to lag a bit behind. But need to catch up eventually!
    countdown(&clock);
}
```

### Rending Task

Can deal with more latency and even skip a couple of ticks

```C
void rendering_task(void)
{
    countdown(&thermometer_polling);
    countdown(&time_rending);
}
```
