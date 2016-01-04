from spine.skeleton.skeleton cimport Skeleton


cdef class AnimationState(object):

    cdef public object data
    cdef public list tracks
    cdef public list events
    cdef public object on_start
    cdef public object on_end
    cdef public object on_complete
    cdef public object on_event
    cdef public float time_scale

    cpdef update(AnimationState self, float dt)
    cpdef apply(AnimationState self, Skeleton skeleton)
    cpdef clear_tracks(AnimationState self)
    cpdef clear_track(AnimationState self, int track_index)
