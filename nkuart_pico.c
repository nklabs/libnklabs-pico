// Copyright 2020 NK Labs, LLC

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

#include <string.h>
#include "nksched.h"
#include "nkuart.h"

#include "pico/stdlib.h"
#include "hardware/uart.h"
#include "hardware/irq.h"

#define UART_ID uart0
#define BAUD_RATE 115200
#define DATA_BITS 8
#define STOP_BITS 1
#define PARITY    UART_PARITY_NONE

// We are using pins 0 and 1, but see the GPIO function select table in the
// datasheet for information on which other pins can be used.
#define UART_TX_PIN 0
#define UART_RX_PIN 1

// Console UART Rx buffer

static unsigned char rx_buf[NK_UART_RXBUF_SIZE];
static uint32_t rx_buf_rd;
static volatile uint32_t rx_buf_wr;
static int tty_mode;

nk_spinlock_t console_lock = SPIN_LOCK_UNLOCKED;

// Task to submit when rx data available
int waiting_rx_tid;
void (*waiting_rx_task)(void *data);
void *waiting_rx_task_data;

void nk_set_uart_callback(int tid, void (*func)(void *data), void *data)
{
        nk_irq_flag_t irq_flag;
        irq_flag = nk_irq_lock(&console_lock);
	if (rx_buf_rd != rx_buf_wr) {
		// Data is available now
		nk_sched(tid, func, data, 0, "UART ISR");
		waiting_rx_task = 0;
	} else {
		waiting_rx_tid = tid;
		waiting_rx_task = func;
		waiting_rx_task_data = data;
	}
	nk_irq_unlock(&console_lock, irq_flag);
}

int nk_get_uart_mode()
{
	return tty_mode;
}

int nk_set_uart_mode(int new_mode)
{
	int old_mode = tty_mode;
	tty_mode = new_mode;
	return old_mode;
}

static void wait_for_space()
{
	while (!uart_is_writable(UART_ID));
}

void nk_putc(char ch)
{
	if (!tty_mode && ch == '\n') {
		wait_for_space();
		uart_putc(UART_ID, '\r');
	}
	wait_for_space();
	uart_putc(UART_ID, ch);
}

void nk_puts(const char *s)
{
	while (*s) {
		nk_putc(*s++);
	}
}

void nk_uart_write(const char *s, int len)
{
	while (len--) {
		nk_putc(*s++);
	}
}

// Transfer any available characters from UART FIFO to input buffer

static void rx_chars(void)
{
	uint32_t c;
	while (uart_is_readable(UART_ID)) {
		if (rx_buf_wr - rx_buf_rd != sizeof(rx_buf)) {
			rx_buf[rx_buf_wr++ & (sizeof(rx_buf) - 1)] = (unsigned char)uart_getc(UART_ID);
		}
	}
}

// Interrupt if characters are available: but Apollo gives interrupt on 4 byte units, not single byte, so
// we still have to poll.

void on_uart_rx()
{
	rx_chars();
	if (waiting_rx_task) {
		nk_sched(waiting_rx_tid, waiting_rx_task, waiting_rx_task_data, 0, "UART ISR");
		waiting_rx_task = 0;
	}
}

int nk_getc()
{
	int ch = -1;
        nk_irq_flag_t irq_flag = nk_irq_lock(&console_lock);
	if (rx_buf_rd != rx_buf_wr) {
		ch = rx_buf[rx_buf_rd++ & (sizeof(rx_buf) - 1)];
	}
	nk_irq_unlock(&console_lock, irq_flag);
	return ch;
}

int nk_kbhit()
{
        nk_irq_flag_t irq_flag;
        irq_flag = nk_irq_lock(&console_lock);
	if (rx_buf_rd != rx_buf_wr) {
		nk_irq_unlock(&console_lock, irq_flag);
		return 1;
	} else {
		nk_irq_unlock(&console_lock, irq_flag);
		return 0;
	}
}

int nk_uart_read(char *s, int len, nk_time_t timeout)
{
	int l = 0;
	int need_time = 1;
	nk_time_t old_time;
	nk_time_t clocks = timeout * NK_TIME_COUNTS_PER_USECOND;
	while (l != len) {
		int c = nk_getc();
		if (c != -1) {
			s[l++] = (char)c;
			need_time = 1;
		} else {
			if (need_time) {
				old_time = nk_get_time();
				need_time = 0;
			}
			if ((nk_get_time() - old_time) >= clocks)
				break;
		}
	}
	return l;
}

// UART configuration settings.

void nk_init_uart()
{
	uart_init(UART_ID, 115200);
	gpio_set_function(UART_TX_PIN, GPIO_FUNC_UART);
	gpio_set_function(UART_RX_PIN, GPIO_FUNC_UART);
	int __unused actual = uart_set_baudrate(UART_ID, BAUD_RATE);
	uart_set_hw_flow(UART_ID, false, false);
	uart_set_format(UART_ID, DATA_BITS, STOP_BITS, PARITY);
	uart_set_fifo_enabled(UART_ID, false); // ?
	int UART_IRQ = UART_ID == uart0 ? UART0_IRQ : UART1_IRQ;
	irq_set_exclusive_handler(UART_IRQ, on_uart_rx);
	irq_set_enabled(UART_IRQ, true);
	// Now enable the UART to send interrupts - RX only
	uart_set_irq_enables(UART_ID, true, false);

}
