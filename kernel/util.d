module kernel.util;

nothrow:
int strlen(const char* str) {
    int len = 0;
    while (str[len])
        len++;
    return len;
}

extern (C) void* memcpy(void* dest, void* src, size_t count) {

    ubyte* d = cast(ubyte*) dest;
    ubyte* s = cast(ubyte*) src;

    for (size_t i = count; i > 0; i--) {
        *d = *s;
        d++;
        s++;
    }

    return dest;
}

extern (C) void* memset(void* dest, ubyte val, size_t count) {
    ubyte* d = cast(ubyte*) dest;
    foreach (i; 0 .. count) {
        *(d++) = val;
    }
    return d;
}
