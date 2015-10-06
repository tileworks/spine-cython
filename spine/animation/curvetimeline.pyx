from spine.animation.timeline cimport Timeline
from spine.skeleton.skeleton cimport Skeleton

cdef:
    int BEZIER_SEGMENTS = 10
    int BEZIER_SIZE = BEZIER_SEGMENTS * 2 - 1
    int LINEAR = 0
    int STEPPED = 1
    int BEZIER = 2


cdef class CurveTimeline(Timeline):

    def __init__(self, frame_count):
        self.curves = [0] * (frame_count - 1) * BEZIER_SIZE

    cpdef apply(CurveTimeline self, Skeleton skeleton,
                float last_time, float time, list fired_events, float alpha):
        raise NotImplementedError()

    def get_curve_type(self, frame_index):
        return self.curves[frame_index * BEZIER_SIZE]

    def get_frame_count(self):
        return len(self.curves) / BEZIER_SIZE + 1

    def set_linear(self, frame_index):
        index = frame_index * BEZIER_SIZE
        self.curves.extend([0] * (index - len(self.curves) + 1))
        self.curves[index] = LINEAR

    def set_stepped(self, frame_index):
        index = frame_index * BEZIER_SIZE
        self.curves.extend([0] * (index - len(self.curves) + 1))
        self.curves[index] = STEPPED

    def set_curve(self, frame_index, cx1, cy1, cx2, cy2):
        """
        Sets the control handle positions for an interpolation bezier curve
        used to transition from this keyframe to the next.
        cx1 and cx2 are from 0 to 1,
        representing the percent of time between the two keyframes.
        cy1 and cy2 are the percent of the difference
        between the keyframe's values.
        """
        sub_div1 = 1.0 / BEZIER_SEGMENTS
        sub_div2 = sub_div1 ** 2
        sub_div3 = sub_div2 * sub_div1
        pre1 = 3 * sub_div1
        pre2 = 3 * sub_div2
        pre4 = 6 * sub_div2
        pre5 = 6 * sub_div3
        tmp1x = -cx1 * 2 + cx2
        tmp1y = -cy1 * 2 + cy2
        tmp2x = (cx1 - cx2) * 3 + 1
        tmp2y = (cy1 - cy2) * 3 + 1
        dfx = cx1 * pre1 + tmp1x * pre2 + tmp2x * sub_div3
        dfy = cy1 * pre1 + tmp1y * pre2 + tmp2y * sub_div3
        ddfx = tmp1x * pre4 + tmp2x * pre5
        ddfy = tmp1y * pre4 + tmp2y * pre5
        dddfx = tmp2x * pre5
        dddfy = tmp2y * pre5

        i = frame_index * BEZIER_SIZE
        curves = self.curves
        curves[i] = BEZIER
        i += 1
        x = dfx
        y = dfy
        n = i + BEZIER_SIZE - 1
        while i < n:
            curves[i] = x
            curves[i + 1] = y
            dfx += ddfx
            dfy += ddfy
            ddfx += dddfx
            ddfy += dddfy
            x += dfx
            y += dfy
            i += 2

    cpdef float get_curve_percent(CurveTimeline self,
                                  int frame_index, float percent):
        cdef:
            list curves = self.curves
            int i = frame_index * BEZIER_SIZE
            int curve_type = curves[i]
            int n, start
            float x, y, prev_x, prev_y
        
        if percent < 0.0:
            percent = 0.0
        if percent > 1.0:
            percent = 1.0
        if curve_type == LINEAR:
            return percent
        if curve_type == STEPPED:
            return 0

        i += 1
        x = 0
        start = i
        n = i + BEZIER_SIZE - 1
        while i < n:
            x = curves[i]
            if x >= percent:
                if i == start:
                    prev_x = 0
                    prev_y = 0
                else:
                    prev_x = curves[i - 2]
                    prev_y = curves[i - 1]
                return prev_y + (curves[i + 1] - prev_y) * \
                                (percent - prev_x) / (x - prev_x)
            i += 2
        y = curves[i - 1]
        return y + (1 - y) * (percent - x) / (1 - x)
