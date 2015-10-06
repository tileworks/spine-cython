from spine.animation.curvetimeline cimport CurveTimeline
from spine.skeleton.skeleton cimport Skeleton


cdef class RotateTimeline(CurveTimeline):

    cdef public list frames
    cdef public int bone_index

    cpdef apply(RotateTimeline self, Skeleton skeleton,
                float last_time, float time, list fired_events, float alpha)