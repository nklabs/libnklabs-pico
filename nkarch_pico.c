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
#include "nkprintf.h"
#include "nkmcuflash.h"
#include "nkarch_pico.h"
#include "nksched.h"
#include "hardware/timer.h"

// Convert delay in milliseconds to number of scheduler timer clock ticks
nk_time_t nk_convert_delay(uint32_t delay)
{
	return delay * (NK_TIME_COUNTS_PER_SECOND / 1000);
}

void nk_init_sched_timer()
{
	// Nothing to do
}

// Generate timer interrupt to wake up system

void nk_sched_wakeup(nk_time_t when)
{
	// Nothing to do, we wake up on every tick
}

// Get current time

nk_time_t nk_get_time()
{
	return timer_hw->timerawl;
}

// Busy loop delay
// Also use sched timer...

void nk_udelay(unsigned long usec)
{
	// Generic implementation
	nk_time_t old = nk_get_time();
	nk_time_t clocks = usec * (NK_TIME_COUNTS_PER_SECOND / 1000000);
	while ((nk_get_time() - old) < clocks);
}

int nk_init_mcuflash()
{
	return 0;
}

int nk_mcuflash_erase(const void *info, uint32_t address, uint32_t byte_count)
{
	(void)info;
	(void)address;
	(void)byte_count;
	return -1;
}

int nk_mcuflash_write(const void *info, uint32_t address, const uint8_t *data, size_t byte_count)
{
	(void)info;
	(void)address;
	(void)data;
	(void)byte_count;
	return -1;
}

int nk_mcuflash_read(const void *info, uint32_t address, uint8_t *data, size_t byte_count)
{
	(void)info;
	(void)address;
	(void)data;
	(void)byte_count;
	return -1;
}

void nk_reboot(void)
{
}
