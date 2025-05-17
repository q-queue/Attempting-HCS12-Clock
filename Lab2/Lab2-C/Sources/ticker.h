
#ifndef TICKER_H_

#define TICKER_H_    // Header Guards!

void init_ticker(
    unsigned char*,
    void (*hard_real_time_task) (void)
);

#endif // TICKER_H_
