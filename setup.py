from setuptools import setup, Extension
from Cython.Build import cythonize

setup(
    name = 'pystats',
    version = '0.1dev',
    ext_modules = cythonize(
        Extension(
           "pystats",
           sources=["pystats.pyx", "RunningStats.cpp"], 
           language="c++",
        )
    )
)
