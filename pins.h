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

// GPIO pin database

#include "nkpin.h"

// Pin table indices

enum pin_idx {
#ifdef NK_PLATFORM_PICO
    PIN_IDX_GP0,
    PIN_IDX_GP1,
    PIN_IDX_GP2,
    PIN_IDX_GP3,
    PIN_IDX_GP4,
    PIN_IDX_GP5,
    PIN_IDX_GP6,
    PIN_IDX_GP7,
    PIN_IDX_GP8,
    PIN_IDX_GP9,
    PIN_IDX_GP10,
    PIN_IDX_GP11,
    PIN_IDX_GP12,
    PIN_IDX_GP13,
    PIN_IDX_GP14,
    PIN_IDX_GP15,
    PIN_IDX_GP16,
    PIN_IDX_GP17,
    PIN_IDX_GP18,
    PIN_IDX_GP19,
    PIN_IDX_GP20,
    PIN_IDX_GP21,
    PIN_IDX_GP22,
    PIN_IDX_GP26,
    PIN_IDX_GP27,
    PIN_IDX_GP28,
#endif


#ifdef NK_PLATFORM_STM32
#ifdef ARD_A0_Pin
    PIN_IDX_ARD_A0,
#endif
    PIN_IDX_ARD_A1,
    PIN_IDX_ARD_A2,
    PIN_IDX_ARD_A3,
    PIN_IDX_ARD_A4,
    PIN_IDX_ARD_A5,

#ifdef ARD_D0_Pin
    PIN_IDX_ARD_D0,
#endif
#ifdef ARD_D1_Pin
    PIN_IDX_ARD_D1,
#endif

    PIN_IDX_ARD_D2,
    PIN_IDX_ARD_D3,
    PIN_IDX_ARD_D4,
    PIN_IDX_ARD_D5,
    PIN_IDX_ARD_D6,
    PIN_IDX_ARD_D7,
    PIN_IDX_ARD_D8,
    PIN_IDX_ARD_D9,
    PIN_IDX_ARD_D10,
    PIN_IDX_ARD_D11,
    PIN_IDX_ARD_D12,
    PIN_IDX_ARD_D13,
#endif

#ifdef NK_PLATFORM_ATSAM
    PIN_IDX_ARD_A0,
    PIN_IDX_ARD_A1,
    PIN_IDX_ARD_A2,
    PIN_IDX_ARD_A3,
    PIN_IDX_ARD_A4,
    PIN_IDX_ARD_A5,

    PIN_IDX_ARD_D0,
    PIN_IDX_ARD_D1,
    PIN_IDX_ARD_D2,
    PIN_IDX_ARD_D3,
    PIN_IDX_ARD_D4,
    PIN_IDX_ARD_D5,
    PIN_IDX_ARD_D6,
    PIN_IDX_ARD_D7,
    PIN_IDX_ARD_D8,
    PIN_IDX_ARD_D9,
    PIN_IDX_ARD_D10,
    PIN_IDX_ARD_D11,
    PIN_IDX_ARD_D12,
    PIN_IDX_ARD_D13,
#endif

    PIN_COUNT
};
