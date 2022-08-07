# libnklabs on Raspberry Pi Pico / RP2040

The Rasberry Pi Pico SDK uses CMake for its build environment.  This is an
added layer of obfuscation that we do not enjoy, so we've replaced it with a
simple Makefile.

To reverse engineer the build process we used CMake as usual, but added
"VERBOSE=1" to the make command so that we could observe what's going on.  This
is what we've learned:

* RP2040 has optimized floating point functions in its boot ROM.  To get gcc
  to use them, the linker's "--wrap" option is used.  This renames a
  particular symbol (for example, foo) with a different name (\_\_wrap_foo). 
  Anyway so you will see around of 150 of these options passed to the
  linker.

* A special tool must be built which converts the .elf output into a
  Microsoft UF2 file suitable for copying to the filesystem that shows up when you plug the Pi Pico into USB.
This lets you install your firmware by just copying this file to the fake drive.

* The image must include a second stage bootloader.  This a separate program
built on its own.  A python script pads out and adds a checksum to the
resulting image.  It is then converted into ASCII hex bytes in an assembly
language source file which is then assembled and included with your own
program.  A key point is that this bootloader must know the type of flash
device that is attached to the RP2040.  CMake produces a C header file that
indicates the board type.  See generated/pico/config_autogen.h,
pico-sdk/src/boards/include/boards, and pico-sdk/src/rp2_common/boot_stage2.

Otherwise the build process is straightforward, matching any other ARM
Cortex-M0 device.  Aside from ARM cross-compiler, the only prerequisites are
Python3 and a native C++ compiler.

The Raspberry Pi Pico SDK expects you to use git submodules, but we've
included it as a subtree instead.  This means that you can use this
repository directly- no need for submodule initialization.

## Prerequisites

* ARM C/C++ cross-compiler
* Python3 (for 2nd stage bootloader checksum)
* Native C++ compiler (for ELF2UF2 tool)

