// Copyright (c) 2015-2016, XMOS Ltd, All rights reserved
    
#if defined(__XS2A__)

	.text
    .issue_mode  dual
	.globl	dsp_fft_forward_xs2
	.align	16
    .skip 8
	.type	dsp_fft_forward_xs2,@function
	.cc_top dsp_fft_forward_xs2.function,dsp_fft_forward_xs2
	
dsp_fft_forward_xs2:

	dualentsp 32
    
	stw r4, sp[27]
	stw r5, sp[26]
	stw r6, sp[25]
	stw r7, sp[24]
	stw r8, sp[23]
	stw r9, sp[22]
	stw r10, sp[19]
    
    ldc r6, 1
    ldc r5, 31
    mkmsk r4, r5
    shl r5, r6, r5
	std r4, r4, sp[10]              //  0x800000000 x 2

	stw r2, sp[18]             // sine
	stw r1, sp[17]             // N
	stw r0, sp[16]             // pts

	clz r11, r1
	ldc r10, 30
	sub r11, r10, r11
    stw r11, sp[15]            // Shift

    ldc r11, 2
    stw r11, sp[14]            // step
outerLoop:
    ldw r11, sp[14]
    shl r10, r11, 3
    stw r10, sp[9]             // step * 8
    shr r11, r11, 1
    stw r11, sp[13]            // step2
    shr r10, r11, 1
    stw r10, sp[12]            // step4

// First loop

    ldc r9, 1
    and r11, r11, r9
    add r10, r11, r10          // step4 + (step2&1)
    stw r10, sp[11]
    ldc r9, 0
kLoop1:
    stw r9, sp[10]             // k
    ldw r10, sp[15]            // shift
    { shl r7, r9, r10  ;   ldw r6, sp[18] }// sine
    
    {ldw r8, sp[17]    ; nop}        // N
    { add r11, r9, r8    ; ldw r0, r6[r7]     }       // k + N        // rIm
    { shr r8, r8, 2 ;   ldw r5, sp[14] }
    { sub r11, r11, r5 ;  sub r8, r8, r7 }        // k + N - step: BLOCK.
                 // N>>2 - k<<shift
    { ldw r1, r6[r8]   ;     shl r3, r11, 3 }          //  rRe


    { ldw r11, sp[16]	  ; ldc r8, 0}
    { add r4, r11, r3   ; ldw r11, sp[9]  }          // & pts[block]
    ldw r9, sp[13]             // step2

#define HIRES 0

innerLoop1:
#if HIRES
	ldd r2, r5, r4[r9]               // r5: tRE2, r2: tIM2
	ldd r10, r7, sp[10]              //  0x800000000 x 2
	maccs r8, r7, r5, r1             // rRe x tRe2
	maccs r8, r7, r2, r0             // rIM x tIm2
	                                 // r8: sRE2

 	ldd r3, r6, r4[0]                // r6: tRE,  r3: tIM

	maccs r8, r7, r6, r10
	{stw r8, r4[0]; neg r10, r10}
	maccs r8, r7, r6, r10
	maccs r8, r7, r6, r10

	ldd r6, r10, sp[10]              //  0x800000000 x 2
	{ ldc r7, 0            ; neg r5, r5}
	maccs r7, r10, r5, r0            // rIM x -tRE2
	maccs r7, r10, r2, r1            // rRE x tIM2
                                     // r7: sIM2
	maccs r7, r10, r3, r6
	{stw r7, r4[1]; neg r6, r6}
	maccs r7, r10, r3, r6
	maccs r7, r10, r3, r6
	{neg r8, r8; neg r7, r7}
	std  r7, r8, r4[r9]
#else
 	ldd r3, r6, r4[0]                // r6: tRE,  r3: tIM
	ashr r6, r6, 1                   // tRE
	ashr r3, r3, 1                   // tIM
	ldd r2, r5, r4[r9]               // r5: tRE2, r2: tIM2
	ldd r10, r7, sp[10]              //  0x800000000 x 2
	maccs r8, r7, r5, r1             // rRe x tRe2
	maccs r8, r7, r2, r0             // rIM x tIm2
	                                 // r8: sRE2
	{ ldc r7, 0            ; neg r5, r5}
	maccs r7, r10, r5, r0            // rIM x -tRE2
	maccs r7, r10, r2, r1            // rRE x tIM2
                                     // r7: sIM2    
	{add  r6, r6, r8       ; sub r8, r6, r8}
	{add  r3, r3, r7       ; sub r7, r3, r7}
	std  r3, r6, r4[0]
	std  r7, r8, r4[r9]
#endif
	{ldw r6, sp[16]        ; sub r4, r4, r11}
	lsu r8, r4, r6    

	bf r8, innerLoop1

    ldw r9, sp[10]             // k
    add r9, r9, 1
	ldw r10, sp[11]
    lsu r10, r9, r10
	bt r10, kLoop1

// Second inner loop

	ldw r10, sp[12]             // step4
    {ldw r11, sp[13]             ;    ldc r9, 1}
    {and r7, r11, r9             ;   bu  kLoop2In}
kLoop2:
    { ldw r10, sp[15]  ; add r11, r7, 0}           // shift
    { shl r9, r11, r10 ;     ldw r7, sp[18]   }         // sine         // k << shift

    ldw r1, r7[r9]            // rRe
    { neg r1, r1                ;    ldw r8, sp[17]}             // N
    { add r11, r11, r8 ;    ldw r6, sp[14]}      // k + N
    
    { shr r8, r8, 2               ;    sub r11, r11, r6}

    { sub r8, r8, r9  ;     ldw r5, sp[12] }            // step4          // N>>2 - k<<shift
    { ldw r0, r7[r8]  ;     add r11, r11, r5 }          // k + N - step + step4: BLOCK.            // rIm
    
    {shl r3, r11, 3              ;    ldw r11, sp[16]}
    {add r4, r11, r3   ;     ldw r9, sp[13] }            // step2        // & pts[block]

	{ldc r8, 0                   ;    ldw r11, sp[9]}
innerLoop2:
#if HIRES
	ldd r2, r5, r4[r9]               // r5: tRE2, r2: tIM2
	ldd r10, r7, sp[10]              //  0x800000000 x 2
	maccs r8, r7, r5, r1             // rRe x tRe2
	maccs r8, r7, r2, r0             // rIM x tIm2
	                                 // r8: sRE2

 	ldd r3, r6, r4[0]                // r6: tRE,  r3: tIM

	maccs r8, r7, r6, r10
	{stw r8, r4[0]; neg r10, r10}
	maccs r8, r7, r6, r10
	maccs r8, r7, r6, r10

	ldd r6, r10, sp[10]              //  0x800000000 x 2
	{ ldc r7, 0            ; neg r5, r5}
	maccs r7, r10, r5, r0            // rIM x -tRE2
	maccs r7, r10, r2, r1            // rRE x tIM2
                                     // r7: sIM2
	maccs r7, r10, r3, r6
	{stw r7, r4[1]; neg r6, r6}
	maccs r7, r10, r3, r6
	maccs r7, r10, r3, r6
	{neg r8, r8; neg r7, r7}
	std  r7, r8, r4[r9]
#else
 	ldd r3, r6, r4[0]               // r6: tRE,  r3: tIM
	ashr r6, r6, 1                  // tRE
	ashr r3, r3, 1                  // tIM
	ldd r2, r5, r4[r9]              // r5: tRE2, r2: tIM2

	ldd r10, r7, sp[10]              //  0x800000000 x 2

	maccs r8, r7, r5, r1            // rRe x tRe2
	maccs r8, r7, r2, r0            // rIM x tIm2
	                                // r8: sRE2
	{ ldc r7, 0                     ; neg r5, r5 }

	maccs r7, r10, r5, r0            // rIM x -tRE2
	maccs r7, r10, r2, r1            // rRE x tIM2
                                    // r7: sIM2
	{add  r6, r6, r8           ; sub r8, r6, r8}
	{add  r3, r3, r7           ; sub r7, r3, r7}
	std  r3, r6, r4[0]
	std  r7, r8, r4[r9]
#endif
	{ldw r6, sp[16]        ; sub r4, r4, r11}
	{lsu r8, r4, r6         ;    ldw r7, sp[10]}             // k

	bf r8, innerLoop2

    {add r7, r7, 1              ;	ldw r10, sp[12]}             // step4

kLoop2In:   
    {lsu r10, r7, r10            ;    stw r7, sp[10]}             // k
	bt r10, kLoop2

	ldd r10, r11, sp[7]
	{sub r10, r10, 1; shl r11, r11, 1}
	std r10, r11, sp[7]

    ldw r10, sp[17]
    add r10, r10, 1
    lsu r10, r10, r11
    bf  r10, outerLoop
    
	ldw r10, sp[19]
	ldw r9, sp[22]
	ldw r8, sp[23]
	ldw r7, sp[24]
	ldw r6, sp[25]
	ldw r5, sp[26]
	ldw r4, sp[27]
	retsp 32
	
	// RETURN_REG_HOLDER
	.cc_bottom dsp_fft_forward_xs2.function
	.set	dsp_fft_forward_xs2.nstackwords,32
	.globl	dsp_fft_forward_xs2.nstackwords
	.set	dsp_fft_forward_xs2.maxcores,1
	.globl	dsp_fft_forward_xs2.maxcores
	.set	dsp_fft_forward_xs2.maxtimers,0
	.globl	dsp_fft_forward_xs2.maxtimers
	.set	dsp_fft_forward_xs2.maxchanends,0
	.globl	dsp_fft_forward_xs2.maxchanends
.Ltmp0:
	.size	dsp_fft_forward_xs2, .Ltmp0-dsp_fft_forward_xs2

    .issue_mode  single
    
#endif
