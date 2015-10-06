from spine.animation.curvetimeline cimport CurveTimeline
from spine.skeleton.skeleton cimport Skeleton


cdef class TranslateTimeline(CurveTimeline):

    cdef public list frames
    cdef public int bone_index