cdef class SkeletonData(object):

    cdef public list bones
    cdef public list slots
    cdef public list skins
    cdef public list events
    cdef public list animations
    cdef public list ik_constraints
    cdef public basestring name
    cdef public object default_skin
    cdef public int width
    cdef public int height
    cdef public basestring version
    cdef public basestring hash
