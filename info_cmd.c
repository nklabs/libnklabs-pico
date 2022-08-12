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
#include <inttypes.h>
#include "version.h"
#include "nkreadline.h"
#include "nkcli.h"
#include "pico/unique_id.h"
#include "hardware/watchdog.h"
#include "hardware/clocks.h"

// Defines from linker
extern char __boot2_start__;
extern char __boot2_end__;
extern char __logical_binary_start;
extern char __flash_binary_end;
extern char __etext;
extern char __data_start__;
extern char __data_end__;
extern char __bss_start__;
extern char __bss_end__;
extern char __end__; // Heap
extern char __StackLimit; // End of RAM

void measure_freqs(void) {
    uint f_pll_sys = frequency_count_khz(CLOCKS_FC0_SRC_VALUE_PLL_SYS_CLKSRC_PRIMARY);
    uint f_pll_usb = frequency_count_khz(CLOCKS_FC0_SRC_VALUE_PLL_USB_CLKSRC_PRIMARY);
    uint f_rosc = frequency_count_khz(CLOCKS_FC0_SRC_VALUE_ROSC_CLKSRC);
    uint f_clk_sys = frequency_count_khz(CLOCKS_FC0_SRC_VALUE_CLK_SYS);
    uint f_clk_peri = frequency_count_khz(CLOCKS_FC0_SRC_VALUE_CLK_PERI);
    uint f_clk_usb = frequency_count_khz(CLOCKS_FC0_SRC_VALUE_CLK_USB);
    uint f_clk_adc = frequency_count_khz(CLOCKS_FC0_SRC_VALUE_CLK_ADC);
    uint f_clk_rtc = frequency_count_khz(CLOCKS_FC0_SRC_VALUE_CLK_RTC);
 
    nk_printf("pll_sys  = %dkHz\n", f_pll_sys);
    nk_printf("pll_usb  = %dkHz\n", f_pll_usb);
    nk_printf("rosc     = %dkHz\n", f_rosc);
    nk_printf("clk_sys  = %dkHz\n", f_clk_sys);
    nk_printf("clk_peri = %dkHz\n", f_clk_peri);
    nk_printf("clk_usb  = %dkHz\n", f_clk_usb);
    nk_printf("clk_adc  = %dkHz\n", f_clk_adc);
    nk_printf("clk_rtc  = %dkHz\n", f_clk_rtc);
 
    // Can't measure clk_ref / xosc as it is the ref
}

// Print information about firmware and system

static int cmd_info(nkinfile_t *args)
{
	if (nk_fscan(args, "")) {
                nk_printf("Firmware version %d.%d\n", firmware_major, firmware_minor);
                nk_printf("Build date: %4.4d-%2.2d-%2.2d %2.2d:%2.2d\n", build_year, build_month, build_day, build_hour, build_minute);
                nk_printf("Git hash: %s\n", git_hash);
                nk_printf("Target platform: %s\n", NK_PLATFORM);
		nk_printf("  sizeof(bool) = %u\n", sizeof(bool));
		nk_printf("  sizeof(char) = %u\n", sizeof(char));
		nk_printf("  sizeof(short) = %u\n", sizeof(short));
		nk_printf("  sizeof(int) = %u\n", sizeof(int));
		nk_printf("  sizeof(long) = %u\n", sizeof(long));
		nk_printf("  sizeof(long long) = %u\n", sizeof(long long));
		nk_printf("  sizeof(void *) = %u\n", sizeof(void *));
		nk_printf("  sizeof(float) = %u\n", sizeof(float));
		nk_printf("  sizeof(double) = %u\n", sizeof(double));
		pico_unique_board_id_t board_id;
		pico_get_unique_board_id(&board_id);

		nk_printf("Unique board id:");
		for (int i = 0; i < PICO_UNIQUE_BOARD_ID_SIZE_BYTES; ++i) {
			nk_printf(" %02x", board_id.id[i]);
		}
		nk_printf("\n");

		nk_printf("Flash locations:\n");
		nk_printf("  __boot2_start__ = %p\n", &__boot2_start__);
		nk_printf("  __boot2_end__ = %p\n", &__boot2_end__);
		nk_printf("  __logical_binary_start = %p\n", &__logical_binary_start);
		nk_printf("  __etext = %p\n", &__etext);
		nk_printf("  __flash_binary_end = %p\n", &__flash_binary_end);
		nk_printf("  an address in current text = %p\n", &cmd_info);
		nk_printf("Image size = %u\n", (unsigned int)&__flash_binary_end - (unsigned int)&__boot2_start__);

		nk_printf("RAM locations:\n");
		nk_printf("  __data_start__ = %p\n", &__data_start__);
		nk_printf("  __data_end__ = %p\n", &__data_end__);
		nk_printf("  __bss_start__ = %p\n", &__bss_start__);
		nk_printf("  __bss_end__ = %p\n", &__bss_end__);
		nk_printf("  __end__ = %p\n", &__end__);
		nk_printf("  __StackLimit = %p\n", &__StackLimit);
		nk_printf("  an address in current stack = %p\n", &args);
		nk_printf("RAM size = %u\n", (unsigned int)&__StackLimit - 0x20000000);

		const char *cause;
		if (watchdog_enable_caused_reboot())
			cause = "Watchdog";
		else if (watchdog_caused_reboot())
			cause = "Software";
		else
			cause = "Hardware";
		nk_printf("Reboot cause = %s\n", cause);

		measure_freqs();
	} else {
		nk_printf("Syntax error\n");
	}
	return 0;
}

COMMAND(cmd_info,
    ">info                      Display serial number and firmware information\n"
    "-info                      Display serial number and firmware information\n"
)
