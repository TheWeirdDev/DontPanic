module kernel.drivers.io;
nothrow:

ubyte inb(ushort port) {
    ubyte ret;
    asm pure @trusted nothrow @nogc {
        mov DX, port;
         in AL, DX;
        mov ret, AL;
    }
    return ret;
}

void outb(uint port, ubyte data) {
    asm pure @trusted nothrow @nogc {
        mov AL, data;
        mov DX, port;
        out DX, AL;
    }
}
