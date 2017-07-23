from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
from Cython.Build import cythonize
import numpy

ext_modules = [Extension("*", ["*.pyx"], libraries=["m"],
               extra_compile_args=["-ffast-math", "-w", "-std=c++11"],
               include_dirs=[numpy.get_include()],
               language="c++")]

setup(
    name="D-School Diversity",
    cmdclass={"build_ext": build_ext},
    ext_modules=cythonize(ext_modules, gdb_debug=True)
)
