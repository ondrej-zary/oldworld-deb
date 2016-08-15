# oldworld-deb
Debian Installer boot floppy for OldWorld PowerMacs

## Problem
OldWorld Power Macintosh machines can't boot from Debian install CD. Debian install documentation says that OldWorld systems should boot from a floppy - but there are none in recent Debian versions!

The last boot-floppy-hfs.img was present in Debian 3.0 (Woody) - and it really worked. The boot.img in Debian 3.1 (Sarge) and 4.0 (Etch) did not work for me (Mac refuses to boot from the floppy by ejecting it) and there are no floppy images since Debian 5.0 (Lenny).

BootX can be used to boot Linux from MacOS but it's not able to boot Debian Installer kernel or any other recent full-featured kernel. It did work only with minimal custom-compiled kernels up to around 9 MB (uncompressed, no initramfs) for me.

## Solution
A boot floppy for Debian 8 (Jessie), called oldworld-deb. Based on miBoot, Linux kernel, kexec and a simple init program.

## Usage
Download the floppy image [oldworld-deb.img] (https://github.com/ondrej-zary/oldworld-deb/releases/download/v1.0/oldworld-deb.img) and create the floppy:

    dd if=oldworld-deb.img of=/dev/fd0

Power off your OldWorld Power Macintosh, insert this floppy in the floppy drive and power on. While booting, insert Debian install CD in the CD-ROM drive (or do it before powering down).

A tiny kernel with a built-in initramfs will load from the floppy, mount the CD, load the real kernel (and initramfs) from there and launch it. Debian Installer will start - proceed with install according to Debian documentation.

## Supported machines
Every OldWorld PowerMac with MESH or 53C94 SCSI controller and a SCSI CD-ROM drive should work.

Tested on Power Macintosh 8200 (same HW as 7200).

## Compiling your own
To save precious floppy space, there's no shell, Busybox or libraries in the initramfs, just two binaries (kexec and init) statically linked with uClibc.

The Makefile only works on x86. You need fakeroot, gcc and hfsutils.
### 0. Toolchain
The Makefile downloads and uses cross-compiling uClibc gcc toolchain from uclibc.org - that's why it only works on x86. If you want to compile on another architecture, you need to compile your own toolchain (or find and download a pre-compiled one).
### 1. kexec
kexec-tools is compiled using the toolchain, with size optimization (-Os). Only the kexec binary is used.
### 2. init
This is the glue that puts everything together. A simple C program that mounts /sys (kexec requires it), then mounts /dev/sr0, loads install/powerpc/vmlinux and install/powerpc/initrd.gz using kexec and finally jumps to the loaded kernel using kexec. Simply compiled using the toolchain.
### 3. initramfs
A minimal initramfs is created using fakeroot and then built into the kernel in the next step. Files in initramfs:

    /dev/console (required by userspace to display anything)
    /dev/sr0 (device to be mounted)
    /mnt (the CD will me mounted here)
    /proc/cmdline (empty file for kexec)
    /proc/device-tree (symlink to /sys/firmware/devicetree/base for kexec)
    /sys (to mount sysfs for kexec)
    /init (binary from step 2)
    /kexec (binary from step 1)

### 4. kernel
The kernel configuration is as minimal as possible to fit the floppy. The most important parts are kexec support, ISO9660 filesystem and drivers for Macintosh hardware (e.g. SCSI). The compilation process requires also a native gcc for your architecture.
### 5. floppy image
Finally, a floppy image is created using hfsutils (Apple ROM can only boot HFS volumes). The miBoot Finder.bin and System.bin (from Debian 3.0 boot-floppies) and vmlinux.strip.gz (from step 4, renamed to zImage) are copied to the image. Then a bootblock (again from Debian 3.0 boot-floppies) is put at the beginning.
