# Clock Timer

Defines the timer interrupts behavior.

- The timer code was rewritten in C to provide better cohesion with the rest of the code base.

## Timer Implementation

### Timer External References

The timer module needs to capture to external references:

```C
// value will be incremented on each timer trigger
static volatile unsigned char* ticker;
    // external reference to be captured at initialization

static void (*in_sync_callback) (void);
```

- `ticker` 8-bit variable which is incremented on each interrupt
- `in_sync_callback` a callback with hard time deadline with low latency tolerance which will be called on each interrupt

### Timer Channel Configuration

The timer is setup to the the 4th timer channel in output capture mode.

```C

#define ENABLE_TIMER_UNT       0x80

// commenting in code form!
#define TIMER_CH4              0x10
#define TIMER_CH               TIMER_CH4

#define PRESCALE_FACTOR        0x07

#define TC                     TC4

#define TCTL_REGISTER          TCTL1

// needs two mask to sets the mode properly!
#define TCTL_MODE_AND_MASKING  0xFC   // set lower two bits to 0 and leaves the rest!
#define TCTL_MODE_OR_MASKING   0x00   // don't set any bits to 1!

// -----------------------------

static void init_timer_uint()
{
    TSCR1 = ENABLE_TIMER_UNT;

    TSCR2 |= PRESCALE_FACTOR;

    TC += SYSTEM_CLOCK_INTERVALS;    // setup next interrupt timer

    TIOS  |= TIMER_CH;    // set as ouput capture mode on the timer channel used

    // sets bits to zero where there are zeros in the mask
    TCTL_REGISTER = TCTL_REGISTER & TCTL_MODE_AND_MASKING;

    // sets bits to one where there are ones in the mask
    TCTL_REGISTER = TCTL_REGISTER | TCTL_MODE_AND_MASKING;

    TIE   |= TIMER_CH;    // enables interrupt on the timer channel
}
```

### Timer ISR Implementation

The timer is implemented as an interrupt service routine which is triggered by the hardware after `SYSTEM_CLOCK_INTERVALS` ticks elapsed as specified external cpu bus clock and the prescale divider factor.

```C
interrupt 12 void TimerISR(void)
{
    TC += SYSTEM_CLOCK_INTERVALS;    // setup next interrupt timer
    TFLG1 |= TIMER_CH;       // clears the interrupt flag

    *ticker += 1;         // indicates how many NEXT_TIMER_TRIGGER have passed

    in_sync_callback();  // hard real time tasks
}

```

## System Clock

Defines how often the interrupt is triggered set be `10ms`.

All counters are configured as multiple of this base interrupt interval.

## Timer Initialization

Function: `init_ticker`

- Parameters:
  - `volatile unsigned char* ticker` capture reference to a ticker variable to be incremented on each interrupt
  - `void (*hard_real_time_task) (void)` low latency tolerance callback which will be triggered on each interrupt

```C
void init_ticker(
    volatile unsigned char* referenced_ticker,
    void (*hard_real_time_task) (void)
){
    // capture reference
    ticker = referenced_ticker;
    in_sync_callback = hard_real_time_task;
    init_timer_uint();
}
```

## Timer Initialization Usage Example

```C
volatile unsigned char ticks;

void poll_buttons(void);

init_ticker(&ticks, poll_buttons);

```
