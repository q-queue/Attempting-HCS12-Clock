
#ifndef ASCII_UTILS_H_

#define ASCII_UTILS_H_

void unsigned_decToASCII(
    unsigned int number, char* at, unsigned char digits
);

void signed_decToASCII(int number, char* at, unsigned char digits);

void repeat_char(char* str, char c, unsigned char length);

#endif //ASCII_UTILS_H_
