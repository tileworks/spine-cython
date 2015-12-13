from spine.animation.timeline cimport Timeline
from spine.skeleton.skeleton cimport Skeleton


cdef class AttachmentTimeline(Timeline):

    cdef public list frames
    cdef public list attachment_names
    cdef public int slot_index

    cpdef apply(AttachmentTimeline self, Skeleton skeleton,
                float last_time, float time, list fired_events, float alpha)
