
# Running these checks unconditionally can be quite wasteful, especially
# for projects with lots of programs.  So run them only when the values
# of the checked variables has possibly changed.  For the moment, we assume
# this can only happen if the Makefile has been updated since the later
# check.  And to give user more control, we also allow him to require these
# checks run unconditionally, by setting AM_FORCE_SANITY_CHECKS to "yes".

# The idiom we employ to implement our "lazy checking" relies on recursive
# make invocations and creation of an auxiliary makefile fragments, and
# such an approach do not interact very well with "make -n"; in such a case,
# it's simpler and safer to go for "greedy checking".
ifeq ($(am.make.dry-run),true)
AM_FORCE_SANITY_CHECKS ?= yes
endif

ifeq ($(AM_FORCE_SANITY_CHECKS),yes)

# Variables with these suffixes are candidates for typo checking.
.am/vartypos/suffixes := _SOURCES _LIBADD _LDADD _LDFLAGS _DEPENDENCIES

# But these variables are not, even if they match the patterns above.
.am/vartypos/whitelisted-vars := \
  AM_LDFLAGS \
  BUILT_SOURCES \
  TAGS_DEPENDENCIES \
  CONFIG_STATUS_DEPENDENCIES \
  CONFIGURE_DEPENDENCIES

# The '*LOG_DEPENDENCIES' variables are used to declare extra dependencies
# for test cases, but only when the parallel testsuite harness is in use.
ifeq "$(am.conf.using-parallel-tests)" "yes"
# Extension-less tests are always accepted.
.am/vartypos/whitelisted-vars += LOG_DEPENDENCIES
# We expect '.ext' to be a valid tests extension iff 'EXT_LOG_DRIVER' is
# defined.  Hence the following logic.
.am/vartypos/whitelisted-vars += \
  $(patsubst %_LOG_DRIVER,%_LOG_DEPENDENCIES, \
             $(filter %_LOG_DRIVER,$(.VARIABLES)))
endif

# Allow the user to add his own whitelist.
# FIXME: this is still undocumented!
.am/vartypos/whitelisted-vars += $(AM_VARTYPOS_WHITELIST)

# Canonicalized names of programs and libraries (vanilla or libtool) that
# have been declared.
.am/vartypos/known-canon-proglibs := \
  $(sort $(call am.util.canon, $(am.all-progs) \
                               $(am.all-libs) \
                               $(am.all-ltlibs)))

# Extract 'foo' from something like "EXTRA_nodist_foo_SOURCES".
define .am/vartypos/canon-name-from-var
$(call am.util.strip-suffixes, $(.am/vartypos/suffixes), \
  $(patsubst dist_%,%, \
  $(patsubst nodist_%,%, \
  $(patsubst nobase_%,%, \
  $(patsubst EXTRA_%,%, \
  $1)))))
endef

define .am/vartypos/check
$(eval $0/canon := $(call .am/vartypos/canon-name-from-var,$1))
$(if $(filter $($0/canon),$(.am/vartypos/known-canon-proglibs)),, \
     $(call am.error,variable '$1' is defined but no program) \
     $(call am.error,  or library has '$($0/canon)' as canonical name))
endef

# The variables candidate for checking of typos.
.am/vartypos/candidate-vars := \
  $(filter-out $(.am/vartypos/whitelisted-vars), \
               $(filter $(addprefix %,$(.am/vartypos/suffixes)), \
                        $(.VARIABLES)))

# Apparently useless use of eval required to avoid a spurious "missing
# separator" error from GNU make.
$(eval $(foreach v,$(.am/vartypos/candidate-vars), \
                   $(call .am/vartypos/check,$v)))

else # $(AM_FORCE_SANITY_CHECKS) != yes

# We use "-include" rather than "include" to avoid getting, on the first
# make run in a clean tree, the following annoying warning:
#    Makefile: .am/check-typos-stamp.mk: No such file or directory
# Although such a warning would *not* be an error in our setup, it still
# is ugly and annoying enough to justify ...
-include $(am.dir)/check-typos-stamp.mk

# ... this workaround; which is required by the fact that, if a recipe
# meant to rebuild a file included with "-include" file fails, the make
# run itself is not considered failed (this is quite consistent with
# the "-include" semantics).
ifdef .am/sanity-checks-failed
$(shell rm -f $(am.dir)/check-typos-stamp.mk)
$(error Some Automake-NG sanity checks failed)
else
$(am.dir)/check-typos-stamp.mk: $(am.relpath.makefile) | $(am.dir)
	@if \
	  $(MAKE) --no-print-directory AM_FORCE_SANITY_CHECKS=yes .am/nil; \
	then \
	  echo "# stamp" > $@; \
	else \
	  echo ".am/sanity-checks-failed = yes" > $@; \
	fi
endif

endif # $(AM_FORCE_SANITY_CHECKS) != yes
