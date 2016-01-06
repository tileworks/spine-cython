from cpython cimport bool

from spine.skeleton.skeleton cimport Skeleton


cdef class Animation(object):

    cdef public basestring name
    cdef public list timelines
    cdef public float duration

    cpdef apply(Animation self, Skeleton skeleton,
                float last_time, float time, bool loop, list events)

    cpdef mix(Animation self, Skeleton skeleton, float last_time, float time,
              bool loop, list events, float alpha)


cdef int binary_search(list values, float target, int step)
cdef int binary_search1(list values, float target)
cdef int linear_search(list values, float target, int step)
