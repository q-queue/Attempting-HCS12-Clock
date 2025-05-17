
#include "render.h"

#include "lcd.h"

// -----------------------------
/****** Global variables ******/
// -----------------------------

static char** starting_title;
static char** current_title;
static char** titles_boundary;

// -----------------------------

void init_title_render(char** titles, unsigned char count)
{
    // assumes LCD initialised! too complected otherwise!
    starting_title = titles;
    current_title = titles;
    titles_boundary = titles + count;
}

// -----------------------------

void render_title(void)
{
    write_line(*current_title++, 0);

    if (current_title >= titles_boundary)
        current_title = starting_title;
}


