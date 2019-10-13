module kernel.console;

import kernel.drivers.io;
import kernel.util;

nothrow:

enum VIDEO_ADDR = 0xB8000;

enum VColor : ubyte {
    BLACK = 0x0,
    BLUE = 0x1,
    GREEN = 0x2,
    CYAN = 0x3,
    RED = 0x4,
    MAGENTA = 0x5,
    BROWN = 0x6,
    GRAY = 0x7,
    DARK_GREY = 0x8,
    BRIGHT_BLUE = 0x9,
    BRIGHT_GREEN = 0xA,
    BRIGHT_CYAN = 0xB,
    BRIGHT_RED = 0xC,
    BRIGHT_MAGENTA = 0xD,
    YELLOW = 0xE,
    WHITE = 0xF,
}

struct Console {
static:
    __gshared {
        int x = 0;
        int y = 0;
        VColor fgcolor = VColor.WHITE;
        VColor bgcolor = VColor.BLACK;
    }
nothrow:
    void putChar(char ch) {
        putChar(ch, fgcolor, bgcolor);
    }

    void enableCursor() {
        enum SCANLINE_LOW = 0, SCANLINE_HIGH = 1;
        outb(0x3D4, 0x0A);
        outb(0x3D5, (inb(0x3D5) & 0xC0) | SCANLINE_LOW);

        outb(0x3D4, 0x0B);
        outb(0x3D5, (inb(0x3D5) & 0xE0) | SCANLINE_HIGH);
    }

    void setCursorPos(uint x, uint y) {
        setCursorPos(cast(ushort) x, cast(uint) y);
    }

    void setCursorPos(ushort x, ushort y) {
        ushort cursor_pos = cast(ushort)(y * 80 + x);

        outb(0x3D4, 0x0F);
        outb(0x3D5, cast(ubyte)(cursor_pos & 0xFF));
        outb(0x3D4, 0x0E);
        outb(0x3D5, cast(ubyte)((cursor_pos >> 8) & 0xFF));
    }

    void scroll(uint n) {
        if (n > 25) {
            clearScreen();
            return;
        }

        for (int i = n; i <= 25; i++) {
            auto src = cast(ubyte*)(VIDEO_ADDR + (i * 80 * 2));
            auto dest = cast(ubyte*)(VIDEO_ADDR + ((i - n) * 80 * 2));
            memcpy(dest, src, 80 * 2);
        }

        for (int i = 25; i >= 25 - n; i--) {
            auto mem = cast(ubyte*)(VIDEO_ADDR + ((i) * 80 * 2));
            memset(mem, 0x0, 80 * 2);
        }

        //TODO: Change y
    }

    void initScreen() {
        enableCursor();
        setCursorPos(0, 0);
        clearScreen();
    }

    void clearScreen() {
        for (size_t i = VIDEO_ADDR; i < (VIDEO_ADDR + (80 * 2 * 25)); i++) {
            ubyte* mem = cast(ubyte*)(i);
            *(mem) = 0x0;
        }
    }

    void putChar(char ch, VColor fg, VColor bg) {
        if (x > 80) {
            nextLine();
        }
        if (ch == '\n') {
            nextLine();
            return;
        }
        ushort* where = cast(ushort*)(VIDEO_ADDR) + (y * 80 + x);
        ushort attrib = (bg << 4) | (fg & 0x0F);
        *(where) = cast(ushort)(ch | (attrib << 8));
        x++;
    }

    void puts(const char* text) {
        puts(text, fgcolor, bgcolor);
    }

    void putLine(const char* line) {
        puts(line);
        nextLine();
    }

    void nextLine() {
        x = 0;
        if (y < 25)
            y++;
        else {
            scroll(1);
            y = 24;
        }
    }

    void puts(const char* text, VColor fg, VColor bg) {
        foreach (i; 0 .. text.strlen) {
            putChar(text[i], fg, bg);
        }
    }

    void putNum(long n) {
        if (n == 0) {
            putChar('0');
            return;
        }
        char[20] buf = void;
        uint i = 0;
        while (n > 0) {
            const s = n % 10;
            char c = cast(char)(s + '0');
            buf[i++] = c;
            n /= 10;
        }
        while (i-- > 0) {
            putChar(buf[i]);
        }
    }
}
