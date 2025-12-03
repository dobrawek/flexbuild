# Copyright 2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# Tensor Interface Module for OpenVX
# TIM-VX is a software integration module provided by VeriSilicon to facilitate deployment of Neural-Networks on OpenVX enabled ML accelerators.
# It serves as the backend binding for runtime frameworks such as Android NN, Tensorflow-Lite, MLIR, TVM and more


# DEPEND: gpu_viv


tim_vx:
	@[ $(SOCFAMILY) != IMX -o $(DISTROVARIANT) = tiny -o $(DISTROVARIANT) = base ] && exit || \
	 $(call fbprint_b,"tim_vx") && \
	 $(call repo-mngr,fetch,tim_vx,apps/ml) && \
	 if [ ! -f $(DESTDIR)/usr/lib/libOpenVX.so ]; then \
	     bld gpu_viv -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 cd $(MLDIR)/tim_vx && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR) -B$(RFSDIR)/usr/lib/aarch64-linux-gnu" && \
	 export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR) -B$(RFSDIR)/usr/lib/aarch64-linux-gnu" && \
	 mkdir -p $(DESTDIR)/usr/include/VX && \
	 cp -f prebuilt-sdk/*linux/include/VX/vx_khr_cnn.h $(DESTDIR)/usr/include/VX && \
	 rm -rf build_$(DISTROTYPE)_$(ARCH) && \
	 mkdir -p build_$(DISTROTYPE)_$(ARCH) && \
	 echo 'set(CMAKE_SYSTEM_NAME Linux)' > toolchain-aarch64.cmake && \
	 echo 'set(CMAKE_SYSTEM_PROCESSOR aarch64)' >> toolchain-aarch64.cmake && \
	 echo 'set(CMAKE_C_COMPILER $(CROSS_COMPILE)gcc)' >> toolchain-aarch64.cmake && \
	 echo 'set(CMAKE_CXX_COMPILER $(CROSS_COMPILE)g++)' >> toolchain-aarch64.cmake && \
	 echo 'set(CMAKE_SYSROOT $(RFSDIR))' >> toolchain-aarch64.cmake && \
	 echo 'set(CMAKE_FIND_ROOT_PATH $(RFSDIR))' >> toolchain-aarch64.cmake && \
	 echo 'set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)' >> toolchain-aarch64.cmake && \
	 echo 'set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)' >> toolchain-aarch64.cmake && \
	 echo 'set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)' >> toolchain-aarch64.cmake && \
	 echo 'set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)' >> toolchain-aarch64.cmake && \
	 echo 'set(CMAKE_C_FLAGS_INIT "-I$(RFSDIR)/usr/include/aarch64-linux-gnu -I$(RFSDIR)/usr/include")' >> toolchain-aarch64.cmake && \
	 echo 'set(CMAKE_CXX_FLAGS_INIT "-I$(RFSDIR)/usr/include/aarch64-linux-gnu -I$(RFSDIR)/usr/include")' >> toolchain-aarch64.cmake && \
	 echo 'set(CMAKE_EXE_LINKER_FLAGS_INIT "-L$(DESTDIR)/usr/lib -L$(RFSDIR)/usr/lib/aarch64-linux-gnu -B$(RFSDIR)/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,$(RFSDIR)/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,$(DESTDIR)/usr/lib")' >> toolchain-aarch64.cmake && \
	 echo 'set(CMAKE_SHARED_LINKER_FLAGS_INIT "-L$(DESTDIR)/usr/lib -L$(RFSDIR)/usr/lib/aarch64-linux-gnu -B$(RFSDIR)/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,$(RFSDIR)/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,$(DESTDIR)/usr/lib")' >> toolchain-aarch64.cmake && \
	 echo 'set(CMAKE_MODULE_LINKER_FLAGS_INIT "-L$(DESTDIR)/usr/lib -L$(RFSDIR)/usr/lib/aarch64-linux-gnu -B$(RFSDIR)/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,$(RFSDIR)/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,$(DESTDIR)/usr/lib")' >> toolchain-aarch64.cmake && \
	 cmake  -S $(MLDIR)/tim_vx \
		-B $(MLDIR)/tim_vx/build_$(DISTROTYPE)_$(ARCH) \
		-DCMAKE_TOOLCHAIN_FILE=$(MLDIR)/tim_vx/toolchain-aarch64.cmake \
		-DCMAKE_CROSSCOMPILING=TRUE \
		-DCMAKE_C_COMPILER_WORKS=TRUE \
		-DCMAKE_CXX_COMPILER_WORKS=TRUE \
		-DCMAKE_SYSROOT=$(RFSDIR) \
		-DCMAKE_C_FLAGS="-I$(DESTDIR)/usr/include -I$(RFSDIR)/usr/include/aarch64-linux-gnu -I$(RFSDIR)/usr/include" \
		-DCMAKE_CXX_FLAGS="-I$(DESTDIR)/usr/include -I$(RFSDIR)/usr/include/aarch64-linux-gnu -I$(RFSDIR)/usr/include" \
		-DCMAKE_EXE_LINKER_FLAGS="-L$(DESTDIR)/usr/lib -L$(RFSDIR)/usr/lib/aarch64-linux-gnu -B$(RFSDIR)/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,$(RFSDIR)/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,$(DESTDIR)/usr/lib" \
		-DCONFIG=YOCTO \
		-DTIM_VX_ENABLE_TEST=off \
		-DTIM_VX_USE_EXTERNAL_OVXLIB=off && \
	 cmake --build $(MLDIR)/tim_vx/build_$(DISTROTYPE)_$(ARCH) -j$(JOBS) --target all && \
	 $(CROSS_COMPILE)strip build_$(DISTROTYPE)_$(ARCH)/src/tim/libtim-vx.so && \
	 cp build_$(DISTROTYPE)_$(ARCH)/src/tim/libtim-vx.so $(DESTDIR)/usr/lib && \
	 install -d $(DESTDIR)/usr/include/tim && \
	 cp -rf $(MLDIR)/tim_vx/include/tim/{transform,vx} $(DESTDIR)/usr/include/tim && \
	 $(call fbprint_d,"tim_vx")
