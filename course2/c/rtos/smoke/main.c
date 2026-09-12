/* smoke/main.c — proves the RTOS tier in QEMU with zero exercises written:
 * the kernel boots on the emulated SysTick, two tasks of different priority
 * interleave through vTaskDelay, the idle hook runs, and the program exits
 * cleanly through semihosting with a status the build can check.
 * Build and run: cmake --preset qemu && cmake --build --preset smoke-rtos
 */

#include <stdio.h>
#include <stdlib.h>

#include "FreeRTOS.h"
#include "task.h"

static volatile uint32_t idle_ticks;

static void high_task(void *arg)
{
    (void)arg;
    for (int i = 0; i < 3; i++) {
        printf("high  tick=%lu\n", (unsigned long)xTaskGetTickCount());
        vTaskDelay(pdMS_TO_TICKS(10));
    }
    printf("course2/c/rtos smoke: idle hook ran %s -- OK\n", idle_ticks ? "yes" : "NO");
    exit(idle_ticks ? 0 : 1);
}

static void low_task(void *arg)
{
    (void)arg;
    for (;;) {
        printf("low   tick=%lu\n", (unsigned long)xTaskGetTickCount());
        vTaskDelay(pdMS_TO_TICKS(7));
    }
}

int main(void)
{
    printf("course2/c/rtos smoke: FreeRTOS %s\n", tskKERNEL_VERSION_NUMBER);
    xTaskCreate(high_task, "high", 256, NULL, 3, NULL);
    xTaskCreate(low_task,  "low",  256, NULL, 1, NULL);
    vTaskStartScheduler();
    printf("scheduler returned: out of heap for the idle task?\n");
    return 2;
}

/* ---- hooks required by config/FreeRTOSConfig.h -------------------------- */

void vApplicationIdleHook(void) { idle_ticks++; }

void vApplicationStackOverflowHook(TaskHandle_t task, char *name)
{
    (void)task;
    printf("STACK OVERFLOW in task %s\n", name);
    exit(3);
}

void vApplicationMallocFailedHook(void)
{
    printf("pvPortMalloc failed\n");
    exit(4);
}

void course2_assert_failed(const char *file, int line)
{
    printf("configASSERT failed: %s:%d\n", file, line);
    exit(5);
}
