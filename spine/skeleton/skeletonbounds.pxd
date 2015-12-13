from cpython cimport bool

from spine.attachment.boundingboxattachment cimport BoundingBoxAttachment
from spine.skeleton.skeleton cimport Skeleton


cdef class SkeletonBounds(object):

    cdef public list polygon_pool
    cdef public list polygons
    cdef public list bounding_boxes
    cdef public float min_x
    cdef public float min_y
    cdef public float max_x
    cdef public float max_y

    cpdef update(SkeletonBounds self, Skeleton skeleton, bool update_aabb)
    cpdef aabb_compute(SkeletonBounds self)
    cpdef bool aabb_contains_point(SkeletonBounds self, float x, float y)
    cpdef bool aabb_intersects_segment(SkeletonBounds self,
                                       float x1, float y1,
                                       float x2, float y2)

    cpdef bool aabb_intersects_skeleton(SkeletonBounds self,
                                        SkeletonBounds bounds)

    cpdef BoundingBoxAttachment contains_point(SkeletonBounds self,
                                               float x, float y)

    cpdef BoundingBoxAttachment intersects_segment(SkeletonBounds self,
                                                   float x1, float y1,
                                                   float x2, float y2)

    cpdef bool polygon_contains_point(SkeletonBounds self, list polygon,
                                      float x, float y)

    cpdef bool polygon_intersects_segment(SkeletonBounds self, list polygon,
                                          float x1, float y1,
                                          float x2, float y2)

    cpdef list get_polygon(SkeletonBounds self,
                           BoundingBoxAttachment attachment)

    cpdef float get_width(self)
    cpdef float get_height(self)
