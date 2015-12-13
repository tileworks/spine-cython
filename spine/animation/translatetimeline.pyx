from spine.animation.curvetimeline cimport CurveTimeline
from spine.animation.animation cimport binary_search
from spine.skeleton.skeleton cimport Skeleton
from spine.bone cimport Bone


cdef:
    int PREV_FRAME_TIME = -3
    int FRAME_X = 1
    int FRAME_Y = 2


cdef class TranslateTimeline(CurveTimeline):

    def __init__(self, frame_count):
        super(TranslateTimeline, self).__init__(frame_count)
        self.frames = [0.0] * frame_count * 3
        self.bone_index = 0

    def get_frame_count(self):
        return len(self.frames) / 3

    def set_frame(self, frame_index, time, x, y):
        frame_index *= 3
        frames = self.frames
        frames[frame_index] = time
        frames[frame_index + 1] = x
        frames[frame_index + 2] = y

    cpdef apply(TranslateTimeline self, Skeleton skeleton,
                float last_time, float time, list fired_events, float alpha):
        cdef list frames = self.frames
        if time < frames[0]:
            return

        cdef:
            Bone bone = skeleton.bones[self.bone_index]
            int frames_count = len(frames)

        if time >= frames[frames_count + PREV_FRAME_TIME]:
            bone.x += ((bone.data.x + frames[frames_count - 2] - bone.x)
                       * alpha)
            bone.y += ((bone.data.y + frames[frames_count - 1] - bone.y)
                       * alpha)
            return

        cdef:
            int frame_index = binary_search(frames, time, 3)
            float prev_frame_x = frames[frame_index - 2]
            float prev_frame_y = frames[frame_index - 1]
            float frame_time = frames[frame_index]
            float percent = (1 - (time - frame_time) / 
                              (frames[frame_index + PREV_FRAME_TIME] -
                               frame_time))
        percent = self.get_curve_percent(frame_index / 3 - 1, percent)
        bone.x += (bone.data.x + prev_frame_x +
                   (frames[frame_index + FRAME_X] - prev_frame_x) *
                   percent - bone.x) * alpha
        bone.y += (bone.data.y + prev_frame_y +
                   (frames[frame_index + FRAME_Y] - prev_frame_y) *
                   percent - bone.y) * alpha
