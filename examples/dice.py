#!/usr/bin/env python
# -*- coding: ascii -*-
"""
Calculate the mean/std of the sum of dice rolls (adding up to at least M) and
the mean/std of the number of rolls.
"""
from __future__ import print_function

import pystats
import random

M = 100
n_exp = 200

sums = pystats.StatsAccumulator()
rolls = pystats.StatsAccumulator()

die = range(6)
for i in xrange(n_exp):
    total = 0
    r = 0
    while total < M:
        total += random.choice(die)
        r += 1
    sums.push(total)
    rolls.push(r)

m, v, s = sums.bayes_mvs(0.95)
print('Sums:')
print('    Mean      : {}, CI {}'.format(m[0], m[1]))
print('    Std. dev. : {}, CI {}'.format(s[0], s[1]))
m, v, s = rolls.bayes_mvs(0.95)
print('Rolls:')
print('    Mean      : {}, CI {}'.format(m[0], m[1]))
print('    Std. dev. : {}, CI {}'.format(s[0], s[1]))
