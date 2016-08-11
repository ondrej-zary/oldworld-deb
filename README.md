# oldworld-deb
Debian Installer boot floppy for OldWorld PowerMacs

## Problem
OldWorld Power Macintosh machines can't boot from Debian install CD. Debian install documentation says that OldWorld systems should boot from a floppy - but there are none in recent Debian versions!
The last boot-floppy-hfs.img was present in Debian 3.0 (Woody) - and it really worked. The boot.img in Debian 3.1 (Sarge) and 4.0 (Etch) did not work for me (Mac refuses to boot from the floppy by ejecting it) and there are no floppy images since Debian 5.0 (Lenny).

## Solution
A boot floppy for Debian 8 (Jessie), called oldworld-deb. Based on miBoot, linux kernel, kexec 

## Usage
Power off your OldWorld Power Macintosh, insert this floppy in the floppy drive and power on. While booting, insert Debian install CD in the CD-ROM drive (or do it before powering down).
A tiny kernel with a built-in initramfs will load from the floppy, mount the CD, load the real kernel (and initramfs) from there and launch it. Debian Installer will start - proceed with install according to Debian documentation.
