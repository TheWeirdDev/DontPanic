module kernel.drivers.keyboard;
import kernel.drivers.io;
import kernel.console;

__gshared enum {
    KEY_A = 0x1E,
    KEY_B = 0x30,
    KEY_C = 0x2E,
    KEY_D = 0x20,
    KEY_E = 0x12,
    KEY_F = 0x21,
    KEY_G = 0x22,
    KEY_H = 0x23,
    KEY_I = 0x17,
    KEY_J = 0x24,
    KEY_K = 0x25,
    KEY_L = 0x26,
    KEY_M = 0x32,
    KEY_N = 0x31,
    KEY_O = 0x18,
    KEY_P = 0x19,
    KEY_Q = 0x10,
    KEY_R = 0x13,
    KEY_S = 0x1F,
    KEY_T = 0x14,
    KEY_U = 0x16,
    KEY_V = 0x2F,
    KEY_W = 0x11,
    KEY_X = 0x2D,
    KEY_Y = 0x15,
    KEY_Z = 0x2C,
    KEY_1 = 0x02,
    KEY_2 = 0x03,
    KEY_3 = 0x04,
    KEY_4 = 0x05,
    KEY_5 = 0x06,
    KEY_6 = 0x07,
    KEY_7 = 0x08,
    KEY_8 = 0x09,
    KEY_9 = 0x0A,
    KEY_0 = 0x0B,
    KEY_MINUS = 0x0C,
    KEY_EQUAL = 0x0D,
    KEY_SQUARE_OPEN_BRACKET = 0x1A,
    KEY_SQUARE_CLOSE_BRACKET = 0x1B,
    KEY_SEMICOLON = 0x27,
    KEY_BACKSLASH = 0x2B,
    KEY_COMMA = 0x33,
    KEY_DOT = 0x34,
    KEY_FORESLHASH = 0x35,
    KEY_F1 = 0x3B,
    KEY_F2 = 0x3C,
    KEY_F3 = 0x3D,
    KEY_F4 = 0x3E,
    KEY_F5 = 0x3F,
    KEY_F6 = 0x40,
    KEY_F7 = 0x41,
    KEY_F8 = 0x42,
    KEY_F9 = 0x43,
    KEY_F10 = 0x44,
    KEY_F11 = 0x85,
    KEY_F12 = 0x86,
    KEY_BACKSPACE = 0x0E,
    KEY_DELETE = 0x53,
    KEY_DOWN = 0x50,
    KEY_END = 0x4F,
    KEY_ENTER = 0x1C,
    KEY_ESC = 0x01,
    KEY_HOME = 0x47,
    KEY_INSERT = 0x52,
    KEY_KEYPAD_5 = 0x4C,
    KEY_KEYPAD_MUL = 0x37,
    KEY_KEYPAD_Minus = 0x4A,
    KEY_KEYPAD_PLUS = 0x4E,
    KEY_KEYPAD_DIV = 0x35,
    KEY_LEFT = 0x4B,
    KEY_PAGE_DOWN = 0x51,
    KEY_PAGE_UP = 0x49,
    KEY_PRINT_SCREEN = 0x37,
    KEY_RIGHT = 0x4D,
    KEY_SPACE = 0x39,
    KEY_TAB = 0x0F,
    KEY_UP = 0x48,
}

char get_ascii_char(ubyte key_code) {
    switch (key_code) {
    case KEY_A:
        return 'A';
    case KEY_B:
        return 'B';
    case KEY_C:
        return 'C';
    case KEY_D:
        return 'D';
    case KEY_E:
        return 'E';
    case KEY_F:
        return 'F';
    case KEY_G:
        return 'G';
    case KEY_H:
        return 'H';
    case KEY_I:
        return 'I';
    case KEY_J:
        return 'J';
    case KEY_K:
        return 'K';
    case KEY_L:
        return 'L';
    case KEY_M:
        return 'M';
    case KEY_N:
        return 'N';
    case KEY_O:
        return 'O';
    case KEY_P:
        return 'P';
    case KEY_Q:
        return 'Q';
    case KEY_R:
        return 'R';
    case KEY_S:
        return 'S';
    case KEY_T:
        return 'T';
    case KEY_U:
        return 'U';
    case KEY_V:
        return 'V';
    case KEY_W:
        return 'W';
    case KEY_X:
        return 'X';
    case KEY_Y:
        return 'Y';
    case KEY_Z:
        return 'Z';
    case KEY_1:
        return '1';
    case KEY_2:
        return '2';
    case KEY_3:
        return '3';
    case KEY_4:
        return '4';
    case KEY_5:
        return '5';
    case KEY_6:
        return '6';
    case KEY_7:
        return '7';
    case KEY_8:
        return '8';
    case KEY_9:
        return '9';
    case KEY_0:
        return '0';
    case KEY_MINUS:
        return '-';
    case KEY_EQUAL:
        return '=';
    case KEY_SQUARE_OPEN_BRACKET:
        return '[';
    case KEY_SQUARE_CLOSE_BRACKET:
        return ']';
    case KEY_SEMICOLON:
        return ';';
    case KEY_BACKSLASH:
        return '\\';
    case KEY_COMMA:
        return ',';
    case KEY_DOT:
        return '.';
    case KEY_FORESLHASH:
        return '/';
    case KEY_SPACE:
        return ' ';
    default:
        return 0;
    }
}

void keyboardHandler() {

    outb(0x20, 0x20);
    ubyte status = inb(0x64);
    /* Lowest bit of status will be set if buffer is not empty */
    if (status & 0x01) {
        ubyte keycode = inb(0x60);
        if (keycode < 0)
            return;
        if (char c = get_ascii_char(keycode)) {
            Console.putChar(c);
        }
    }
    //Console.putNum(regs.intNo);
    //Console.puts("\n");
}
