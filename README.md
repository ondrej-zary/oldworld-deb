# oldworld-deb
Debian Installer boot floppy for OldWorld PowerMacs

## Problem
OldWorld Power Macintosh machines can't boot from Debian install CD. Debian install documentation says that OldWorld systems should boot from a floppy - but there are none in recent Debian versions!

The last boot-floppy-hfs.img was present in Debian 3.0 (Woody) - and it really worked. The boot.img in Debian 3.1 (Sarge) and 4.0 (Etch) did not work for me (Mac refuses to boot from the floppy by ejecting it) and there are no floppy images since Debian 5.0 (Lenny).

BootX can be used to boot Linux from MacOS but it's not able to boot Debian Installer kernel or any other recent full-featured kernel. It did work only with minimal custom-compiled kernels up to around 9 MB (uncompressed, no initramfs) for me.

## Solution
A boot floppy for Debian 8 (Jessie), called oldworld-deb. Based on miBoot, Linux kernel, kexec and a simple init program.

## Usage
Download the floppy image oldworld-deb.img and create the floppy:

    dd if=oldworld-deb.img of=/dev/fd0

Power off your OldWorld Power Macintosh, insert this floppy in the floppy drive and power on. While booting, insert Debian install CD in the CD-ROM drive (or do it before powering down).

A tiny kernel with a built-in initramfs will load from the floppy, mount the CD, load the real kernel (and initramfs) from there and launch it. Debian Installer will start - proceed with install according to Debian documentation.

## Compiling your own
To save precious floppy space, there's no shell, Busybox or libraries in the initramfs, just two binaries (kexec and init) statically linked with uClibc.
### 0. Toolchain
### 1. kexec
### 2. init
### 3. initramfs
### 4. kernel
### 5. floppy image
