
#include "ASCII-Utils.h"

void unsigned_decToASCII(unsigned int number, char* at, unsigned char digits)
{
    // writes leading zeros

    unsigned int rest;

    while (digits-- > 0)
    {
        rest = number % 10;
        at[digits] = rest + '0';
        number /= 10;
    }
}

void signed_decToASCII(int number, char* at, unsigned char digits)
{
    // requires one extra space for the sign

    at[0] = ' ';

    if (number < 0)
    {
        at[0] = '-';
        number = -number; // ~number +1
    }

    unsigned_decToASCII(number, at +1, digits);
}

// ----------------------------

void repeat_char(char* str, char c, unsigned char length)
{
    while (length--) *str++ = c; // countdown loop
}
