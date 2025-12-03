# Copyright 2023-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# NNStreamer-Edge library
# Remote source nodes for NNStreamer pipelines without GStreamer dependencies

# NNStreamer LICENSE: Apache-2.0

# DEPENDS: gtest

nnstreamer_edge:
	@[ $(SOCFAMILY) != IMX -o $(DISTROVARIANT) = tiny -o $(DISTROVARIANT) = base ] && exit || \
	 $(call fbprint_b,"nnstreamer_edge") && \
	 $(call repo-mngr,fetch,nnstreamer_edge,apps/ml) && \
	 cd $(MLDIR)/nnstreamer_edge && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR) -B$(RFSDIR)/usr/lib/aarch64-linux-gnu" && \
	 export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR) -B$(RFSDIR)/usr/lib/aarch64-linux-gnu" && \
	 export LDFLAGS="-L$(RFSDIR)/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,$(RFSDIR)/usr/lib/aarch64-linux-gnu $(RFSDIR)/usr/lib/aarch64-linux-gnu/libstdc++.so.6" && \
	 export PKG_CONFIG_LIBDIR=$(RFSDIR)/usr/lib/aarch64-linux-gnu/pkgconfig && \
	 export PKG_CONFIG_PATH=$(RFSDIR)/usr/share/pkgconfig && \
	 rm -rf build_$(DISTROTYPE)_$(ARCH) && \
	 mkdir -p build_$(DISTROTYPE)_$(ARCH) && \
	 cmake  -S $(MLDIR)/nnstreamer_edge \
		-B build_$(DISTROTYPE)_$(ARCH) \
		-DCMAKE_C_COMPILER_WORKS=TRUE \
		-DCMAKE_CXX_COMPILER_WORKS=TRUE \
		-DCMAKE_BUILD_TYPE=release \
		-DCMAKE_C_FLAGS="-I$(RFSDIR)/usr/include/aarch64-linux-gnu -I$(RFSDIR)/usr/include" \
		-DCMAKE_CXX_FLAGS="-I$(RFSDIR)/usr/include/aarch64-linux-gnu -I$(RFSDIR)/usr/include" \
		-DCMAKE_EXE_LINKER_FLAGS="-L$(RFSDIR)/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,$(RFSDIR)/usr/lib/aarch64-linux-gnu $(RFSDIR)/usr/lib/aarch64-linux-gnu/libstdc++.so.6" \
		-DENABLE_TEST=OFF && \
	 cmake --build build_$(DISTROTYPE)_$(ARCH) -j$(JOBS) --target all && \
	 cmake --install build_$(DISTROTYPE)_$(ARCH) --prefix /usr && \
	 mv $(DESTDIR)/usr/local/include/nnstreamer/nnstreamer-edge.h $(DESTDIR)/usr/include && \
	 mv $(DESTDIR)/pkgconfig/nnstreamer-edge.pc $(DESTDIR)/usr/lib/pkgconfig/ && \
	 rm -rf $(DESTDIR)/pkgconfig && \
	 $(call fbprint_d,"nnstreamer_edge")
