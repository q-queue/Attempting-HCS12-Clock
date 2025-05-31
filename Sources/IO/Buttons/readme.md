# Buttons

Provide a way to interface with input buttons on the Dragon Board12.

## Buttons Initialization

The `init_buttons` function must be called at the start before configuring the buttons with the initial enabled buttons state.

- To enable buttons labels are specified like `ENABLE_PTH3`
- To enable multiple buttons bitwise or `|` is needed with the buttons enable label.

- The buttons callback is set to an empty callback in the initialization phase which will overwrite any registered callback. That is why the `init_buttons` must be called first!

```C
    init_buttons(ENABLE_PTH3 | ENABLE_PTH7);
```

## Enabled Buttons Mask

A global variable `enabled` is used to mask buttons.

```C
static volatile unsigned char enabled = 0x00;
```

- The variable `enabled` is only defined in the [buttons.c](buttons.c) translation unit to protect it and make it only accessible by intended functions.

- When polling the buttons the enabled mask is used in an and mask to ignore a button press on a disabled button

- Due to reverse polarity `active-low/active-high` when compiling for `SIMULATOR/MONITOR` targets an assembler directive is used to change the function like macro definition

```C
#ifdef SIMULATOR
    // inlined
        #define poll_buttons_state() (PTH & enabled)
    #else
        #define poll_buttons_state() (~PTH & enabled)
#endif
```

## Buttons Call Back Registrar

Array of function pointers to bind a callback when a buttons is pressed.

- A label is used to specify the button table entry like `PTH0_TABLE_ENTRY`

```C
    BUTTONS_CALLBACK_REGISTRAR[PTH3_TABLE_ENTRY] = switch_clock_mode;
    BUTTONS_CALLBACK_REGISTRAR[PTH7_TABLE_ENTRY] = toggle_am_pm;

    BUTTONS_CALLBACK_REGISTRAR[PTH2_TABLE_ENTRY] = inc_hours;
    BUTTONS_CALLBACK_REGISTRAR[PTH1_TABLE_ENTRY] = inc_minutes;
    BUTTONS_CALLBACK_REGISTRAR[PTH0_TABLE_ENTRY] = inc_seconds;
```

## Toggle Enabled Buttons

Use the XOR operator `^` with a bit select mask to toggle the enable state of the buttons like is required when switching clock modes.

```C
    toggle_enabled_buttons(ENABLE_PTH0 | ENABLE_PTH1 | ENABLE_PTH2);
```

## Buttons Polling

This is done by calling the `poll_buttons` function.

- First the current buttons state is polled.
  - To account for active `low/high` polarity state the register will be negated if needed depending on compilation target
  - The buttons register is masked be the enabled bit select mask to ignore disabled buttons

- A loop test the state of the buttons at a specific bit
  - If the bit is set to 1 this means the buttons is pressed
  - If a buttons is pressed a callback from the `BUTTONS_CALLBACK_REGISTRAR` is triggered
  - The `mask` variable shifted to test next bit position.

```C
void poll_buttons(void)
{
    unsigned char i;

    unsigned char mask = 1;
        // shifted to test the buttons register at a specific bit

    unsigned char buttons = poll_buttons_state();
        // current buttons state normalized to be true if pressed independent from compilation target
        // buttons state is masked by enabled buttons!

    for (i = 0; i < BUTTONS_COUNT; i++)
    {   // loops over all registered callbacks and call the ones with active button state
        if (mask & buttons)
            BUTTONS_CALLBACK_REGISTRAR[i]();

        mask = mask << 1;
    }
}
```
