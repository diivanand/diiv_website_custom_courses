/* semihost.h — Arm semihosting for the Course 2 QEMU runtime.
 *
 * Semihosting is a debugger/emulator service: the program executes `bkpt 0xAB`
 * with an operation number in r0 and a parameter block in r1, and the host
 * (QEMU with -semihosting-config enable=on, or a debug probe) performs the
 * request.  The runtime uses it for two things only: console output, so that
 * newlib's printf reaches the terminal, and exit, so that QEMU terminates with
 * the program's status.  On the real NUCLEO these calls trap into the debugger
 * (or hang without one) — semihosting is a bench-and-emulator facility, not a
 * product feature.  Reference: Arm "Semihosting for AArch32 and AArch64".
 */
#ifndef COURSE2_SEMIHOST_H
#define COURSE2_SEMIHOST_H

#include <stddef.h>
#include <stdint.h>

/* Write a NUL-terminated string to the host console (SYS_WRITE0). */
void semihost_write0(const char *s);

/* Write n bytes to the host console (chunked SYS_WRITE0; QEMU prints them on
 * its own stderr, so redirect 2>&1 when capturing a run). */
void semihost_write(const void *buf, size_t n);

/* Terminate: SYS_EXIT_EXTENDED with the given status; QEMU exits with it. */
void semihost_exit(int status) __attribute__((noreturn));

#endif
