
#ifndef RENDER_H_

#define RENDER_H_

#include "clock.h"

void init_render(void);

void render_time(
    unsigned char hours,
    unsigned char minutes,
    unsigned char seconds,
    int temperature
);

void toggle_am_pm(void);

// cycles through titles
void render_title(void);

#endif RENDER_H_
