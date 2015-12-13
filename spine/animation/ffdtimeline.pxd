from spine.animation.curvetimeline cimport CurveTimeline
from spine.skeleton.skeleton cimport Skeleton
from spine.attachment.attachment cimport Attachment


cdef class FfdTimeline(CurveTimeline):

    cdef public list frames
    cdef public list frame_vertices
    cdef public int slot_index
    cdef public Attachment attachment

    cpdef apply(FfdTimeline self, Skeleton skeleton,
                float last_time, float time, list fired_events, float alpha)
