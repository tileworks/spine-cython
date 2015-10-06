from spine.attachment.attachment cimport Attachment
from spine.bone cimport BoneData, Bone


cdef class SlotData(object):

    cdef public basestring name
    cdef public BoneData bone_data
    cdef public float r
    cdef public float g
    cdef public float b
    cdef public float a
    cdef public basestring attachment_name
    cdef public int blend_mode


cdef class Slot(object):

    cdef public SlotData data
    cdef public Bone bone
    cdef public float r
    cdef public float g
    cdef public float b
    cdef public float a
    cdef float _attachment_time
    cdef public Attachment attachment
    cdef public list attachment_vertices
