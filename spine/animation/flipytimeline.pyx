from cpython cimport bool

from spine.animation.flipxtimeline cimport FlipXTimeline
from spine.bone cimport Bone


cdef class FlipYTimeline(FlipXTimeline):

    cpdef set_flip(FlipYTimeline self, Bone bone, bool flip):
        bone.flip_y = flip
