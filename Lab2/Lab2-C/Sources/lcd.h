
#ifndef LCD_DRIVER_H_

#define LCD_DRIVER_H_

        // wrapper definitions for the lcd.asm

void init_LCD(void);

void write_line(char *text, char line);

#endif // LCD_DRIVER_H_
