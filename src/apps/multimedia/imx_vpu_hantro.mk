# Copyright 2021-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# i.MX HANTRO VPU library for IMX8MM, IMX8MP, IMX8MQ

# RDEPEND: imx_vpu_hantro_daemon


imx_vpu_hantro:
	@[ $(DISTROVARIANT) != desktop -o $(SOCFAMILY) != IMX ] && exit || \
	 $(call fbprint_b,"imx_vpu_hantro") && \
	 cd $(MMDIR) && \
	 if [ ! -d imx_vpu_hantro ]; then \
	     wget -q $(repo_vpu_hantro_bin_url) -O vpu_hantro.bin && chmod +x vpu_hantro.bin && \
	     /bin/sh ./vpu_hantro.bin --auto-accept && \
	     mv imx-vpu-hantro-* imx_vpu_hantro && rm -f vpu_hantro.bin; \
	 fi && \
	 \
	 if [ ! -f $(DESTDIR)/usr/include/linux/hantrodec.h ]; then \
	     bld linux-headers -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 cd imx_vpu_hantro && \
	 sed -i 's/\/imx//' Makefile_G1G2 Makefile_H1 && \
	 sed -i 's/dma-buf.h/dma-buf-imx.h/' decoder_sw/software/linux/dwl/dwl_linux.c \
	     h1_encoder/software/linux_reference/ewl/ewl_x280_common.c && \
	 sed -i 's|-I\$$(SDKTARGETSYSROOT)/usr/include|-I$$(SDKTARGETSYSROOT)/usr/include/aarch64-linux-gnu -I$$(SDKTARGETSYSROOT)/usr/include|' Makefile_G1G2 && \
	 for mkfile in decoder_sw/software/linux/h264high/Makefile \
	               decoder_sw/software/linux/mpeg4/Makefile \
	               decoder_sw/software/linux/mpeg2/Makefile \
	               decoder_sw/software/linux/vc1/Makefile \
	               decoder_sw/software/linux/vp6/Makefile \
	               decoder_sw/software/linux/vp8/Makefile \
	               decoder_sw/software/linux/jpeg/Makefile \
	               decoder_sw/software/linux/rv/Makefile \
	               decoder_sw/software/linux/avs/Makefile; do \
	     if [ -f $$mkfile ] && ! grep -q 'SDKTARGETSYSROOT' $$mkfile; then \
	         sed -i '/^# extra compiler switches/i INCLUDE += -I$$(SDKTARGETSYSROOT)/usr/include/aarch64-linux-gnu -I$$(SDKTARGETSYSROOT)/usr/include\n' $$mkfile; \
	     fi; \
	 done && \
	 sed -i 's|make -C \$$(SOURCE_ROOT)/linux/\([a-z0-9]*\) |make -C $$(SOURCE_ROOT)/linux/\1 SDKTARGETSYSROOT=$$(SDKTARGETSYSROOT) |g' Makefile_G1G2 && \
	 sed -i '/^AR = /a LDFLAGS += -L$$(SDKTARGETSYSROOT)/usr/lib/aarch64-linux-gnu -B$$(SDKTARGETSYSROOT)/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,$$(SDKTARGETSYSROOT)/usr/lib/aarch64-linux-gnu' Makefile_G1G2 && \
	 sed -i 's| test$$||' Makefile_G1G2 && \
	 sed -i 's|cp -P \$$(LIBG1COMMONNAME)|#cp -P $$(LIBG1COMMONNAME)|' Makefile_G1G2 && \
	 sed -i 's|cp \$$(RELEASE_BIN)/|#cp $$(RELEASE_BIN)/|' Makefile_G1G2 && \
	 sed -i '/^CC = /a LDFLAGS += -L$$(SDKTARGETSYSROOT)/usr/lib/aarch64-linux-gnu -B$$(SDKTARGETSYSROOT)/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,$$(SDKTARGETSYSROOT)/usr/lib/aarch64-linux-gnu' Makefile_test && \
	 sed -i 's|-I\$$(SDKTARGETSYSROOT)/usr/include$$|-I$$(SDKTARGETSYSROOT)/usr/include/aarch64-linux-gnu -I$$(SDKTARGETSYSROOT)/usr/include|' Makefile_H1 && \
	 sed -i '/^AR = /a LDFLAGS += -L$$(SDKTARGETSYSROOT)/usr/lib/aarch64-linux-gnu -B$$(SDKTARGETSYSROOT)/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,$$(SDKTARGETSYSROOT)/usr/lib/aarch64-linux-gnu' Makefile_H1 && \
	 h1mkfile=h1_encoder/software/linux_reference/Makefile && \
	 if [ -f $$h1mkfile ] && ! grep -q 'SDKTARGETSYSROOT' $$h1mkfile; then \
	     sed -i '/^# Compiler switches/i INCLUDE += -I$$(SDKTARGETSYSROOT)/usr/include/aarch64-linux-gnu -I$$(SDKTARGETSYSROOT)/usr/include\n' $$h1mkfile; \
	 fi && \
	 sed -i 's| test$$||' Makefile_H1 && \
	 sed -i 's|cp \$$(SOURCE_ROOT)/linux_reference/test/|#cp $$(SOURCE_ROOT)/linux_reference/test/|g' Makefile_H1 && \
	 ln -sf dma-buf.h $(DESTDIR)/usr/include/linux/dma-buf-imx.h && \
	 sudo cp -rf $(DESTDIR)/usr/include/linux $(RFSDIR)/usr/include/ && \
	 export SDKTARGETSYSROOT=$(RFSDIR) && \
	 DEST_DIR=$(DESTDIR) CROSS_COMPILE="aarch64-linux-gnu-" \
	 CROSS="aarch64-linux-gnu-" \
	 PLATFORM=IMX8MM ARCH="-march=armv8-a+crc+crypto" SDKTARGETSYSROOT=$(RFSDIR) \
	 CFLAGS="-O2 --sysroot=$(RFSDIR) -I$(RFSDIR)/usr/include/aarch64-linux-gnu -I$(RFSDIR)/usr/include" \
	 LDFLAGS="-L$(RFSDIR)/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,$(RFSDIR)/usr/lib/aarch64-linux-gnu --sysroot=$(RFSDIR)" \
	 $(MAKE) all && \
	 $(MAKE) install PLATFORM=IMX8MM DEST_DIR=$(DESTDIR) libdir=/usr/lib && \
	 $(call fbprint_d,"imx_vpu_hantro")
