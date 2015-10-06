cdef class EventData(object):

    def __init__(self, name):
        self.name = name
        self.int_value = 0
        self.float_value = 0.0
        self.string_value = None


cdef class Event(object):

    def __init__(self, event_data):
        self.data = event_data
        self.int_value = 0
        self.float_value = 0.0
        self.string_value = None
