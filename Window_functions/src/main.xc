/*
 * main.xc
 *
 *  Created on: Mar 20, 2017
 *      Author: sasa
 */


#include <stdio.h>
#include <stdint.h>
#include <window.h>

#define Q_form 16
#define num_samples 256
#define DO_HANN 0
#define DO_BLACK 1

int main()
{
#if DO_HANN
    /*
     * Hann window
     */
    for (int i = 0; i< num_samples; ++i)
    {
        printf("%d\n", hann(i, num_samples, Q_form));
    }
#endif

#if DO_BLACK
    /*
     * Blackman window
     */
    for (int i = 0; i< num_samples; ++i)
    {
        printf("%d\n", blackman(i, num_samples, Q_form));
    }
#endif

    return 0;
}
