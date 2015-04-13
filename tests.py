from nose.tools import assert_equal

import numpy as np
import pystats
import scipy.stats as stats


def check_same(a, b):
    assert_equal(a.size, b.size)
    assert_equal(a.min(), b.min())
    assert_equal(a.max(), b.max())
    assert_equal(a.mean(), b.mean())
    assert_equal(a.std(), b.std())
    assert_equal(a.sum(), b.sum())
    for i in range(3):
        assert_equal(a.var(ddof=i), b.var(ddof=i))


class TestPyStats(object):
    def test_accumulate(self):
        a = pystats.StatsAccumulator()
        for i in xrange(100):
            a.push(i)
        b = np.array(xrange(100))
        check_same(a, b)
        assert_equal(stats.skew(b), a.skew())
        assert_equal(stats.kurtosis(b), a.kurtosis())

    def test_copy(self):
        a = pystats.StatsAccumulator()
        for i in xrange(100):
            a.push(i)
        b = a.copy()
        check_same(a, b)

    def test_add(self):
        a = pystats.StatsAccumulator()
        for i in xrange(100):
            a.push(i)
        b = a.copy()
        c = a + b
        d = np.array(range(100)+range(100))
        check_same(c, d)
        assert_equal(stats.skew(d), c.skew())
        assert_equal(stats.kurtosis(d), c.kurtosis())

    def test_iadd(self):
        a = pystats.StatsAccumulator()
        for i in xrange(100):
            a.push(i)
        b = a.copy()
        d = np.array(range(100)+range(100))
        a += b
        check_same(a, d)

    def test_init1(self):
        a = xrange(10)
        b = pystats.StatsAccumulator(a)
        assert_equal(len(b), 10)

    def test_init2(self):
        a = np.array(xrange(10))
        b = pystats.StatsAccumulator(a)
        assert_equal(len(b), 10)

    def test_init3(self):
        a = pystats.StatsAccumulator()
        for i in xrange(10):
            a.push(i)
        b = pystats.StatsAccumulator(a)
        check_same(a, b)
