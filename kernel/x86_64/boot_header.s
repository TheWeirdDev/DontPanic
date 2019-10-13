section .multiboot_header
align 8
extern kstart

header_start:
    dd 0xe85250d6                ; magic number (multiboot 2)
    dd 0                         ; architecture 0 (protected mode i386)
    dd header_end - header_start ; header length
    ; checksum
    dd 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start))

    ; tags
	; entry point override
	dw 3, 0 ; multiboot_header_tag_entry_address
	dd 12
	dd kstart

	dd 0 ; align next tag to 8 byte boundry

	; request some information from GRUB for the kernel
	dw 1, 0 ; multiboot_header_tag_information_request
	dd 16
	dd 6 ; request multiboot_tag_type_mmap
	dd 8 ; request MULTIBOOT_TAG_TYPE_FRAMEBUFFER

	; request a video mode
	; dw 5, 0 ; MULTIBOOT_HEADER_TAG_FRAMEBUFFER
	; dd 20
	; dd 0 ; width
	; dd 0 ; height
	; dd 0 ; depth

	dd 0 ; align next tag to 8 byte boundry

	; end of tags
	dw 0, 0 ; MULTIBOOT_TAG_TYPE_END
	dd 8
header_end: