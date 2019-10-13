/*
THIS FILE IS EXPERIMENTAL AND IT IS DISCARDED IN THE CURRENT BUILD
*/

extern (C) void long_mode_start();

__gshared void* multibootPtr;

extern (C) void kstart() {
    // asm {
    //     mov multibootPtr, EBX;
    // }
    //err();
    initDescriptorTables();
}

void err() {
    uint* where = cast(uint*)(0xb8000);
    *(where++) = 0x4f524f45;
    *(where++) = 0x4f3a4f52;
    *(where++) = 0x4f204f20;
    *(where++) = '0';
    asm {
    a:
        hlt;
        jmp a;
    }
}

struct GtdEntry {
align(1):
    ushort limit_low; // The lower 16 bits of the limit.
    ushort base_low; // The lower 16 bits of the base.
    ubyte base_middle; // The next 8 bits of the base.
    ubyte access; // Access flags, determine what ring this segment can be used in.
    ubyte granularity;
    ubyte base_high; // The last 8 bits of the base.
}

struct GdtPtr {
align(1):
    ushort limit; // The upper 16 bits of all selector limits.
    uint base; // The address of the first gdt_entry_t struct.
}

__gshared {
    GtdEntry[5] gdtEntries;
    GdtPtr gdtPtr;
    // idt_entry_t idt_entries[256];
    // idt_ptr_t idt_ptr;
}

void initDescriptorTables() {
    InitGdt();
}

void InitGdt() {
    gdtPtr.limit = (GtdEntry.sizeof * 5) - 1;
    gdtPtr.base = cast(uint)&gdtEntries;

    gdtSetGate(0, 0, 0, 0, 0); // Null segment
    gdtSetGate(1, 0, 0xFFFFFFFF, 0x9A, 0xCF); // Code segment
    gdtSetGate(2, 0, 0xFFFFFFFF, 0x92, 0xCF); // Data segment
    gdtSetGate(3, 0, 0xFFFFFFFF, 0xFA, 0xCF); // User mode code segment
    gdtSetGate(4, 0, 0xFFFFFFFF, 0xF2, 0xCF); // User mode data segment

    gdtFlush(cast(void*)&gdtPtr);
}

static void gdtSetGate(int num, uint base, uint limit, ubyte access, ubyte gran) {
    gdtEntries[num].base_low = (base & 0xFFFF);
    gdtEntries[num].base_middle = (base >> 16) & 0xFF;
    gdtEntries[num].base_high = (base >> 24) & 0xFF;

    gdtEntries[num].limit_low = (limit & 0xFFFF);
    gdtEntries[num].granularity = (limit >> 16) & 0x0F;

    gdtEntries[num].granularity |= gran & 0xF0;
    gdtEntries[num].access = access;
}

void gdtFlush(void* ptr) {
    asm {
        lgdt[ptr];
        mov EDI, multibootPtr;
    }
    long_mode_start();
}
