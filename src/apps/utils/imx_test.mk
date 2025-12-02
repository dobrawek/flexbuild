# Copyright 2023-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# Unit tests for the i.MX BSP


PLATFORM = IMX8

imx_test:
	@[ $(DESTARCH) != arm64 -o $(SOCFAMILY) != IMX -o $(DISTROVARIANT) != desktop ] && exit || \
	 $(call fbprint_b,"imx_test") && \
	 $(call repo-mngr,fetch,imx_test,apps/utils) && \
	 if [ ! -f $(DESTDIR)/usr/include/linux/mxc_asrc.h ]; then \
	     bld linux-headers -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/include/xf86drm.h ]; then \
	     bld libdrm -r $(DISTROTYPE):$(DISTROVARIANT); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/include/alsa/asoundlib.h ]; then \
	     bld alsa_lib -r $(DISTROTYPE):$(DISTROVARIANT); \
	 fi && \
	 sudo cp -rf $(DESTDIR)/usr/include/alsa $(RFSDIR)/usr/include && \
	 cd $(UTILSDIR)/imx_test && \
	 mkdir -p $(DESTDIR)/opt/unit_tests && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR) -B$(RFSDIR)/usr/lib/aarch64-linux-gnu -I$(RFSDIR)/usr/include/aarch64-linux-gnu -I$(RFSDIR)/usr/include -I$(DESTDIR)/usr/include -O2 -pipe -g -L$(RFSDIR)/usr/lib/aarch64-linux-gnu -L$(RFSDIR)/lib/aarch64-linux-gnu -Wl,-rpath-link,$(RFSDIR)/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,$(RFSDIR)/lib/aarch64-linux-gnu" && \
	 export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR) -B$(RFSDIR)/usr/lib/aarch64-linux-gnu -I$(RFSDIR)/usr/include/aarch64-linux-gnu -I$(RFSDIR)/usr/include -I$(DESTDIR)/usr/include -L$(RFSDIR)/usr/lib/aarch64-linux-gnu -L$(RFSDIR)/lib/aarch64-linux-gnu -Wl,-rpath-link,$(RFSDIR)/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,$(RFSDIR)/lib/aarch64-linux-gnu $(RFSDIR)/usr/lib/aarch64-linux-gnu/libstdc++.so.6" && \
	 export LDFLAGS="-L$(RFSDIR)/usr/lib/aarch64-linux-gnu -L$(RFSDIR)/lib/aarch64-linux-gnu -Wl,-rpath-link,$(RFSDIR)/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,$(RFSDIR)/lib/aarch64-linux-gnu" && \
	 V=0 VERBOSE='' SDKTARGETSYSROOT=$(DESTDIR) PLATFORM=$(PLATFORM) \
	 $(MAKE) -j$(JOBS) && \
	 $(MAKE) install DESTDIR=$(DESTDIR)/opt/unit_tests PLATFORM=$(PLATFORM) && \
	 $(call fbprint_d,"imx_test")
