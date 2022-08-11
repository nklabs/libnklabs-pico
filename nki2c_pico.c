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

// rp2040 I2C

#include "nkarch.h"
#include "nki2c.h"
#include "hardware/i2c.h"

int nk_hal_i2c_write(void *port, uint8_t addr, size_t len, const uint8_t *buf)
{
	int rtn = i2c_write_blocking(port, addr, buf, len, false);

        return rtn;
}

int nk_hal_i2c_write_nostop(void *port, uint8_t addr, size_t len, const uint8_t *buf)
{
	int rtn = i2c_write_blocking(port, addr, buf, len, true);  // true to keep master control of bus

	return rtn;
}

int nk_hal_i2c_read(void *port, uint8_t addr, size_t len, uint8_t *buf)
{
	int rtn = i2c_read_blocking(port, addr, buf, len, false);

	return rtn;
}

int nk_hal_i2c_ping(void *port, uint8_t addr)
{
	uint8_t buf;
	int rtn = nk_hal_i2c_read(port, addr, 1, &buf);
	if (rtn < 0)
		return rtn;
	else
		return 0;
}
