# Copyright 2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# Smart Fitness application on i.MX

# DEPENDS: glib-2.0 gstreamer1.0 nnstreamer cairo

GPNT_APPS_FOLDER = /opt/gopoint-apps

IMX_SMART_FITNESS_DIR = $(GPNT_APPS_FOLDER)/scripts/machine_learning/imx_smart_fitness

imx_smart_fitness:
	@[ $(SOCFAMILY) != IMX -o $(DISTROVARIANT) != desktop ] && exit || \
	 $(call fbprint_b,"imx_smart_fitness") && \
	 $(call repo-mngr,fetch,imx_smart_fitness,apps/gopoint) && \
	 if [ ! -f $(DESTDIR)/usr/lib/gstreamer-1.0/libnnstreamer.so ]; then \
	     bld nnstreamer -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 sudo cp -rf $(DESTDIR)//usr/include/nnstreamer $(RFSDIR)//usr/include && \
	 cd $(GPDIR)/imx_smart_fitness && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR) -B$(RFSDIR)/usr/lib/aarch64-linux-gnu" && \
	 export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR) -B$(RFSDIR)/usr/lib/aarch64-linux-gnu" && \
	 export PKG_CONFIG_LIBDIR=$(RFSDIR)/usr/lib/aarch64-linux-gnu/pkgconfig && \
	 export PKG_CONFIG_PATH=$(RFSDIR)/usr/share/pkgconfig && \
	 rm -rf build_$(DISTROTYPE)_$(ARCH) && \
	 mkdir -p build_$(DISTROTYPE)_$(ARCH) && \
	 cmake  -S $(GPDIR)/imx_smart_fitness \
		-B build_$(DISTROTYPE)_$(ARCH) \
		-DCMAKE_C_COMPILER_WORKS=TRUE \
		-DCMAKE_CXX_COMPILER_WORKS=TRUE \
		-DCMAKE_SYSROOT=$(RFSDIR) \
		-DCMAKE_C_FLAGS="-I$(DESTDIR)/usr/include -I$(RFSDIR)/usr/include/aarch64-linux-gnu -I$(RFSDIR)/usr/include" \
		-DCMAKE_CXX_FLAGS="-I$(DESTDIR)/usr/include -I$(RFSDIR)/usr/include/aarch64-linux-gnu -I$(RFSDIR)/usr/include" \
		-DCMAKE_EXE_LINKER_FLAGS="-L$(RFSDIR)/usr/lib/aarch64-linux-gnu -B$(RFSDIR)/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,$(RFSDIR)/usr/lib/aarch64-linux-gnu" \
		-DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
		-DLIBRARY_PATH=$(RFSDIR)/usr/lib/aarch64-linux-gnu \
		-DCMAKE_BUILD_TYPE=release && \
	 cmake --build build_$(DISTROTYPE)_$(ARCH) --target all && \
	 cmake --install build_$(DISTROTYPE)_$(ARCH) --prefix /usr && \
	 $(CROSS_COMPILE)strip --remove-section=.comment --remove-section=.note --strip-unneeded \
	 build_$(DISTROTYPE)_$(ARCH)/src/imx-smart-fitness && \
	 install -m 0755 build_$(DISTROTYPE)_$(ARCH)/src/imx-smart-fitness $(DESTDIR)/$(IMX_SMART_FITNESS_DIR) && \
	 $(call fbprint_d,"imx_smart_fitness")
