
#ifndef BUTTONS_DRIVER_H_

#define BUTTONS_DRIVER_H_

#define BUTTONS_COUNT 8

#ifndef _HCS12_SERIALMON
    #ifndef SIMULATOR 
        #define SIMULATOR
    #endif
#endif

// Labels already defined under similar names in mc9s12dp256.h!
    // 23562 line files should only be looked into once!
        // just want to make it a bit easier to change stuff if needed
#define PTH0_TABLE_ENTRY     0U
#define PTH1_TABLE_ENTRY     1U
#define PTH2_TABLE_ENTRY     2U
#define PTH3_TABLE_ENTRY     3U
#define PTH4_TABLE_ENTRY     4U
#define PTH5_TABLE_ENTRY     5U
#define PTH6_TABLE_ENTRY     6U
#define PTH7_TABLE_ENTRY     7U

#define ENABLE_PTH0         1U
#define ENABLE_PTH1         2U
#define ENABLE_PTH2         4U
#define ENABLE_PTH3         8U
#define ENABLE_PTH4         16U
#define ENABLE_PTH5         32U
#define ENABLE_PTH6         64U
#define ENABLE_PTH7         128U

void init_buttons(unsigned char enable_initial_state);

extern void (*BUTTONS_CALLBACK_REGISTRAR[BUTTONS_COUNT])(void);   // only after initialization!

void toggle_enable_buttons(unsigned char mask);

void poll_buttons(void);

#endif // BUTTONS_DRIVER_H_
