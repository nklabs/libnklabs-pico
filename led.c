// Copyright 2021 NK Labs, LLC

// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to permit
// persons to whom the Software is furnished to do so, subject to the
// following conditions:

// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
// OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
// THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#include "nkarch.h"
#include "nksched.h"
#include "nkprintf.h"
#include "led.h"
#include "pico/stdlib.h"

// Blink USER LED

#define BLINK_DELAY 500 // Blink interval

int led_tid; // Task ID for LED blinker
int led_blink; // LED state

// Blink USER_LED

void led_blinker(void *data)
{
    (void)data;
    if (led_blink)
    {
#ifdef PICO_DEFAULT_LED_PIN
        gpio_put(PICO_DEFAULT_LED_PIN, 0);
#endif
        led_blink = 0;
    }
    else
    {
#ifdef PICO_DEFAULT_LED_PIN
        gpio_put(PICO_DEFAULT_LED_PIN, 1);
#endif
        led_blink = 1;
    }
    nk_sched(led_tid, led_blinker, NULL, BLINK_DELAY, "LED blinker");
}

void nk_init_led()
{
    nk_startup_message("LED\n");
#ifdef PICO_DEFAULT_LED_PIN
    gpio_init(PICO_DEFAULT_LED_PIN);
    gpio_set_dir(PICO_DEFAULT_LED_PIN, GPIO_OUT);
#endif
    led_tid = nk_alloc_tid();
    nk_sched(led_tid, led_blinker, NULL, BLINK_DELAY, "LED blinker");
}
