from spine.animation.animation cimport binary_search
from spine.animation.translatetimeline cimport TranslateTimeline
from spine.skeleton.skeleton cimport Skeleton
from spine.bone cimport Bone

cdef:
    int PREV_FRAME_TIME = -3
    int FRAME_X = 1
    int FRAME_Y = 2


cdef class ScaleTimeline(TranslateTimeline):

    cpdef apply(ScaleTimeline self, Skeleton skeleton,
                float last_time, float time, list fired_events, float alpha):
        cdef list frames = self.frames
        if time < frames[0]:
            return

        cdef:
            Bone bone = skeleton.bones[self.bone_index]
            int frames_count = len(frames)

        if time >= frames[frames_count - 3]:
            bone.scale_x += ((bone.data.scale_x *
                             frames[frames_count - 2] - bone.scale_x) * alpha)
            bone.scale_y += ((bone.data.scale_y *
                             frames[frames_count - 1] - bone.scale_y) * alpha)
            return

        # Interpolate between the previous frame and the current frame.
        cdef:
            int frame_index = binary_search(frames, time, 3)
            float prev_frame_x = frames[frame_index - 2]
            float prev_frame_y = frames[frame_index - 1]
            float frame_time = frames[frame_index]
            float percent = (1 - (time - frame_time) /
                              (frames[frame_index + PREV_FRAME_TIME] -
                               frame_time))
        percent = self.get_curve_percent(frame_index / 3 - 1, percent)
        bone.scale_x += (bone.data.scale_x *
                         (prev_frame_x +
                          (frames[frame_index + FRAME_X] -
                           prev_frame_x) * percent) - bone.scale_x) * alpha
        bone.scale_y += (bone.data.scale_y *
                         (prev_frame_y +
                          (frames[frame_index + FRAME_Y] -
                           prev_frame_y) * percent) - bone.scale_y) * alpha
