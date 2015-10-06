from spine.animation.animation cimport binary_search1
from spine.animation.curvetimeline cimport CurveTimeline
from spine.skeleton.skeleton cimport Skeleton
from spine.slot cimport Slot


cdef class FfdTimeline(CurveTimeline):

    def __init__(self, frame_count):
        super(FfdTimeline, self).__init__(frame_count)
        self.frames = [0.0] * frame_count
        self.frame_vertices = [[0.0]] * frame_count
        self.slot_index = 0
        self.attachment = None

    def get_frame_count(self):
        return len(self.frames)

    def set_frame(self, frame_index, time, vertices):
        self.frames[frame_index] = time
        self.frame_vertices[frame_index] = vertices

    cpdef apply(FfdTimeline self, Skeleton skeleton,
                float last_time, float time, list fired_events, float alpha):
        cdef Slot slot = skeleton.slots[self.slot_index]
        if slot.attachment != self.attachment:
            return
        cdef list frames = self.frames
        if time < frames[0]:
            return

        cdef:
            list frame_vertices = self.frame_vertices
            int vertex_count = len(frame_vertices[0])
            list vertices = slot.attachment_vertices
            int last_frame_index, i
            list last_vertices

        if len(vertices) != vertex_count:
            alpha = 1.0

        if len(vertices) < vertex_count:
            vertices.extend([0.0] * (vertex_count - len(vertices)))
        elif len(vertices) > vertex_count:
            vertices[:] = vertices[0:vertex_count]

        last_frame_index = len(frames) - 1
        if time >= frames[last_frame_index]:
            last_vertices = frame_vertices[last_frame_index]
            if alpha < 1.0:
                i = 0
                while i < vertex_count:
                    vertices[i] += (last_vertices[i] - vertices[i]) * alpha
                    i += 1
            else:
                i = 0
                while i < vertex_count:
                    vertices[i] = last_vertices[i]
                    i += 1
            return

        # Interpolate between the previous frame and the current frame.
        cdef:
            int frame_index = binary_search1(frames, time)
            float frame_time = frames[frame_index]
            float percent, prev
            list prev_vertices, next_vertices

        last_frame_index = frame_index - 1
        percent = (1 - (time - frame_time) /
                   (frames[last_frame_index] - frame_time))
        percent = self.get_curve_percent(last_frame_index, percent)

        prev_vertices = frame_vertices[last_frame_index]
        next_vertices = frame_vertices[frame_index]

        if alpha < 1.0:
            i = 0
            while i < vertex_count:
                prev = prev_vertices[i]
                vertices[i] += (prev + (next_vertices[i] - prev) *
                                percent - vertices[i]) * alpha
                i += 1
        else:
            i = 0
            while i < vertex_count:
                prev = prev_vertices[i]
                vertices[i] = prev + (next_vertices[i] - prev) * percent
                i += 1
