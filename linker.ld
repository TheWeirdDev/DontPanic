ENTRY(kstart)

SECTIONS {
    . = 1M;

    .boot :
    {
        /* ensure that the multiboot header is at the beginning */
        *(.multiboot_header)
    }

    .text :
    {
        *(.text)
    }
   .data   : {   *(.data  )   }
    .rodata : ALIGN(4K) {
        *(.rodata)

    }
   .bss   : {   *(.bss   )   }

}
