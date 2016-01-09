EXTRA_DIST = configs/armStrap_sun4i_defconfig  configs/armStrap_sun4i-stage_defconfig  configs/armStrap_sun7i-ct_defconfig  configs/armStrap_sun7i_defconfig  configs/armStrap_sun7i-stage_defconfig configs/armStrap_sunxi-next_defconfig configs/armStrap_mainline_defconfig mkvirtual Kernel.mk

MAKE_CMD = CC=$(CC) KBUILD_DEBARCH=$(KBUILD_DEBARCH) dpkg-architecture -t$(host_alias) -c $(MAKE) $(MAKE_PARAMS) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE)
MAKE_CLN = $(MAKE_CMD) -C $(KERNEL_SRC) distclean
MAKE_KNL = $(MAKE_CMD) -C $(KERNEL_SRC) EXTRAVERSION=-$(KERNEL_CNF)

BUILDER_ROOT = $(abs_top_srcdir)/src/linux

SOURCE_LST = sunxi/https\://github.com/linux-sunxi/linux-sunxi.git sunxi-ct/https\://github.com/armStrapTools/linux-sunxi-ap6210.git mainline/git\://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
SOURCE_TYPE = `echo -n "$@" | awk -F '/' '{print $$1}'`
SOURCE_DIR = $(BUILDER_ROOT)/`echo -n "$@" | awk -F '/' '{print $$1}'`
SOURCE_GIT = `echo -n "$@" | sed -e 's/^\([^\/]*\)\///'`

KERNEL_LST = sunxi/sunxi-3.4/sun4i sunxi/sunxi-3.4/sun7i sunxi/stage_sunxi-3.4/sun4i-stage sunxi/stage_sunxi-3.4/sun7i-stage sunxi-ct/sunxi-3.4/sun7i-ct sunxi/sunxi-next/sunxi-next mainline/master/mainline
KERNEL_SRC = $(BUILDER_ROOT)/`echo -n "$@" | awk -F '/' '{print $$1}'`
KERNEL_BRN = `echo -n "$@" | awk -F '/' '{print $$2}' | sed -e 's/_/\//'`
KERNEL_CNF = `echo -n "$@" | awk -F '/' '{print $$3}'`

.PHONY: kernels-git $(SOURCE_LST)

kernels-git: $(SOURCE_LST)

$(SOURCE_LST):
	@$(MAKE) -C $(abs_srcdir) -f $(abs_srcdir)/Kernel.mk SOURCE_TYPE="$(SOURCE_TYPE)" SOURCE_GIT="$(SOURCE_GIT)" abs_top_srcdir="$(abs_top_srcdir)"

git-rm:

PHONY: kernels-builder $(KERNEL_LST)

kernels-builder: $(KERNEL_LST)

sun4i: sunxi/sunxi-3.4/sun4i

sun7i: sunxi/sunxi-3.4/sun7i

sun4i-stage: sunxi/stage_sunxi-3.4/sun4i-stage

sun7i-stage: sunxi/stage_sunxi-3.4/sun7i-stage

sun7i-ct: sunxi-ct/sunxi-3.4/sun7i-ct

sunxi-next: sunxi/sunxi-next/sunxi-next

mainline: mainline/master/mainline

$(KERNEL_LST): version
	@$(MAKE) -C $(abs_srcdir) -f $(abs_srcdir)/Kernel.mk KERNEL_SRC="$(KERNEL_SRC)" KERNEL_BRN="$(KERNEL_BRN)" KERNEL_CNF="$(KERNEL_CNF)" MAKE_CMD="$(MAKE_CMD)" abs_top_srcdir="$(abs_top_srcdir)" abs_srcdir="$(abs_srcdir)" INSTALL_DATA="$(INSTALL_DATA)" MKDIR_P="$(MKDIR_P)" PACKAGE_BUGREPORT="$(PACKAGE_BUGREPORT)" prefix="$(prefix)" host_alias="$(host_alias)" SHELL="$(SHELL)"

version:
	${SHELL} $(abs_top_srcdir)/makever $(abs_srcdir)/.version $(abs_srcdir)/.version_build
	@touch version

version-clean:
	-rm -fv $(abs_srcdir)/.version $(abs_srcdir)/.version_build $(abs_srcdir)/version

Kernels: kernels-git kernels-builder

all-local: version Kernels

clean-local: version-clean
	-rm -fv $(abs_srcdir)/*.build $(abs_srcdir)/*.git $(abs_srcdir)/kernel-version

clean-git:
	if [ -d $(abs_top_srcdir)/src/linux ]; then rm -rfv $(abs_top_srcdir)/src/linux; fi
	
clean-version:

help:
	@echo -e "\narmStrap Kernels builder."
	@echo -e "\nCleaning targets:"
	@echo "  clean            - Remove most generated files but keep the config."
	@echo "  distclean        - Remove all generated files + config + various backup files."
	@echo -e "\nBuilding targets:"
	@echo "                   - Build everything."
	@echo "  sun4i            - Build sun4i kernel."
	@echo "  sun7i            - Build sun7i kernel."
	@echo "  sun4i-stage      - Build sun4i-stage kernel."
	@echo "  sun7i-stage      - Build sun7i-stage kernel."
	@echo "  sun7i-ct         - Build sun7i-ct kernel."
	@echo "  sunxi-next       - Build sunxi-next kernel."
	@echo -e "  mainline         - Build mainline kernel.\n"

