# Copyright © 2017 Mauro Rossi <issor.oruam@gmail.com>
# Copyright © 2017 Intel Corporation
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice (including the next
# paragraph) shall be included in all copies or substantial portions of the
# Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.

LOCAL_PATH := $(call my-dir)

# Import variables
include $(LOCAL_PATH)/Makefile.sources

#
# libmesa_vulkan_util
#

include $(CLEAR_VARS)
LOCAL_MODULE := libmesa_vulkan_util
LOCAL_MODULE_CLASS := STATIC_LIBRARIES

intermediates := $(call local-generated-sources-dir)

LOCAL_C_INCLUDES := \
	$(MESA_TOP)/include/vulkan \
	$(MESA_TOP)/src/util \
	$(MESA_TOP)/src/vulkan/util \
	$(MESA_TOP)/src/gallium/include \
	$(intermediates)/util \

ifeq ($(shell test $(PLATFORM_SDK_VERSION) -ge 27; echo $$?), 0)
LOCAL_C_INCLUDES += \
	frameworks/native/libs/nativebase/include \
	frameworks/native/libs/nativewindow/include \
	frameworks/native/libs/arect/include
LOCAL_HEADER_LIBRARIES += libcutils_headers libsystem_headers
endif

LOCAL_STATIC_LIBRARIES := \
	libmesa_nir

LOCAL_GENERATED_SOURCES := $(addprefix $(intermediates)/, \
	$(VULKAN_UTIL_GENERATED_FILES))

LOCAL_SRC_FILES := $(VULKAN_UTIL_FILES) $(VULKAN_WSI_FILES)

vulkan_api_xml = $(MESA_TOP)/src/vulkan/registry/vk.xml

$(intermediates)/util/vk_enum_to_str.c: $(MESA_TOP)/src/vulkan/util/gen_enum_to_str.py \
		$(vulkan_api_xml)
	@echo "target Generated: $(PRIVATE_MODULE) <= $(notdir $(@))"
	@mkdir -p $(dir $@)
	$(hide) $(MESA_PYTHON3) $< \
	    --xml $(vulkan_api_xml) \
	    --outdir $(dir $@)

$(intermediates)/util/vk_enum_to_str.h: $(intermediates)/util/vk_enum_to_str.c

$(intermediates)/util/vk_common_entrypoints.c: $(MESA_TOP)/src/vulkan/util/vk_entrypoints_gen.py \
		$(vulkan_api_xml)
	@echo "target Generated: $(PRIVATE_MODULE) <= $(notdir $(@))"
	@mkdir -p $(dir $@)
	$(hide) $(MESA_PYTHON3) $< \
	    --xml $(vulkan_api_xml) \
	    --proto --weak --prefix vk_common \
	    --out-c $@ --out-h $(dir $@)/vk_common_entrypoints.h

$(intermediates)/util/vk_common_entrypoints.h: $(intermediates)/util/vk_common_entrypoints.c

$(intermediates)/util/vk_dispatch_table.c: $(MESA_TOP)/src/vulkan/util/vk_dispatch_table_gen.py \
		$(vulkan_api_xml)
	@echo "target Generated: $(PRIVATE_MODULE) <= $(notdir $(@))"
	@mkdir -p $(dir $@)
	$(hide) $(MESA_PYTHON3) $< \
	    --xml $(vulkan_api_xml) \
	    --out-c $@

$(intermediates)/util/vk_dispatch_table.h: $(MESA_TOP)/src/vulkan/util/vk_dispatch_table_gen.py \
		$(vulkan_api_xml)
	@echo "target Generated: $(PRIVATE_MODULE) <= $(notdir $(@))"
	@mkdir -p $(dir $@)
	$(hide) $(MESA_PYTHON3) $< \
	    --xml $(vulkan_api_xml) \
	    --out-h $@

$(intermediates)/util/vk_extensions.c: $(MESA_TOP)/src/vulkan/util/vk_extensions_gen.py \
		$(vulkan_api_xml)
	@echo "target Generated: $(PRIVATE_MODULE) <= $(notdir $(@))"
	@mkdir -p $(dir $@)
	$(hide) $(MESA_PYTHON3) $< \
	    --xml $(vulkan_api_xml) \
	    --out-c $@

$(intermediates)/util/vk_extensions.h: $(MESA_TOP)/src/vulkan/util/vk_extensions_gen.py \
		$(vulkan_api_xml)
	@echo "target Generated: $(PRIVATE_MODULE) <= $(notdir $(@))"
	@mkdir -p $(dir $@)
	$(hide) $(MESA_PYTHON3) $< \
	    --xml $(vulkan_api_xml) \
	    --out-h $@

LOCAL_EXPORT_C_INCLUDE_DIRS := $(intermediates)/util

ifeq ($(filter $(MESA_ANDROID_MAJOR_VERSION), 4 5 6 7),)
LOCAL_SHARED_LIBRARIES += libnativewindow
endif

include $(MESA_COMMON_MK)
include $(BUILD_STATIC_LIBRARY)
