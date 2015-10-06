cdef class EventData(object):

    cdef public basestring name
    cdef public int int_value
    cdef public float float_value
    cdef public basestring string_value


cdef class Event(object):

    cdef public EventData data
    cdef public int int_value
    cdef public float float_value
    cdef public basestring string_value
