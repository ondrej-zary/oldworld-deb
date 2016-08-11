CFLAGS=-Wall -Wextra -Os
FD_IMAGE=oldworld-deb.img
KERNEL=linux-3.16.36
KEXEC_TOOLS=kexec-tools-2.0.7

all: $(FD_IMAGE)
################################################################################
cross-compiler-powerpc.tar.bz2:
	wget https://uclibc.org/downloads/binaries/0.9.30.1/cross-compiler-powerpc.tar.bz2

cross-compiler-powerpc/: cross-compiler-powerpc.tar.bz2
	tar xf cross-compiler-powerpc.tar.bz2
################################################################################
boot-floppies-3.0.23/:
	tar xf boot-floppies_3.0.23.tar.gz

boot-floppies_3.0.23.tar.gz:
	wget http://archive.debian.org/debian//pool/main/b/boot-floppies/boot-floppies_3.0.23.tar.gz
################################################################################
init: cross-compiler-powerpc/ init.c
	cross-compiler-powerpc/bin/powerpc-gcc $(CFLAGS) -static -Wall -Wextra init.c -o init
	cross-compiler-powerpc/bin/powerpc-strip init
################################################################################
$(KEXEC_TOOLS).tar.xz:
	wget https://www.kernel.org/pub/linux/utils/kernel/kexec/$(KEXEC_TOOLS).tar.xz

$(KEXEC_TOOLS)/: $(KEXEC_TOOLS).tar.xz
	tar xf $(KEXEC_TOOLS).tar.xz

$(KEXEC_TOOLS)/build/sbin/kexec: | $(KEXEC_TOOLS)/
	cd $(KEXEC_TOOLS)/ && \
	CFLAGS=-Os LDFLAGS=-static AR=../cross-compiler-powerpc/bin/powerpc-ar \
	STRIP=../cross-compiler-powerpc/bin/powerpc-strip OBJCOPY=../cross-compiler-powerpc/bin/powerpc-objcopy \
	CC=../cross-compiler-powerpc/bin/powerpc-gcc AS=../cross-compiler-powerpc/bin/powerpc-as \
	LD=../cross-compiler-powerpc/bin/powerpc-ld ./configure --host=powerpc-unknown-linux-uclibc && \
	make && \
	../cross-compiler-powerpc/bin/powerpc-strip build/sbin/kexec
################################################################################
$(KERNEL).tar.xz:
	wget https://www.kernel.org/pub/linux/kernel/v3.x/$(KERNEL).tar.xz

$(KERNEL)/: $(KERNEL).tar.xz
	tar xf $(KERNEL).tar.xz

$(KERNEL)/vmlinux.strip.gz: init $(KEXEC_TOOLS)/build/sbin/kexec | $(KERNEL)/
	cp .config $(KERNEL)/
	rm -rf initramfs
	fakeroot -- sh -c 'mkdir -p initramfs/dev initramfs/mnt initramfs/proc initramfs/sys && \
	mknod initramfs/dev/console c 5 1 && mknod initramfs/dev/sr0 b 11 0 && \
	echo > initramfs/proc/cmdline && ln -s /sys/firmware/devicetree/base initramfs/proc/device-tree && \
	cp init $(KEXEC_TOOLS)/build/sbin/kexec initramfs/ && \
	cd $(KERNEL)/ && ARCH=powerpc make oldconfig && ARCH=powerpc make'
################################################################################
$(FD_IMAGE): $(KERNEL)/vmlinux.strip.gz boot-floppies-3.0.23/
	dd if=/dev/zero of=$(FD_IMAGE) bs=1024 count=1440
	hformat -l "Debian/PowerPC" $(FD_IMAGE)
	hmount $(FD_IMAGE)
	hcopy boot-floppies-3.0.23/powerpc-specials/miBoot/Finder.bin :
	hcopy boot-floppies-3.0.23/powerpc-specials/miBoot/System.bin :
	hcopy -r $(KERNEL)/vmlinux.strip.gz :zImage
	hattrib -b :
	humount
	dd if=boot-floppies-3.0.23/powerpc-specials/miBoot/hfs-bootblock.b of=$(FD_IMAGE) conv=notrunc
################################################################################
clean:
	rm -rf init $(FD_IMAGE) initramfs cross-compiler-powerpc boot-floppies-3.0.23 $(KEXEC_TOOLS) $(KERNEL)

realclean: clean
	rm -rf cross-compiler-powerpc.tar.bz2 boot-floppies_3.0.23.tar.gz $(KEXEC_TOOLS).tar.xz $(KERNEL).tar.xz
