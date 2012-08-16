
TEXI2DVI = texi2dvi
TEXI2PDF = $(TEXI2DVI) --pdf --batch
DVIPS = dvips
MAKEINFOHTML = $(MAKEINFO) --html
AM_MAKEINFOHTMLFLAGS ?= $(AM_MAKEINFOFLAGS)

define am.texi.build.dvi-or-pdf
	$1$(am.cmd.ensure-target-dir-exists) && \
	TEXINPUTS="$(am__TEXINFO_TEX_DIR)$(PATH_SEPARATOR)$$TEXINPUTS" \
	MAKEINFO='$(MAKEINFO) $(AM_MAKEINFOFLAGS) $(MAKEINFOFLAGS) \
	                      -I $(@D) -I $(srcdir)/$(@D)' \
	$2 $(AM_V_TEXI_QUIETOPTS) --build-dir=$3 \
	   -o $@ $< $(AM_V_TEXI_DEVNULL_REDIRECT)
endef

define am.texi.build.info
	$(if $1,,$(AM_V_at)$(am.cmd.ensure-target-dir-exists))
	$(AM_V_MAKEINFO)$(MAKEINFO) $(AM_MAKEINFOFLAGS) $(MAKEINFOFLAGS) \
	                --no-split -I $(@D) -I $(srcdir)/$(@D) -o $@-t $<
	$(AM_V_at)mv -f $@-t $@
endef

define am.texi.build.html
	$(AM_V_MAKEINFO)$(am.cmd.ensure-target-dir-exists) \
	  && { test ! -d $(@:.html=.htp) || rm -rf $(@:.html=.htp); } \
	  || exit 1; \
	if $(MAKEINFOHTML) $(AM_MAKEINFOHTMLFLAGS) $(MAKEINFOFLAGS) \
	                    -I $(@D) -I $(srcdir)/$(@D) \
			    -o $(@:.html=.htp) $<; \
	then \
	  rm -rf $@ && mv $(@:.html=.htp) $@; \
	else \
	  rm -rf $(@:.html=.htp) $@; exit 1; \
	fi
endef

%.info: %.texi
	$(call am.texi.build.info,$(am.texi.info-in-srcdir))
%.dvi: %.texi
	$(call am.texi.build.dvi-or-pdf,$(AM_V_TEXI2DVI),$(TEXI2DVI),$(@:.dvi=.t2d))
%.pdf: %.texi
	$(call am.texi.build.dvi-or-pdf,$(AM_V_TEXI2PDF),$(TEXI2PDF),$(@:.pdf=.t2p))
%.html: %.texi
	$(call am.texi.build.html)
%.ps: %.dvi
	$(AM_V_DVIPS)TEXINPUTS="$(am__TEXINFO_TEX_DIR)$(PATH_SEPARATOR)$$TEXINPUTS" \
	$(DVIPS) $(AM_V_TEXI_QUIETOPTS) -o $@ $<
