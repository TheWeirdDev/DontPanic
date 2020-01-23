
all: kernel

run: kernel iso
	qemu-system-x86_64 -cdrom build/os.iso

debug: kernel iso
	qemu-system-x86_64 -s -S -cdrom build/os.iso

iso:
	grub-mkrescue -o build/os.iso build/iso/

kernel: asm d
	ld -n -o build/iso/boot/kernel.bin -T linker.ld \
	    build/boot.o \
		build/boot_header.o \
		build/long_mode.o \
		build/kernel.o

asm:
	nasm -f elf64 -F dwarf -g -o build/long_mode.o 		kernel/x86_64/long_mode.s
	nasm -f elf64 -F dwarf -g -o build/boot.o 			kernel/x86_64/boot.s
	nasm -f elf64 -F dwarf -g -o build/boot_header.o 	kernel/x86_64/boot_header.s

d:
	ldc -c -nodefaultlib -boundscheck=off -code-model=kernel -betterC -g -nogc -of=build/kernel.o \
		kernel/kmain.d \
		kernel/panic.d \
		kernel/util.d \
		kernel/x86_64/idt.d \
		kernel/console.d \
		kernel/drivers/io.d \
		kernel/drivers/keyboard.d \
		kernel/multiboot.d

clean:
	rm build/*.o build/iso/boot/kernel.bin build/os.iso