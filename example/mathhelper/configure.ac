dnl Process this file with autoconf to produce a configure script.
AC_INIT([mathhelper], [1.0])
AC_CONFIG_SRCDIR([libmathhelper/mathhelper.c])
AC_CONFIG_AUX_DIR([.])

dnl handles checking target
AC_CANONICAL_TARGET([])

AM_INIT_AUTOMAKE([ng])

dnl Checks for programs.
AC_PROG_CC
AC_PROG_CXX
AC_PROG_LIBTOOL

dnl Checks for typedefs, structures, and compiler characteristics.
AC_C_CONST

AC_CONFIG_FILES([Makefile
    libmathhelper/Makefile
    testsuite/Makefile
    testsuite/mathhelper/Makefile ])
AC_OUTPUT
 
