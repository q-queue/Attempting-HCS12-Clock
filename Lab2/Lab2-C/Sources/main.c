/*  Lab 2 - Main C file for Clock program

    Computerarchitektur 3
    (C) 2018 J. Friedrich, W. Zimmermann
    Hochschule Esslingen

    Author:  W.Zimmermann, July 19, 2017
*/

// Compiler Known Include PATHs
#include <hidef.h>                              // Common defines

#include "clock.h"

void main(void) 
{
    EnableInterrupts;       // Global interrupt enable

    init_clock();

    start_clock_loop();
}
