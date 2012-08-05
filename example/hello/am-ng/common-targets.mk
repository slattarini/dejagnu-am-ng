
# ------------------- #
#  The 'all' target.  #
# ------------------- #

.PHONY: all all-am all-local
ifdef SUBDIRS
.PHONY: all-recursive
endif

all-am: all-local $(am.all.targets)
all: $(if $(SUBDIRS),all-recursive,all-am)

# --------------------- #
#  The 'check' target.  #
# --------------------- #

.PHONY: check check-am check-local
ifdef SUBDIRS
.PHONY: check-recursive
endif

# The check target must depend on the local equivalent of 'all', to
# ensure all the primary targets are built; then it must build the
# local check dependencies, and finally run the actual tests (as given
# by $(TESTS), by DejaGNU, and by the 'check-local' target).
am.test-suite.check-targets = check-DEJAGNU check-TESTS check-local
.PHONY: $(am.test-suite.check-targets)
check-am: $(am.test-suite.check-targets)
$(am.test-suite.check-targets): all-am $(am.test-suite.deps)

check: $(if $(SUBDIRS),check-recursive,check-am)

.PHONY: installdirs installdirs-local
ifdef SUBDIRS
.PHONY: installdirs-am
RECURSIVE_TARGETS += installdirs-recursive
installdirs: installdirs-recursive
endif

$(if $(SUBDIRS),installdirs-am,installdirs): installdirs-local
ifdef am__installdirs
# The reason we loop over $(am__installdirs), instead of simply running
# "$(MKDIR_P) $(am__installdirs), is that directories variable such as
# "$(DESTDIR)$(mydir)" can potentially expand to "" if $(mydir) is
# conditionally defined.  BTW,  directories in $(am__installdirs) are
# already quoted in order to support installation paths with spaces.
	for dir in $(am__installdirs); do \
	  test -z "$$dir" || $(MKDIR_P) "$$dir"; \
	done
endif

# ------------------ #
#  Install targets.  #
# ------------------ #

.PHONY: install install-exec install-data uninstall
.PHONY: install-exec-am install-data-am uninstall-am

ifdef SUBDIRS
RECURSIVE_TARGETS += install-data-recursive install-exec-recursive
RECURSIVE_TARGETS += install-recursive uninstall-recursive
install-exec: install-exec-recursive
install-data: install-data-recursive
uninstall: uninstall-recursive
else
install-exec: install-exec-am
install-data: install-data-am
uninstall: uninstall-am
endif

install: $(if $(SUBDIRS),install-recursive,install-am)

.PHONY: install-am
install-am: all-am
	@$(MAKE) install-exec-am install-data-am


.PHONY: installcheck
ifdef SUBDIRS
installcheck: installcheck-recursive
else
installcheck: installcheck-am
.PHONY: installcheck-am
installcheck-am:
endif
.PHONY: install-strip
install-strip:
	$(MAKE) INSTALL_PROGRAM="$(INSTALL_STRIP_PROGRAM)" \
	        install_sh_PROGRAM="$(INSTALL_STRIP_PROGRAM)" \
		INSTALL_STRIP_FLAG=-s \
		$(if $(STRIP),"INSTALL_PROGRAM_ENV=STRIPPROG='$(STRIP)'") \
		install

# Allow parallel install with forced relink.  See commit Automake bd4a1d5
# of 2000-10-19 for a little more background.
# FIXME: this is gross, and is debatable how useful and/or needed this
# workaround still is today.  This is something that should be eventually
# discussed with the Libtool guys.
ifdef bin_PROGRAMS
  ifdef lib_LTLIBRARIES
    install-binPROGRAMS: install-libLTLIBRARIES
  endif
  ifdef nobase_lib_LTLIBRARIES
    install-binPROGRAMS: install-nobase_libLTLIBRARIES
  endif
endif

# -------------------------------------- #
#  $(BUILT_SOURCES) and config headers.  #
# -------------------------------------- #

# We need to make sure $(BUILT_SOURCES) files are built before
# any "ordinary" target (all, check, install, ...) is run.
# Ditto for config.h (or files specified in AC_CONFIG_HEADERS).
# But of course, we shouldn't attempt to build any of them when
# running in dry mode.
am.built-early = $(am.config-hdr.local) $(BUILT_SOURCES)
ifeq ($(am.make.dry-run),true)
# A trick to make the "make -n" output more useful, albeit not
# completely accurate.
all check install: | $(am.built-early)
else
$(foreach x,$(am.built-early),$(eval -include .am/built-sources/$(x)))
.am/built-sources/%: | %
	@$(am.cmd.ensure-target-dir-exists)
	@touch $@
endif
