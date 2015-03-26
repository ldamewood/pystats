#ifndef RUNNINGSTATS_H
#define RUNNINGSTATS_H
 
cdef extern from "RunningStats.h":
    cdef cppclass RunningStats:
        RunningStats() except +
        void Clear()
        void Push(double x)
        long long NumDataValues() const
        double Mean() const
        double Variance() const
        double StandardDeviation() const;
        double Skewness() const;
        double Kurtosis() const;
        double Minimum() const;
        double Maximum() const;
        RunningStats* operator+(RunningStats*)
 
# class RunningStats
# {
# public:
#     RunningStats();
#     void Clear();
#     void Push(double x);
#     long long NumDataValues() const;
#     double Mean() const;
#     double Variance() const;
#     double StandardDeviation() const;
#     double Skewness() const;
#     double Kurtosis() const;
#
#     friend RunningStats operator+(const RunningStats a, const RunningStats b);
#     RunningStats& operator+=(const RunningStats &rhs);
#
# private:
#     long long n;
#     double M1, M2, M3, M4;
# };
 
#endif