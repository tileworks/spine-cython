cdef class TrackEntry(object):

    def __init__(self):
        self.next = None
        self.previous = None
        self.animation = None
        self.loop = False
        self.delay = 0.0
        self.time = 0.0
        self.last_time = -1.0
        self.end_time = 0.0
        self.time_scale = 1.0
        self.mix_time = 0.0
        self.mix_duration = 0.0
        self.mix = 1.0
        self.on_start = None
        self.on_end = None
        self.on_complete = None
        self.on_event = None
