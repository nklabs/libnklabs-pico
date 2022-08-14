# Makefile for RP2040 / PICO PI

# Name of this project, final target

NAME := pico

# Which board?  The 2nd stage bootloader needs this to know what type of flash IC is used
# But also see generated/config_autogen.h
# Set this with "make config BOARD=pico"

BOARD ?= $(shell cat BOARD)

# Where is pico-sdk?
PICO_SDK := pico-sdk/

# Where should we put object and dependency files?
# This directory is deleted by "make clean"
OBJ_DIR := obj/

# libnklabs: collect information for version.c

# Version number of your firmware

NK_VERSION_MAJOR := $(shell cat VERSION_MAJOR)
NK_VERSION_MINOR := $(shell cat VERSION_MINOR)

# Build date/time

NK_DATE := $(shell date -u -Iminute)
NK_YEAR := $(shell expr $(shell echo $(NK_DATE) | cut -b 1-4) + 0)
NK_MONTH := $(shell expr $(shell echo $(NK_DATE) | cut -b 6-7) + 0)
NK_DAY := $(shell expr $(shell echo $(NK_DATE) | cut -b 9-10) + 0)
NK_HOUR := $(shell expr $(shell echo $(NK_DATE) | cut -b 12-13) + 0)
NK_MINUTE := $(shell expr $(shell echo $(NK_DATE) | cut -b 15-16) + 0)

# Get git hash as a string
# It is postfixed with -dirty if there are uncommitted changed; otherwise, it is postfixed with -clean.

NK_GIT_REV := \"$(if $(shell git rev-parse --is-inside-work-tree),$(shell git rev-parse HEAD)-$(shell if git diff-index --quiet HEAD --; then echo clean; else echo dirty; fi),unknown)\"

# libnklabs: A define for the platform

NK_PLATFORM := NK_PLATFORM_PICO

# Tools used

# Cross compiler
TOOL_DIR := 

CC := $(TOOL_DIR)arm-none-eabi-gcc
CPP := $(TOOL_DIR)arm-none-eabi-g++
AS := $(TOOL_DIR)arm-none-eabi-gcc
LD := $(TOOL_DIR)arm-none-eabi-g++
OBJCOPY := $(TOOL_DIR)arm-none-eabi-objcopy
OBJDUMP := $(TOOL_DIR)arm-none-eabi-objdump

# Native C++ compiler for elf2uf2
NATIVE_CPP := c++

# ELF2UF2 tool
ELF2UF2 := ./elf2uf2

# C compiler flags

CFLAGS :=  \
 -D$(NK_PLATFORM) \
 -DNK_PLATFORM=\"$(NK_PLATFORM)\" \
 -DNK_VERSION_MAJOR=$(NK_VERSION_MAJOR) \
 -DNK_VERSION_MINOR=$(NK_VERSION_MINOR) \
 -DNK_YEAR=$(NK_YEAR) \
 -DNK_MONTH=$(NK_MONTH) \
 -DNK_DAY=$(NK_DAY) \
 -DNK_HOUR=$(NK_HOUR) \
 -DNK_MINUTE=$(NK_MINUTE) \
 -DNK_GIT_REV=$(NK_GIT_REV) \
 -DPICO_BOARD=\"$(BOARD)\" \
 -DPICO_BUILD=1 \
 -DPICO_CMAKE_BUILD_TYPE=\"Release\" \
 -DPICO_COPY_TO_RAM=0 \
 -DPICO_CXX_ENABLE_EXCEPTIONS=0 \
 -DPICO_NO_FLASH=0 \
 -DPICO_NO_HARDWARE=0 \
 -DPICO_ON_DEVICE=1 \
 -DPICO_PROGRAM_URL=\"https://github.com/raspberrypi/pico-examples/tree/HEAD/blink\" \
 -DPICO_TARGET_NAME=\"$(NAME)\" \
 -DPICO_USE_BLOCKED_RAM=0 \
 -DLIB_PICO_BIT_OPS=1 \
 -DLIB_PICO_BIT_OPS_PICO=1 \
 -DLIB_PICO_BOOTSEL_VIA_DOUBLE_RESET=1 \
 -DLIB_PICO_DIVIDER=1 \
 -DLIB_PICO_DIVIDER_HARDWARE=1 \
 -DLIB_PICO_DOUBLE=1 \
 -DLIB_PICO_DOUBLE_PICO=1 \
 -DLIB_PICO_FLOAT=1 \
 -DLIB_PICO_FLOAT_PICO=1 \
 -DLIB_PICO_INT64_OPS=1 \
 -DLIB_PICO_INT64_OPS_PICO=1 \
 -DLIB_PICO_MALLOC=1 \
 -DLIB_PICO_MEM_OPS=1 \
 -DLIB_PICO_MEM_OPS_PICO=1 \
 -DLIB_PICO_MULTICORE=1 \
 -DLIB_PICO_PLATFORM=1 \
 -DLIB_PICO_PRINTF=1 \
 -DLIB_PICO_PRINTF_PICO=1 \
 -DLIB_PICO_RUNTIME=1 \
 -DLIB_PICO_STANDARD_LINK=1 \
 -DLIB_PICO_STDIO=1 \
 -DLIB_PICO_STDIO_UART=1 \
 -DLIB_PICO_STDLIB=1 \
 -DLIB_PICO_SYNC=1 \
 -DLIB_PICO_SYNC_CORE=1 \
 -DLIB_PICO_SYNC_CRITICAL_SECTION=1 \
 -DLIB_PICO_SYNC_MUTEX=1 \
 -DLIB_PICO_SYNC_SEM=1 \
 -DLIB_PICO_TIME=1 \
 -DLIB_PICO_UNIQUE_ID=1 \
 -DLIB_PICO_UTIL=1 \
 -I$(PICO_SDK)src/common/pico_stdlib/include \
 -I$(PICO_SDK)src/rp2_common/hardware_gpio/include \
 -I$(PICO_SDK)src/common/pico_base/include \
 -Igenerated \
 -I$(PICO_SDK)src/boards/include \
 -I$(PICO_SDK)src/rp2_common/pico_platform/include \
 -I$(PICO_SDK)src/rp2040/hardware_regs/include \
 -I$(PICO_SDK)src/rp2_common/hardware_base/include \
 -I$(PICO_SDK)src/rp2040/hardware_structs/include \
 -I$(PICO_SDK)src/rp2_common/hardware_claim/include \
 -I$(PICO_SDK)src/rp2_common/hardware_sync/include \
 -I$(PICO_SDK)src/rp2_common/hardware_irq/include \
 -I$(PICO_SDK)src/common/pico_sync/include \
 -I$(PICO_SDK)src/common/pico_time/include \
 -I$(PICO_SDK)src/rp2_common/hardware_timer/include \
 -I$(PICO_SDK)src/common/pico_util/include \
 -I$(PICO_SDK)src/rp2_common/hardware_uart/include \
 -I$(PICO_SDK)src/rp2_common/hardware_divider/include \
 -I$(PICO_SDK)src/rp2_common/pico_runtime/include \
 -I$(PICO_SDK)src/rp2_common/hardware_clocks/include \
 -I$(PICO_SDK)src/rp2_common/hardware_resets/include \
 -I$(PICO_SDK)src/rp2_common/hardware_pll/include \
 -I$(PICO_SDK)src/rp2_common/hardware_vreg/include \
 -I$(PICO_SDK)src/rp2_common/hardware_watchdog/include \
 -I$(PICO_SDK)src/rp2_common/hardware_xosc/include \
 -I$(PICO_SDK)src/rp2_common/pico_printf/include \
 -I$(PICO_SDK)src/rp2_common/pico_bootrom/include \
 -I$(PICO_SDK)src/common/pico_bit_ops/include \
 -I$(PICO_SDK)src/common/pico_divider/include \
 -I$(PICO_SDK)src/rp2_common/pico_double/include \
 -I$(PICO_SDK)src/rp2_common/pico_int64_ops/include \
 -I$(PICO_SDK)src/rp2_common/pico_float/include \
 -I$(PICO_SDK)src/rp2_common/pico_malloc/include \
 -I$(PICO_SDK)src/rp2_common/boot_stage2/include \
 -I$(PICO_SDK)src/common/pico_binary_info/include \
 -I$(PICO_SDK)src/rp2_common/pico_stdio/include \
 -I$(PICO_SDK)src/rp2_common/pico_stdio_uart/include \
 -I$(PICO_SDK)src/rp2_common/hardware_dma/include \
 -I$(PICO_SDK)src/rp2_common/hardware_flash/include \
 -I$(PICO_SDK)src/rp2_common/hardware_i2c/include \
 -I$(PICO_SDK)src/rp2_common/hardware_interp/include \
 -I$(PICO_SDK)src/rp2_common/hardware_pio/include \
 -I$(PICO_SDK)src/rp2_common/hardware_pwm/include \
 -I$(PICO_SDK)src/rp2_common/hardware_rtc/include \
 -I$(PICO_SDK)src/rp2_common/hardware_spi/include \
 -I$(PICO_SDK)src/rp2_common/pico_unique_id/include \
 -I$(PICO_SDK)src/rp2_common/pico_multicore/include \
 -I libnklabs/inc \
 -I config \
 -I . \
 -mcpu=cortex-m0plus \
 -mthumb \
 -O3 \
 -DNDEBUG \
 -ffunction-sections \
 -fdata-sections \
 -std=gnu11

# List object files here

OBJS := \
  $(PICO_SDK)src/common/pico_sync/critical_section.o \
  $(PICO_SDK)src/common/pico_sync/lock_core.o \
  $(PICO_SDK)src/common/pico_sync/mutex.o \
  $(PICO_SDK)src/common/pico_sync/sem.o \
  $(PICO_SDK)src/common/pico_time/time.o \
  $(PICO_SDK)src/common/pico_time/timeout_helper.o \
  $(PICO_SDK)src/common/pico_util/datetime.o \
  $(PICO_SDK)src/common/pico_util/pheap.o \
  $(PICO_SDK)src/common/pico_util/queue.o \
  $(PICO_SDK)src/rp2_common/hardware_claim/claim.o \
  $(PICO_SDK)src/rp2_common/hardware_clocks/clocks.o \
  $(PICO_SDK)src/rp2_common/hardware_divider/divider.o \
  $(PICO_SDK)src/rp2_common/hardware_gpio/gpio.o \
  $(PICO_SDK)src/rp2_common/hardware_irq/irq.o \
  $(PICO_SDK)src/rp2_common/hardware_irq/irq_handler_chain.o \
  $(PICO_SDK)src/rp2_common/hardware_pll/pll.o \
  $(PICO_SDK)src/rp2_common/hardware_sync/sync.o \
  $(PICO_SDK)src/rp2_common/hardware_timer/timer.o \
  $(PICO_SDK)src/rp2_common/hardware_uart/uart.o \
  $(PICO_SDK)src/rp2_common/hardware_vreg/vreg.o \
  $(PICO_SDK)src/rp2_common/hardware_watchdog/watchdog.o \
  $(PICO_SDK)src/rp2_common/hardware_xosc/xosc.o \
  $(PICO_SDK)src/rp2_common/pico_bit_ops/bit_ops_aeabi.o \
  $(PICO_SDK)src/rp2_common/pico_bootrom/bootrom.o \
  $(PICO_SDK)src/rp2_common/pico_divider/divider.o \
  $(PICO_SDK)src/rp2_common/pico_double/double_aeabi.o \
  $(PICO_SDK)src/rp2_common/pico_double/double_init_rom.o \
  $(PICO_SDK)src/rp2_common/pico_double/double_math.o \
  $(PICO_SDK)src/rp2_common/pico_double/double_v1_rom_shim.o \
  $(PICO_SDK)src/rp2_common/pico_float/float_aeabi.o \
  $(PICO_SDK)src/rp2_common/pico_float/float_init_rom.o \
  $(PICO_SDK)src/rp2_common/pico_float/float_math.o \
  $(PICO_SDK)src/rp2_common/pico_float/float_v1_rom_shim.o \
  $(PICO_SDK)src/rp2_common/pico_int64_ops/pico_int64_ops_aeabi.o \
  $(PICO_SDK)src/rp2_common/pico_malloc/pico_malloc.o \
  $(PICO_SDK)src/rp2_common/pico_mem_ops/mem_ops_aeabi.o \
  $(PICO_SDK)src/rp2_common/pico_platform/platform.o \
  $(PICO_SDK)src/rp2_common/pico_printf/printf.o \
  $(PICO_SDK)src/rp2_common/pico_runtime/runtime.o \
  $(PICO_SDK)src/rp2_common/pico_standard_link/binary_info.o \
  $(PICO_SDK)src/rp2_common/pico_standard_link/crt0.o \
  $(PICO_SDK)src/rp2_common/pico_standard_link/new_delete.o \
  $(PICO_SDK)src/rp2_common/pico_stdio/stdio.o \
  $(PICO_SDK)src/rp2_common/pico_stdio_uart/stdio_uart.o \
  $(PICO_SDK)src/rp2_common/pico_stdlib/stdlib.o \
  $(PICO_SDK)src/rp2_common/hardware_dma/dma.o \
  $(PICO_SDK)src/rp2_common/hardware_flash/flash.o \
  $(PICO_SDK)src/rp2_common/hardware_i2c/i2c.o \
  $(PICO_SDK)src/rp2_common/hardware_interp/interp.o \
  $(PICO_SDK)src/rp2_common/hardware_pio/pio.o \
  $(PICO_SDK)src/rp2_common/hardware_rtc/rtc.o \
  $(PICO_SDK)src/rp2_common/hardware_spi/spi.o \
  $(PICO_SDK)src/rp2_common/pico_unique_id/unique_id.o \
  $(PICO_SDK)src/rp2_common/pico_bootsel_via_double_reset/pico_bootsel_via_double_reset.o \
  $(PICO_SDK)src/rp2_common/pico_multicore/multicore.o \
  basic_cmds.o \
  database.o \
  i2c.o \
  info_cmd.o \
  libnklabs/src/nkchecked.o \
  libnklabs/src/nkcli.o \
  libnklabs/src/nkcrclib.o \
  libnklabs/src/nkdbase.o \
  libnklabs/src/nkdatetime.o \
  libnklabs/src/nkdirect.o \
  libnklabs/src/nki2c.o \
  libnklabs/src/nkinfile.o \
  libnklabs/src/nkmcuflash.o \
  libnklabs/src/nkoutfile.o \
  libnklabs/src/nkprintf.o \
  libnklabs/src/nkreadline.o \
  libnklabs/src/nkrtc.o \
  libnklabs/src/nkscan.o \
  libnklabs/src/nksched.o \
  libnklabs/src/nkserialize.o \
  libnklabs/src/nkstring.o \
  libnklabs/src/nkymodem.o \
  main.o \
  nkarch_pico.o \
  nkdriver_rtc_pico.o \
  nki2c_pico.o \
  nkuart_pico.o \
  nkymodem_cmd.o \
  rtc.o \
  wdt.o \

# Keep object files in a subdirectory

MOST_OBJS := $(addprefix $(OBJ_DIR), $(OBJS))

SUBDIR_OBJS := $(MOST_OBJS) $(OBJ_DIR)version.o

# Default target
# Convert .elf to other formats

$(NAME).uf2 $(NAME).hex $(NAME).bin $(NAME).dis: $(NAME).elf $(ELF2UF2)
	@echo
	$(ELF2UF2) $(NAME).elf $(NAME).uf2
	$(OBJCOPY) -Oihex $(NAME).elf $(NAME).hex
	$(OBJCOPY) -Obinary $(NAME).elf $(NAME).bin
	$(OBJDUMP) -h $(NAME).elf >$(NAME).dis
	$(OBJDUMP) -d $(NAME).elf >>$(NAME).dis
	@echo

# Link
# All the --wraps are for directing math functions to use bootloader ROM versions

$(NAME).elf: pico.ld $(SUBDIR_OBJS) bs2_default_padded_checksummed.S
	@echo
	$(LD)  -mcpu=cortex-m0plus -mthumb -O3 -DNDEBUG \
 -Wl,--build-id=none \
 --specs=nosys.specs \
 -Wl,--wrap=sprintf \
 -Wl,--wrap=snprintf \
 -Wl,--wrap=vsnprintf \
 -Wl,--wrap=__clzsi2 \
 -Wl,--wrap=__clzdi2 \
 -Wl,--wrap=__ctzsi2 \
 -Wl,--wrap=__ctzdi2 \
 -Wl,--wrap=__popcountsi2 \
 -Wl,--wrap=__popcountdi2 \
 -Wl,--wrap=__clz \
 -Wl,--wrap=__clzl \
 -Wl,--wrap=__clzll \
 -Wl,--wrap=__aeabi_idiv \
 -Wl,--wrap=__aeabi_idivmod \
 -Wl,--wrap=__aeabi_ldivmod \
 -Wl,--wrap=__aeabi_uidiv \
 -Wl,--wrap=__aeabi_uidivmod \
 -Wl,--wrap=__aeabi_uldivmod \
 -Wl,--wrap=__aeabi_dadd \
 -Wl,--wrap=__aeabi_ddiv \
 -Wl,--wrap=__aeabi_dmul \
 -Wl,--wrap=__aeabi_drsub \
 -Wl,--wrap=__aeabi_dsub \
 -Wl,--wrap=__aeabi_cdcmpeq \
 -Wl,--wrap=__aeabi_cdrcmple \
 -Wl,--wrap=__aeabi_cdcmple \
 -Wl,--wrap=__aeabi_dcmpeq \
 -Wl,--wrap=__aeabi_dcmplt \
 -Wl,--wrap=__aeabi_dcmple \
 -Wl,--wrap=__aeabi_dcmpge \
 -Wl,--wrap=__aeabi_dcmpgt \
 -Wl,--wrap=__aeabi_dcmpun \
 -Wl,--wrap=__aeabi_i2d \
 -Wl,--wrap=__aeabi_l2d \
 -Wl,--wrap=__aeabi_ui2d \
 -Wl,--wrap=__aeabi_ul2d \
 -Wl,--wrap=__aeabi_d2iz \
 -Wl,--wrap=__aeabi_d2lz \
 -Wl,--wrap=__aeabi_d2uiz \
 -Wl,--wrap=__aeabi_d2ulz \
 -Wl,--wrap=__aeabi_d2f \
 -Wl,--wrap=sqrt \
 -Wl,--wrap=cos \
 -Wl,--wrap=sin \
 -Wl,--wrap=tan \
 -Wl,--wrap=atan2 \
 -Wl,--wrap=exp \
 -Wl,--wrap=log \
 -Wl,--wrap=ldexp \
 -Wl,--wrap=copysign \
 -Wl,--wrap=trunc \
 -Wl,--wrap=floor \
 -Wl,--wrap=ceil \
 -Wl,--wrap=round \
 -Wl,--wrap=sincos \
 -Wl,--wrap=asin \
 -Wl,--wrap=acos \
 -Wl,--wrap=atan \
 -Wl,--wrap=sinh \
 -Wl,--wrap=cosh \
 -Wl,--wrap=tanh \
 -Wl,--wrap=asinh \
 -Wl,--wrap=acosh \
 -Wl,--wrap=atanh \
 -Wl,--wrap=exp2 \
 -Wl,--wrap=log2 \
 -Wl,--wrap=exp10 \
 -Wl,--wrap=log10 \
 -Wl,--wrap=pow \
 -Wl,--wrap=powint \
 -Wl,--wrap=hypot \
 -Wl,--wrap=cbrt \
 -Wl,--wrap=fmod \
 -Wl,--wrap=drem \
 -Wl,--wrap=remainder \
 -Wl,--wrap=remquo \
 -Wl,--wrap=expm1 \
 -Wl,--wrap=log1p \
 -Wl,--wrap=fma \
 -Wl,--wrap=__aeabi_lmul \
 -Wl,--wrap=__aeabi_fadd \
 -Wl,--wrap=__aeabi_fdiv \
 -Wl,--wrap=__aeabi_fmul \
 -Wl,--wrap=__aeabi_frsub \
 -Wl,--wrap=__aeabi_fsub \
 -Wl,--wrap=__aeabi_cfcmpeq \
 -Wl,--wrap=__aeabi_cfrcmple \
 -Wl,--wrap=__aeabi_cfcmple \
 -Wl,--wrap=__aeabi_fcmpeq \
 -Wl,--wrap=__aeabi_fcmplt \
 -Wl,--wrap=__aeabi_fcmple \
 -Wl,--wrap=__aeabi_fcmpge \
 -Wl,--wrap=__aeabi_fcmpgt \
 -Wl,--wrap=__aeabi_fcmpun \
 -Wl,--wrap=__aeabi_i2f \
 -Wl,--wrap=__aeabi_l2f \
 -Wl,--wrap=__aeabi_ui2f \
 -Wl,--wrap=__aeabi_ul2f \
 -Wl,--wrap=__aeabi_f2iz \
 -Wl,--wrap=__aeabi_f2lz \
 -Wl,--wrap=__aeabi_f2uiz \
 -Wl,--wrap=__aeabi_f2ulz \
 -Wl,--wrap=__aeabi_f2d \
 -Wl,--wrap=sqrtf \
 -Wl,--wrap=cosf \
 -Wl,--wrap=sinf \
 -Wl,--wrap=tanf \
 -Wl,--wrap=atan2f \
 -Wl,--wrap=expf \
 -Wl,--wrap=logf \
 -Wl,--wrap=ldexpf \
 -Wl,--wrap=copysignf \
 -Wl,--wrap=truncf \
 -Wl,--wrap=floorf \
 -Wl,--wrap=ceilf \
 -Wl,--wrap=roundf \
 -Wl,--wrap=sincosf \
 -Wl,--wrap=asinf \
 -Wl,--wrap=acosf \
 -Wl,--wrap=atanf \
 -Wl,--wrap=sinhf \
 -Wl,--wrap=coshf \
 -Wl,--wrap=tanhf \
 -Wl,--wrap=asinhf \
 -Wl,--wrap=acoshf \
 -Wl,--wrap=atanhf \
 -Wl,--wrap=exp2f \
 -Wl,--wrap=log2f \
 -Wl,--wrap=exp10f \
 -Wl,--wrap=log10f \
 -Wl,--wrap=powf \
 -Wl,--wrap=powintf \
 -Wl,--wrap=hypotf \
 -Wl,--wrap=cbrtf \
 -Wl,--wrap=fmodf \
 -Wl,--wrap=dremf \
 -Wl,--wrap=remainderf \
 -Wl,--wrap=remquof \
 -Wl,--wrap=expm1f \
 -Wl,--wrap=log1pf \
 -Wl,--wrap=fmaf \
 -Wl,--wrap=malloc \
 -Wl,--wrap=calloc \
 -Wl,--wrap=realloc \
 -Wl,--wrap=free \
 -Wl,--wrap=memcpy \
 -Wl,--wrap=memset \
 -Wl,--wrap=__aeabi_memcpy \
 -Wl,--wrap=__aeabi_memset \
 -Wl,--wrap=__aeabi_memcpy4 \
 -Wl,--wrap=__aeabi_memset4 \
 -Wl,--wrap=__aeabi_memcpy8 \
 -Wl,--wrap=__aeabi_memset8 \
 -Wl,-Map=$(NAME).map \
 -Wl,--script=pico.ld \
 -Wl,-z,max-page-size=4096 \
 -Wl,--gc-sections \
 -Wl,--wrap=printf \
 -Wl,--wrap=vprintf \
 -Wl,--wrap=puts \
 -Wl,--wrap=putchar \
 -Wl,--wrap=getchar \
 $(SUBDIR_OBJS)  -o $(NAME).elf bs2_default_padded_checksummed.S

# Rebuild version.o if any other file changed

$(OBJ_DIR)version.o: $(MOST_OBJS) VERSION_MAJOR VERSION_MINOR

# Commmands / phony targets

.PHONY: help
help:
	@echo
	@echo "make                     Build $(NAME).uf2"
	@echo
	@echo "make flash               Program flash memory by copying $(NAME).uf2 to /media/$(USER)/RPI-RP2"
	@echo
	@echo "make clean               Delete intermediate files"
	@echo
	@echo "make cleaner             Delete intermediate files and final image"
	@echo
	@echo "make config BOARD=xxxx   Configure build for specified board.  See $(PICO_SDK)src/boards/include/boards"
	@echo

.PHONY: clean
clean:
	rm -f $(ELF2UF2)
	rm -f bs2_default.bin bs2_default.dis bs2_default.elf bs2_default_padded_checksummed.S compile_time_choice.o
	rm -rf $(OBJ_DIR)

.PHONY: cleaner
cleaner: clean
	rm -f $(NAME).elf $(NAME).hex $(NAME).bin $(NAME).dis $(NAME).uf2

.PHONY: flash
flash: $(NAME).uf2
	cp $(NAME).uf2 /media/$(USER)/RPI-RP2

.PHONY: config
config: clean
	@echo
	echo "$(BOARD)" >BOARD
	echo "#include \"../../$(PICO_SDK)src/boards/include/boards/$(BOARD).h\"" >generated/pico/config_autogen.h
	echo "#include \"../../$(PICO_SDK)src/rp2_common/cmsis/include/cmsis/rename_exceptions.h\"" >>generated/pico/config_autogen.h
	@echo
	@echo "Selected board = $(BOARD)"
	@echo

# include dependancy files if they exist
-include $(SUBDIR_OBJS:.o=.d)

# Compile and generate dependency info, C files
$(OBJ_DIR)%.o: %.c
	@echo
	@mkdir -p $(OBJ_DIR)$(shell dirname $*)
	$(CC) -c $(CFLAGS) -MT $@ -MMD -MP -MF $(OBJ_DIR)$*.d $*.c -o $(OBJ_DIR)$*.o

# Compile and generate dependency info, CPP files
$(OBJ_DIR)%.o: %.cpp
	@echo
	@mkdir -p $(OBJ_DIR)$(shell dirname $*)
	$(CPP) -c $(CFLAGS) -MT $@ -MMD -MP -MF $(OBJ_DIR)$*.d $*.cpp -o $(OBJ_DIR)$*.o

# Assemble
$(OBJ_DIR)%.o: %.S
	@echo
	@mkdir -p $(OBJ_DIR)$(shell dirname $*)
	$(CC) -c $(CFLAGS) -MT $@ -MMD -MP -MF $(OBJ_DIR)$*.d $*.S -o $(OBJ_DIR)$*.o

#
# Build elf2uf2 tool using native compiler
#

$(ELF2UF2): $(PICO_SDK)tools/elf2uf2/main.cpp
	@echo
	$(NATIVE_CPP)  -I$(PICO_SDK)src/common/boot_uf2/include -std=gnu++14 -o $(ELF2UF2) $(PICO_SDK)tools/elf2uf2/main.cpp


#
# Build 2nd stage bootloader
#

# Compile
compile_time_choice.o : $(PICO_SDK)src/rp2_common/boot_stage2/compile_time_choice.S generated/pico/config_autogen.h
	@echo
	$(CC) \
  -DPICO_BOARD=\"$(BOARD)\" \
  -DPICO_BUILD=1 \
  -DPICO_NO_HARDWARE=0 \
  -DPICO_ON_DEVICE=1 \
  -I$(PICO_SDK)src/rp2_common/boot_stage2/asminclude \
  -I$(PICO_SDK)src/rp2040/hardware_regs/include \
  -I$(PICO_SDK)src/rp2_common/hardware_base/include \
  -I$(PICO_SDK)src/common/pico_base/include \
  -Igenerated \
  -I$(PICO_SDK)src/boards/include \
  -I$(PICO_SDK)src/rp2_common/pico_platform/include \
  -I$(PICO_SDK)src/rp2_common/boot_stage2/include \
  -mcpu=cortex-m0plus \
  -mthumb \
  -O3 \
  -DNDEBUG \
  -o compile_time_choice.o -c $(PICO_SDK)src/rp2_common/boot_stage2/compile_time_choice.S

# Link
bs2_default.elf : compile_time_choice.o
	@echo
	$(CC) \
  -mcpu=cortex-m0plus \
  -mthumb \
  -O3 \
  -DNDEBUG \
  -Wl,--build-id=none \
  --specs=nosys.specs \
  -nostartfiles \
  -Wl,--script=$(PICO_SDK)src/rp2_common/boot_stage2/boot_stage2.ld \
  -Wl,-Map=bs2_default.elf.map \
  compile_time_choice.o \
  -o bs2_default.elf

# Convert to binary
bs2_default.bin bs2_default.dis: bs2_default.elf
	@echo
	$(OBJCOPY) -Obinary bs2_default.elf bs2_default.bin
	$(OBJDUMP) -h bs2_default.elf >bs2_default.dis
	$(OBJDUMP) -d bs2_default.elf >>bs2_default.dis

# Pad and checksum
bs2_default_padded_checksummed.S : bs2_default.bin
	@echo
	python3 $(PICO_SDK)src/rp2_common/boot_stage2/pad_checksum -s 0xffffffff bs2_default.bin bs2_default_padded_checksummed.S
	@echo
