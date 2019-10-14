module kernel.kmain;
import kernel.panic;
import kernel.console;
import kernel.multiboot;
import kernel.x86_64.idt;

nothrow:
@system:

extern (C) void kmain(void* addr, int magic) {

    multiboot_tag* tag = cast(multiboot_tag*)(addr + 8);
    Console.initScreen();
    Console.puts("Welcome To DontPanic OS\n");
    while (tag.type != MULTIBOOT_TAG_TYPE_END) {
        scope (exit)
            tag = cast(multiboot_tag*)(cast(ubyte*) tag + ((tag.size + 7) & ~7));

        switch (tag.type) {
        case MULTIBOOT_TAG_TYPE_BOOT_LOADER_NAME:
            multiboot_tag_string* name = cast(multiboot_tag_string*) tag;
            Console.puts("Bootloader: ");
            Console.putLine(cast(char*) name.string);
            break;
        case MULTIBOOT_TAG_TYPE_CMDLINE:
            multiboot_tag_string* name = cast(multiboot_tag_string*) tag;
            Console.putLine(cast(char*) name.string);
            break;
        case MULTIBOOT_TAG_TYPE_BASIC_MEMINFO:
            uint memsize = cast(uint)((cast(multiboot_tag_basic_meminfo*) tag).mem_lower) + cast(
                    uint)((cast(multiboot_tag_basic_meminfo*) tag).mem_upper);
            break;
        case MULTIBOOT_TAG_TYPE_MMAP:
            long total_system_memory = 0;
            long reserved_memory = 0;
            auto mmap_tag = cast(multiboot_tag_mmap*) tag;

            multiboot_mmap_entry* mmap;
            for (mmap = cast(multiboot_mmap_entry*) mmap_tag.entries; cast(size_t) mmap < cast(
                    size_t) tag + cast(size_t) tag.size; mmap = cast(multiboot_mmap_entry*)(
                    cast(size_t) mmap + cast(size_t) mmap_tag.entry_size)) {

                if (mmap.type == MULTIBOOT_MEMORY_AVAILABLE) {
                    /* this memory is avaliable for usage */
                    total_system_memory += mmap.len;
                } else if (mmap.type == MULTIBOOT_MEMORY_RESERVED) {
                    reserved_memory += mmap.len;
                }
            }
            Console.putNum(total_system_memory / 1024 / 1024 + 1);
            Console.puts(" MB Ram\n");

            Console.putNum(reserved_memory / 1024);
            Console.puts(" Reserved\n");
        default:

            break;
        }
    }
    initIDT();
    for (;;) { //Loop forever. You can add your kernel logic here
        asm {
            hlt;
        }
    }
}
