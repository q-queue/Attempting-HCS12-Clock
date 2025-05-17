
#include "counter.h"

void countdown(Counter* counter)
{
    if (counter->ticker-- != 0) return;

    counter->ticker = counter->reset;

    counter->callback();
}

void init_counter(Counter* counter, unsigned char reset_on, void (*subroutine) (void))
{
    counter->ticker   = 0;
    counter->reset    = reset_on -1;
    counter->callback = subroutine;
}


