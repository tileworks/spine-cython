from spine.animation.translatetimeline cimport TranslateTimeline
from spine.skeleton.skeleton cimport Skeleton


cdef class ScaleTimeline(TranslateTimeline):

    cpdef apply(ScaleTimeline self, Skeleton skeleton,
                float last_time, float time, list fired_events, float alpha)