################################################################
##
## A simple script for building a boot disk
##
##

## Remove the old files
rm boot.bin
rm floppy.img

## Assemble the bootsector + kernal
nasm -f bin -o boot.bin boot.asm

## Create the floopy disk
#dd if=/dev/zero of=floppy.img bs=512 count=2880

## Format the disk
#mkfs.msdos -F 12 -n SEONAIDH -I ./floppy.img

##mkdir /media/floppy
##sudo mount -o loop ./floppy.img /media/floppy


## Copy the kernal files to the disk

##umount /media/floppy

## Write the boot sector
#dd if=boot.bin of=floppy.img seek=0 count=1 conv=notrunc
cp Vfloppy.img floppy.img
dd if=boot.bin of=floppy.img bs=512 count=1 conv=notrunc
