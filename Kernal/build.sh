nasm -f bin -o kernal.com kernal.asm

mkdir /media/floppy
sudo mount -o loop ../Bootloader/floppy.img /media/floppy

## Copy the kernal files to the disk
sudo rm /media/floppy/kernal.com
sudo cp kernal.com /media/floppy/kernal.com

sudo umount /media/floppy