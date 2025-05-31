
#include "counter.h"


void init_counter(
    Counter* counter,
    unsigned char reset_on,
    void (*subroutine) (void)
){
    counter->ticker   = 0;                  // set to trigger at next countdown call // used as initializer
    counter->reset    = reset_on -1;        // triggers on the n th tick. resets at zero!
    counter->callback = subroutine;         // called on reset
}

// -------------------------------------------------------------

void countdown(Counter* counter)
{
    if (counter->ticker-- != 0) return;     // no reset yet

    counter->ticker = counter->reset;

    counter->callback();                    // triggers callback on reset
}

// -------------------------------------------------------------

void rewind(Counter* counter)
{
    counter->ticker = counter->reset;
}

