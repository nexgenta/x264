dnl
dnl Adapted from 'configure' from x264 by Mo McRoberts <mo.mcroberts@nexgenta.com>
dnl

dnl --------------------------------------------------------------------------
dnl Check if a specified preprocessor flag works
dnl --------------------------------------------------------------------------
AC_DEFUN([X264_CHECK_CPPFLAG],[
AC_LANG_PUSH([C])
oldcpp="$CPPFLAGS"
CPPFLAGS="$CPPFLAGS $1"
AC_MSG_CHECKING([if preprocessor flag $1 works])
AC_PREPROC_IFELSE([AC_LANG_PROGRAM([int foo;],[foo = 1234;])],[r=yes],[r=no])
CPPFLAGS="$oldcpp"
AC_LANG_POP
AC_MSG_RESULT([$r])
if test x"$r" = x"yes" ; then
	m4_if($2,,true,$2)
else
	m4_if($3,,true,$3)
fi	
])

AC_DEFUN([X264_TRY_ADD_CPPFLAG],[
X264_CHECK_CPPFLAG([$1],[CPPFLAGS="$CPPFLAGS $1"])
AC_SUBST([CPPFLAGS])
])

dnl --------------------------------------------------------------------------
dnl Check if a specified compiler flag works
dnl --------------------------------------------------------------------------
AC_DEFUN([X264_CHECK_CFLAG],[
AC_LANG_PUSH([C])
oldc="$CFLAGS"
CFLAGS="$CFLAGS $1"
r=yes
AC_MSG_CHECKING([if compiler flag $1 works])
AC_COMPILE_IFELSE([AC_LANG_PROGRAM([int foo;],[foo = 1234;])],[r=yes],[r=no])
CFLAGS="$oldc"
AC_LANG_POP
AC_MSG_RESULT([$r])
if test x"$r" = x"yes" ; then
	m4_if($2,,true,$2)
else
	m4_if($3,,true,$3)
fi	
])

AC_DEFUN([X264_TRY_ADD_CFLAG],[
X264_CHECK_CFLAG([$1],[CFLAGS="$CFLAGS $1"])
AC_SUBST([CFLAGS])
])

dnl --------------------------------------------------------------------------
dnl Check if a specified linker flag works
dnl --------------------------------------------------------------------------
AC_DEFUN([X264_CHECK_LDFLAG],[
AC_LANG_PUSH([C])
oldld="$LDFLAGS"
LDFLAGS="$LDFLAGS $1"
AC_MSG_CHECKING([if linker flag $1 works])
AC_COMPILE_IFELSE([AC_LANG_PROGRAM([int foo;],[foo = 1234;])],[r=yes],[r=no])
LDFLAGS="$oldld"
AC_LANG_POP
AC_MSG_RESULT([$r])
if test x"$r" = x"yes" ; then
	m4_if($2,,true,$2)
else
	m4_if($3,,true,$3)
fi	
])

AC_DEFUN([X264_TRY_ADD_LDFLAG],[
X264_CHECK_LDFLAG([$1],[LDFLAGS="$LDFLAGS $1"])
AC_SUBST([LDFLAGS])
])

dnl --------------------------------------------------------------------------
dnl Determine system type ($SYS)
dnl --------------------------------------------------------------------------
AC_DEFUN([X264_SYSTEM],[
AC_REQUIRE([AC_CANONICAL_HOST])
AC_BEFORE([X264_PLATFORM])
case "$host_os" in
	darwin*)
		AC_DEFINE([SYS_MACOSX], [1], [Define if building for Mac OS X and Darwin])
		SYS=MACOSX
		CFLAGS="$CFLAGS -falign-loops=16"
		if test x"$pic_mode" = x"yes" ; then
			CFLAGS="$CFLAGS -mdynamic-no-pic"
		fi
		ASFLAGS="$ASFLAGS -DPREFIX"
		case "$host_cpu" in
			i?86|x86)
				YASMFLAGS="$YASMFLAGS -f macho"
				;;
		    x86_64|amd64)
				YASMFLAGS="$YASMFLAGS -f macho64"
				;;
		    arm*)
				ASFLAGS="$ASFLAGS -DPREFIX -DPIC"
				case "$CFLAGS" in
					*-march*)
						;;
					*)
						CFLAGS="$CFLAGS -arch armv7"
						;;
				esac
				;;
			ppc|powerpc|powerpc64|ppc64)
				CFLAGS="$CFLAGS -faltivec -fastf -mcpu=G4"
				;;
		esac
		;;
	cygwin*)
		AC_DEFINE([SYS_MINGW],[1],[Define if building for MinGW and Cygwin])
		SYS=MINGW
		DEVNULL="NUL"
		CFLAGS="$CFLAGS -mno-cygwin"
		LDFLAGS="$LDFLAGS -mno-cygwin"
		ASFLAGS="$ASFLAGS -DPREFIX"
		;;
	mingw*)
		AC_DEFINE([SYS_MINGW],[1],[Define if building for MinGW and Cygwin])
		SYS=MINGW
		DEVNULL="NUL"
		ASFLAGS="$ASFLAGS -DPREFIX"
	    YASMFLAGS="$YASMFLAGS -f win32"
		;;
	beos)
		AC_DEFINE([SYS_BEOS],[1],[Define if building for BeOS])
		SYS=BEOS
		YASMFLAGS="$YASMFLAGS -f elf"
		;;
	freebsd|kfreebsd*-gnu)
		AC_DEFINE([SYS_FREEBSD],[1],[Define if building for FreeBSD])
		SYS=FREEBSD
		YASMFLAGS="$YASMFLAGS -f elf"
		;;
	openbsd)
		AC_DEFINE([SYS_OPENBSD],[1],[Define if building for OpenBSD])
		SYS=OPENBSD
		YASMFLAGS="$YASMFLAGS -f elf"
		;;
	netbsd)
		AC_DEFINE([SYS_NETBSD],[1],[Define if building for NetBSD])
		SYS=NETBSD
		YASMFLAGS="$YASMFLAGS -f elf"
		;;
	linux|linux-gnu)
		AC_DEFINE([SYS_LINUX],[1],[Define if building for Linux])
		SYS=LINUX
		YASMFLAGS="$YASMFLAGS -f elf"
		;;
	sunos*|solaris*)
		AC_DEFINE([SYS_SunOS],[1],[Define if building for Solaris])
		SYS=SunOS
		YASMFLAGS="$YASMFLAGS -f elf"
		;;
	*)
		AC_MSG_RESULT([warning: unknown system $host_os; assuming an ELF system])
		SYS=`echo $host_os | tr a-z A-Z`
		YASMFLAGS="$YASMFLAGS -f elf"
		;;
esac
test x"$DEVNULL" = x"" && DEVNULL="/dev/null"
AC_MSG_CHECKING([system type])
AC_MSG_RESULT([$SYS])
])

dnl --------------------------------------------------------------------------
dnl Determine platform ($ARCH)
dnl --------------------------------------------------------------------------
AC_DEFUN([X264_PLATFORM],[
AC_REQUIRE([AC_CANONICAL_HOST])
case "$host_cpu" in
	i*86|x86)
		AC_DEFINE_UNQUOTED([ARCH_X86],[1],[Define if building for x86])
		ARCH=X86
		;;
	x86_64|amd64)
		AC_DEFINE_UNQUOTED([ARCH_X86_64],[1],[Define if building for x86_64])
		ARCH=X86_64
		YASMFLAGS="$YASMFLAGS -m amd64"
		ASFLAGS="$ASFLAGS -DARCH_X86_64"
		;;
	powerpc*|ppc*)
		AC_DEFINE([ARCH_PPC],[1],[Define if building for PowerPC])
		;;
	sun4u)
		AC_DEFINE([ARCH_UltraSparc],[1],[Define if building for UltraSparc])
		;;
	sparc)
		AC_DEFINE([ARCH_Sparc],[1],[Define if building for Sparc])
		;;
	*)
		ARCH=`echo $host_cpu | tr a-z A-Z`
		;;
esac
AM_CONDITIONAL([ARCH_X86],[test x"$ARCH" = x"X86"])
AM_CONDITIONAL([ARCH_X86_64],[test x"$ARCH" = x"X86_64"])
AC_MSG_CHECKING([system architecture])
AC_MSG_RESULT([$ARCH])
])

dnl --------------------------------------------------------------------------
dnl Enable assembly optimization (--enable-asm)
dnl --------------------------------------------------------------------------
AC_DEFUN([X264_ENABLE_ASM],[
AC_REQUIRE([X264_SYSTEM])
AC_REQUIRE([X264_PLATFORM])
AC_ARG_ENABLE([asm],[AS_HELP_STRING([--disable-asm],[disables assembly optimizations on x86 and arm])],[asm=$enableval],[asm=yes])
if test x"$asm" = x"yes" ; then
	if test x"$ARCH" = x"X86" || test x"$ARCH" = x"X86_64" ; then	
		AC_CHECK_TOOL([YASM],[yasm])
		if test x"$YASM" = x"" ; then
			AC_MSG_ERROR([cannot locate yasm, which is required for optimised builds on $host_cpu platforms])
		fi
		AS="$YASM"
		ASFLAGS="$ASFLAGS $YASMFLAGS"
	else
## Todo: SPARC and arm assembly
		asm=no
	fi
fi
if test x"$asm" = x"yes" ; then
	AC_DEFINE([ASM],[1],[Enable assembly optimizations on x86 and arm])
	if test x"$ARCH" = x"X86" ; then
		case "$CFLAGS" in
			*-march*)
				;;
			*)
				CFLAGS="$CFLAGS -march=i686"
				;;
		esac
		case "$CFLAGS" in
			*-mfpmath*)
				;;
			*)
				CFLAGS="$CFLAGS -mfpmath=sse -msse"
				;;
		esac
	fi	
	if test x"$ARCH" = x"X86" || test x"$ARCH" = x"X86_64" ; then
## Todo: Test compiler and assembler
		AC_DEFINE([HAVE_MMX],[1],[define if MMX and SSE3 instructions are available])
	fi
fi
AM_CONDITIONAL([ASM],[test x"$asm" = x"yes"])
AC_MSG_CHECKING([whether to enable assembly optimizations])
AC_MSG_RESULT([$asm])
AC_SUBST([AS])
AC_SUBST([ASFLAGS])
])

dnl --------------------------------------------------------------------------
dnl Enable avisynth input (--enable-avs-input)
dnl --------------------------------------------------------------------------
AC_DEFUN([X264_ENABLE_AVS],[
AC_ARG_ENABLE([avs-input],[AS_HELP_STRING([--disable-avs-input],[disables avisynth input (Win32 only)])],[avs_input=$enableval],[avs_input=yes])
if test x"$avs_input" = x"yes" ; then
	avs_input=no
	case "$host_os" in
		mingw*)
			AC_CHECK_HEADER([avisynth_c.h])
			avs_input=yes
			;;
	esac
fi
if test x"$avs_input" = x"yes" ; then
	AC_DEFINE([AVS_INPUT],[1],[Enable avisynth input])
fi
AM_CONDITIONAL([AVS_INPUT],[test x$"avs_input" = x"yes"])
AC_MSG_CHECKING([whether to enable avisynth input])
AC_MSG_RESULT([$avs_input])
])

dnl --------------------------------------------------------------------------
dnl Enable libavformat input (--enable-lavf-input)
dnl --------------------------------------------------------------------------
AC_DEFUN([X264_ENABLE_LAVF],[
AC_ARG_ENABLE([lavf-input],[AS_HELP_STRING([--disable-lavf-input],[disables libavformat input])],[lavf_input=$enableval],[lavf_input=yes])
lavf_input=no
if test x"$lavf_input" = x"yes" ; then
	AC_DEFINE([LAVF_INPUT],[1],[Enable libavformat input])
fi
AM_CONDITIONAL([LAVF_INPUT],[test x"$lavf_input" = x"yes"])
AC_MSG_CHECKING([whether to enable libavformat input])
AC_MSG_RESULT([$lavf_input])
])

dnl --------------------------------------------------------------------------
dnl Enable ffmpegsource input (--enable-ffms-input)
dnl --------------------------------------------------------------------------
AC_DEFUN([X264_ENABLE_FFMS],[
AC_ARG_ENABLE([ffms-input],[AS_HELP_STRING([--disable-ffms-input],[disables ffmpegsource input])],[ffms_input=$enableval],[ffms_input=yes])
ffms_input=no
if test x"$ffms_input" = x"yes" ; then
	AC_DEFINE([FFMS_INPUT],[1],[Enable ffmpegsource input])
fi
AM_CONDITIONAL([FFMS_INPUT],[test x"$ffms_input" = x"yes"])
AC_MSG_CHECKING([whether to enable ffmpegsource input])
AC_MSG_RESULT([$ffms_input])
])

dnl --------------------------------------------------------------------------
dnl Enable MP4 output (--enable-mp4-output)
dnl --------------------------------------------------------------------------
AC_DEFUN([X264_ENABLE_MP4],[
AC_ARG_ENABLE([mp4-output],[AS_HELP_STRING([--disable-mp4-output],[disables MP4 output (using gpac)])],[mp4_output=$enableval],[mp4_output=yes])
mp4_output=no
if test x"$mp4_output" = x"yes" ; then
	AC_DEFINE([MP4_OUTPUT],[1],[Enable MP4 output])
fi
AM_CONDITIONAL([MP4_OUTPUT],[test x"$mp4_output" = x"yes"])
AC_MSG_CHECKING([whether to enable MP4 output])
AC_MSG_RESULT([$mp4_output])
])

dnl --------------------------------------------------------------------------
dnl Enable POSIX threads (--enable-pthread)
dnl --------------------------------------------------------------------------
AC_DEFUN([X264_ENABLE_PTHREAD],[
AC_ARG_ENABLE([pthread],[AS_HELP_STRING([--disable-pthread],[disables multithreaded encoding])],[pthread=$enableval],[pthread=yes])
if test x"$pthread" = x"yes" ; then
	AC_CHECK_HEADER([pthread.h],,[pthread=no])
fi
if test x"$pthread" = x"yes" ; then
	oldflags="$LDFLAGS"
	LDFLAGS="$LDFLAGS -pthread"
	AC_CHECK_FUNC([pthread_create],,[
		LDFLAGS="$oldflags"
		AC_CHECK_LIB([pthread],[pthread_create],,[
			pthread=no
# Todo: Win32 pthread emulation as per configure.dist
		])
	])
fi
if test x"$pthread" = x"yes" ; then
	AC_DEFINE([HAVE_PTHREAD],[1],[Enable multithreaded encoding])
fi
AM_CONDITIONAL([HAVE_PTHREAD],[test x"$pthread" = x"yes"])
AC_MSG_CHECKING([whether to enable multithreaded encoding])
AC_MSG_RESULT([$pthread])
])

dnl --------------------------------------------------------------------------
dnl Enable visualization (--enable-visualize)
dnl --------------------------------------------------------------------------
AC_DEFUN([X264_ENABLE_VIS],[
AC_ARG_ENABLE([visualize],[AS_HELP_STRING([--enable-visualize],[enables visualization (X11 only)])],[vis=$enableval],[vis=no])
vis=no
if test x"$vis" = x"yes" ; then
	AC_DEFINE([VIS],[1],[Enable visualization])
fi
AM_CONDITIONAL([VIS],[test x"$vis" = x"yes"])
AC_MSG_CHECKING([whether to enable visualization])
AC_MSG_RESULT([$vis])
])

dnl --------------------------------------------------------------------------
dnl Enable debugging (--enable-debug)
dnl --------------------------------------------------------------------------
AC_DEFUN([X264_ENABLE_DEBUG],[
AC_ARG_ENABLE([debug],[AS_HELP_STRING([--enable-debug],[adds -g, doesn't strip])],[debug=$enableval],[debug=no])
AC_ARG_ENABLE([gprof],[AS_HELP_STRING([--enable-gprof],[adds -gp, doesn't strip])],[gprof=$enableval],[gprof=no])

if test x"$gprof" = x"yes" ; then
	X264_TRY_ADD_CFLAG(-pg)
fi

if test x"$debug" = x"yes" ; then
	X264_TRY_ADD_CFLAG(-O1)
	X264_TRY_ADD_CFLAG(-g)
fi

if test x"$debug" = x"no" && test x"$gprof" = x"no" ; then
	X264_TRY_ADD_CFLAG(-s)
	X264_TRY_ADD_CFLAG(-fomit-frame-pointer)
	X264_TRY_ADD_LDFLAG(-s)
	X264_TRY_ADD_CFLAG(-O3)
	if test x"$ARCH" = x"ARM" ; then
		X264_TRY_ADD_CFLAG(-fno-fast-math)
	else
		X264_TRY_ADD_CFLAG(-ffast-math)
	fi
fi
])
