module kernel.panic;
import kernel.console;

nothrow:
@system:
extern (C) void __assert(const char* msg, const char* file, int line) {
    Console.puts("KERNEL PANIC: ");
    Console.putLine(file);
    for (;;) {
    }
}
