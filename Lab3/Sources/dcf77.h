/*  Header for DCF77 module

    Computerarchitektur 3
    (C) 2018 J. Friedrich, W. Zimmermann Hochschule Esslingen

    Author:   W.Zimmermann, Jun  10, 2016
    Modified: -
*/

#ifndef _HCS12_SERIALMON
    #ifndef SIMULATOR 
        #define SIMULATOR
    #endif
#endif

// Data type for DCF77 signal events
typedef enum { NODCF77EVENT, VALID_ZERO, VALID_ONE, VALID_SECOND, VALID_MINUTE, INVALID } DCF77EVENT;

// Global variable holding the last DCF77 event
extern DCF77EVENT dcf77Event;

// Public functions, for details see dcf77.c
void initDCF77(void);
DCF77EVENT sampleSignalDCF77(int currentTime);
void processEventsDCF77(DCF77EVENT event);

