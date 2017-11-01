################################################################
##
## A simple script for building a boot disk
##
##

## Remove the old files
rm boot.bin
rm floppy.img
rm SEONAIDH.com

## Assemble the bootsector + kernal
nasm -f bin -o boot.bin boot.asm
nasm -f bin -o SEONAIDH.com SEONAIDH.asm

mkfs.msdos -C ./floppy.img 1440

dd if=boot.bin of=floppy.img bs=512 count=1 conv=notrunc

## Format the disk
#mkfs.msdos -F 12 -n SEONAIDH -I ./floppy.img

mkdir /media/floppy
sudo mount -o loop ./floppy.img /media/floppy

cp SEONAIDH.com /media/floppy/SEONAIDH.com
#cp SEO.com /media/floppy/SEO.com
#cp TD.EXE /media/floppy/TD.EXE

## Copy the kernal files to the disk

umount /media/floppy

## Write the boot sector
#dd if=boot.bin of=floppy.img seek=0 count=1 conv=notrunc
#cp Vfloppy.img floppy.img
