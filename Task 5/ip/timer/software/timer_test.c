#include <stdio.h>
#include <stdint.h>

#define TIMER_BASE   0x400040
#define TIMER_CTRL   (*((volatile uint32_t *)(TIMER_BASE + 0x00)))
#define TIMER_LOAD   (*((volatile uint32_t *)(TIMER_BASE + 0x04)))
#define TIMER_VALUE  (*((volatile uint32_t *)(TIMER_BASE + 0x08)))
#define TIMER_STATUS (*((volatile uint32_t *)(TIMER_BASE + 0x0C)))

void main() {
    printf("=== Test 1: One-shot mode ===\n");
    TIMER_LOAD = 10;
    TIMER_CTRL = 0x1;
    printf("Timer started. Load=10\n");
    printf("Waiting for TIMEOUT...\n");
    while (!(TIMER_STATUS & 1));
    printf("TIMEOUT! VALUE=%d\n", (int)TIMER_VALUE);
    TIMER_STATUS = 1;
    printf("TIMEOUT cleared. STATUS=%d\n", (int)TIMER_STATUS);
    TIMER_CTRL = 0;

    printf("\n=== Test 2: Periodic mode (3 timeouts) ===\n");
    TIMER_LOAD = 50;
    TIMER_CTRL = 0x3;
    int count = 0;
    while (count < 3) {
        while (!(TIMER_STATUS & 1));
        count++;
        TIMER_STATUS = 1;
        printf("Timeout #%d! VALUE=%d\n", count, (int)TIMER_VALUE);
    }
    TIMER_CTRL = 0;
    printf("\nALL TESTS DONE\n");
}
