from spine.attachment.attachment cimport Attachment
from spine.attachment.attachment import AttachmentType
from spine.bone cimport Bone


cdef class BoundingBoxAttachment(Attachment):

    def __init__(self, name):
        super(BoundingBoxAttachment, self).__init__(name)
        self.type = AttachmentType.boundingbox
        self.vertices = []

    # world_vertices must have at least the same length
    # as this attachment's vertices.
    cpdef compute_world_vertices(BoundingBoxAttachment self,
                                 float x, float y,
                                 Bone bone, list world_vertices):
        cdef:
            float m00, m01, m10, m11, px, py
            list vertices = self.vertices
            int vertices_count = len(vertices)
            int i = 0

        x += bone.world_x
        y += bone.world_y
        m00, m01, m10, m11 = bone.m00, bone.m01, bone.m10, bone.m11
        while i < vertices_count:
            px = vertices[i]
            py = vertices[i + 1]
            world_vertices[i] = px * m00 + py * m01 + x
            world_vertices[i + 1] = px * m10 + py * m11 + y
            i += 2
