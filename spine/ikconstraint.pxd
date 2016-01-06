from spine.bone cimport Bone, BoneData


cdef class IkConstraintData(object):

    cdef public basestring name
    cdef public list bones
    cdef public BoneData target
    cdef public int bend_direction
    cdef public float mix


cdef class IkConstraint(object):

    cdef public IkConstraintData data
    cdef public float mix
    cdef public int bend_direction
    cdef public list bones
    cdef public Bone target

    cpdef apply(IkConstraint self)


cdef apply1(Bone bone, float target_x, float target_y, float alpha)
cdef apply2(Bone parent, Bone child, float target_x, float target_y,
            int bend_direction, float alpha)
