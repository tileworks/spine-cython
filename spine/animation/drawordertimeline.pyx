from spine.animation.animation cimport binary_search1
from spine.animation.timeline cimport Timeline
from spine.skeleton.skeleton cimport Skeleton


cdef class DrawOrderTimeline(Timeline):

    def __init__(self, frame_count):
        self.frames = [0.0] * frame_count
        self.draw_orders = [[0]] * frame_count

    def get_frame_count(self):
        return len(self.frames)

    def set_frame(self, frame_index, time, draw_order):
        self.frames[frame_index] = time
        self.draw_orders[frame_index] = draw_order

    cpdef apply(DrawOrderTimeline self, Skeleton skeleton,
                float last_time, float time, list fired_events, float alpha):
        cdef list frames = self.frames

        if time < frames[0]:
            return

        cdef:
            int i, n
            int frames_count = len(frames)
            int frame_index = frames_count - 1
            list draw_order = skeleton.draw_order
            list slots = skeleton.slots
            list draw_order_to_setup_index = self.draw_orders[frame_index]

        if time < frames[frame_index]:
            frame_index = binary_search1(frames, time) - 1

        if not draw_order_to_setup_index:
            draw_order[0:len(slots)] = slots
        else:
            i = 0
            n = len(draw_order_to_setup_index)
            while i < n:
                draw_order[i] = slots[draw_order_to_setup_index[i]]
                i += 1
