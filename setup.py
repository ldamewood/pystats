#!/usr/bin/env python
from distutils.core import setup
from distutils.extension import Extension

try:
    from Cython.Distutils import build_ext
except ImportError:
    from distutils.command import build_ext
    use_cython = False
else:
    use_cython = True

kwds = {'long_description': open('README.md').read()}

macros = []
cmdclass = {}
if use_cython:
    print("Compiling with Cython")
    ext_modules = [Extension('_accumulator', ["_accumulator.pyx"], define_macros=macros)]
    cmdclass.update({'build_ext': build_ext})
else:
    ext_modules = [Extension('_accumulator', ['_accumulator.c'])]

setup(name='pystats',
      version='0.2.dev',
      author="Liam Damewood",
      description="Statistics Accumulator",
      url="http://github.org/ldamewood/pystats",
      license='The MIT License: http://www.opensource.org/licenses/mit-license.php',
      cmdclass = cmdclass,
      ext_modules = ext_modules,
      py_modules=['pystats'],
      classifiers = [
        'Development Status :: 3 - Alpha',
        "Topic :: Scientific/Engineering", 
        "Topic :: Utilities",
        "Operating System :: OS Independent",
        "Intended Audience :: Science/Research",
        "Programming Language :: Python",
        "License :: OSI Approved :: MIT License"
      ],
      **kwds
      )
