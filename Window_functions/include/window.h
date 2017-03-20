/*
 * window.h
 *
 *  Created on: Mar 20, 2017
 *      Author: sasa
 */


#ifndef WINDOW_H_
#define WINDOW_H_

/*
 * w = .5* (1-cos(2*pi*n/(M-1)))
 */
int32_t hann(unsigned n, unsigned window_size, unsigned Q_form);

/*
 * w = .42 - .5*cos(2*pi*n/(M-1)) + .08*cos(4*pi*n/(M-1))
 */
int32_t blackman(unsigned n, unsigned window_size, unsigned Q_form);

/*
 * w = .2810639 - .5208972*cos(2*pi*n/(M-1)) + .1980399*cos(4*pi*n/(M-1))
 */
int32_t flat_top(unsigned n, unsigned window_size, unsigned Q_form);
#endif /* WINDOW_H_ */
