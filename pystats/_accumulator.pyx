"""
Adapted from http://www.johndcook.com/blog/skewness_kurtosis/
"""
from __future__ import division

import scipy
import scipy.stats

cimport libc.math as cymath

cdef class Accumulator:
    cdef public long long n
    cdef public double M1, M2, M3, M4, M5, minimum, maximum

    def __init__(self, init=None):
        self.clear()

        if init is not None:
            if isinstance(init, Accumulator):
                init.copy(out=self)
            elif hasattr(init, '__getitem__'):
                self.from_list(init)

    def clear(self):
        self.n = 0
        self.M1 = self.M2 = self.M3 = self.M4 = self.M5 = 0.0
        self.minimum = float('inf')
        self.maximum = float('-inf')

    def from_list(self, lst):
        if hasattr(lst, 'ravel'):
            lst = lst.ravel()
        self.n = len(lst)
        self.minimum = min(lst)
        self.maximum = max(lst)
        self.M1 = scipy.mean(lst)
        self.M2 = self.n * scipy.var(lst)
        self.M3 = scipy.stats.skew(lst)*cymath.pow(self.M2, 1.5)
        self.M3 *= cymath.sqrt(1.*self.n)
        self.M4 = (scipy.stats.kurtosis(lst) + 3.) * (self.M2*self.M2) / self.n
        self.M5 = sum(lst)

    def copy(self, out=None):
        if out is None:
            out = Accumulator()
        out.n = self.n
        out.M1 = self.M1
        out.M2 = self.M2
        out.M3 = self.M3
        out.M4 = self.M4
        out.M5 = self.M5
        out.minimum = self.minimum
        out.maximum = self.maximum
        return out

    def push(self, x):
        cdef double delta, delta_n, delta_n2, term1
        cdef long long n1 = self.n
        self.n += 1
        cdef long long n = self.n
        delta = x - self.M1
        delta_n = delta / n
        delta_n2 = delta_n * delta_n
        term1 = delta * delta_n * n1
        self.M1 += delta_n
        self.M4 += term1 * delta_n2 * (n * n - 3 * n + 3)
        self.M4 += 6 * delta_n2 * self.M2 - 4 * delta_n * self.M3
        self.M3 += term1 * delta_n * (n - 2) - 3 * delta_n * self.M2
        self.M2 += term1
        self.M5 += x
        self.minimum = min(self.minimum, x)
        self.maximum = max(self.maximum, x)
        return self

    def __add__(a, b):
        combined = Accumulator()

        combined.n = a.n + b.n

        cdef double delta = b.M1 - a.M1
        cdef double delta2 = delta*delta
        cdef double delta3 = delta*delta2
        cdef double delta4 = delta2*delta2
        cdef double temp

        combined.M1 = (a.n*a.M1 + b.n*b.M1) / combined.n
        combined.M2 = a.M2 + b.M2 + delta2 * a.n * b.n / combined.n

        combined.M3 = a.M3 + b.M3 + delta3 * a.n * b.n
        combined.M3 *= (a.n - b.n) / (combined.n*combined.n)
        combined.M3 += 3.0*delta * (a.n*b.M2 - b.n*a.M2) / combined.n

        combined.M4 = a.M4 + b.M4
        temp = delta4*a.n*b.n * (a.n*a.n - a.n*b.n + b.n*b.n)
        temp /= (combined.n*combined.n*combined.n)
        combined.M4 += temp
        temp = 6.0*delta2 * (a.n*a.n*b.M2 + b.n*b.n*a.M2)
        temp /= (combined.n*combined.n)
        combined.M4 += temp
        combined.M4 += 4.0*delta*(a.n*b.M3 - b.n*a.M3) / combined.n

        combined.M5 = a.M5 + b.M5
        combined.minimum = min(a.minimum, b.minimum)
        combined.maximum = max(a.maximum, b.maximum)

        return combined

    def __iadd__(a, b):
        a = a + b
        return a

    def __len__(self):
        return self.n

    @property
    def size(self):
        return self.n

    def min(self):
        return self.minimum

    def max(self):
        return self.maximum

    def mean(self):
        return self.M1

    def var(self, ddof=0):
        return self.M2 / (self.n - ddof)

    def std(self):
        return cymath.sqrt(self.M2 / self.n)

    def skew(self):
        return cymath.sqrt(1. * self.n) * self.M3 / cymath.pow(self.M2, 1.5)

    def kurtosis(self, fisher=True):
        return self.n*self.M4 / (self.M2*self.M2) - (3.0 if fisher else 0.0)

    def sum(self):
        return self.M5

    def bayes_mvs(self, alpha=0.9):
        """
        Bayes approximations to confidence intervals from
        scipy.stats.bayes_mvs.
        """
        
        cdef double xbar, C, fac, val
        cdef long long n, nm1
        if alpha >= 1 or alpha <= 0:
            raise ValueError(
                "0 < alpha < 1 is required, but alpha=%s was given." % alpha)

        n = len(self)
        if n < 2:
            raise ValueError("Need at least 2 data-points.")
        xbar = self.mean()
        C = self.var()
        if n > 1000:  # gaussian approximations for large n
            md = scipy.stats.distributions.norm(loc=xbar, scale=cymath.sqrt(C/n))
            sd = scipy.stats.distributions.norm(loc=cymath.sqrt(C), scale=cymath.sqrt(C/(2.*n)))
            vd = scipy.stats.distributions.norm(loc=C, scale=cymath.sqrt(2.0/n)*C)
        else:
            nm1 = n-1
            fac = n*C/2.
            val = nm1/2.
            md = scipy.stats.distributions.t(nm1, loc=xbar, scale=cymath.sqrt(C/nm1))
            sd = scipy.stats.distributions.gengamma(val, -2, scale=cymath.sqrt(fac))
            vd = scipy.stats.distributions.invgamma(val, scale=fac)
        return tuple((x.mean(), x.interval(alpha)) for x in [md, vd, sd])
