from cpython cimport bool

from spine.skeleton.skeleton cimport Skeleton


cdef class BoneData(object):

    cdef public basestring name
    cdef public BoneData parent
    cdef public int length
    cdef public float x
    cdef public float y
    cdef public float rotation
    cdef public float scale_x
    cdef public float scale_y
    cdef public bool inherit_scale
    cdef public bool inherit_rotation
    cdef public bool flip_x
    cdef public bool flip_y


cdef class Bone(object):

    cdef public BoneData data
    cdef public Skeleton skeleton
    cdef public Bone parent
    cdef public float x
    cdef public float y
    cdef public float rotation
    cdef public float rotation_ik
    cdef public float scale_x
    cdef public float scale_y
    cdef public bool flip_x
    cdef public bool flip_y
    cdef public float m00
    cdef public float m01
    cdef public float m10
    cdef public float m11
    cdef public float world_x
    cdef public float world_y
    cdef public float world_rotation
    cdef public float world_scale_x
    cdef public float world_scale_y
    cdef public bool world_flip_x
    cdef public bool world_flip_y

    cpdef world_to_local(Bone self, list world)
    cpdef local_to_world(Bone self, list local)
    cpdef update_world_transform(Bone self)
