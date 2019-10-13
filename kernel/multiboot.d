module kernel.multiboot;

enum MULTIBOOT_TAG_ALIGN = 8;
enum MULTIBOOT_TAG_TYPE_END = 0;
enum MULTIBOOT_TAG_TYPE_CMDLINE = 1;
enum MULTIBOOT_TAG_TYPE_BOOT_LOADER_NAME = 2;
enum MULTIBOOT_TAG_TYPE_MODULE = 3;
enum MULTIBOOT_TAG_TYPE_BASIC_MEMINFO = 4;
enum MULTIBOOT_TAG_TYPE_BOOTDEV = 5;
enum MULTIBOOT_TAG_TYPE_MMAP = 6;
enum MULTIBOOT_TAG_TYPE_VBE = 7;
enum MULTIBOOT_TAG_TYPE_FRAMEBUFFER = 8;
enum MULTIBOOT_TAG_TYPE_ELF_SECTIONS = 9;
enum MULTIBOOT_TAG_TYPE_APM = 10;
enum MULTIBOOT_TAG_TYPE_EFI32 = 11;
enum MULTIBOOT_TAG_TYPE_EFI64 = 12;
enum MULTIBOOT_TAG_TYPE_SMBIOS = 13;
enum MULTIBOOT_TAG_TYPE_ACPI_OLD = 14;
enum MULTIBOOT_TAG_TYPE_ACPI_NEW = 15;
enum MULTIBOOT_TAG_TYPE_NETWORK = 16;
enum MULTIBOOT_TAG_TYPE_EFI_MMAP = 17;
enum MULTIBOOT_TAG_TYPE_EFI_BS = 18;
enum MULTIBOOT_TAG_TYPE_EFI32_IH = 19;
enum MULTIBOOT_TAG_TYPE_EFI64_IH = 20;
enum MULTIBOOT_TAG_TYPE_LOAD_BASE_ADDR = 21;

enum MULTIBOOT_HEADER_TAG_END = 0;
enum MULTIBOOT_HEADER_TAG_INFORMATION_REQUEST = 1;
enum MULTIBOOT_HEADER_TAG_ADDRESS = 2;
enum MULTIBOOT_HEADER_TAG_ENTRY_ADDRESS = 3;
enum MULTIBOOT_HEADER_TAG_CONSOLE_FLAGS = 4;
enum MULTIBOOT_HEADER_TAG_FRAMEBUFFER = 5;
enum MULTIBOOT_HEADER_TAG_MODULE_ALIGN = 6;
enum MULTIBOOT_HEADER_TAG_EFI_BS = 7;
enum MULTIBOOT_HEADER_TAG_ENTRY_ADDRESS_EFI32 = 8;
enum MULTIBOOT_HEADER_TAG_ENTRY_ADDRESS_EFI64 = 9;
enum MULTIBOOT_HEADER_TAG_RELOCATABLE = 10;

enum MULTIBOOT_ARCHITECTURE_I386 = 0;
enum MULTIBOOT_ARCHITECTURE_MIPS32 = 4;
enum MULTIBOOT_HEADER_TAG_OPTIONAL = 1;

enum MULTIBOOT_LOAD_PREFERENCE_NONE = 0;
enum MULTIBOOT_LOAD_PREFERENCE_LOW = 1;
enum MULTIBOOT_LOAD_PREFERENCE_HIGH = 2;

enum MULTIBOOT_CONSOLE_FLAGS_CONSOLE_REQUIRED = 1;
enum MULTIBOOT_CONSOLE_FLAGS_EGA_TEXT_SUPPORTED = 2;

align(8):

struct multiboot_header {
    /*  Must be MULTIBOOT_MAGIC - see above. */
    uint magic;

    /*  ISA */
    uint architecture;

    /*  Total header length. */
    uint header_length;

    /*  The above fields plus this one must equal 0 mod 2^32. */
    uint checksum;
}

struct multiboot_header_tag {
    ushort type;
    ushort flags;
    uint size;
}

struct multiboot_header_tag_information_request {
    ushort type;
    ushort flags;
    uint size;
    uint[0] requests;
}

struct multiboot_header_tag_address {
    ushort type;
    ushort flags;
    uint size;
    uint header_addr;
    uint load_addr;
    uint load_end_addr;
    uint bss_end_addr;
}

struct multiboot_header_tag_entry_address {
    ushort type;
    ushort flags;
    uint size;
    uint entry_addr;
}

struct multiboot_header_tag_console_flags {
    ushort type;
    ushort flags;
    uint size;
    uint console_flags;
}

struct multiboot_header_tag_framebuffer {
    ushort type;
    ushort flags;
    uint size;
    uint width;
    uint height;
    uint depth;
}

struct multiboot_header_tag_module_align {
    ushort type;
    ushort flags;
    uint size;
}

struct multiboot_header_tag_relocatable {
    ushort type;
    ushort flags;
    uint size;
    uint min_addr;
    uint max_addr;
    uint align_;
    uint preference;
}

struct multiboot_color {
    ubyte red;
    ubyte green;
    ubyte blue;
}

enum MULTIBOOT_MEMORY_AVAILABLE = 1;
enum MULTIBOOT_MEMORY_ACPI_RECLAIMABLE = 3;
enum MULTIBOOT_MEMORY_RESERVED = 2;
enum MULTIBOOT_MEMORY_NVS = 4;
enum MULTIBOOT_MEMORY_BADRAM = 5;

struct multiboot_mmap_entry {
align(1):
    ulong addr;
    ulong len;
    uint type;
    uint zero;
}

struct multiboot_tag {
    uint type;
    uint size;
}

struct multiboot_tag_string {
    uint type;
    uint size;
    char[0] string;
}

struct multiboot_tag_module {
    uint type;
    uint size;
    uint mod_start;
    uint mod_end;
    char[0] cmdline;
}

struct multiboot_tag_basic_meminfo {
    uint type;
    uint size;
    uint mem_lower;
    uint mem_upper;
}

struct multiboot_tag_bootdev {
    uint type;
    uint size;
    uint biosdev;
    uint slice;
    uint part;
}

struct multiboot_tag_mmap {
    uint type;
    uint size;
    uint entry_size;
    uint entry_version;
    multiboot_mmap_entry[0] entries;
}

struct multiboot_vbe_info_block {
    ubyte[512] external_specification;
}

struct multiboot_vbe_mode_info_block {
    ubyte[256] external_specification;
}

struct multiboot_tag_vbe {
    uint type;
    uint size;

    ushort vbe_mode;
    ushort vbe_interface_seg;
    ushort vbe_interface_off;
    ushort vbe_interface_len;

    multiboot_vbe_info_block vbe_control_info;
    multiboot_vbe_mode_info_block vbe_mode_info;
}

enum MULTIBOOT_FRAMEBUFFER_TYPE_INDEXED = 0;
enum MULTIBOOT_FRAMEBUFFER_TYPE_RGB = 1;
enum MULTIBOOT_FRAMEBUFFER_TYPE_EGA_TEXT = 2;
struct multiboot_tag_framebuffer_common {
    uint type;
    uint size;
    ulong framebuffer_addr;
    uint framebuffer_pitch;
    uint framebuffer_width;
    uint framebuffer_height;
    ubyte framebuffer_bpp;
    ubyte framebuffer_type;
    ushort reserved;
}

struct multiboot_tag_framebuffer {
    multiboot_tag_framebuffer_common common;

    union {
        struct {
            ushort framebuffer_palette_num_colors;
            multiboot_color[0] framebuffer_palette;
        }

        struct {
            ubyte framebuffer_red_field_position;
            ubyte framebuffer_red_mask_size;
            ubyte framebuffer_green_field_position;
            ubyte framebuffer_green_mask_size;
            ubyte framebuffer_blue_field_position;
            ubyte framebuffer_blue_mask_size;
        }
    }
}

struct multiboot_tag_elf_sections {
    uint type;
    uint size;
    uint num;
    uint entsize;
    uint shndx;
    char[0] sections;
}

struct multiboot_tag_apm {
    uint type;
    uint size;
    ushort version_;
    ushort cseg;
    uint offset;
    ushort cseg_16;
    ushort dseg;
    ushort flags;
    ushort cseg_len;
    ushort cseg_16_len;
    ushort dseg_len;
}

struct multiboot_tag_efi32 {
    uint type;
    uint size;
    uint pointer;
}

struct multiboot_tag_efi64 {
    uint type;
    uint size;
    ulong pointer;
}

struct multiboot_tag_smbios {
    uint type;
    uint size;
    ubyte major;
    ubyte minor;
    ubyte[6] reserved;
    ubyte[0] tables;
}

struct multiboot_tag_old_acpi {
    uint type;
    uint size;
    ubyte[0] rsdp;
}

struct multiboot_tag_new_acpi {
    uint type;
    uint size;
    ubyte[0] rsdp;
}

struct multiboot_tag_network {
    uint type;
    uint size;
    ubyte[0] dhcpack;
}

struct multiboot_tag_efi_mmap {
    uint type;
    uint size;
    uint descr_size;
    uint descr_vers;
    ubyte[0] efi_mmap;
}

struct multiboot_tag_efi32_ih {
    uint type;
    uint size;
    uint pointer;
}

struct multiboot_tag_efi64_ih {
    uint type;
    uint size;
    ulong pointer;
}

struct multiboot_tag_load_base_addr {
    uint type;
    uint size;
    uint load_base_addr;
}
