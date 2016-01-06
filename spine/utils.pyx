from cython cimport cdivision
from libc.math cimport M_PI


@cdivision(True)
cdef inline float radians(float degrees):
    return degrees * M_PI / 180.0


@cdivision(True)
cdef inline float degrees(float radians):
    return radians * 180.0 / M_PI
