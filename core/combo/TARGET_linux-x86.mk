#
# Copyright (C) 2006 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Configuration for Linux on x86 as a target.
# Included by combo/select.mk

# Provide a default variant.
ifeq ($(strip $(TARGET_$(combo_2nd_arch_prefix)ARCH_VARIANT)),)
TARGET_$(combo_2nd_arch_prefix)ARCH_VARIANT := x86
endif

# Decouple NDK library selection with platform compiler version
$(combo_2nd_arch_prefix)TARGET_NDK_GCC_VERSION := 4.9

$(combo_2nd_arch_prefix)TARGET_GCC_VERSION := 4.9

# Include the arch-variant-specific configuration file.
# Its role is to define various ARCH_X86_HAVE_XXX feature macros,
# plus initial values for TARGET_GLOBAL_CFLAGS
#
TARGET_ARCH_SPECIFIC_MAKEFILE := $(BUILD_COMBOS)/arch/$(TARGET_$(combo_2nd_arch_prefix)ARCH)/$(TARGET_$(combo_2nd_arch_prefix)ARCH_VARIANT).mk
ifeq ($(strip $(wildcard $(TARGET_ARCH_SPECIFIC_MAKEFILE))),)
$(error Unknown $(TARGET_$(combo_2nd_arch_prefix)ARCH) architecture version: $(TARGET_$(combo_2nd_arch_prefix)ARCH_VARIANT))
endif

include $(TARGET_ARCH_SPECIFIC_MAKEFILE)
include $(BUILD_SYSTEM)/combo/fdo.mk

$(combo_2nd_arch_prefix)TARGET_TOOLCHAIN_ROOT := prebuilts/gcc/$(HOST_PREBUILT_TAG)/x86/x86_64-linux-android-$($(combo_2nd_arch_prefix)TARGET_GCC_VERSION)

define $(combo_var_prefix)transform-shared-lib-to-toc
$(call _gen_toc_command_for_elf,$(1),$(2))
endef

libc_root := bionic/libc

KERNEL_HEADERS_COMMON := $(libc_root)/kernel/uapi
KERNEL_HEADERS_COMMON += $(libc_root)/kernel/common
KERNEL_HEADERS_ARCH   := $(libc_root)/kernel/uapi/asm-x86 # x86 covers both x86 and x86_64.
KERNEL_HEADERS := $(KERNEL_HEADERS_COMMON) $(KERNEL_HEADERS_ARCH)

$(combo_2nd_arch_prefix)TARGET_GLOBAL_CFLAGS += \
			-O2 \
			-Wa,--noexecstack \
			-Werror=format-security \
			-D_FORTIFY_SOURCE=2 \
			-Wstrict-aliasing=2 \
			-ffunction-sections \
			-finline-functions \
			-finline-limit=300 \
			-fno-short-enums \
			-fstrict-aliasing \
			-funswitch-loops \
			-funwind-tables \
			-fstack-protector-strong \
			-m32 \
			-no-canonical-prefixes \
			-fno-canonical-system-headers \

$(combo_2nd_arch_prefix)TARGET_GLOBAL_CFLAGS += $(arch_variant_cflags)

ifeq ($(ARCH_X86_HAVE_SSSE3),true)   # yes, really SSSE3, not SSE3!
    $(combo_2nd_arch_prefix)TARGET_GLOBAL_CFLAGS += -DUSE_SSSE3 -mssse3
endif
ifeq ($(ARCH_X86_HAVE_SSE4),true)
    $(combo_2nd_arch_prefix)TARGET_GLOBAL_CFLAGS += -msse4
endif
ifeq ($(ARCH_X86_HAVE_SSE4_1),true)
    $(combo_2nd_arch_prefix)TARGET_GLOBAL_CFLAGS += -msse4.1
endif
ifeq ($(ARCH_X86_HAVE_SSE4_2),true)
    $(combo_2nd_arch_prefix)TARGET_GLOBAL_CFLAGS += -msse4.2
endif
ifeq ($(ARCH_X86_HAVE_AVX),true)
    $(combo_2nd_arch_prefix)TARGET_GLOBAL_CFLAGS += -mavx
endif
ifeq ($(ARCH_X86_HAVE_AES_NI),true)
    $(combo_2nd_arch_prefix)TARGET_GLOBAL_CFLAGS += -maes
endif

$(combo_2nd_arch_prefix)TARGET_GLOBAL_LDFLAGS += -m32

$(combo_2nd_arch_prefix)TARGET_GLOBAL_LDFLAGS += -Wl,-z,noexecstack
$(combo_2nd_arch_prefix)TARGET_GLOBAL_LDFLAGS += -Wl,-z,relro -Wl,-z,now
$(combo_2nd_arch_prefix)TARGET_GLOBAL_LDFLAGS += -Wl,--build-id=md5
$(combo_2nd_arch_prefix)TARGET_GLOBAL_LDFLAGS += -Wl,--warn-shared-textrel
$(combo_2nd_arch_prefix)TARGET_GLOBAL_LDFLAGS += -Wl,--fatal-warnings
$(combo_2nd_arch_prefix)TARGET_GLOBAL_LDFLAGS += -Wl,--gc-sections
$(combo_2nd_arch_prefix)TARGET_GLOBAL_LDFLAGS += -Wl,--hash-style=gnu
$(combo_2nd_arch_prefix)TARGET_GLOBAL_LDFLAGS += -Wl,--no-undefined-version

$(combo_2nd_arch_prefix)TARGET_C_INCLUDES := \
	$(libc_root)/arch-x86/include \
	$(libc_root)/include \
	$(KERNEL_HEADERS) \

$(combo_2nd_arch_prefix)TARGET_CRTBEGIN_STATIC_O := $($(combo_2nd_arch_prefix)TARGET_OUT_INTERMEDIATE_LIBRARIES)/crtbegin_static.o
$(combo_2nd_arch_prefix)TARGET_CRTBEGIN_DYNAMIC_O := $($(combo_2nd_arch_prefix)TARGET_OUT_INTERMEDIATE_LIBRARIES)/crtbegin_dynamic.o
$(combo_2nd_arch_prefix)TARGET_CRTEND_O := $($(combo_2nd_arch_prefix)TARGET_OUT_INTERMEDIATE_LIBRARIES)/crtend_android.o

$(combo_2nd_arch_prefix)TARGET_CRTBEGIN_SO_O := $($(combo_2nd_arch_prefix)TARGET_OUT_INTERMEDIATE_LIBRARIES)/crtbegin_so.o
$(combo_2nd_arch_prefix)TARGET_CRTEND_SO_O := $($(combo_2nd_arch_prefix)TARGET_OUT_INTERMEDIATE_LIBRARIES)/crtend_so.o

$(combo_2nd_arch_prefix)TARGET_PACK_MODULE_RELOCATIONS := true

$(combo_2nd_arch_prefix)TARGET_LINKER := /system/bin/linker

$(combo_2nd_arch_prefix)TARGET_GLOBAL_YASM_FLAGS := -f elf32 -m x86
