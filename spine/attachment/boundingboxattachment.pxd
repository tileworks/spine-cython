from spine.attachment.attachment cimport Attachment
from spine.slot cimport Slot


cdef class BoundingBoxAttachment(Attachment):

    cdef public list vertices

    cpdef compute_world_vertices(BoundingBoxAttachment self, Slot slot,
                                 list world_vertices)
