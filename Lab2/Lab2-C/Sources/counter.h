
#ifndef COUNTER_H_

#define COUNTER_H_

typedef struct {                // not opaque!

    unsigned char ticker;   // initial waiting time for first trigger
    // counts how many external clock ticks must go by until reset/trigger

    unsigned char reset;    // periodic countown trigger value

    void (*callback) (void);  // triggered on reset

} Counter;

void countdown(Counter*);         // decrement until resets and then triggers the callback

// triggers on next tick by default
// resets on the N th tick
// reset value of 1 means in sync with external clock
void init_counter(Counter*, unsigned char reset_on, void (*subroutine) (void));

#endif // COUNTER_H_
