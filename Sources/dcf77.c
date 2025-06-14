/*  Radio signal clock - DCF77 Module

    Computerarchitektur 3
    (C) 2018 J. Friedrich, W. Zimmermann Hochschule Esslingen

    Author:   W.Zimmermann, Jun  10, 2016
    Modified: -
*/

/*
; A C H T U N G:  D I E S E  S O F T W A R E  I S T  U N V O L L S T ? N D I G
; Dieses Modul enth?lt nur Funktionsrahmen, die von Ihnen ausprogrammiert werden
; sollen.
*/


#include <hidef.h>                                      // Common defines
#include <mc9s12dp256.h>                                // CPU specific defines
#include <stdio.h>

#include "dcf77.h"
#include "led.h"
#include "clock.h"
#include "lcd.h"

// Global variable holding the last DCF77 event
DCF77EVENT dcf77Event = NODCF77EVENT;

// Modul internal global variables
static char dcf77Month   = 1,
            dcf77Day     = 1,
            dcf77Hour    = 0,
            dcf77Minute  = 0,
            dcf77Weekday = 7;       //dcf77 Date and time as integer values

static int dcf77Year     = 2017;

static char DC77_UTC_TIME_ZONE = +2;    // CEST

// Prototypes of functions simulation DCF77 signals, when testing without
// a DCF77 radio signal receiver
void initializePortSim(void);                   // Use instead of initializePort() for testing
char readPortSim(void);                         // Use instead of readPort() for testing

// ****************************************************************************
// Initalize the hardware port on which the DCF77 signal is connected as input
// Parameter:   -
// Returns:     -
void initializePort(void)
{
    DDRH = 0x00;    // Data Direction Input
    PIEH = 0x00;    // disable interrupt. polling is used
}

// ****************************************************************************
// Read the hardware port on which the DCF77 signal is connected as input
// Parameter:   -
// Returns:     0 if signal is Low, >0 if signal is High
#ifdef SIMULATOR
    #define readPort readPortSim
#else

    static char readPortBoard(void)
    {
        return PTH & 0x01;
    }

    #define readPort readPortBoard
#endif


// ****************************************************************************
//  Initialize DCF77 module
//  Called once before using the module
void initDCF77(void)
{
    setClock(dcf77Hour, dcf77Minute, 0, dcf77Day, dcf77Month, dcf77Year, dcf77Weekday, DC77_UTC_TIME_ZONE);
    displayDateDcf77();
    
    setLED(0x04);

    initializePort();
}


// ****************************************************************************
//  Read and evaluate DCF77 signal and detect events
//  Must be called by user every 10ms
//  Parameter:  Current CPU time base in milliseconds
//  Returns:    DCF77 event, i.e. second pulse, 0 or 1 data bit or minute marker



DCF77EVENT sampleSignalDCF77(int currentTime)
{
    static char last_sample;
    static unsigned int T_low, T_pulse, falling_edge = 0;
    static unsigned int last_valid_sample = 0;

    DCF77EVENT event = NODCF77EVENT;

    char sample = readPort();

    if (sample != last_sample) // Flanke erkannt
    {
        toggleLED(0x01);       // Req 1.3

        if (last_sample != 0 && sample == 0)
        {
            // falling edge
            // start capture low pulse duration
            T_pulse = currentTime - falling_edge;   // calculate last pulse duration
            falling_edge = currentTime;             // rest pulse

            setLED(0x02);   // Req 1.4

            if (T_pulse >= 900U && T_pulse <= 1100U)       event = VALID_SECOND;
            else if (T_pulse >= 1900U && T_pulse <= 2100U) event = VALID_MINUTE;
            else                                           event = INVALID;
        }
        else
        {   // must be rising edge then
            T_low = currentTime - falling_edge;

            clrLED(0x02);   // Req 1.4

            if (T_low >= 70 && T_low <= 130U)       event = VALID_ZERO;
            else if (T_low >= 170 && T_low <= 230U) event = VALID_ONE;
            else                                    event = INVALID;
        }

        last_sample = sample;   // update changed sample
        last_valid_sample = 0;
    } else {
        if (last_valid_sample > 220U)  // longest valid pulse value  // multiple of 10ms
          return INVALID;
        last_valid_sample++;    
    }

    return event;
}


// ****************************************************************************

static const char TRANSMISSION_BIT_WEIGHT[] = {
    1,  2,  4,  8,     // first  digit positional bit values multipliers
    10, 20, 40, 80     // second digit positional bit values multipliers
};

// -------------------------------------------------------------
/******************** Finite State Machine ********************/
// -------------------------------------------------------------

static void wait_for_minute_end(DCF77EVENT event);

#define RESET_FSM wait_for_minute_end

static volatile void (*transition)(DCF77EVENT event) = RESET_FSM;

// -----------------------------
/******* Perceived Time *******/
// -----------------------------

// only flushed on the one minute transmission validation

static char valid_transmission = 0;
static char received_bit = 0;
static char parity = 0;

static char recived_timezone = 0;

static char received_hours = 0;
static char received_minutes = 0;

static char received_month_day = 0;
static char received_week_day = 0;
static char received_month = 0;
static char received_year = 0;

// -------------------------------------------------------------

static void synchronize_clock(void)
{
    #define CENTURY_OFFSET 2000U // won't change again in my life time

    dcf77Year   = received_year + CENTURY_OFFSET;
    dcf77Month  = received_month;
    dcf77Day    = received_month_day;

    dcf77Weekday = received_week_day;

    dcf77Hour   = received_hours;
    dcf77Minute = received_minutes;
    
    DC77_UTC_TIME_ZONE = recived_timezone;

    setClock(
        dcf77Hour, dcf77Minute, 0,
        dcf77Day, dcf77Month, dcf77Year,
        dcf77Weekday,
        DC77_UTC_TIME_ZONE
    );

    setLED(0x08);   // Req 1.5
    clrLED(0x04);
}

// -------------------------------------------------------------

static void decode_year(DCF77EVENT event)
{
    char bit = (event == VALID_ONE) ? 1 : 0;

    if (received_bit == 58) // check parity
    {
        transition = RESET_FSM;

        valid_transmission = (parity == bit); // if not valid won't sync!

        return;
    }

    received_year += bit * TRANSMISSION_BIT_WEIGHT[received_bit - 50]; // week day bit weighted offset

    parity ^= bit;
}

// ----------------------------

static void decode_month(DCF77EVENT event)
{
    char bit = (event == VALID_ONE) ? 1 : 0;

    received_month += bit * TRANSMISSION_BIT_WEIGHT[received_bit - 45]; // week day bit weighted offset

    parity ^= bit;

    if (received_bit == 49)
        transition = decode_year;
}

// ----------------------------

static void decode_week_day(DCF77EVENT event)
{
    char bit = (event == VALID_ONE) ? 1 : 0;

    received_week_day += bit * TRANSMISSION_BIT_WEIGHT[received_bit - 42]; // week day bit weighted offset

    parity ^= bit;

    if (received_bit == 44)
        transition = decode_month;
}

// ----------------------------

static void decode_month_day(DCF77EVENT event)
{
    char bit = (event == VALID_ONE) ? 1 : 0;

    received_month_day += bit * TRANSMISSION_BIT_WEIGHT[received_bit - 36]; // month day bit weighted offset

    parity ^= bit;

    if (received_bit == 41)
        transition = decode_week_day;
}

// ----------------------------

static void decode_hours(DCF77EVENT event)
{
    char bit = (event == VALID_ONE) ? 1 : 0;

    if (received_bit == 35) // check parity
    {
        if (parity != bit) transition = RESET_FSM;   // invalid
        else {
            parity = 0;     // common used resource!
            transition = decode_month_day;
        }
        return;
    }

    parity ^= bit;

    received_hours += bit * TRANSMISSION_BIT_WEIGHT[received_bit - 29]; // hours bit weighted offset
}

// ----------------------------

static void decode_minutes(DCF77EVENT event)
{
    char bit = (event == VALID_ONE) ? 1 : 0;

    if (received_bit == 28) // check parity
    {
        if (parity != bit) transition = RESET_FSM;   // invalid
        else {
            parity = 0;     // common used resource!
            transition = decode_hours;
        }
        return;
    }

    parity ^= bit;

    received_minutes += bit * TRANSMISSION_BIT_WEIGHT[received_bit - 21]; // minutes bit weighted offset
}

// ----------------------------

static void validate_minutes_transmission_start(DCF77EVENT event)
{
    if (event != VALID_ONE)
    {
        // invalid transmission!
        transition = RESET_FSM;
        return;
    }
    transition = decode_minutes;
}

// ----------------------------

static void decode_clock_info(DCF77EVENT event)
{
    static char CLOCK_INFO[20];
    
    CLOCK_INFO[received_bit] = (event == VALID_ONE) ? 1 : 0;
        

    #define CLOCK_INFO_BITS 19     // TODO: less skipping

    if (received_bit < CLOCK_INFO_BITS) return;
    
    if (CLOCK_INFO[0] != 0)
    {
          transition = RESET_FSM;   // invalid  
          return;
    }
    
    if      (CLOCK_INFO[17] == 0 && CLOCK_INFO[18] == 1)  recived_timezone = +1;    // CET
    else if (CLOCK_INFO[17] == 1 && CLOCK_INFO[18] == 0)  recived_timezone = +2;    // CEST
    else                                                  { /*ERROR pass??*/ }

    // reset and transition state
    transition = validate_minutes_transmission_start;
}

// ----------------------------

static void wait_for_minute_end(DCF77EVENT event)
{
    if (event != VALID_MINUTE)  // stay in waiting if FSM encounter invalid state
    {
        setLED(0x04);   // Req 1.5
        clrLED(0x08);
        valid_transmission = 0; // de-validate transmission sequence without proper stop
        transition = RESET_FSM; // it's a trap
        return;
    }

    if (valid_transmission)
        synchronize_clock();    // flush values

    // rest FSM State

    parity = 0;
    received_bit = 0;
    valid_transmission = 0;

    received_hours = 0;
    received_minutes = 0;

    received_month_day = 0;
    received_week_day = 0;
    received_month = 0;
    received_year = 0;

    transition = decode_clock_info;
}

// ****************************************************************************
// Process the DCF77 events
// Contains the DCF77 state machine
// Parameter:   Result of sampleSignalDCF77 as parameter
// Returns:     -
void processEventsDCF77(DCF77EVENT event)
{
    switch (event)
    {
        case INVALID:
        case VALID_MINUTE:
            RESET_FSM(event);
            break;

        case VALID_ONE:
        case VALID_ZERO:
            transition(event);
            received_bit++;
            break;
    }
}
