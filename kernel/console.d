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
        uint x = 0;
        uint y = 0;
        VColor fgcolor = VColor.WHITE;
        VColor bgcolor = VColor.BLACK;
    }
nothrow:
    void putChar(char ch) {
        putChar(ch, fgcolor, bgcolor);
    }

    void enableCursor() {

        outb(0x3D4, 0x09); // set maximum scan line register to 15
        outb(0x3D5, 0x0F);

        outb(0x3D4, 0x0B); // set the cursor end line to 15
        outb(0x3D5, 0x0F);

        outb(0x3D4, 0x0A); // set the cursor start line to 0 and enable cursor visibility
        outb(0x3D5, 0x0);
    }

    void setCursorPos(uint x, uint y) {
        setCursorPos(cast(ushort) x, cast(ushort) y);
    }

    void setCursorPos(ushort x, ushort y) {
        ushort cursor_pos = cast(ushort)(y * 80 + x);

        outb(0x3D4, 0x0F);
        outb(0x3D5, cast(ubyte)(cursor_pos & 0xFF));
        outb(0x3D4, 0x0E);
        outb(0x3D5, cast(ubyte)((cursor_pos >> 8) & 0xFF));
    }

    void scroll(uint n) {
        if (n > 24) {
            clearScreen();
            return;
        }

        for (int i = n; i <= 24; i++) {
            auto src = cast(ubyte*)(VIDEO_ADDR + (i * 80 * 2));
            auto dest = cast(ubyte*)(VIDEO_ADDR + ((i - n) * 80 * 2));
            memcpy(dest, src, 80 * 2);
        }

        for (int i = 24; i >= 24 - n + 1; i--) {
            auto mem = (VIDEO_ADDR + ((i) * 80 * 2));
            for (size_t j = mem; j < mem + (80 * 2); j += 2) {
                ushort* m = cast(ushort*) j;
                ushort attrib = (VColor.BLACK << 4) | (VColor.WHITE & 0x0F);
                *(m) = cast(ushort)(0x0 | (attrib << 8));
            }
        }

        //TODO: Change y
    }

    void initScreen() {
        enableCursor();
        setCursorPos(0, 0);
        clearScreen();
    }

    void clearScreen() {
        for (size_t i = VIDEO_ADDR; i < (VIDEO_ADDR + (80 * 25 * 2)); i += 2) {
            ushort* mem = cast(ushort*)(i);
            ushort attrib = (VColor.BLACK << 4) | (VColor.WHITE & 0x0F);
            *(mem) = cast(ushort)(0x0 | (attrib << 8));
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
        setCursorPos(x, y);
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
        if (y < 24)
            y++;
        else {
            scroll(1);
            y = 24;
        }
        setCursorPos(0, y);
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

struct Log {
static nothrow:
    void ok(const char* msg) {
        Console.putChar('[');
        Console.puts(" OK ", VColor.BRIGHT_GREEN, VColor.BLACK);
        Console.puts("] ");
        Console.putLine(msg);
    }

    void error(const char* msg) {
        Console.putChar('[');
        Console.puts(" NO ", VColor.BRIGHT_RED, VColor.BLACK);
        Console.puts("] ");
        Console.putLine(msg);
    }
}
