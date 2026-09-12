/* startup.c — the Course 2 bare-metal runtime for QEMU's STM32L4 board and the
 * NUCLEO-L476RG, written in C so that it can be read next to CubeMX's
 * startup_stm32l476xx.s (course3/firmware/).  Same job, same order:
 *
 *   1. the vector table, placed first in flash by qemu/stm32l4.ld;
 *   2. Reset_Handler: copy .data from flash, zero .bss, enable the FPU, call main;
 *   3. weak default handlers for every exception, so an exercise overrides only
 *      the ones it needs (HardFault_Handler, SysTick_Handler, ...).
 *
 * Only the Cortex-M4 system exceptions and the first sixteen STM32L4 device
 * IRQs are named; the remaining table entries are zero, so an unexpected IRQ
 * escalates to a fault instead of spinning silently.  Nothing here depends on
 * CMSIS — the one register address used is written out so that the file is
 * self-contained.
 */

#include <stdint.h>

extern uint32_t _estack;   /* from the linker script: initial MSP           */
extern uint32_t _sidata;   /* flash copy of .data                           */
extern uint32_t _sdata;    /* .data start in RAM                            */
extern uint32_t _edata;    /* .data end in RAM                              */
extern uint32_t _sbss;     /* .bss start                                    */
extern uint32_t _ebss;     /* .bss end                                      */

int  main(void);
void _exit(int status);    /* qemu/semihost.c — reports the exit code to QEMU */

/* ---- default handlers ------------------------------------------------- */

void Default_Handler(void)
{
    for (;;) {
        __asm volatile ("bkpt #0");
    }
}

#define WEAK_HANDLER(name) \
    void name(void) __attribute__((weak, alias("Default_Handler")))

void Reset_Handler(void) __attribute__((noreturn));

WEAK_HANDLER(NMI_Handler);
WEAK_HANDLER(HardFault_Handler);
WEAK_HANDLER(MemManage_Handler);
WEAK_HANDLER(BusFault_Handler);
WEAK_HANDLER(UsageFault_Handler);
WEAK_HANDLER(SVC_Handler);
WEAK_HANDLER(DebugMon_Handler);
WEAK_HANDLER(PendSV_Handler);
WEAK_HANDLER(SysTick_Handler);
/* STM32L4 device interrupts 0..15 (RM0351, vector table) */
WEAK_HANDLER(WWDG_IRQHandler);
WEAK_HANDLER(PVD_PVM_IRQHandler);
WEAK_HANDLER(TAMP_STAMP_IRQHandler);
WEAK_HANDLER(RTC_WKUP_IRQHandler);
WEAK_HANDLER(FLASH_IRQHandler);
WEAK_HANDLER(RCC_IRQHandler);
WEAK_HANDLER(EXTI0_IRQHandler);
WEAK_HANDLER(EXTI1_IRQHandler);
WEAK_HANDLER(EXTI2_IRQHandler);
WEAK_HANDLER(EXTI3_IRQHandler);
WEAK_HANDLER(EXTI4_IRQHandler);
WEAK_HANDLER(DMA1_Channel1_IRQHandler);
WEAK_HANDLER(DMA1_Channel2_IRQHandler);
WEAK_HANDLER(DMA1_Channel3_IRQHandler);
WEAK_HANDLER(DMA1_Channel4_IRQHandler);
WEAK_HANDLER(DMA1_Channel5_IRQHandler);

/* ---- the vector table -------------------------------------------------- */

typedef void (*handler_t)(void);

/* Entry 0 is a data pointer (the initial SP), every other entry a function
 * pointer; a union keeps the table well-typed without a pedantic cast. */
typedef union {
    handler_t   fn;
    const void *sp;
} vector_t;

#define STM32L4_IRQ_COUNT 82   /* IRQ0..IRQ81 on the STM32L4x6 (RM0351) */
#define V(h) { .fn = (h) }

__attribute__((section(".isr_vector"), used))
const vector_t g_vector_table[16 + STM32L4_IRQ_COUNT] = {
    { .sp = &_estack },     /*  0: initial stack pointer   */
    V(Reset_Handler),       /*  1: reset                   */
    V(NMI_Handler),         /*  2                          */
    V(HardFault_Handler),   /*  3                          */
    V(MemManage_Handler),   /*  4                          */
    V(BusFault_Handler),    /*  5                          */
    V(UsageFault_Handler),  /*  6                          */
    V(0), V(0), V(0), V(0), /*  7-10: reserved             */
    V(SVC_Handler),         /* 11                          */
    V(DebugMon_Handler),    /* 12                          */
    V(0),                   /* 13: reserved                */
    V(PendSV_Handler),      /* 14                          */
    V(SysTick_Handler),     /* 15                          */
    /* device IRQs — 16 onward */
    V(WWDG_IRQHandler),
    V(PVD_PVM_IRQHandler),
    V(TAMP_STAMP_IRQHandler),
    V(RTC_WKUP_IRQHandler),
    V(FLASH_IRQHandler),
    V(RCC_IRQHandler),
    V(EXTI0_IRQHandler),
    V(EXTI1_IRQHandler),
    V(EXTI2_IRQHandler),
    V(EXTI3_IRQHandler),
    V(EXTI4_IRQHandler),
    V(DMA1_Channel1_IRQHandler),
    V(DMA1_Channel2_IRQHandler),
    V(DMA1_Channel3_IRQHandler),
    V(DMA1_Channel4_IRQHandler),
    V(DMA1_Channel5_IRQHandler),
    /* remaining entries stay zero: an unexpected IRQ escalates to a fault
       (vector 0 is not executable) instead of spinning silently */
};

/* ---- reset ------------------------------------------------------------- */

#define SCB_CPACR (*(volatile uint32_t *)0xE000ED88u)  /* coprocessor access control */

void Reset_Handler(void)
{
    /* .data: flash -> RAM */
    const uint32_t *src = &_sidata;
    for (uint32_t *dst = &_sdata; dst < &_edata; ) {
        *dst++ = *src++;
    }
    /* .bss: zero */
    for (uint32_t *dst = &_sbss; dst < &_ebss; ) {
        *dst++ = 0u;
    }
    /* FPU: full access for CP10 and CP11 (the hard-float ABI assumes it). */
    SCB_CPACR |= (0x3u << 20) | (0x3u << 22);
    __asm volatile ("dsb; isb");

    _exit(main());
}
