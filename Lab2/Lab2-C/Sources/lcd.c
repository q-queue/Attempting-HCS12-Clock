
#include "lcd.h"

// -------------------------------------------------------------

// -----------------------------
/********** exported **********/
// -----------------------------

void initLCD(void);             // defined in lcd.asm

void init_LCD(void)
{
    initLCD();              // Initialize the LCD
}

// ----------------------------

void writeLine(void);           // defined in lcd.asm

void write_line(char *text, char line)  // asembly wrapper
{
    asm
    {
        LDX  text
        LDAB line
        JSR  writeLine
    }
}
