/* semihost.c — semihosting calls plus the newlib hooks that route printf and
 * exit through them.  Linked only by the `qemu` preset (arm-none-eabi-gcc with
 * --specs=nano.specs --specs=nosys.specs); nosys's own _write/_exit are library
 * symbols, so these object-file definitions take precedence.
 */

#include "semihost.h"

#include <errno.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

enum {
    SYS_WRITE0        = 0x04,
    SYS_EXIT          = 0x18,
    SYS_EXIT_EXTENDED = 0x20,
};

#define ADP_Stopped_ApplicationExit 0x20026u

static inline uintptr_t semihost_call(uint32_t op, void *arg)
{
    register uint32_t  r0 __asm("r0") = op;
    register void     *r1 __asm("r1") = arg;
    __asm volatile ("bkpt #0xAB" : "+r"(r0) : "r"(r1) : "memory");
    return r0;
}

void semihost_write0(const char *s)
{
    (void)semihost_call(SYS_WRITE0, (void *)s);
}

void semihost_write(const void *buf, size_t n)
{
    /* SYS_WRITE0 wants a NUL-terminated string; stdio hands us byte ranges.
     * Copy through a small stack buffer so that no heap and no global state
     * are involved (this may be called from a fault handler). */
    const char *p = buf;
    char chunk[64];
    while (n > 0) {
        size_t k = n < sizeof chunk - 1 ? n : sizeof chunk - 1;
        for (size_t i = 0; i < k; i++) {
            chunk[i] = p[i];
        }
        chunk[k] = '\0';
        semihost_write0(chunk);
        p += k;
        n -= k;
    }
}

void semihost_exit(int status)
{
    uintptr_t block[2] = { ADP_Stopped_ApplicationExit, (uintptr_t)status };
    (void)semihost_call(SYS_EXIT_EXTENDED, block);
    /* Older hosts only implement SYS_EXIT (status cannot be passed). */
    (void)semihost_call(SYS_EXIT, (void *)ADP_Stopped_ApplicationExit);
    for (;;) { }
}

/* ---- newlib hooks ------------------------------------------------------ */

int _write(int fd, const void *buf, size_t n);
int _write(int fd, const void *buf, size_t n)
{
    if (fd != STDOUT_FILENO && fd != STDERR_FILENO) {
        errno = EBADF;
        return -1;
    }
    semihost_write(buf, n);
    return (int)n;
}

void _exit(int status);
void _exit(int status)
{
    semihost_exit(status);
}

/* newlib's stdio probes the descriptor; --specs=nosys.specs supplies failing
 * versions of these but warns at link time.  Minimal honest answers instead:
 * stdout is a character device, nothing is seekable or readable. */
int _close(int fd);
int _close(int fd) { (void)fd; return -1; }

int _fstat(int fd, struct stat *st);
int _fstat(int fd, struct stat *st) { (void)fd; st->st_mode = S_IFCHR; return 0; }

int _isatty(int fd);
int _isatty(int fd) { (void)fd; return 1; }

off_t _lseek(int fd, off_t off, int whence);
off_t _lseek(int fd, off_t off, int whence) { (void)fd; (void)off; (void)whence; return 0; }

int _read(int fd, void *buf, size_t n);
int _read(int fd, void *buf, size_t n) { (void)fd; (void)buf; (void)n; return 0; }
