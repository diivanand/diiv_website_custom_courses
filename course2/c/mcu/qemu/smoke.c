/* smoke.c — proves the bare-metal tier end to end with zero exercises written:
 * .data copied, .bss zeroed, the FPU enabled, printf routed over semihosting,
 * and QEMU exiting with main's return value.  Built as smoke-qemu.elf by the
 * `qemu` preset; run with `cmake --build --preset qemu --target run-smoke-qemu`.
 */

#include <stdint.h>
#include <stdio.h>

static uint32_t initialized = 0x12345678u;   /* .data — must survive the copy   */
static uint32_t zeroed[4];                    /* .bss  — must read as zero        */
static volatile float f = 1.5f;               /* exercises the FPU (VFP4-SP)      */

int main(void)
{
    f = f * 2.0f;
    printf("course2/c/mcu smoke: .data=%08lx .bss=%lu f=%d/2 -- OK\n",
           (unsigned long)initialized,
           (unsigned long)(zeroed[0] | zeroed[1] | zeroed[2] | zeroed[3]),
           (int)(f * 2.0f));
    return (initialized == 0x12345678u && zeroed[3] == 0u && f == 3.0f) ? 0 : 1;
}
