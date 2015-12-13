from spine.animation.curvetimeline cimport CurveTimeline
from spine.skeleton.skeleton cimport Skeleton


cdef class ColorTimeline(CurveTimeline):

    cdef public list frames
    cdef public int slot_index

    cpdef apply(ColorTimeline self, Skeleton skeleton,
                float last_time, float time, list fired_events, float alpha)
