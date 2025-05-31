
#ifndef LCD_DRIVER_H_

#define LCD_DRIVER_H_

        // wrapper definitions for the lcd.asm

#define LCD_LINE_WIDTH 16

void init_LCD(void);

void write_line(const char *text, char line);

// -----------------------------

#ifndef _HCS12_SERIALMON
    #ifndef SIMULATOR 
        #define SIMULATOR
    #endif
#endif

#ifdef SIMULATOR
    #define TEMPERATURE_GRADE_ENCODING 0xB0
#else
    #define TEMPERATURE_GRADE_ENCODING 0xDF
#endif

#endif // LCD_DRIVER_H_
