/*
 * Hann_window.xc
 *
 *  Created on: Mar 20, 2017
 *      Author: sasa
 */

#include <dsp.h>

extern q8_24 dsp_math_cos(q8_24 rad);

int32_t hann(unsigned n, unsigned window_size, unsigned Q_form)
{
    int32_t x = dsp_math_divide(n,window_size-2, 24);

    int32_t y = dsp_math_multiply(PI2_Q8_24, x, 24);

    x = dsp_math_cos(y);

    y = x >> (24-Q_form);

    return (((1*(1<<Q_form))-y) >> 1);
}

int32_t blackman(unsigned n, unsigned window_size, unsigned Q_form)
{
    int32_t x = dsp_math_divide(n,window_size-2, 24);

    int32_t pi2 = dsp_math_multiply(PI2_Q8_24, x, 24);

    int32_t y1 = dsp_math_multiply(pi2, x, 24);

    int32_t y2 = dsp_math_multiply(2*pi2, x, 24);

    int32_t a1 = dsp_math_cos(y1);

    int32_t a2 = dsp_math_cos(y2);

    y1 = a1 >> (24-Q_form);

    y2 = a2 >> (24-Q_form);

    return (0.42*(1<<Q_form) - dsp_math_multiply(0.5*(1<<Q_form), y1, Q_form) + dsp_math_multiply(0.08*(1<<Q_form), y2, Q_form));
}
