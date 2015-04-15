#!/usr/bin/env python
import os
from setuptools import setup, Extension, find_packages

try:
    from Cython.Distutils import build_ext
except ImportError:
    from distutils.command import build_ext
    use_cython = False
else:
    use_cython = True

# Utility function to read the README file.
# Used for the long_description.  It's nice, because now 1) we have a top level
# README file and 2) it's easier to type in the README file than to put a raw
# string in below ...
def read(fname):
    return open(os.path.join(os.path.dirname(__file__), fname)).read()

macros = []
cmdclass={}
if use_cython:
    print("Compiling with Cython")
    ext_modules = [Extension('pystats._accumulator', ["pystats/_accumulator.pyx"], define_macros=macros)]
    cmdclass.update({'build_ext': build_ext})
else:
    ext_modules = [Extension('pystats._accumulator', ['pystats/_accumulator.c'])]

setup(name='pystats',
      version='0.2.dev',
      author="Liam Damewood",
      author_email="liam.physics82@gmail.com",
      description="Statistics Accumulator",
      url="http://github.org/ldamewood/pystats",
      license='MIT',
      cmdclass = cmdclass,
      ext_modules = ext_modules,
      packages=find_packages(exclude=['tests.*']),
      test_suite='nose.collector',
      classifiers = [
        'Development Status :: 3 - Alpha',
        "Topic :: Scientific/Engineering", 
        "Topic :: Utilities",
        "Operating System :: OS Independent",
        "Intended Audience :: Science/Research",
        "Programming Language :: Python",
        "License :: OSI Approved :: MIT License"
      ])
