# Copyright 2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# NNStreamer - Stream Pipeline Paradigm for Neural Network Applications
# NNStreamer is a GStreamer plugin allowing to construct neural network applications with stream pipeline paradigm.

nnstreamer:
	@[ $(SOCFAMILY) != IMX -o $(DISTROVARIANT) = tiny -o $(DISTROVARIANT) = base ] && exit || \
	 $(call fbprint_b,"nnstreamer") && \
	 $(call repo-mngr,fetch,nnstreamer,apps/ml) && \
	 cd $(MLDIR)/nnstreamer && \
	 rm -rf build_debian_arm64 && \
	 if [ ! -f .patchdone ]; then \
	     git am $(FBDIR)/patch/nnstreamer/*.patch && touch .patchdone; \
         fi && \
	 mkdir -p $(DESTDIR)/usr/lib/pkgconfig && \
	 rm -f meson.cross && \
	 sed -i 's/werror=true/werror=false/' meson.build && \
	 sed -i 's/cpp_std=c++14/cpp_std=c++17/' meson.build && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     -e 's%@DESTDIR@%$(DESTDIR)%g' $(FBDIR)/src/system/meson.cross > meson.cross && \
	 if [ ! -d $(RFSDIR)/usr/lib/aarch64-linux-gnu ]; then \
	     bld rfs -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/lib/gstreamer-1.0/libgstopengl.so ]; then \
	     bld gst_plugins_base -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/lib/libtensorflow-lite.so ]; then \
	     bld tflite -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/lib/libnnstreamer-edge.so ]; then \
	     bld nnstreamer_edge -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/lib/libflatbuffers.so ]; then \
	     bld flatbuffers -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR) -march=armv8-a+crc+crypto -B$(RFSDIR)/usr/lib/aarch64-linux-gnu" && \
	 export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR) -march=armv8-a+crc+crypto -B$(RFSDIR)/usr/lib/aarch64-linux-gnu" && \
	 export CXXFLAGS="-O2 -pipe -g -fPIC -feliminate-unused-debug-types -fcanon-prefix-map" && \
	 meson setup build_$(DISTROTYPE)_$(ARCH) \
		--cross-file meson.cross \
		--prefix=/usr --buildtype=release \
		--strip \
		-Dc_args="-I$(DESTDIR)/usr/include -I$(RFSDIR)/usr/include -I$(RFSDIR)/usr/include/aarch64-linux-gnu" \
		-Dcpp_args="-I$(DESTDIR)/usr/include -I$(RFSDIR)/usr/include -I$(RFSDIR)/usr/include/aarch64-linux-gnu -I$(MLDIR)/tvm/3rdparty/dmlc-core/include \
			    -I$(MLDIR)/tflite/build_debian_arm64/abseil-cpp -I$(MLDIR)/tflite \
			    -Wno-error=comment -Wno-sign-compare -Wno-error=unused-parameter -Wno-error=redundant-decls \
			    -I$(MLDIR)/tflite/third_party/xla/third_party/tsl \
			    -I$(MLDIR)/tflite/build_debian_arm64/eigen \
			    -I$(MLDIR)/tflite/build_debian_arm64/ml_dtypes \
			    -I$(MLDIR)/tflite/build_debian_arm64/protobuf/src \
			    -I$(MLDIR)/tflite/build_debian_arm64/gemmlowp \
			    -I$(MLDIR)/tflite/tensorflow/lite/toco \
			    -I$(MLDIR)/nnstreamer/third_party/xla/third_party/tsl" \
		-Dc_link_args="-L$(DESTDIR)/usr/lib -L$(RFSDIR)/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,$(RFSDIR)/usr/lib/aarch64-linux-gnu" \
		-Dcpp_link_args="-L$(DESTDIR)/usr/lib -L$(RFSDIR)/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,$(RFSDIR)/usr/lib/aarch64-linux-gnu $(RFSDIR)/usr/lib/aarch64-linux-gnu/libstdc++.so.6" \
		-Denable-float16=true \
		-Denable-test=true \
		-Dinstall-test=true \
		-Dtflite2-custom-support=disabled \
		-Dflatbuf-support=disabled \
		-Dgrpc-support=disabled \
		-Dprotobuf-support=enabled \
		-Dpython3-support=enabled \
		-Dnnstreamer-edge-support=enabled \
		-Dtflite2-support=enabled \
		-Dtvm-support=disabled && \
	 rm -f $(MLDIR)/nnstreamer/build_$(DISTROTYPE)_$(ARCH)/ext/nnstreamer/extra/nnstreamer_python.so && \
	 protoc --cpp_out=$(MLDIR)/tflite/tensorflow/lite/toco/ --proto_path=$(MLDIR)/tflite/ $(MLDIR)/tflite/tensorflow/lite/toco/model_flags.proto && \
	 protoc --cpp_out=$(MLDIR)/tflite/tensorflow/lite/toco/ --proto_path=$(MLDIR)/tflite/ $(MLDIR)/tflite/tensorflow/lite/toco/types.proto && \
	 protoc --cpp_out=. --proto_path=$(MLDIR)/tflite/ $(MLDIR)/tflite/third_party/xla/third_party/tsl/tsl/protobuf/error_codes.proto && \
	 sudo mkdir -p $(RFSDIR)/usr/local/include/nnstreamer && \
	 ninja -j $(JOBS) -C build_$(DISTROTYPE)_$(ARCH) install && \
	 $(call fbprint_d,"nnstreamer")
