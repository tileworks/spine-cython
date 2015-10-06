from spine.animation.animation cimport binary_search
from spine.animation.curvetimeline cimport CurveTimeline
from spine.skeleton.skeleton cimport Skeleton
from spine.bone cimport Bone

cdef:
    int PREV_FRAME_TIME = -2
    int FRAME_VALUE = 1


cdef class RotateTimeline(CurveTimeline):

    def __init__(self, frame_count):
        super(RotateTimeline, self).__init__(frame_count)
        self.frames = [0.0] * (frame_count << 1)
        self.bone_index = 0

    def get_frame_count(self):
        return len(self.frames) >> 1

    def set_frame(self, frame_index, time, angle):
        frame_index <<= 1
        frames = self.frames
        frames[frame_index] = time
        frames[frame_index + 1] = angle

    cpdef apply(RotateTimeline self, Skeleton skeleton,
                float last_time, float time, list fired_events, float alpha):
        cdef list frames = self.frames
        if time < frames[0]:
            return

        cdef:
            Bone bone = skeleton.bones[self.bone_index]
            int frames_count = len(frames)
            float amount = 0
        
        if time >= frames[frames_count - 2]:
            amount = (bone.data.rotation
                      + frames[frames_count - 1] - bone.rotation)
            while amount > 180:
                amount -= 360
            while amount < -180:
                amount += 360
            bone.rotation += amount * alpha
            return

        cdef:
            int frame_index = binary_search(frames, time, 2)
            float prev_frame_value = frames[frame_index - 1]
            float frame_time = frames[frame_index]
            float percent = (1 - (time - frame_time) /
                              (frames[frame_index + PREV_FRAME_TIME] -
                               frame_time))
        percent = self.get_curve_percent((frame_index >> 1) - 1, percent)

        amount = frames[frame_index + FRAME_VALUE] - prev_frame_value

        while amount > 180:
            amount -= 360
        while amount < -180:
            amount += 360

        amount = (bone.data.rotation +
                  (prev_frame_value + amount * percent) - bone.rotation)
        while amount > 180:
            amount -= 360
        while amount < -180:
            amount += 360

        bone.rotation += amount * alpha
