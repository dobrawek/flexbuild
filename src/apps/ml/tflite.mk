# Copyright 2022-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# TensorFlow Lite C++ Library
# Version: 2.16.2

# DEPEND: protobuf-compiler + libprotobuf-dev + libprotoc-dev for protoc on host
# libpython3.11-dev python3-pybind11 on target

# run ./benchmark_model --external_delegate_path=<patch_to_libvx_delegate.so> --graph=<tflite_model.tflite>

model-mobv1 = https://storage.googleapis.com/download.tensorflow.org/models/mobilenet_v1_2018_08_02/mobilenet_v1_1.0_224_quant.tgz

TFLITE_VERSION = tensorflow-lite-2.16.2

tflite:
	@[ $(SOCFAMILY) != IMX -o $(DISTROVARIANT) = tiny -o $(DISTROVARIANT) = base ] && exit || \
	 $(call fbprint_b,"tensorflow-lite") && \
	 $(call repo-mngr,fetch,tflite,apps/ml) && \
	 cd $(MLDIR)/tflite && \
	 if [ -f .builddone ]; then \
	     $(call fbprint_n,"TensorFlow-lite has been compiled already.") ; \
	     $(call fbprint_n,"Skip...") && exit ; \
	 fi && \
	 [ ! -f mobilenet.tgz ] && wget -q $(model-mobv1) -O mobilenet.tgz && tar xf mobilenet.tgz || true && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR) -B$(RFSDIR)/usr/lib/aarch64-linux-gnu" && \
	 export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR) -B$(RFSDIR)/usr/lib/aarch64-linux-gnu" && \
	 export CFLAGS="-I$(RFSDIR)/usr/include -I$(RFSDIR)/usr/include/aarch64-linux-gnu" && \
	 export CXXFLAGS="-I$(RFSDIR)/usr/include -I$(RFSDIR)/usr/include/aarch64-linux-gnu" && \
	 export LDFLAGS="-L$(RFSDIR)/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,$(RFSDIR)/usr/lib/aarch64-linux-gnu $(RFSDIR)/usr/lib/aarch64-linux-gnu/libstdc++.so.6" && \
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
	 echo 'set(CMAKE_EXE_LINKER_FLAGS_INIT "-L$(RFSDIR)/usr/lib/aarch64-linux-gnu -B$(RFSDIR)/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,$(RFSDIR)/usr/lib/aarch64-linux-gnu")' >> toolchain-aarch64.cmake && \
	 echo 'set(CMAKE_SHARED_LINKER_FLAGS_INIT "-L$(RFSDIR)/usr/lib/aarch64-linux-gnu -B$(RFSDIR)/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,$(RFSDIR)/usr/lib/aarch64-linux-gnu")' >> toolchain-aarch64.cmake && \
	 echo 'set(CMAKE_MODULE_LINKER_FLAGS_INIT "-L$(RFSDIR)/usr/lib/aarch64-linux-gnu -B$(RFSDIR)/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,$(RFSDIR)/usr/lib/aarch64-linux-gnu")' >> toolchain-aarch64.cmake && \
	 cmake  -S tensorflow/lite \
		-B build_$(DISTROTYPE)_$(ARCH) \
		-DCMAKE_TOOLCHAIN_FILE=$(MLDIR)/tflite/toolchain-aarch64.cmake \
		-DCMAKE_CROSSCOMPILING=TRUE \
		-DCMAKE_C_COMPILER_WORKS=TRUE \
		-DCMAKE_CXX_COMPILER_WORKS=TRUE \
		-DCMAKE_SYSROOT=$(RFSDIR) \
		-DCMAKE_BUILD_TYPE=release \
		-DCMAKE_SYSTEM_NAME=Linux \
		-DCMAKE_SYSTEM_PROCESSOR=aarch64 \
		-DCMAKE_C_FLAGS="-I$(RFSDIR)/usr/include/aarch64-linux-gnu -I$(RFSDIR)/usr/include" \
		-DCMAKE_CXX_FLAGS="-I$(RFSDIR)/usr/include/aarch64-linux-gnu -I$(RFSDIR)/usr/include" \
		-DCMAKE_EXE_LINKER_FLAGS="-L$(RFSDIR)/usr/lib/aarch64-linux-gnu -B$(RFSDIR)/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,$(RFSDIR)/usr/lib/aarch64-linux-gnu $(RFSDIR)/usr/lib/aarch64-linux-gnu/libstdc++.so.6" \
		-DTFLITE_HOST_TOOLS_DIR=/usr/bin \
		-DFETCHCONTENT_FULLY_DISCONNECTED=OFF \
		-DTFLITE_EVAL_TOOLS=on \
		-DTFLITE_BUILD_SHARED_LIB=on \
		-DTFLITE_ENABLE_NNAPI=off \
		-DTFLITE_ENABLE_NNAPI_VERBOSE_VALIDATION=on \
		-DTFLITE_ENABLE_RUY=on \
		-DTFLITE_ENABLE_XNNPACK=on \
		-DTFLITE_PYTHON_WRAPPER_BUILD_CMAKE2=off \
		-DTFLITE_ENABLE_EXTERNAL_DELEGATE=on && \
	 VERBOSE=0 cmake --build build_$(DISTROTYPE)_$(ARCH) -j$(JOBS) --target all -- benchmark_model label_image && \
	 cd build_$(DISTROTYPE)_$(ARCH) && \
	 $(CROSS_COMPILE)strip libtensorflow-lite.so* && \
	 cp -Pf libtensorflow-lite.so* $(DESTDIR)/usr/lib && \
	 install -d $(DESTDIR)/usr/include/tensorflow/lite && \
	 install -d $(DESTDIR)/usr/share/pkgconfig && \
	 install -d $(DESTDIR)/usr/include/tensorflow/core/public && \
	 install -d $(DESTDIR)/usr/include/tensorflow/core/platform && \
	 install -d $(DESTDIR)/usr/include/tsl/platform && \
	 install -d $(DESTDIR)/usr/lib/python3.11/site-packages && \
	 cd $(MLDIR)/tflite/tensorflow/lite && \
	 find . -name "*.h" | xargs -I {} cp {} $(DESTDIR)/usr/include/tensorflow/lite && \
	 cp $(MLDIR)/tflite/tensorflow/core/public/version.h $(DESTDIR)/usr/include/tensorflow/core/public && \
	 rsync -avz $(MLDIR)/tflite/tensorflow/* $(DESTDIR)/usr/include/tensorflow/ && \
	 cp $(FBDIR)/src/system/pkgconfig/tensorflow2-lite.pc $(DESTDIR)/usr/lib/pkgconfig && \
	 \
	 $(call fbprint_n,"install examples") && \
	 install -d $(DESTDIR)/usr/bin/$(TFLITE_VERSION)/examples && \
	 cd $(MLDIR)/tflite/build_$(DISTROTYPE)_$(ARCH) && \
	 $(CROSS_COMPILE)strip examples/label_image/label_image tools/benchmark/benchmark_model \
	     tools/evaluation/{coco_object_detection_run_eval,imagenet_image_classification_run_eval,inference_diff_run_eval} && \
	 install -m 0555 examples/label_image/label_image $(DESTDIR)/usr/bin/$(TFLITE_VERSION)/examples && \
	 install -m 0555 tools/benchmark/benchmark_model $(DESTDIR)/usr/bin/$(TFLITE_VERSION)/examples && \
	 install -m 0555 tools/evaluation/{coco_object_detection_run_eval,imagenet_image_classification_run_eval,inference_diff_run_eval} \
		 $(DESTDIR)/usr/bin/$(TFLITE_VERSION)/examples && \
	 \
	 $(call fbprint_n,"install label_image data") && \
	 cp $(MLDIR)/tflite/tensorflow/lite/examples/label_image/testdata/grace_hopper.bmp $(DESTDIR)/usr/bin/$(TFLITE_VERSION)/examples && \
	 cp $(MLDIR)/tflite/tensorflow/lite/java/ovic/src/testdata/labels.txt $(DESTDIR)/usr/bin/$(TFLITE_VERSION)/examples && \
	 \
	 $(call fbprint_n,"install mobilenet tflite file python example") && \
	 cp $(MLDIR)/tflite/mobilenet_*.tflite $(DESTDIR)/usr/bin/$(TFLITE_VERSION)/examples && \
	 cp $(MLDIR)/tflite/tensorflow/lite/examples/python/label_image.py $(DESTDIR)/usr/bin/$(TFLITE_VERSION)/examples && \
	 touch .builddone && \
	 $(call fbprint_d,"tflite")
