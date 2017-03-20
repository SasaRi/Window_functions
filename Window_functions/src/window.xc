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
    int32_t y[2], a[2];

    int32_t x = dsp_math_divide(n,window_size-2, 24);

    for (int i = 0; i < 2; ++i)
    {
        y[i] = dsp_math_multiply((i+1)*PI2_Q8_24, x, 24);
        a[i] = dsp_math_cos(y[i]);
        y[i] = a[i] >> (24-Q_form);
    }

    return (0.42*(1<<Q_form) - dsp_math_multiply(0.5*(1<<Q_form), y[0], Q_form) + dsp_math_multiply(0.08*(1<<Q_form), y[1], Q_form));
}

int32_t flat_top(unsigned n, unsigned window_size, unsigned Q_form)
{
    int32_t y[2], a[2];

    int32_t x = dsp_math_divide(n,window_size-2, 24);

    for (int i = 0; i < 2; ++i)
    {
        y[i]= dsp_math_multiply((i+1)*PI2_Q8_24, x, 24);
        a[i] = dsp_math_cos(y[i]);
        y[i] = a[i] >> (24-Q_form);
    }

    return (0.2810639*(1<<Q_form) - dsp_math_multiply(0.5208972*(1<<Q_form), y[0], Q_form) + dsp_math_multiply(0.1980399*(1<<Q_form), y[1], Q_form));
}
