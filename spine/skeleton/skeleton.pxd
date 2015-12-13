from cpython cimport bool

from spine.skeleton.skeletondata cimport SkeletonData


cdef class Skeleton(object):

    cdef public SkeletonData data
    cdef public list bones
    cdef public list bone_cache
    cdef public list slots
    cdef public list draw_order
    cdef public list ik_constraints
    cdef public object skin
    cdef public float x
    cdef public float y
    cdef public float z
    cdef public float r
    cdef public float g
    cdef public float b
    cdef public float a
    cdef public float time
    cdef public bool flip_x
    cdef public bool flip_y

    cpdef update_world_transform(Skeleton self)
