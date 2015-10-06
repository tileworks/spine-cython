from spine.animation.animation cimport binary_search
from spine.animation.curvetimeline cimport CurveTimeline
from spine.ikconstraint cimport IkConstraint
from spine.skeleton.skeleton cimport Skeleton

cdef:
    int PREV_FRAME_TIME = -3
    int PREV_FRAME_MIX = -2
    int PREV_FRAME_BEND_DIRECTION = -1
    int FRAME_MIX = 1


cdef class IkConstraintTimeline(CurveTimeline):

    def __init__(self, frame_count):
        super(IkConstraintTimeline, self).__init__(frame_count)
        self.frames = [0.0] * frame_count * 3
        self.ik_constraint_index = 0

    def get_frame_count(self):
        return len(self.frames) / 3

    def set_frame(self, frame_index, time, mix, bend_direction):
        frame_index *= 3
        frames = self.frames
        frames[frame_index] = time
        frames[frame_index + 1] = mix
        frames[frame_index + 2] = bend_direction

    cpdef apply(IkConstraintTimeline self, Skeleton skeleton,
                float last_time, float time, list fired_events, float alpha):
        cdef:
            list frames = self.frames

        if time < frames[0]:
            return

        cdef:
            int frames_count = len(frames)
            IkConstraint ik_constraint

        ik_constraint = skeleton.ik_constraints[self.ik_constraint_index]
        if time >= frames[frames_count - 3]:
            ik_constraint.mix += (frames[frames_count - 2] -
                                  ik_constraint.mix) * alpha
            ik_constraint.bend_direction = frames[frames_count - 1]
            return

        cdef:
            float mix
            int frame_index = binary_search(frames, time, 3)
            float prev_frame_mix = frames[frame_index + PREV_FRAME_MIX]
            float frame_time = frames[frame_index]
            float percent = (1 - (time - frame_time) /
                             (frames[frame_index + PREV_FRAME_TIME] -
                              frame_time))
        percent = self.get_curve_percent(frame_index / 3 - 1, percent)
        mix = prev_frame_mix + (frames[frame_index + FRAME_MIX] -
                                prev_frame_mix) * percent
        ik_constraint.mix += (mix - ik_constraint.mix) * alpha
        ik_constraint.bend_direction = \
            frames[frame_index + PREV_FRAME_BEND_DIRECTION]
