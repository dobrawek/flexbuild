# Copyright 2023-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# TensorFlow Lite VX Delegate

# DEPEND: tensorflow-lite tim-vx

# ./benchmark_model --external_delegate_path=<patch_to_libvx_delegate.so> --graph=<tflite_model.tflite>



tflite_vx_delegate:
	@[ $(SOCFAMILY) != IMX -o $(DISTROVARIANT) = tiny -o $(DISTROVARIANT) = base ] && exit || \
	 $(call fbprint_b,"tflite_vx_delegate") && \
	 $(call repo-mngr,fetch,tflite_vx_delegate,apps/ml) && \
	 if [ ! -f $(DESTDIR)/usr/lib/libtensorflow-lite.so ]; then \
	     bld tflite -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/lib/libtim-vx.so ]; then \
	     bld tim_vx -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 cd $(MLDIR)/tflite_vx_delegate && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR) -B$(RFSDIR)/usr/lib/aarch64-linux-gnu" && \
	 export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR) -B$(RFSDIR)/usr/lib/aarch64-linux-gnu" && \
	 export CXXFLAGS="-O2 -pipe -g -fPIC -feliminate-unused-debug-types -I$(RFSDIR)/usr/include/python3.11 -I$(RFSDIR)/usr/include/aarch64-linux-gnu" && \
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
	 echo 'set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)' >> toolchain-aarch64.cmake && \
	 cmake  -S $(MLDIR)/tflite_vx_delegate \
		-B $(MLDIR)/tflite_vx_delegate/build_$(DISTROTYPE)_$(ARCH) \
		-DCMAKE_TOOLCHAIN_FILE=$(MLDIR)/tflite_vx_delegate/toolchain-aarch64.cmake \
		-DCMAKE_CROSSCOMPILING=TRUE \
		-DCMAKE_C_COMPILER_WORKS=TRUE \
		-DCMAKE_CXX_COMPILER_WORKS=TRUE \
		-DCMAKE_SYSROOT=$(RFSDIR) \
		-DCMAKE_C_FLAGS="-I$(RFSDIR)/usr/include/aarch64-linux-gnu -I$(RFSDIR)/usr/include" \
		-DCMAKE_CXX_FLAGS="-I$(RFSDIR)/usr/include/aarch64-linux-gnu -I$(RFSDIR)/usr/include" \
		-DCMAKE_EXE_LINKER_FLAGS="-L$(DESTDIR)/usr/lib -L$(RFSDIR)/usr/lib/aarch64-linux-gnu -B$(RFSDIR)/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,$(RFSDIR)/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,$(DESTDIR)/usr/lib" \
		-DFETCHCONTENT_FULLY_DISCONNECTED=OFF \
		-DTIM_VX_INSTALL=$(DESTDIR)/usr \
		-DFETCHCONTENT_SOURCE_DIR_TENSORFLOW=$(MLDIR)/tflite \
		-DTFLITE_LIB_LOC=$(DESTDIR)/usr/lib/libtensorflow-lite.so && \
	 $(MAKE) -j$(JOBS) -C build_$(DISTROTYPE)_$(ARCH) vx_delegate && \
	 $(CROSS_COMPILE)strip build_$(DISTROTYPE)_$(ARCH)/libvx_delegate.so && \
	 cp -f build_$(DISTROTYPE)_$(ARCH)/libvx_delegate.so $(DESTDIR)/usr/lib && \
	 install -d $(DESTDIR)/usr/include/tensorflow-lite-vx-delegate && \
	 cp --parents vsi_npu_custom_op.h op_map.h utils.h delegate_main.h examples/util.h \
	    $(DESTDIR)/usr/include/tensorflow-lite-vx-delegate && \
	 $(call fbprint_d,"tflite_vx_delegate")
