
#include "render.h"

#include "lcd.h"

// -----------------------------
/*** Global Localized Vars ****/
// -----------------------------

const char* TITLES[] = {
    "(C) IT SS2025",
    "Q, Queue",
    "Mackerels!"
};

// -----------------------------

#define SIZEOF(Array) (sizeof(Array) / sizeof(Array[0]))

static char** starting_title = TITLES;
static char** current_title = TITLES;
static char** titles_boundary = TITLES + SIZEOF(TITLES);

// -----------------------------

void render_title(void)
{
    // render current title and shift the pointer for next title
    write_line(*current_title++, 0);

    // check of out of bound to rewind if needed
    if (current_title >= titles_boundary)
        current_title = starting_title;
}


