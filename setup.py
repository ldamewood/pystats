#!/usr/bin/env python
from setuptools import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

ext_modules = [Extension("pystats", [ "pystats.pyx", "RunningStats.cpp"], language="c++")]
cmdclass = {'build_ext': build_ext}

setup(name = 'pystats',
      version = '0.1dev',
      cmdclass = cmdclass,
      ext_modules = ext_modules)
