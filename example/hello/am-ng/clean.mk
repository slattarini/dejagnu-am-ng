
am.clean.mostly.f += $(MOSTLYCLEANFILES)
am.clean.normal.f += $(CLEANFILES)
am.clean.dist.f   += $(DISTCLEANFILES)
am.clean.maint.f  += $(MAINTAINERCLEANFILES)

# Add files computed  automatically by the automake script, at automake
# runtime.
$(foreach t,f d, \
  $(foreach k, mostly normal dist maint, \
    $(eval am.clean.$k.$t += $(am.clean.$k.$t.auto))))

am.clean.dist.f += $(CONFIG_CLEAN_FILES)

# Some files must be cleaned only in VPATH builds -- e.g., those linked
# in usages like "AC_CONFIG_LINKS([GNUmakefile:GNUmakefile])".
ifneq ($(srcdir),.)
am.clean.dist.f += $(CONFIG_CLEAN_VPATH_FILES)
endif

# Built sources are automatically removed by maintainer-clean.
# This is what mainline Automake does.
am.clean.maint.f += $(BUILT_SOURCES)

mostlyclean-am: mostlyclean-generic
mostlyclean-generic:
	$(call am.clean-cmd.f,$(am.clean.mostly.f))
	$(call am.clean-cmd.d,$(am.clean.mostly.d))

clean-am: clean-generic mostlyclean-am
clean-generic:
	$(call am.clean-cmd.f,$(am.clean.normal.f))
	$(call am.clean-cmd.d,$(am.clean.normal.d))

distclean-am: distclean-generic clean-am
distclean-generic:
	$(call am.clean-cmd.f,$(am.clean.dist.f))
	$(call am.clean-cmd.d,$(am.clean.dist.d))

maintainer-clean-am: maintainer-clean-generic distclean-am
maintainer-clean-generic:
	$(call am.clean-cmd.f,$(am.clean.maint.f))
	$(call am.clean-cmd.d,$(am.clean.maint.d))

# Makefiles and their dependencies cannot be cleaned by an '-am'
# dependency, because that would prevent other distclean dependencies
# from calling make recursively (the multilib cleaning used to do
# this, and it's not unreasonable to expect user-defined rules might
# do that as well).
distclean:
	rm -f $(am.relpath.makefile) $(am__config_distclean_files)
maintainer-clean:
	rm -f $(am.relpath.makefile) $(am__config_distclean_files)

.PHONY: clean mostlyclean distclean maintainer-clean \
clean-generic mostlyclean-generic distclean-generic maintainer-clean-generic

ifndef SUBDIRS
clean: clean-am
distclean: distclean-am
mostlyclean: mostlyclean-am
maintainer-clean: maintainer-clean-am
endif
