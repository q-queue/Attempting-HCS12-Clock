= LCD Driver

Provides a way to interface with LCD Screen Device.

== LCD Initialization

Call `init_LCD` to setup the LCD.

== LCD Display Interface Functions

=== Write Line

- Parameters:
  - `const char* text` the string to be written on LCD
  - `char line` the line on which the string will be written

- The use of `const` should have no effect on the functionality and will work when passed a non constant value. This is just a promise from the function not to change values passed to it as a pointer.

== Special Character Encoding

The display device has a special encoding for the temperature celsius grade encoding `°` which is not in the original ASCII standard but form the extended one.

- The encoding differ depending on compilation target.

```C
#ifdef SIMULATOR
    #define TEMPERATURE_GRADE_ENCODING 0xB0
#else
    #define TEMPERATURE_GRADE_ENCODING 0xDF
#endif
```
