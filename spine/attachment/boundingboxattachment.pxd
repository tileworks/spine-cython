from spine.attachment.attachment cimport Attachment
from spine.bone cimport Bone


cdef class BoundingBoxAttachment(Attachment):

    cdef public list vertices

    cpdef compute_world_vertices(BoundingBoxAttachment self,
                                 float x, float y,
                                 Bone bone, list world_vertices)
