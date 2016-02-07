from cpython cimport bool

from spine.animation.timeline cimport Timeline
from spine.skeleton.skeleton cimport Skeleton


cdef class Animation(object):

    def __init__(self, name, timelines, duration):
        self.name = name
        self.timelines = timelines
        self.duration = duration

    cpdef apply(Animation self, Skeleton skeleton,
                float last_time, float time, bool loop, list events):
        cdef:
            float duration = self.duration
            Timeline timeline
        if loop is True and duration != 0.0:
            time %= duration
            last_time %= duration
        for timeline in self.timelines:
            timeline.apply(skeleton, last_time, time, events, 1.0)

    cpdef mix(Animation self, Skeleton skeleton, float last_time, float time,
              bool loop, list events, float alpha):
        cdef:
            float duration = self.duration
            Timeline timeline
        duration = self.duration
        if loop is True and duration != 0.0:
            time %= duration
            last_time %= duration
        for timeline in self.timelines:
            timeline.apply(skeleton, last_time, time, events, alpha)


cdef inline int binary_search(list values, float target, int step):
    cdef:
        int low = 0
        int high = len(values) / step - 2
        int current
    if high == 0:
        return step
    current = high >> 1
    while True:
        if values[(current + 1) * step] <= target:
            low = current + 1
        else:
            high = current
        if low == high:
            return (low + 1) * step
        current = (low + high) >> 1


cdef inline int binary_search1(list values, float target):
    cdef:
        int low = 0
        int high = len(values) - 2
        int current
    if high == 0:
        return 1
    current = high >> 1
    while True:
        if values[current + 1] <= target:
            low = current + 1
        else:
            high = current
        if low == high:
            return low + 1
        current = (low + high) >> 1


cdef inline int linear_search(list values, float target, int step):
    cdef:
        int index = 0
        int last = len(values) - step
    while index <= last:
        if values[index] > target:
            return index
        index += step
    return -1
