
# Internal make variables that point to a sandbox directory where we can
# play freely to implement internal details that require interaction with
# the filesystem.  It is not created by default; recipes needing it
# should add an order-only dependency on it, as in:
#
#     am-rule: am-prereqs | $(am.dir)
#         [recipe creating/using files in $(am.dir)]
#
am.dir = .am

# Its counterpart with an absolute path, for recipes that can chdir around.
am.dir.abs = $(abs_builddir)/$(am.dir)

# Its counterpart for use in subdir makefiles, in case they need to refer
# to the top-level $(am.dir) directory.
am.top-dir = $(top_builddir)/$(am.dir)

# Its counterpart with an absolute path and for use in subdir makefiles.
am.top-dir.abs = $(abs_top_builddir)/$(am.dir)

am.clean.dist.d += $(am.dir)

$(am.dir):
	@mkdir $@
