from spine.animation.timeline cimport Timeline


cdef class CurveTimeline(Timeline):

    cdef public list curves

    cpdef float get_curve_percent(CurveTimeline self,
                                  int frame_index, float percent)
