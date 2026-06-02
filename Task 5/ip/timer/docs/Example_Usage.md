# Example Usage

## Setup
```c
#define TIMER_BASE   0x400040
#define TIMER_CTRL   (*((volatile uint32_t *)(TIMER_BASE + 0x00)))
#define TIMER_LOAD   (*((volatile uint32_t *)(TIMER_BASE + 0x04)))
#define TIMER_VALUE  (*((volatile uint32_t *)(TIMER_BASE + 0x08)))
#define TIMER_STATUS (*((volatile uint32_t *)(TIMER_BASE + 0x0C)))
```

## One-Shot
```c
TIMER_LOAD = 1000;
TIMER_CTRL = 0x1;
while (!(TIMER_STATUS & 0x1));
TIMER_STATUS = 0x1;
```

## Periodic
```c
TIMER_LOAD = 50;
TIMER_CTRL = 0x3;
for(int i=0; i<3; i++) {
    while (!(TIMER_STATUS & 0x1));
    TIMER_STATUS = 0x1;
}
```

## LED Blink
```c
#define GPIO_DATA (*((volatile uint32_t *)(0x400020)))
GPIO_DATA = 0x01;  // ON
// wait for timeout
GPIO_DATA = 0x00;  // OFF
```
