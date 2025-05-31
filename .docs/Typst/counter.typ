
= Software Counter

- Implements a software counter that:
  - Countdowns to zero from a starting value
  - When counter hits zeros it resets back to the starting value
  - On Reset a callback is triggered

== Counter Object Like Implementation

Defined as structure `Counter` that is meant emulate object orient use-case:

- By holding a state `ticker` aka. `#attribute`
- And defining function `countdown` that modify the `object` state `#method`

This approach is more or less what the #link("https://go.dev/")[Go Programming Language] takes to implements objects oriented programming features and what is inspiration for the `Counter` module.

- #link("https://go.dev/tour/methods")[Methods in Go]

== Structured Counter

The `Counter` structure holds the following information:

- `ticker` current counter value.
- `reset` reset value when the `ticker` hits zero.
- `callback` a void function pointer to be called on reset.

```C
typedef struct {               // not opaque!

    unsigned char ticker;      // ticking counter until next rest
    // counts how many external clock ticks must go by until reset/trigger

    unsigned char reset;       // periodic countown trigger value

    void (*callback) (void);   // triggered on reset

} Counter;
```

== Counter Functionality

The `counter.h` module defines the following operation `"methods"` on the `Counter` structure `"object"`.

== Initialize Counter

Function: `init_counter`

Initialize a counter structure to abstract some `Counter` implementation details.

- Parameters:
  - `Counter* counter` Pointer to the structure instance.
  - `unsigned char reset_on` Specify when the `counter` to trigger a reset
  - `void (*subroutine) (void)` A callback which runs on rest

#pagebreak()
  
=== Initialize Counter Implementation

- The `counter` is initialized to be triggered on the first `countdown` call

- The `reset_on` value refers to how many time a countdown need to happens until reset. `reset on the n-th tick`
  - `reset_on` value of 1 means reset on every countdown.

```C
void init_counter(
    Counter* counter,
    unsigned char reset_on,
    void (*subroutine) (void)
){
    counter->ticker   = 0;                  // set to trigger at next countdown call // used as initializer
    counter->reset    = reset_on -1;        // triggers on the n th tick. resets at zero!
    counter->callback = subroutine;         // called on reset
}
```

=== Initialize Counter Usage Example

```C
#define BUTTONS_POLLING_RATE     30

void poll_buttons(void);

Counter buttons_polling;

init_counter(&buttons_polling, BUTTONS_POLLING_RATE, poll_buttons);
```

== Counter Countdown

Function: `countdown`

- `countdown` check the current value of the ticker `attribute`
  - After checking `counter->ticker` value will be decremented.
  - If the `ticker` value is zero a reset will be triggered.
  - In case of reset the `ticker` value is assigned the `counter->reset` to count down again from there.
  - A callback is called on reset

== Counter Countdown Implementation

```C
void countdown(Counter* counter)
{
    if (counter->ticker-- != 0) return;     // no reset yet

    counter->ticker = counter->reset;

    counter->callback();                    // triggers callback on reset
}
```

== Counter Countdown Usage Example

```C
countdown(&buttons_polling);
```

== Rewind Counter

Just a counter reset without a callback triggered.
