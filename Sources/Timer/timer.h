
#ifndef TIMER_H_

#define TIMER_H_    // Header Guards!

#define TEN_MS                   1875
#define HUNDRED_MS               18750

#define SYSTEM_CLOCK_INTERVALS   TEN_MS

void init_ticker(
    volatile unsigned char*,
    void (*hard_real_time_task) (void)
);

#endif // TIMER_H_
