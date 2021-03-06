module kernel.x86_64.idt;

import kernel.drivers.io;
import kernel.drivers.keyboard;
import kernel.util;
import kernel.console;
import kernel.panic;

__gshared {
    IDTEntry[256] idt;
    IDTBase idtP;
}

align(1) struct IDTBase {
align(1):
    ushort limit;
    ulong offset;
}

align(1) struct IDTEntry {
align(1):
    ushort offsetLow;
    ushort selector;
    ubyte zero;
    ubyte flags;
    ushort offsetMiddle;
    uint offsetHigh;
    uint reserved;
}

struct Registers {
    ulong ds;
    ulong rdi, rsi, rbp, rsp, rbx, rdx, rcx, rax;
    ulong intNo, errCode;
    ulong rip, cs, eflags, useresp, ss;
}

nothrow:
extern (C) void isrx() {
    asm nothrow {
        naked;
        cli;
        nop;
        sti;
        iretq;
    }
}

extern (C) void isr0() {
    static char* dvz = cast(char*) "DIVIDE BY ZERO";
    asm nothrow {
        naked;
        cli;
        mov RDI, dvz;
        call panic;
        hlt;
    }
}

extern (C) void isr1() {
    asm nothrow {
        naked;
        cli;
        // push 0;
        // push 1;

        push RAX;
        push RCX;
        push RDX;
        push RBX;
        push RBP;
        push RSI;
        push RDI;

        mov AX, DS;
        push RAX;
        mov AX, 0x10;
        mov DS, AX;
        mov ES, AX;
        mov FS, AX;
        mov GS, AX;

        call keyboardHandler;
        pop RBX;
        mov DS, BX;
        mov ES, BX;
        mov FS, BX;
        mov GS, BX;

        pop RDI;
        pop RSI;
        pop RBP;
        pop RBX;
        pop RDX;
        pop RCX;
        pop RAX;
        //add RSP, 8;
        sti;
        iretq;
    }
}

void loadIDT() {
    asm nothrow {
        naked;
        lidt [idtP];
        sti;
        ret;
    }
}

void initIDT() {
    idtP.limit = (IDTEntry.sizeof * 256) - 1;
    idtP.offset = cast(ulong)&idt;

    memset(&idt, 0, IDTEntry.sizeof * 256);

    idtSet(0u, cast(ulong)&isr0, 0x08u, 0x8Eu);
    foreach (ubyte i; 1 .. 22) {
        if (i == 9u) {
            idtSet(i, cast(ulong)&isr1, 0x08u, 0x8Eu);
        } else
            idtSet(i, cast(ulong)&isrx, 0x08u, 0x8Eu);
    }
    outb(0x21, 0xfd);
    outb(0xa1, 0xff);
    loadIDT();
    Log.ok("Load idt");
    Log.ok("Keyboard init");
}

void idtSet(ubyte number, ulong offset, ushort selector, ubyte flags) {
    /* Set Base Address */
    idt[number].offsetLow = offset & 0xFFFF;
    idt[number].offsetMiddle = (offset >> 16) & 0xFFFF;
    idt[number].offsetHigh = (offset >> 32) & 0xFFFFFFFF;

    /* Set Selector */
    idt[number].selector = selector;
    idt[number].flags = flags;

    /* Set Reserved Areas to Zero */
    idt[number].zero = 0;
    idt[number].reserved = 0;
}

void isrHandler( /*Registers regs*/ ) {

}
