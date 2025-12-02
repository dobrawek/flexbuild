# Copyright 2021-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# Sample program to monitor i.MX GPU performance data


gputop:
	@[ $(DESTARCH) != arm64 -o $(DISTROVARIANT) != desktop ] && exit || \
	 $(call fbprint_b,"gputop") && \
	 $(call repo-mngr,fetch,gputop,apps/graphics) && \
	 if [ ! -f $(DESTDIR)/usr/include/gpuperfcnt/gpuperfcnt.h ]; then \
	     bld libgpuperfcnt -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 cd $(GRAPHICSDIR)/gputop && \
	 mkdir -p build_$(DISTROTYPE)_$(ARCH) && \
	 cd build_$(DISTROTYPE)_$(ARCH) && \
	 export ARCH=arm64 && \
	 export CFLAGS="--sysroot=$(RFSDIR) -B$(RFSDIR)/usr/lib/aarch64-linux-gnu -I$(RFSDIR)/usr/include -I$(RFSDIR)/usr/include/aarch64-linux-gnu" && \
	 export CXXFLAGS="--sysroot=$(RFSDIR) -B$(RFSDIR)/usr/lib/aarch64-linux-gnu -I$(RFSDIR)/usr/include -I$(RFSDIR)/usr/include/aarch64-linux-gnu -L$(RFSDIR)/usr/lib/aarch64-linux-gnu" && \
	 export LDFLAGS="--sysroot=$(RFSDIR) -B$(RFSDIR)/usr/lib/aarch64-linux-gnu -L$(RFSDIR)/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,$(RFSDIR)/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,$(RFSDIR)/lib" && \
	 export OECORE_TARGET_SYSROOT=$(RFSDIR) && \
	 cmake -DCMAKE_TOOLCHAIN_FILE=$(GRAPHICSDIR)/gputop/cmake/OEToolchainConfig.cmake \
	       -DCMAKE_C_COMPILER="$(CROSS_COMPILE)gcc" \
	       -DCMAKE_CXX_COMPILER="$(CROSS_COMPILE)g++" \
	       -DCMAKE_SYSROOT=$(RFSDIR) \
	       -DCMAKE_C_COMPILER_WORKS=TRUE \
	       -DCMAKE_CXX_COMPILER_WORKS=TRUE \
	       -DGPUPERFCNT_INCLUDE_PATH=$(DESTDIR)/usr/include \
	       -DGPUPERFCNT_LIB_PATH=$(DESTDIR)/usr/lib .. && \
	 $(MAKE) -j$(JOBS) && $(MAKE) install && \
	 install -m 0444 ../man/* $(DESTDIR)/usr/local/share/man/man8/ && \
	 $(call fbprint_d,"gputop")
