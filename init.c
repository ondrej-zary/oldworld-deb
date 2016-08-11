#include <unistd.h>
#include <stdio.h>
#include <sys/mount.h>
#include <sys/wait.h>

int main(void) {
	char *kexec_load[] = { "/kexec", "-l", "/mnt/install/powerpc/vmlinux", "--initrd=/mnt/install/powerpc/initrd.gz", NULL };
	char *kexec_run[] = { "/kexec", "-e", "-x", NULL };
	char *env[] = { NULL };
	int status;

	printf("Mounting /sys...\n");
	if (mount("sysfs", "/sys", "sysfs", MS_MGC_VAL, NULL) != 0)
		perror("mount");

	printf("Mounting Debian Install CD /dev/sr0...\n");
	do {
		status = mount("/dev/sr0", "/mnt", "iso9660", MS_MGC_VAL|MS_RDONLY, NULL);
		if (status != 0) {
			perror("mount");
			sleep(5);
		}
	} while (status != 0);

	printf("Loading kernel and initramfs from CD...\n");
	switch (fork()) {
	case -1:	/* error */
		perror("fork");
		break;
	case 0:		/* child */
		execve(kexec_load[0], kexec_load, env);
		perror("execve");
		break;
	default:	/* parent */
		if (wait(&status) == -1) {
			perror("wait");
			break;
		}
		if (!WIFEXITED(status)) {
			printf("child not terminated normally\n");
			break;
		}
		if (WEXITSTATUS(status) != 0) {
			printf("kexec returned %d\n", WEXITSTATUS(status));
			break;
		}
		printf("Starting kernel...\n");
		execve(kexec_run[0], kexec_run, env);
		perror("execve");
	}

	return 0xaa;
}
