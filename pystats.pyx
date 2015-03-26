cdef class RunningStatistics:
    cdef RunningStats *thisptr

    def __cinit__(self):
        self.thisptr = new RunningStats()

    def __dealloc(self):
        del self.thisptr

    def clear(self):
        self.thisptr.Clear()

    def __iadd__(self, x):
        self.push(x)
        return self

    def push(self, x):
        self.thisptr.Push(x)

    @property
    def size(self):
        return self.thisptr.NumDataValues()

    @property
    def min(self):
        return self.thisptr.Minimum()
    
    @property
    def max(self):
        return self.thisptr.Maximum()

    @property
    def mean(self):
        return self.thisptr.Mean()

    def var(self, dof = 0):
        return self.variance * (self.size - 1) / (self.size - dof)

    @property
    def variance(self):
        return self.thisptr.Variance()

    @property
    def std(self):
        return self.thisptr.StandardDeviation()

    @property
    def skewness(self):
        return self.thisptr.Skewness()

    @property
    def kertosis(self):
        return self.thisptr.Kurtosis()