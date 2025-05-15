
#ifndef RENDER_H_

#define RENDER_H_

#ifndef _HCS12_SERIALMON
    #ifndef SIMULATOR 
        #define SIMULATOR
    #endif
#endif

void init_time_render(void);

void render_time(
    unsigned char hours,
    unsigned char minutes,
    unsigned char seconds,
    int temperature
);

void toggle_am_pm(void);

void init_title_render(char** titles, unsigned char count);

// cycles through titles
void render_title(void);

#endif RENDER_H_
