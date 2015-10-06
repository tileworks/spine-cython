from cpython cimport bool

from spine.animation.animation cimport Animation


cdef class TrackEntry(object):

    cdef public TrackEntry next
    cdef public TrackEntry previous
    cdef public Animation animation
    cdef public bool loop
    cdef public float delay
    cdef public float time
    cdef public float last_time
    cdef public float end_time
    cdef public float time_scale
    cdef public float mix_time
    cdef public float mix_duration
    cdef public float mix
    cdef public object on_start
    cdef public object on_end
    cdef public object on_complete
    cdef public object on_event
