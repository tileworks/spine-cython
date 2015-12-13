from spine.animation.curvetimeline cimport CurveTimeline


cdef class TranslateTimeline(CurveTimeline):

    cdef public list frames
    cdef public int bone_index
