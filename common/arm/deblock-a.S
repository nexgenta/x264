/*****************************************************************************
 * deblock.S: h264 encoder
 *****************************************************************************
 * Copyright (C) 2009 x264 project
 *
 * Authors: Mans Rullgard <mans@mansr.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02111, USA.
 *****************************************************************************/

#include "asm.S"

.fpu neon

.macro h264_loop_filter_start
    ldr             ip,  [sp]
    ldr             ip,  [ip]
    vmov.32         d24[0], ip
    and             ip,  ip,  ip, lsl #16
    ands            ip,  ip,  ip, lsl #8
    bxlt            lr
.endm

.macro align_push_regs
    and             ip,  sp,  #15
    add             ip,  ip,  #32
    sub             sp,  sp,  ip
    vst1.64         {d12-d15}, [sp,:128]
    sub             sp,  sp,  #32
    vst1.64         {d8-d11},  [sp,:128]
.endm

.macro align_pop_regs
    vld1.64         {d8-d11},  [sp,:128]!
    vld1.64         {d12-d15}, [sp,:128], ip
.endm

.macro h264_loop_filter_luma
    vdup.8          q11, r2         @ alpha
    vmovl.u8        q12, d24
    vabd.u8         q6,  q8,  q0    @ abs(p0 - q0)
    vmovl.u16       q12, d24
    vabd.u8         q14, q9,  q8    @ abs(p1 - p0)
    vsli.16         q12, q12, #8
    vabd.u8         q15, q1,  q0    @ abs(q1 - q0)
    vsli.32         q12, q12, #16
    vclt.u8         q6,  q6,  q11   @ < alpha
    vdup.8          q11, r3         @ beta
    vclt.s8         q7,  q12, #0
    vclt.u8         q14, q14, q11   @ < beta
    vclt.u8         q15, q15, q11   @ < beta
    vbic            q6,  q6,  q7
    vabd.u8         q4,  q10, q8    @ abs(p2 - p0)
    vand            q6,  q6,  q14
    vabd.u8         q5,  q2,  q0    @ abs(q2 - q0)
    vclt.u8         q4,  q4,  q11   @ < beta
    vand            q6,  q6,  q15
    vclt.u8         q5,  q5,  q11   @ < beta
    vand            q4,  q4,  q6
    vand            q5,  q5,  q6
    vand            q12, q12, q6
    vrhadd.u8       q14, q8,  q0
    vsub.i8         q6,  q12, q4
    vqadd.u8        q7,  q9,  q12
    vhadd.u8        q10, q10, q14
    vsub.i8         q6,  q6,  q5
    vhadd.u8        q14, q2,  q14
    vmin.u8         q7,  q7,  q10
    vqsub.u8        q11, q9,  q12
    vqadd.u8        q2,  q1,  q12
    vmax.u8         q7,  q7,  q11
    vqsub.u8        q11, q1,  q12
    vmin.u8         q14, q2,  q14
    vmovl.u8        q2,  d0
    vmax.u8         q14, q14, q11
    vmovl.u8        q10, d1
    vsubw.u8        q2,  q2,  d16
    vsubw.u8        q10, q10, d17
    vshl.i16        q2,  q2,  #2
    vshl.i16        q10, q10, #2
    vaddw.u8        q2,  q2,  d18
    vaddw.u8        q10, q10, d19
    vsubw.u8        q2,  q2,  d2
    vsubw.u8        q10, q10, d3
    vrshrn.i16      d4,  q2,  #3
    vrshrn.i16      d5,  q10, #3
    vbsl            q4,  q7,  q9
    vbsl            q5,  q14, q1
    vneg.s8         q7,  q6
    vmovl.u8        q14, d16
    vmin.s8         q2,  q2,  q6
    vmovl.u8        q6,  d17
    vmax.s8         q2,  q2,  q7
    vmovl.u8        q11, d0
    vmovl.u8        q12, d1
    vaddw.s8        q14, q14, d4
    vaddw.s8        q6,  q6,  d5
    vsubw.s8        q11, q11, d4
    vsubw.s8        q12, q12, d5
    vqmovun.s16     d16, q14
    vqmovun.s16     d17, q6
    vqmovun.s16     d0,  q11
    vqmovun.s16     d1,  q12
.endm

function x264_deblock_v_luma_neon
    h264_loop_filter_start

    vld1.64         {d0, d1},  [r0,:128], r1
    vld1.64         {d2, d3},  [r0,:128], r1
    vld1.64         {d4, d5},  [r0,:128], r1
    sub             r0,  r0,  r1, lsl #2
    sub             r0,  r0,  r1, lsl #1
    vld1.64         {d20,d21}, [r0,:128], r1
    vld1.64         {d18,d19}, [r0,:128], r1
    vld1.64         {d16,d17}, [r0,:128], r1

    align_push_regs

    h264_loop_filter_luma

    sub             r0,  r0,  r1, lsl #1
    vst1.64         {d8, d9},  [r0,:128], r1
    vst1.64         {d16,d17}, [r0,:128], r1
    vst1.64         {d0, d1},  [r0,:128], r1
    vst1.64         {d10,d11}, [r0,:128]

    align_pop_regs
    bx              lr
.endfunc

function x264_deblock_h_luma_neon
    h264_loop_filter_start

    sub             r0,  r0,  #4
    vld1.64         {d6},  [r0], r1
    vld1.64         {d20}, [r0], r1
    vld1.64         {d18}, [r0], r1
    vld1.64         {d16}, [r0], r1
    vld1.64         {d0},  [r0], r1
    vld1.64         {d2},  [r0], r1
    vld1.64         {d4},  [r0], r1
    vld1.64         {d26}, [r0], r1
    vld1.64         {d7},  [r0], r1
    vld1.64         {d21}, [r0], r1
    vld1.64         {d19}, [r0], r1
    vld1.64         {d17}, [r0], r1
    vld1.64         {d1},  [r0], r1
    vld1.64         {d3},  [r0], r1
    vld1.64         {d5},  [r0], r1
    vld1.64         {d27}, [r0], r1

    TRANSPOSE8x8    q3, q10, q9, q8, q0, q1, q2, q13

    align_push_regs

    h264_loop_filter_luma

    TRANSPOSE4x4    q4, q8, q0, q5

    sub             r0,  r0,  r1, lsl #4
    add             r0,  r0,  #2
    vst1.32         {d8[0]},  [r0], r1
    vst1.32         {d16[0]}, [r0], r1
    vst1.32         {d0[0]},  [r0], r1
    vst1.32         {d10[0]}, [r0], r1
    vst1.32         {d8[1]},  [r0], r1
    vst1.32         {d16[1]}, [r0], r1
    vst1.32         {d0[1]},  [r0], r1
    vst1.32         {d10[1]}, [r0], r1
    vst1.32         {d9[0]},  [r0], r1
    vst1.32         {d17[0]}, [r0], r1
    vst1.32         {d1[0]},  [r0], r1
    vst1.32         {d11[0]}, [r0], r1
    vst1.32         {d9[1]},  [r0], r1
    vst1.32         {d17[1]}, [r0], r1
    vst1.32         {d1[1]},  [r0], r1
    vst1.32         {d11[1]}, [r0], r1

    align_pop_regs
    bx              lr
.endfunc

.macro h264_loop_filter_chroma
    vdup.8          d22, r2         // alpha
    vmovl.u8        q12, d24
    vabd.u8         d26, d16, d0    // abs(p0 - q0)
    vmovl.u8        q2,  d0
    vabd.u8         d28, d18, d16   // abs(p1 - p0)
    vsubw.u8        q2,  q2,  d16
    vsli.16         d24, d24, #8
    vshl.i16        q2,  q2,  #2
    vabd.u8         d30, d2,  d0    // abs(q1 - q0)
    vaddw.u8        q2,  q2,  d18
    vclt.u8         d26, d26, d22   // < alpha
    vsubw.u8        q2,  q2,  d2
    vdup.8          d22, r3         // beta
    vclt.s8         d25, d24, #0
    vrshrn.i16      d4,  q2,  #3
    vclt.u8         d28, d28, d22   // < beta
    vbic            d26, d26, d25
    vclt.u8         d30, d30, d22   // < beta
    vand            d26, d26, d28
    vneg.s8         d25, d24
    vand            d26, d26, d30
    vmin.s8         d4,  d4,  d24
    vmovl.u8        q14, d16
    vand            d4,  d4,  d26
    vmax.s8         d4,  d4,  d25
    vmovl.u8        q11, d0
    vaddw.s8        q14, q14, d4
    vsubw.s8        q11, q11, d4
    vqmovun.s16     d16, q14
    vqmovun.s16     d0,  q11
.endm

function x264_deblock_v_chroma_neon
    h264_loop_filter_start

    sub             r0,  r0,  r1, lsl #1
    vld1.64         {d18}, [r0,:64], r1
    vld1.64         {d16}, [r0,:64], r1
    vld1.64         {d0},  [r0,:64], r1
    vld1.64         {d2},  [r0,:64]

    h264_loop_filter_chroma

    sub             r0,  r0,  r1, lsl #1
    vst1.64         {d16}, [r0,:64], r1
    vst1.64         {d0},  [r0,:64], r1

    bx              lr
.endfunc

function x264_deblock_h_chroma_neon
    h264_loop_filter_start

    sub             r0,  r0,  #2
    vld1.32         {d18[]},  [r0], r1
    vld1.32         {d16[]},  [r0], r1
    vld1.32         {d0[]},   [r0], r1
    vld1.32         {d2[]},   [r0], r1
    vld1.32         {d18[1]}, [r0], r1
    vld1.32         {d16[1]}, [r0], r1
    vld1.32         {d0[1]},  [r0], r1
    vld1.32         {d2[1]},  [r0], r1

    vtrn.16         d18, d0
    vtrn.16         d16, d2
    vtrn.8          d18, d16
    vtrn.8          d0,  d2

    h264_loop_filter_chroma

    vtrn.16         d18, d0
    vtrn.16         d16, d2
    vtrn.8          d18, d16
    vtrn.8          d0,  d2

    sub             r0,  r0,  r1, lsl #3
    vst1.32         {d18[0]}, [r0], r1
    vst1.32         {d16[0]}, [r0], r1
    vst1.32         {d0[0]},  [r0], r1
    vst1.32         {d2[0]},  [r0], r1
    vst1.32         {d18[1]}, [r0], r1
    vst1.32         {d16[1]}, [r0], r1
    vst1.32         {d0[1]},  [r0], r1
    vst1.32         {d2[1]},  [r0], r1

    bx              lr
.endfunc
