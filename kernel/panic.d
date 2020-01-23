module kernel.panic;
import kernel.console;

nothrow:
@system:
extern (C) void __assert(const char* msg, const char* file, int line) {
    panic(msg);
}

struct StackFrame {
align(1):
    StackFrame* ebp;
    uint eip;
}

void panic(const char* msg) {
    Console.puts("OH SHIT I PANICKED AGAIN:\n");
    Console.putLine(msg);

    StackFrame* stk;
    asm nothrow {
        mov stk, EBP;
    }

    Console.putLine("Stack trace:");
    for (uint frame = 0; cast(uint) stk !is 0 && frame < 10; ++frame) {
        // Unwind to previous stack frame
        Console.putNum(stk.eip);
        Console.nextLine();
        stk = stk.ebp;
    }

    for (;;) {
        asm nothrow {
            cli;
            hlt;
        }
    }
}
