from spine.animation.timeline cimport Timeline
from spine.skeleton.skeleton cimport Skeleton


cdef class DrawOrderTimeline(Timeline):

    cdef public list frames
    cdef public list draw_orders

    cpdef apply(DrawOrderTimeline self, Skeleton skeleton,
                float last_time, float time, list fired_events, float alpha)
