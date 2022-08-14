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

// STM32 built-in RTC

#include <string.h>
#include "nkdriver_rtc_pico.h"
#include "hardware/rtc.h"

int nk_mcu_rtc_init(const void *junk)
{
    (void)junk;
    rtc_init();
    return 0;
}

int nk_mcu_rtc_get_datetime(const void *rtc, nkdatetime_t *datetime)
{
    datetime_t t;

    rtc_get_datetime(&t);

    datetime->year = t.year;
    datetime->month = t.month - 1;
    datetime->day = t.day - 1;
    datetime->weekday = t.dotw;

    datetime->hour = t.hour;
    datetime->min = t.min;
    datetime->sec = t.sec;

    return nk_datetime_sanity(datetime);
}

int nk_mcu_rtc_set_datetime(const void *rtc, const nkdatetime_t *datetime)
{
    datetime_t t;

    t.year = datetime->year;
    t.month = datetime->month + 1; // 1..12
    t.day = datetime->day + 1; // 1..31
    t.dotw = datetime->weekday; // 0..6

    t.hour = datetime->hour;
    t.min = datetime->min;
    t.sec = datetime->sec;

    rtc_set_datetime(&t);
    return 0;
}
