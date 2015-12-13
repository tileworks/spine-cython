from cpython cimport bool

from spine.animation.timeline cimport Timeline
from spine.skeleton.skeleton cimport Skeleton
from spine.bone cimport Bone

cdef class FlipXTimeline(Timeline):

    cdef public list frames
    cdef public int bone_index

    cpdef apply(FlipXTimeline self, Skeleton skeleton,
                float last_time, float time, list fired_events, float alpha)

    cpdef set_flip(FlipXTimeline self, Bone bone, bool flip)
