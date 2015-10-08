from cpython cimport bool

from spine.attachment.attachment cimport Attachment
from spine.slot cimport Slot


cdef class MeshAttachment(Attachment):

    cdef public list vertices
    cdef public list uvs
    cdef public list region_uvs
    cdef public list triangles
    cdef public int hull_length
    cdef public float r
    cdef public float g
    cdef public float b
    cdef public float a
    cdef public basestring path
    cdef public object renderer_object
    cdef public float region_u
    cdef public float region_v
    cdef public float region_u2
    cdef public float region_v2
    cdef public bool region_rotate
    cdef public float region_offset_x
    cdef public float region_offset_y
    cdef public float region_width
    cdef public float region_height
    cdef public float region_original_width
    cdef public float region_original_height
    cdef public list edges
    cdef public float width
    cdef public float height

    cpdef compute_world_vertices(MeshAttachment self, Slot slot,
                                 list world_vertices)

    cpdef compute_world_vertices_z(MeshAttachment self, Slot slot,
                                   list world_vertices)

    cpdef compute_world_vertices_uvs(MeshAttachment self, Slot slot,
                                     list world_vertices)

    cpdef compute_world_vertices_z_uvs(MeshAttachment self, Slot slot,
                                       list world_vertices)
