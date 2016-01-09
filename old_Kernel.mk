MAKE_CLN = $(MAKE_CMD) -C $(KERNEL_SRC) distclean
MAKE_KNL = $(MAKE_CMD) -C $(KERNEL_SRC) EXTRAVERSION=-$(KERNEL_CNF)

BUILDER_ROOT = $(abs_top_srcdir)/src/linux

SOURCE_DIR = $(BUILDER_ROOT)/$(SOURCE_TYPE)

$(SOURCE_TYPE).git:
	@echo "-------------------[ Downloading/Updating kernel sources ]-------------------"
	@echo "---  Source Directory : $(SOURCE_DIR)"
	@echo "--- Source Repository : $(SOURCE_GIT)"
	@echo "-----------------------------------------------------------------------------"
	@if [ -d $(SOURCE_DIR) ]; then cd $(SOURCE_DIR) && git pull; else git clone $(SOURCE_GIT) $(SOURCE_DIR); fi
	@touch $(SOURCE_TYPE).git

$(KERNEL_CNF).build:
	@echo "-------------------------[ Building kernel package ]-------------------------"
	@echo "---  Source Directory : $(KERNEL_SRC)"
	@echo "---     Source Branch : $(KERNEL_BRN)"
	@echo "---       Kernel Type : $(KERNEL_CNF)"
	@echo "-----------------------------------------------------------------------------"
	$(MAKE_CLN)
	-cd $(KERNEL_SRC) && git stash && git stash drop 
	-cd $(KERNEL_SRC) && git checkout $(KERNEL_BRN)
	$(MAKE_CLN)
	if [ -f $(abs_srcdir)/configs/armStrap_$(KERNEL_CNF)_defconfig ]; then \
		$(INSTALL_DATA) $(abs_srcdir)/configs/armStrap_$(KERNEL_CNF)_defconfig $(KERNEL_SRC)/arch/arm/configs/; \
		$(MAKE_KNL) armStrap_$(KERNEL_CNF)_defconfig; \
	else \
		$(MAKE_KNL) $(KERNEL_CNF)_defconfig; \
		sed -i "s/CONFIG_LOCALVERSION_AUTO=y/# CONFIG_LOCALVERSION_AUTO is not set/" $(KERNEL_SRC)/.config; \
	fi
	$(MAKE_KNL)
	$(MAKE_KNL) --no-print-directory -s kernelrelease > $(abs_srcdir)/kernel-version
	if [ -d $(abs_srcdir)/dtbs ]; then rm -rfv $(abs_srcdir)/dtbs; fi;
	if [ -d $(abs_srcdir)/debian ]; then rm -rfv $(abs_srcdir)/debian; fi;
	if [ -f $(KERNEL_SRC)/arch/arm/boot/dts/sun4i-a10.dtsi ]; then \
		$(MKDIR_P) $(abs_srcdir)/dtbs; \
		$(MAKE_KNL) INSTALL_PATH=$(abs_srcdir)/dtbs/boot dtbs; \
		$(MAKE_KNL) INSTALL_PATH=$(abs_srcdir)/dtbs/boot dtbs_install; \
		$(SHELL) $(abs_top_srcdir)/makedeb -n "linux-dtbs" -v @$(abs_srcdir)/kernel-version -F -B @$(KERNEL_SRC)/.version -s "linux-upstream" -S "kernel" -u $(PACKAGE_BUGREPORT) -b $(abs_srcdir)/dtbs -p $(prefix) -h $(host_alias) -l " This package install the dtbs files for linux-kernel."; \
	fi
	cp $(KERNEL_SRC)/scripts/package/builddeb $(KERNEL_SRC)/scripts/package/builddeb.save
	sed -i 's/^libc_headers_packagename=linux-libc-dev.*/libc_headers_packagename=linux-libc-dev-$$version/' "$(KERNEL_SRC)/scripts/package/builddeb"
	sed -i 's/^fwpackagename=linux-firmware-image.*/fwpackagename=linux-firmware-image-$$version/' "$(KERNEL_SRC)/scripts/package/builddeb"
	chmod +x $(KERNEL_SRC)/scripts/package/builddeb
	$(MAKE_KNL) deb-pkg
	mv $(KERNEL_SRC)/scripts/package/builddeb.save $(KERNEL_SRC)/scripts/package/builddeb
	chmod +x $(KERNEL_SRC)/scripts/package/builddeb
	[ "`ls -A $(abs_srcdir)/*.deb`" ] && mv $(abs_srcdir)/*.deb $(abs_top_srcdir) || echo "No packages found in $(abs_srcdir)"
	[ "`ls -A $(BUILDER_ROOT)/*.deb`" ] && mv $(BUILDER_ROOT)/*.deb $(abs_top_srcdir) || echo "No packages found in $(BUILDER_ROOT)"
	if [ -f $(abs_srcdir)/kernel-version ]; then rm -fv kernel-version; fi;
	if [ -d $(abs_srcdir)/dtbs ]; then rm -rfv $(abs_srcdir)/dtbs; fi;
	if [ -d $(abs_srcdir)/debian ]; then rm -rfv $(abs_srcdir)/debian; fi;
	if [ -f $(KERNEL_SRC)/arch/arm/configs/armStrap_$(KERNEL_CNF)_defconfig ]; then rm -fv $(KERNEL_SRC)/arch/arm/configs/armStrap_$(KERNEL_CNF)_defconfig; fi
	$(SHELL) $(abs_srcdir)/mkvirtual -t $(abs_top_srcdir) -s $(abs_srcdir) -b $(PACKAGE_BUGREPORT) -p $(prefix) -h $(host_alias) -k $(KERNEL_CNF) -d $(abs_top_srcdir)
	[ "`ls -A $(abs_srcdir)/*.deb`" ] && mv $(abs_srcdir)/*.deb $(abs_top_srcdir) || echo "No packages found in $(abs_srcdir)"
	$(MAKE_CLN)
	@touch $(KERNEL_CNF).build
