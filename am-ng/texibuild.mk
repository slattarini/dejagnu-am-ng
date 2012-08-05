
TEXI2DVI = texi2dvi
TEXI2PDF = $(TEXI2DVI) --pdf --batch
DVIPS = dvips
MAKEINFOHTML = $(MAKEINFO) --html
AM_MAKEINFOHTMLFLAGS ?= $(AM_MAKEINFOFLAGS)

define am__texibuild_dvi_or_pdf
	$1$(am.cmd.ensure-target-dir-exists) && \
	TEXINPUTS="$(am__TEXINFO_TEX_DIR)$(PATH_SEPARATOR)$$TEXINPUTS" \
	MAKEINFO='$(MAKEINFO) $(AM_MAKEINFOFLAGS) $(MAKEINFOFLAGS) \
	                      -I $(@D) -I $(srcdir)/$(@D)' \
	$2 $(AM_V_TEXI_QUIETOPTS) --build-dir=$3 \
	   -o $@ $< $(AM_V_TEXI_DEVNULL_REDIRECT)
endef

define am__texibuild_info
	$(if $1,,@$(am.cmd.ensure-target-dir-exists))
	$(AM_V_MAKEINFO)restore=: && backupdir=.am$$$$ && \
	$(if $1,am__cwd=`pwd` && cd $(srcdir) &&) \
	rm -rf $$backupdir && mkdir $$backupdir && \
	if ($(MAKEINFO) --version) >/dev/null 2>&1; then \
	  for f in $@ $@-[0-9] $@-[0-9][0-9]; do \
	    if test -f $$f; then mv $$f $$backupdir; restore=mv; else :; fi; \
	  done; \
	else :; fi && \
	$(if $(am__info_insrc),cd "$$am__cwd" &&) \
	if $(MAKEINFO) $(AM_MAKEINFOFLAGS) $(MAKEINFOFLAGS) \
	               -I $(@D) -I $(srcdir)/$(@D) -o $@ $<; \
	then \
	  rc=0; \
	  $(if $(am__info_insrc),cd $(srcdir);) \
	else \
	  rc=$$?; \
	  $(if $(am__info_insrc),cd $(srcdir) &&) \
	  $$restore $$backupdir/* $(@D); \
	fi; \
	rm -rf $$backupdir; exit $$rc
endef

define am__texibuild_html
	$(AM_V_MAKEINFO)$(am.cmd.ensure-target-dir-exists) \
	  && { test ! -d $(@:.html=.htp) || rm -rf $(@:.html=.htp); } \
	  || exit 1; \
	if $(MAKEINFOHTML) $(AM_MAKEINFOHTMLFLAGS) $(MAKEINFOFLAGS) \
	                    -I $(@D) -I $(srcdir)/$(@D) \
			    -o $(@:.html=.htp) $<; \
	then \
	  rm -rf $@; \
	  if test ! -d $(@:.html=.htp) && test -d $(@:.html=); then \
	    mv $(@:.html=) $@; else mv $(@:.html=.htp) $@; fi; \
	else \
	  if test ! -d $(@:.html=.htp) && test -d $(@:.html=); then \
	    rm -rf $(@:.html=); else rm -Rf $(@:.html=.htp) $@; fi; \
	  exit 1; \
	fi
endef

%.info: %.texi
	$(call am__texibuild_info,$(am__info_insrc))
%.dvi: %.texi
	$(call am__texibuild_dvi_or_pdf,$(AM_V_TEXI2DVI),$(TEXI2DVI),$(@:.dvi=.t2d))
%.pdf: %.texi
	$(call am__texibuild_dvi_or_pdf,$(AM_V_TEXI2PDF),$(TEXI2PDF),$(@:.pdf=.t2p))
%.html: %.texi
	$(call am__texibuild_html)
%.ps: %.dvi
	$(AM_V_DVIPS)TEXINPUTS="$(am__TEXINFO_TEX_DIR)$(PATH_SEPARATOR)$$TEXINPUTS" \
	$(DVIPS) $(AM_V_TEXI_QUIETOPTS) -o $@ $<
