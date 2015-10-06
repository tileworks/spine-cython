from cpython cimport bool
from sys import maxsize as max_integer

from spine.animation.animation cimport binary_search
from spine.animation.timeline cimport Timeline
from spine.skeleton.skeleton cimport Skeleton
from spine.bone cimport Bone

cdef long MAX_INTEGER = max_integer


cdef class FlipXTimeline(Timeline):

    def __init__(self, frame_count):
        self.frames = [0.0] * (frame_count << 1)
        self.bone_index = 0

    def get_frame_count(self):
        return len(self.frames) >> 1

    def set_frame(self, frame_index, time, flip):
        frame_index <<= 1
        frames = self.frames
        frames[frame_index] = time
        frames[frame_index + 1] = 1 if flip else 0

    cpdef apply(FlipXTimeline self, Skeleton skeleton, 
                float last_time, float time, list fired_events, float alpha):
        
        cdef list frames = self.frames

        if time < frames[0] and last_time > time:
            self.apply(skeleton, last_time, MAX_INTEGER, None, 0)
            return
        elif last_time > time:
            last_time = -1

        cdef:
            int frames_count = len(frames)
            int frame_index = frames_count - 2

        if time >= frames[frame_index]:
            frame_index = binary_search(frames, time, 2) - 2

        if frames[frame_index] < last_time:
            return

        self.set_flip(skeleton.bones[self.bone_index],
                      frames[frame_index + 1] != 0)

    cpdef set_flip(FlipXTimeline self, Bone bone, bool flip):
        bone.flip_x = flip
