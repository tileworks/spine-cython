from spine.animation.curvetimeline cimport CurveTimeline
from spine.skeleton.skeleton cimport Skeleton


cdef class IkConstraintTimeline(CurveTimeline):

    cdef public list frames
    cdef public int ik_constraint_index

    cpdef apply(IkConstraintTimeline self, Skeleton skeleton,
                float last_time, float time, list fired_events, float alpha)
