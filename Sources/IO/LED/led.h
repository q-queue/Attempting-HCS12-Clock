
#ifndef LED_DRIVER_H_

#define LED_DRIVER_H_

void init_LED(void);

void set_LED(unsigned char value);

unsigned char get_LED();

void toggle_LED(unsigned char mask);

#endif // LED_DRIVER_H_
