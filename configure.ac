dnl
dnl Adapted from 'configure' from x264 by Mo McRoberts <mo.mcroberts@nexgenta.com>
dnl

AC_INIT([x264],[0.85.1442])
X264_API=85
X264_REVISION=1442
X264_VCS_COMMIT="781d300"

AM_INIT_AUTOMAKE([foreign subdir-objects])
AM_MAINTAINER_MODE


AC_DEFINE_UNQUOTED([X264_VERSION],[" r$X264_REVISION $X264_VCS_COMMIT"],[printable version string])
AC_DEFINE_UNQUOTED([X264_POINTVER],["$VERSION $X264_VCS_COMMIT"],[major.minor version string])

AC_CANONICAL_HOST
AC_PROG_CC
AC_PROG_CC_C99

AC_DISABLE_SHARED
AC_LIBTOOL_PICMODE([no])
AC_PROG_LIBTOOL
test x"$pic_mode" = x"default" && pic_mode="no"
AC_SYS_LARGEFILE

AC_CHECK_LIB(m,cos)
AC_CHECK_FUNC([log2f])

AC_CONFIG_HEADER([config.h])

AC_CHECK_HEADERS([malloc.h inttypes.h])

AC_CHECK_FUNC([getopt_long])

olibs="$LIBS"
AC_PATH_X
LIBS="$olibs"

AC_C_BIGENDIAN
if test "x$ac_cv_c_bigendian" = "xyes"; then
	AC_DEFINE([WORDS_BIGENDIAN],[1],[define if building on a big-endian system])
fi

X264_SYSTEM
X264_PLATFORM
X264_ENABLE_ASM
X264_ENABLE_AVS
X264_ENABLE_LAVF
X264_ENABLE_FFMS
X264_ENABLE_MP4
X264_ENABLE_PTHREAD
X264_ENABLE_VIS
X264_ENABLE_DEBUG

dnl This is a huge hack, and will probably stop working very unceremoniously
cat <<__EOF__ >>libtool
# ### BEGIN LIBTOOL TAG CONFIG: yasm
pic_flag='-DPIC'
# ### END LIBTOOL TAG CONFIG: yasm
__EOF__

AC_CONFIG_FILES([
Makefile
])

AC_OUTPUT

AC_MSG_RESULT([
Platform:   $ARCH
System:     $SYS
asm:        $asm
avs input:  $avs_input
lavf input: $lavf_input
ffms input: $ffms_input
mp4 output: $mp4_output
pthread:    $pthread
debug:      $debug
gprof:      $gprof
PIC:        $pic_mode
shared:     $enable_shared
visualize:  $vis
])
