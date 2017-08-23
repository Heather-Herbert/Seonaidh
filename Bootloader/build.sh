rm boot.bin
rm floppy.img
nasm -f bin -o boot.bin boot.asm
dd if=/dev/zero of=floppy.img bs=1024 count=1440
dd if=boot.bin of=floppy.img seek=0 count=1 conv=notrunc
