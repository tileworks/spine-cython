from spine.animation.timeline cimport Timeline
from spine.skeleton.skeleton cimport Skeleton


cdef class EventTimeline(Timeline):

    cdef public list frames
    cdef public list events

    cpdef apply(EventTimeline self, Skeleton skeleton,
                float last_time, float time, list fired_events, float alpha)
