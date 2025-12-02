# Copyright 2017-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# depends on libnl-3-dev

tsntool:
	@[ $(DISTROVARIANT) = tiny -o $(DISTROVARIANT) = base ] && exit || \
	 $(call fbprint_b,"tsntool") && \
	 $(call repo-mngr,fetch,tsntool,apps/networking) && \
	 $(call repo-mngr,fetch,linux,linux) && \
	 if [ ! -f $(RFSDIR)/lib/aarch64-linux-gnu/libnl-genl-3.so -a ! -f $(RFSDIR)/usr/lib/libnl-genl-3.so ]; then \
	     echo missing libnl-genl-3.so in $(RFSDIR) && exit 1; \
	 fi && \
	 if [ -L $(RFSDIR)/lib/aarch64-linux-gnu/libtinfo.so ]; then \
	     sudo ln -sf libtinfo.so.6 $(RFSDIR)/lib/aarch64-linux-gnu/libtinfo.so; \
	 fi && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR) -B$(RFSDIR)/usr/lib/aarch64-linux-gnu" && \
	 export CFLAGS="-I$(DESTDIR)/usr/include -I$(RFSDIR)/usr/include/libnl3 -I$(RFSDIR)/usr/include -I$(RFSDIR)/usr/include/aarch64-linux-gnu" && \
	 export LDFLAGS="-L$(RFSDIR)/usr/lib/aarch64-linux-gnu -L$(RFSDIR)/lib/aarch64-linux-gnu \
	                 -L$(DESTDIR)/usr/lib/aarch64-linux-gnu -L$(RFSDIR)/usr/lib \
	                 -Wl,-rpath-link,$(RFSDIR)/usr/lib/aarch64-linux-gnu \
	                 -Wl,-rpath-link,$(RFSDIR)/lib/aarch64-linux-gnu \
	                 -lcjson -lnl-3 -lnl-genl-3" && \
	 \
	 cd $(NETDIR)/tsntool && \
	 mkdir -p include/linux && \
	 cp -f $(KERNEL_PATH)/include/uapi/linux/tsn.h include/linux && \
	 $(MAKE) clean && \
	 $(MAKE) -j$(JOBS) && \
	 install -d $(DESTDIR)/usr/local/bin && install -d $(DESTDIR)/usr/lib && \
	 install -m 755 tsntool $(DESTDIR)/usr/local/bin/tsntool && \
	 install -m 755 libtsn.so $(DESTDIR)/usr/lib/libtsn.so && \
	 $(call fbprint_d,"tsntool")
