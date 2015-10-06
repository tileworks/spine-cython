from spine.animation.animation cimport binary_search
from spine.animation.curvetimeline cimport CurveTimeline
from spine.skeleton.skeleton cimport Skeleton
from spine.slot cimport Slot

cdef:
    int PREV_FRAME_TIME = -5
    int FRAME_R = 1
    int FRAME_G = 2
    int FRAME_B = 3
    int FRAME_A = 4


cdef class ColorTimeline(CurveTimeline):

    def __init__(self, frame_count):
        super(ColorTimeline, self).__init__(frame_count)
        self.frames = [0.0] * frame_count * 5
        self.slot_index = 0

    def get_frame_count(self):
        return len(self.frames) / 5

    def set_frame(self, frame_index, time, r, g, b, a):
        frame_index *= 5
        frames = self.frames
        frames[frame_index] = time
        frames[frame_index + 1] = r
        frames[frame_index + 2] = g
        frames[frame_index + 3] = b
        frames[frame_index + 4] = a

    cpdef apply(ColorTimeline self, Skeleton skeleton,
                float last_time, float time, list fired_events, float alpha):

        cdef list frames = self.frames
        if time < frames[0]:
            # Time is before first frame.
            return

        cdef:
            int frames_count = len(frames)
            int i
            float r, g, b, a, percent, frame_time
            float prev_frame_r, prev_frame_g, prev_frame_b, prev_frame_a
            Slot slot

        if time >= frames[frames_count + PREV_FRAME_TIME]:
            # Time is after last frame.
            i = frames_count - 1
            r = frames[i - 3]
            g = frames[i - 2]
            b = frames[i - 1]
            a = frames[i]
        else:
            # Interpolate between the previous frame and the current frame.
            frame_index = binary_search(frames, time, 5)
            prev_frame_r = frames[frame_index - 4]
            prev_frame_g = frames[frame_index - 3]
            prev_frame_b = frames[frame_index - 2]
            prev_frame_a = frames[frame_index - 1]
            frame_time = frames[frame_index]
            percent = (1 - (time - frame_time) /
                       (frames[frame_index + PREV_FRAME_TIME] - frame_time))
            percent = self.get_curve_percent(frame_index / 5 - 1, percent)

            r = prev_frame_r + \
                (frames[frame_index + FRAME_R] - prev_frame_r) * percent
            g = prev_frame_g + \
                (frames[frame_index + FRAME_G] - prev_frame_g) * percent
            b = prev_frame_b + \
                (frames[frame_index + FRAME_B] - prev_frame_b) * percent
            a = prev_frame_a + \
                (frames[frame_index + FRAME_A] - prev_frame_a) * percent

        slot = skeleton.slots[self.slot_index]
        if alpha < 1.0:
            slot.r += (r - slot.r) * alpha
            slot.g += (g - slot.g) * alpha
            slot.b += (b - slot.b) * alpha
            slot.a += (a - slot.a) * alpha
        else:
            slot.r = r
            slot.g = g
            slot.b = b
            slot.a = a
