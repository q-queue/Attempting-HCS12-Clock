= Clock Display

Defines how the title/time/temperature to be displayed on the LCD Screen.

Interface with the LCD driver functions defined in `lcd.h`

== Time Render

- Needs to have `ENABLED_AM_PM_MODE` defined to set AM-PM mode.

- Must be initialized first by calling `init_render` to setup the internal buffer.

- Defines the `render_time_function` which is called from the `clock.c` and given the time and temperature as parameters.

=== Time Render Global Variables

- `AM_PM_MODE` AM-PM State
- `TIME_LINE` Buffer to be flushed on the second LCD line when `render_time` is called
  - Buffer size is defined by the `LCD_LINE_WIDTH` defined in `lcd.h`
  - The internal buffer offsets are labeled to allow the time/temperature to be updated independently form one another.
  - The buffer is split into two section to allow for different `LCD_LINE_WIDTH` values.
    - right aligned clock representation
    - left aligned temperature representation
      - A minium line width of $15$ must be accounted for otherwise temperature and time will overlap!

```C
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
```

=== Initialize Time Rendering Buffer

- `TEMPERATURE_GRADE_ENCODING` is specified in `lcd.h` with different values for different compilation targets

```C
void init_render()
{
    repeat_char(TIME_LINE, ' ', LCD_LINE_WIDTH);   // initialize buffer line

    hm_separator[0] = ':';
    ms_separator[0] = ':';

    temperature_unit_str[0] = TEMPERATURE_GRADE_ENCODING; // defined in lcd.h

    temperature_unit_str[1] = 'C';
}
```

=== Updating Rendered Time

Uses `decToASCII`, `signed/unsigned` functions defined in `ASCII-Utils.c` to convert numbers into decimal ASCII representation.

Expect values that is to displayed to be passed as parameters.

```C
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
```

=== Toggle AM-PM

- A global variable is used to keep track of current am-pm mode.

```C
static unsigned char AM_PM_MODE = ENABLED_AM_PM_MODE;
```

- Toggling the AM-PM mode will always sets the `AM_PM_str` as empty spaces. This will be accounted for `represent_hours` function

```C
void toggle_am_pm(void)
{
    AM_PM_str[0] = ' ';
    AM_PM_str[1] = ' ';

    AM_PM_MODE = !AM_PM_MODE;
}
```

#pagebreak()

==== Represent Hours

Hours representation need to be handled by a function to allow toggle am-pm mode in runtime

```C
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
```

== Title Render

- Writes a title to second LCD line by calling `render_title` function.

- Cycles through Titles in the array `TITLES` from the header file `title-render.c` each time the `render_title is called`.


=== Title Renderer Implementation

- One or more Title is defined in the `TITLES` Array.
  - Titles will be cycled each time the title is needed to be updated
- Three global pointer variable are needed to keep track of current/next title
  - `starting_title` points to the first string in the array. Also needed to rewind the titles.
  - `current_title`
  - `titles_boundary` points to end of the arrays

```C
const char* TITLES[] = {
    "(C) IT SS2025",
    "Q, Queue",
    "Mackerels!"
};
// -----------------------------
#define SIZEOF(Array) (sizeof(Array) / sizeof(Array[0]))

static char** starting_title = TITLES;
static char** current_title = TITLES;
static char** titles_boundary = TITLES + SIZEOF(TITLES);

// -----------------------------

void render_title(void)
{
    // render current title and shift the pointer for next title
    write_line(*current_title++, 0);

    // check of out of bound to rewind if needed
    if (current_title >= titles_boundary)
        current_title = starting_title;
}
```

#pagebreak()

== ASCII-Utils

=== decToASCII

==== unsigned_decToASCII

- Parameters:
  - `unsigned int number` to be converted
  - `char* at` starting posting on a string to start writing the digits
  - `unsigned char digits` number of digits to write

- Converts a 16-bit unsigned integer to decimal ASCII representation
- Writes n lower decimal digits into a string.
- Writes leading zeros if number requires less digits than specified.

- Does not adds null termination!

```C
void unsigned_decToASCII(unsigned int number, char* at, unsigned char digits)
{   // writes leading zeros
    unsigned int rest;

    while (digits-- > 0)
    {
        rest = number % 10;
        at[digits] = rest + '0';
        number /= 10;
    }
}
```



#pagebreak()

==== signed_decToASCII

- Parameters:
  - `int number` to be converted
  - `char* at` starting posting on a string to start writing the digits
  - `unsigned char digits` number of digits to write
  - requires one more char for the sign!

- Converts a 16-bit integer to decimal ASCII representation
- Write either a negative sign or empty space for positive numbers.
- Writes n lower decimal digits into a string.
- Writes leading zeros if number requires less digits than specified.

- Does not adds null termination!

```C

void signed_decToASCII(int number, char* at, unsigned char digits)
{ // requires one extra space for the sign
    at[0] = ' ';
    if (number < 0)
    {
        at[0] = '-';
        number = -number; // ~number +1
    }
    unsigned_decToASCII(number, at +1, digits);
}
```

==== repeat_char

- Parameters:
  - `char* str` starting position of the string
  - `char c` character to be repeated
  - `unsigned char length` length of string/repeat count

- used to initialize a string buffer with a specific value.

- Does not adds null termination!

```C
void repeat_char(char* str, char c, unsigned char length)
{
    while (length--) *str++ = c; // countdown loop
}
```