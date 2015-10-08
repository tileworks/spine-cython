from cpython cimport bool
from sys import maxsize as max_integer

from spine.attachment.attachment import AttachmentType
from spine.attachment.attachment cimport Attachment
from spine.attachment.boundingboxattachment cimport BoundingBoxAttachment
from spine.skeleton.skeleton cimport Skeleton
from spine.slot cimport Slot

cdef long MAX_INTEGER = max_integer


cdef class SkeletonBounds(object):

    def __init__(self):
        self.polygon_pool = []
        self.polygons = []
        self.bounding_boxes = []
        self.min_x = 0
        self.min_y = 0
        self.max_x = 0
        self.max_y = 0

    cpdef update(SkeletonBounds self, Skeleton skeleton, bool update_aabb):
        cdef:
            list slots = skeleton.slots
            float x = skeleton.x
            float y = skeleton.y
            list bounding_boxes = self.bounding_boxes
            list polygon_pool = self.polygon_pool
            list polygons = self.polygons
            Slot slot
            BoundingBoxAttachment bounding_box
            Attachment attachment
            int delta, pool_count, polygon_vertex_count
            list polygon

        del bounding_boxes[:]
        polygon_pool.extend(polygons)
        del polygons[:]

        for slot in slots:
            attachment = slot.attachment
            if attachment.type != AttachmentType.boundingbox:
                continue
            bounding_box = <BoundingBoxAttachment> attachment
            bounding_boxes.append(bounding_box)

            pool_count = len(polygon_pool)
            if pool_count > 0:
                polygon_index = pool_count - 1
                polygon = polygon_pool[polygon_index]
                polygon_pool.pop(polygon_index)
            else:
                polygon = []
            polygons.append(polygon)
            polygon_vertex_count = len(polygon)
            delta = len(bounding_box.vertices) - polygon_vertex_count
            if delta > 0:
                polygon.extend([0.0] * delta)
            elif delta < 0:
                polygon[:] = polygon[0:polygon_vertex_count + delta]
            bounding_box.compute_world_vertices(slot, polygon)

        if update_aabb is True:
            self.aabb_compute()

    cpdef aabb_compute(SkeletonBounds self):
        cdef:
            list polygons = self.polygons
            float min_x = MAX_INTEGER
            float min_y = MAX_INTEGER
            float max_x = -MAX_INTEGER
            float max_y = -MAX_INTEGER
            list vertices
            int i, vertices_count
            float x, y

        for vertices in polygons:
            i = 0
            vertices_count = len(vertices)
            while i < vertices_count:
                x = vertices[i]
                y = vertices[i + 1]
                min_x = min(min_x, x)
                min_y = min(min_y, y)
                max_x = max(max_x, x)
                max_y = max(max_y, y)
                i += 2
        self.min_x = min_x
        self.min_y = min_y
        self.max_x = max_x
        self.max_y = max_y

    cpdef bool aabb_contains_point(SkeletonBounds self, float x, float y):
        """
        Returns True if the axis aligned bounding box contains the point.
        """
        return (self.min_x <= x <= self.max_x and
                self.min_y <= y <= self.max_y)

    cpdef bool aabb_intersects_segment(SkeletonBounds self,
                                       float x1, float y1, float x2, float y2):
        """
        Returns True if the axis aligned bounding box
        intersects the line segment.
        """
        cdef:
            float min_x = self.min_x
            float min_y = self.min_y
            float max_x = self.max_x
            float max_y = self.max_y

        if (x1 <= min_x and x2 <= min_x) or \
           (y1 <= min_y and y2 <= min_y) or \
           (x1 >= max_x and x2 >= max_x) or \
           (y1 >= max_y and y2 > max_y):
            return False
        m = (y2 - y1) / (x2 - x1)

        y = m * (min_x - x1) + y1
        if min_y < y < max_y:
            return True

        y = m * (max_x - x1) + y1
        if min_y < y < max_y:
            return True

        x = (min_y - y1) / m + x1
        if min_x < x < max_x:
            return True

        x = (max_y - y1) / m + x1
        if min_x < x < max_x:
            return True
        return False

    cpdef bool aabb_intersects_skeleton(SkeletonBounds self,
                                        SkeletonBounds bounds):
        """
        Returns True if the axis aligned bounding box
        intersects the axis aligned bounding box of the specified bounds.
        """
        return (self.min_x < bounds.max_x and
                self.max_x > bounds.min_x and
                self.min_y < bounds.max_y and
                self.max_y > bounds.min_y)

    cpdef BoundingBoxAttachment contains_point(SkeletonBounds self,
                                               float x, float y):
        """
        Returns the first bounding box attachment
        that contains the point, or null. When doing many checks,
        it is usually more efficient to only call this method
        if {@link #aabbContainsPoint(float, float)} returns True.
        """
        cdef:
            int i,
            list polygon

        for i, polygon in enumerate(self.polygons):
            if self.polygon_contains_point(polygon, x, y):
                return self.bounding_boxes[i]
        return None

    cpdef BoundingBoxAttachment intersects_segment(SkeletonBounds self,
                                                   float x1, float y1,
                                                   float x2, float y2):
        """
        Returns the first bounding box attachment
        that contains the line segment, or null. When doing many checks,
        it is usually more efficient to only call this method
        if {@link #aabbIntersectsSegment(float, float, float, float)}
        returns True.
        """
        cdef:
            int i
            list polygon

        for i, polygon in enumerate(self.polygons):
            if self.polygon_intersects_segment(polygon, x1, y1, x2, y2):
                return self.bounding_boxes[i]
        return None

    cpdef bool polygon_contains_point(SkeletonBounds self, list polygon,
                                      float x, float y):
        cdef:
            int nn = len(polygon)
            int prev_index = nn - 2
            bool inside = False
            int ii = 0
            float vertex_y, prev_y, vertex_x

        while ii < nn:
            vertex_y = polygon[ii + 1]
            prev_y = polygon[prev_index + 1]
            if vertex_y < y < prev_y or prev_y < y < vertex_y:
                vertex_x = polygon[ii]
                if (vertex_x + (y - vertex_y) / (prev_y - vertex_y)
                   * (polygon[prev_index] - vertex_x) < x):
                    inside = not inside
            prev_index = ii
            ii += 2
        return inside

    cpdef bool polygon_intersects_segment(SkeletonBounds self, list polygon,
                                          float x1, float y1,
                                          float x2, float y2):
        """
        Returns True if the polygon contains the line segment.
        """
        cdef:
            int nn = len(polygon)
            float width12 = x1 - x2
            float height12 = y1 - y2
            float det1 = x1 * y2 - y1 * x2
            float x3 = polygon[nn - 2]
            float y3 = polygon[nn - 1]
            float x4, y4, det2, det3, width34, height34, x, y
            int ii = 0

        while ii < nn:
            x4 = polygon[ii]
            y4 = polygon[ii + 1]
            det2 = x3 * y4 - y3 * x4
            width34 = x3 - x4
            height34 = y3 - y4
            det3 = width12 * height34 - height12 * width34
            x = (det1 * width34 - width12 * det2) / det3
            if (x3 <= x <= x4 or x4 <= x <= x3) and \
               (x1 <= x <= x2 or x2 <= x < x1):
                y = (det1 * height34 - height12 * det2) / det3
                if (y3 <= y <= y4 or y4 <= y <= y4) and \
                   (y1 <= y < y2 or y2 <= y <= y2):
                    return True
            x3 = x4
            y3 = y4
            ii += 2
        return False

    cpdef list get_polygon(SkeletonBounds self,
                           BoundingBoxAttachment attachment):
        try:
            index = self.bounding_boxes.index(attachment)
            return self.polygons[index]
        except ValueError:
            return None

    cpdef float get_width(self):
        return self.max_x - self.min_x

    cpdef float get_height(self):
        return self.max_y - self.min_y
