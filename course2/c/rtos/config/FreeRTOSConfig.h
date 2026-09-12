/* FreeRTOSConfig.h — the Course 2 RTOS tier's shared kernel configuration.
 *
 * Read next to the FreeRTOS book's "Developer Support" chapter and CubeMX's
 * generated FreeRTOSConfig.h in course3/firmware/m7-rtos/.  Every value here is
 * a design decision the Module 7 lessons discuss; an exercise that needs a
 * different one copies this file into its own directory and edits it there.
 *
 * Clock: QEMU's b-l475e-iot01a does not model the RCC/PLL timing faithfully
 * and the NUCLEO runs at whatever CubeMX programs (80 MHz in Course 3).  The
 * value below only sizes the SysTick reload; inside QEMU, tick durations are
 * not wall-clock — reason about ORDER there, measure durations on the board.
 */
#ifndef FREERTOS_CONFIG_H
#define FREERTOS_CONFIG_H

#include <stdint.h>

extern void course2_assert_failed(const char *file, int line) __attribute__((noreturn));

/* ---- scheduler ---------------------------------------------------------- */
#define configUSE_PREEMPTION                    1
#define configUSE_TIME_SLICING                  1
#define configUSE_PORT_OPTIMISED_TASK_SELECTION 1   /* CLZ-based on Cortex-M */
#define configUSE_TICKLESS_IDLE                 0
#define configCPU_CLOCK_HZ                      ((uint32_t)4000000)   /* MSI reset default on the STM32L4 */
#define configTICK_RATE_HZ                      ((TickType_t)1000)    /* 1 kHz tick */
#define configMAX_PRIORITIES                    8
#define configMINIMAL_STACK_SIZE                ((uint16_t)128)       /* WORDS, not bytes — idle/timer tasks */
#define configMAX_TASK_NAME_LEN                 12
#define configTICK_TYPE_WIDTH_IN_BITS           TICK_TYPE_WIDTH_32_BITS
#define configIDLE_SHOULD_YIELD                 1
#define configUSE_TASK_NOTIFICATIONS            1
#define configTASK_NOTIFICATION_ARRAY_ENTRIES   2
#define configUSE_MUTEXES                       1
#define configUSE_RECURSIVE_MUTEXES             1
#define configUSE_COUNTING_SEMAPHORES           1
#define configQUEUE_REGISTRY_SIZE               8
#define configUSE_QUEUE_SETS                    1
#define configUSE_NEWLIB_REENTRANT              0
#define configENABLE_BACKWARD_COMPATIBILITY     0
#define configNUM_THREAD_LOCAL_STORAGE_POINTERS 0
#define configUSE_MINI_LIST_ITEM                1
#define configSTACK_DEPTH_TYPE                  uint16_t
#define configMESSAGE_BUFFER_LENGTH_TYPE        size_t

/* ---- memory ------------------------------------------------------------- */
#define configSUPPORT_STATIC_ALLOCATION         1
#define configSUPPORT_DYNAMIC_ALLOCATION        1
#define configKERNEL_PROVIDED_STATIC_MEMORY     1   /* kernel supplies idle/timer task memory when static */
#define configTOTAL_HEAP_SIZE                   ((size_t)(16 * 1024))
#define configAPPLICATION_ALLOCATED_HEAP        0

/* ---- hooks and checks --------------------------------------------------- */
#define configUSE_IDLE_HOOK                     1
#define configUSE_TICK_HOOK                     0
#define configCHECK_FOR_STACK_OVERFLOW          2   /* method 2: pattern check on every switch */
#define configUSE_MALLOC_FAILED_HOOK            1
#define configUSE_DAEMON_TASK_STARTUP_HOOK      0
#define configASSERT(x) do { if (!(x)) { course2_assert_failed(__FILE__, __LINE__); } } while (0)

/* ---- run-time and task stats -------------------------------------------- */
#define configGENERATE_RUN_TIME_STATS           0
#define configUSE_TRACE_FACILITY                1
#define configUSE_STATS_FORMATTING_FUNCTIONS    1

/* ---- software timers ---------------------------------------------------- */
#define configUSE_TIMERS                        1
#define configTIMER_TASK_PRIORITY               (configMAX_PRIORITIES - 1)
#define configTIMER_QUEUE_LENGTH                8
#define configTIMER_TASK_STACK_DEPTH            (configMINIMAL_STACK_SIZE * 2)

/* ---- Cortex-M interrupt priorities -------------------------------------- *
 * The STM32L4 implements 4 priority bits: 0 (highest) .. 15 (lowest).  The
 * kernel's own interrupts (SysTick, PendSV) run at the LOWEST priority; an ISR
 * may call FromISR APIs only if its priority is numerically >= 
 * configMAX_SYSCALL_INTERRUPT_PRIORITY's logical value (here 5..15). */
#define configPRIO_BITS                         4
#define configLIBRARY_LOWEST_INTERRUPT_PRIORITY         15
#define configLIBRARY_MAX_SYSCALL_INTERRUPT_PRIORITY    5
#define configKERNEL_INTERRUPT_PRIORITY \
    (configLIBRARY_LOWEST_INTERRUPT_PRIORITY << (8 - configPRIO_BITS))
#define configMAX_SYSCALL_INTERRUPT_PRIORITY \
    (configLIBRARY_MAX_SYSCALL_INTERRUPT_PRIORITY << (8 - configPRIO_BITS))

/* ---- optional API ------------------------------------------------------- */
#define INCLUDE_vTaskPrioritySet                1
#define INCLUDE_uxTaskPriorityGet               1
#define INCLUDE_vTaskDelete                     1
#define INCLUDE_vTaskSuspend                    1
#define INCLUDE_xTaskDelayUntil                 1
#define INCLUDE_vTaskDelay                      1
#define INCLUDE_xTaskGetSchedulerState          1
#define INCLUDE_xTaskGetCurrentTaskHandle       1
#define INCLUDE_uxTaskGetStackHighWaterMark     1
#define INCLUDE_xTaskGetIdleTaskHandle          1
#define INCLUDE_eTaskGetState                   1
#define INCLUDE_xTimerPendFunctionCall          1
#define INCLUDE_xTaskAbortDelay                 1
#define INCLUDE_xTaskGetHandle                  1
#define INCLUDE_xQueueGetMutexHolder            1

/* ---- map the port's handlers onto the runtime's weak vector names --------- */
#define vPortSVCHandler     SVC_Handler
#define xPortPendSVHandler  PendSV_Handler
#define xPortSysTickHandler SysTick_Handler

#endif /* FREERTOS_CONFIG_H */
