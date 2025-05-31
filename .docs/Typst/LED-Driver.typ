= LED Interface

== LED Initialization

The Function `init_LED` need to be called before using the LED to setup the Data Direction Registry on the `PORTB`

- The Seven Segments Display also needs to disabled when running on board otherwise will the lights might flicker.
  - Because this is not really a part of the clock. Disabling the Seven Segments Display can be done at the same time when initializing the LEDs

```C
static void disable_seven_segment(void)
{
    // will flicker otherwise
    DDRP = 0x0F;    // Port P.3..0 as outputs (seven segment display control)
    PTP  = 0x0F;    // Turn off seven segment display
}

void init_LED(void)
{
    DDRJ_DDRJ1  = 1;    // Port J.1 as output
    PTIJ_PTIJ1  = 0;  
    DDRB        = 0xFF;  // Port B as output
    PORTB       = 0x00;
    disable_seven_segment();    // just hide it here. doesn't really have place elsewhere
}
```

== set LED

Function: `set_LED`

Overwrites the LED register with a given value.

- Parameters:
  - `unsigned char value` value to overwrites the LED state on `PORTB`

```C
    set_LED(0x80);
```

== get LED

Function: `get_LED`

returns the LED register state.

```C
    unsigned char LED_State = get_LED();
```

== toggle LED

Function: `toggle_LED`

Uses a bit select mask to switch LED `on/off` at a specific bit position.

- Parameters:
  - `unsigned char mask` bit select to target a bit position to toggle LED with the xor operator.

```C
    toggle_LED(0x01);
```
