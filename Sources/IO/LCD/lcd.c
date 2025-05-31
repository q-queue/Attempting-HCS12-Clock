
#include "lcd.h"

// -----------------------------
/********** exported **********/
// -----------------------------

void initLCD(void);    // defined in lcd.asm

void init_LCD(void)
{
    initLCD();         // Initialize the LCD
}

// ----------------------------

void writeLine(void);  // defined in lcd.asm

void write_line(const char *text, char line)
{                      // assembly wrapper
    asm
    {
        LDX  text
        LDAB line
        JSR  writeLine
    }
}
