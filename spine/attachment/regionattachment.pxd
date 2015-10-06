from spine.attachment.attachment cimport Attachment
from spine.bone cimport Bone


cdef class RegionAttachment(Attachment):

    cdef public list offset
    cdef public list uvs
    cdef public float x
    cdef public float y
    cdef public float rotation
    cdef public float scale_x
    cdef public float scale_y
    cdef public float width
    cdef public float height
    cdef public float r
    cdef public float g
    cdef public float b
    cdef public float a
    cdef public basestring path
    cdef public object renderer_object
    cdef public float region_offset_x
    cdef public float region_offset_y
    cdef public float region_width
    cdef public float region_height
    cdef public float region_original_width
    cdef public float region_original_height

    cpdef compute_vertices(RegionAttachment self,
                           float x, float y,
                           Bone bone, list vertices)

    cpdef compute_vertices_with_uvs(RegionAttachment self,
                                    float x, float y,
                                    Bone bone, list vertices)
