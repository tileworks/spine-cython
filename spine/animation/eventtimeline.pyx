from sys import maxsize as max_integer

from spine.animation.animation cimport binary_search1
from spine.animation.timeline cimport Timeline
from spine.skeleton.skeleton cimport Skeleton

cdef long MAX_INTEGER = max_integer


cdef class EventTimeline(Timeline):

    def __init__(self, frame_count):
        self.frames = [0.0] * frame_count
        self.events = [None] * frame_count

    def get_frame_count(self):
        return len(self.frames)

    def set_frame(self, frame_index, time, event):
        self.frames[frame_index] = time
        self.events[frame_index] = event

    # Fires events for frames > lastTime and <= time.
    cpdef apply(EventTimeline self, Skeleton skeleton,
                float last_time, float time, list fired_events, float alpha):
        if fired_events is None:
            return
        cdef:
            list frames = self.frames
            int frames_count = len(frames)

        if last_time > time:
            # Fire events after last time for looped animations
            self.apply(skeleton, last_time, MAX_INTEGER, fired_events, alpha)
            last_time = -1
        elif last_time >= frames[frames_count - 1]:
            # Last time is after last frame.
            return

        cdef:
            int frame_index = 0
            float frame
            list events = self.events

        if last_time >= frames[0]:
            frame_index = binary_search1(frames, last_time)
            frame = frames[frame_index]
            while frame_index > 0:
                # Fire multiple events with the same frame.
                if frames[frame_index - 1] != frame:
                    break
                frame_index -= 1

        while frame_index < frames_count and time >= frames[frame_index]:
            fired_events.append(events[frame_index])
            frame_index += 1
