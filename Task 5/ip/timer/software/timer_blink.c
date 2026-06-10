#include <stdio.h>
#include <stdint.h>

// Timer IP Registers (Base: 0x400040)
#define TIMER_BASE   0x400040
#define TIMER_CTRL   (*((volatile uint32_t *)(TIMER_BASE + 0x00)))
#define TIMER_LOAD   (*((volatile uint32_t *)(TIMER_BASE + 0x04)))
#define TIMER_VALUE  (*((volatile uint32_t *)(TIMER_BASE + 0x08)))
#define TIMER_STATUS (*((volatile uint32_t *)(TIMER_BASE + 0x0C)))

// GPIO IP Registers (Base: 0x400020)
#define GPIO_BASE    0x400020
#define GPIO_DATA    (*((volatile uint32_t *)(GPIO_BASE + 0x00)))
#define GPIO_DIR     (*((volatile uint32_t *)(GPIO_BASE + 0x04)))
#define GPIO_READ    (*((volatile uint32_t *)(GPIO_BASE + 0x08)))

// UART Registers
#define UART_DAT     (*(volatile uint32_t*)0x00400008)
#define UART_CNTL    (*(volatile uint32_t*)0x00400010)

// UART Helper Functions
static void uart_putchar(char c) {
    while (!(UART_CNTL & (1 << 8)));
    UART_DAT = (uint32_t)c;
}

static void uart_print(const char *s) {
    while (*s) {
        uart_putchar(*s++);
    }
}

static void uart_newline(void) {
    uart_putchar('\r');
    uart_putchar('\n');
}

static void uart_print_hex(uint32_t val) {
    uart_print("0x");
    for (int i = 7; i >= 0; i--) {
        uint8_t nibble = (val >> (i * 4)) & 0xF;
        uart_putchar(nibble < 10 ? '0' + nibble : 'A' + nibble - 10);
    }
}

static void print_reg(const char *name, uint32_t val) {
    uart_print(name);
    uart_print(" = ");
    uart_print_hex(val);
    uart_newline();
}

// Simple delay
static void delay(uint32_t count) {
    volatile uint32_t i;
    for (i = 0; i < count; i++);
}

// Main program
int main(void) {
    delay(1000);
    
    uart_print("================================");
    uart_newline();
    uart_print("  Task-4: Timer IP Hardware Demo");
    uart_newline();
    uart_print("  VSDSquadron FPGA Mini");
    uart_newline();
    uart_print("================================");
    uart_newline();
    uart_newline();

    // Setup GPIO
    uart_print("Setting up GPIO for LED output");
    uart_newline();
    GPIO_DIR  = 0x000000FF;
    GPIO_DATA = 0x00000000;
    delay(100);
    print_reg("GPIO_DIR", GPIO_DIR);
    uart_newline();

    // Setup Timer: 468750 counts with /256 prescaler = ~10 seconds at 12MHz
    uart_print("Configuring Timer for 10-second intervals");
    uart_newline();
    uart_print("TIMER_LOAD written: ");
    uart_print("468750");
    uart_newline();
    
    TIMER_CTRL = 0x00000000;  // Disable first
    delay(100);
    
    TIMER_LOAD = 468750;
    
    // CTRL = EN(1) | MODE(1) | PRESC_EN(1) | PRESC_DIV(255)
    //      = 0x0000FF07
    TIMER_CTRL = (255 << 8) | (1 << 2) | (1 << 1) | (1 << 0);
    uart_print("TIMER_CTRL written: EN=1 MODE=periodic PRESC=255");
    uart_newline();
    uart_newline();

    // LED blink loop
    int timeout_count = 0;
    int led_state = 1;

    GPIO_DATA = 0x00000001;  // LED ON
    uart_print("LED ON - waiting for first timeout...");
    uart_newline();
    uart_print("================================");
    uart_newline();

    while (1) {
        // Poll for TIMEOUT
        if (TIMER_STATUS & 0x1) {
            timeout_count++;
            led_state = !led_state;
            GPIO_DATA = led_state ? 0x00000001 : 0x00000000;
            TIMER_STATUS = 0x1;  // Clear TIMEOUT
            
            uart_print("TIMEOUT #");
            if (timeout_count < 10)
                uart_putchar('0');
            uart_putchar('0' + (timeout_count % 10));
            uart_print(" -> LED ");
            uart_print(led_state ? "ON" : "OFF");
            uart_newline();
            
            if (timeout_count >= 10)
                break;
            
            delay(1000);
        }
    }

    uart_newline();
    uart_print("================================");
    uart_newline();
    uart_print("DEMO COMPLETE - Timer IP works!");
    uart_newline();
    uart_print("================================");
    uart_newline();

    TIMER_CTRL = 0x0;
    GPIO_DATA = 0x0;

    while (1);
    return 0;
}
