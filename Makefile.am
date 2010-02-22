SUFFIXES = .asm

lib_LTLIBRARIES = libx264.la

libx264_la_SOURCES = common/mc.c common/predict.c common/pixel.c \
	common/macroblock.c common/frame.c common/dct.c common/cpu.c \
	common/cabac.c common/common.c common/mdate.c common/set.c \
	common/quant.c common/vlc.c \
	encoder/analyse.c encoder/me.c encoder/ratecontrol.c \
	encoder/set.c encoder/macroblock.c encoder/cabac.c \
	encoder/cavlc.c encoder/encoder.c encoder/lookahead.c

X86SRC = common/x86/mc-c.c common/x86/predict-c.c

X86ASRC_COMMON = common/x86/cabac-a.asm common/x86/dct-a.asm \
	common/x86/deblock-a.asm common/x86/mc-a.asm common/x86/mc-a2.asm \
	common/x86/pixel-a.asm common/x86/predict-a.asm common/x86/quant-a.asm \
	common/x86/sad-a.asm common/x86/cpu-a.asm

X86ASRC = $(X86ASRC_COMMON) common/x86/dct-32.asm common/x86/pixel-32.asm
X86_64ASRC = $(X86ASRC_COMMON) common/x86/dct-64.asm common/x86/pixel-64.asm

if VIS
libx264_la_SOURCES += common/visualize.c common/display-x11.c
endif

if ARCH_X86
libx264_la_SOURCES += $(X86SRC)
if ASM
libx264_la_SOURCES += $(X86ASRC)
endif
endif

bin_PROGRAMS = x264

x264_SOURCES = x264.c input/yuv.c input/y4m.c output/raw.c \
	output/matroska.c output/matroska_ebml.c \
	output/flv.c output/flv_bytestream.c

x264_LDADD = libx264.la

if AVS_INPUT
x264_SOURCES += input/avs.c
endif

if HAVE_PTHREAD
x264_SOURCES += input/thread.c
endif

if LAVF_INPUT
x264_SOURCES += input/lavf.c
endif

if FFMS_INPUT
x264_SOURCES += input/ffms.c
endif

if MP4_OUTPUT
x264_SOURCES += output/mp4.c
endif

.asm.o:
	$(AS) $(ASFLAGS) -o $@ $<
	
.asm.lo:
	$(LIBTOOL) --mode=compile --tag=yasm $(AS) $(ASFLAGS) -o $@ $<
