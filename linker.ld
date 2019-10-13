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
   .rodata   : {   *(.rodata)   }
   .bss   : {   *(.bss   )   }

}
