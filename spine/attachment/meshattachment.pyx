from spine.attachment.attachment cimport Attachment
from spine.attachment.attachment import AttachmentType
from spine.skeleton.skeleton cimport Skeleton
from spine.bone cimport Bone
from spine.slot cimport Slot


cdef class MeshAttachment(Attachment):

    def __init__(self, name):
        super(MeshAttachment, self).__init__(name)
        self.type = AttachmentType.mesh
        self.vertices = []
        self.uvs = []
        self.region_uvs = []
        self.triangles = []
        self.hull_length = 0
        self.r = 1.0
        self.g = 1.0
        self.b = 1.0
        self.a = 1.0
        self.path = None
        self.renderer_object = None
        self.region_u = 0.0
        self.region_v = 0.0
        self.region_u2 = 0.0
        self.region_v2 = 0.0
        self.region_rotate = False
        self.region_offset_x = 0.0
        self.region_offset_y = 0.0
        self.region_width = 0.0
        self.region_height = 0.0
        self.region_original_width = 0.0
        self.region_original_height = 0.0
        self.edges = []
        self.width = 0.0
        self.height = 0.0

    def update_uvs(self):
        region_u = self.region_u
        region_v = self.region_v
        width = self.region_u2 - region_u
        height = self.region_v2 - region_v
        region_uvs = self.region_uvs
        uvs = self.uvs
        uvs_count = len(region_uvs)
        if not uvs or len(uvs) != uvs_count:
            uvs[:] = [0.0] * uvs_count
        i = 0
        if self.region_rotate:
            while i < uvs_count:
                uvs[i] = region_u + region_uvs[i + 1] * width
                uvs[i + 1] = region_v + height - region_uvs[i] * height
                i += 2
        else:
            while i < uvs_count:
                uvs[i] = region_u + region_uvs[i] * width
                uvs[i + 1] = region_v + region_uvs[i + 1] * height
                i += 2

    cpdef compute_world_vertices(MeshAttachment self, Slot slot,
                                 list world_vertices):
        cdef:
            float m00, m01, m10, m11, vx, vy
            Bone bone = slot.bone
            Skeleton skeleton = bone.skeleton
            float x = skeleton.x + bone.world_x
            float y = skeleton.y + bone.world_y
            list vertices = self.vertices
            int vertices_count = len(vertices)
            int i, delta
        m00, m01, m10, m11 = bone.m00, bone.m01, bone.m10, bone.m11
        if len(slot.attachment_vertices) == vertices_count:
            vertices = slot.attachment_vertices
        delta = len(world_vertices) - vertices_count
        if delta < 0:
            for i in range(-delta):
                world_vertices.append(0.0)
        elif delta > 0:
            del world_vertices[vertices_count:]
        i = 0
        while i < vertices_count:
            vx = vertices[i]
            vy = vertices[i + 1]
            world_vertices[i] = vx * m00 + vy * m01 + x
            world_vertices[i + 1] = vx * m10 + vy * m11 + y
            i += 2

    cpdef compute_world_vertices_uvs(MeshAttachment self, Slot slot,
                                     list world_vertices):
        cdef:
            float m00, m01, m10, m11, vx, vy
            Bone bone = slot.bone
            Skeleton skeleton = bone.skeleton
            float x = skeleton.x + bone.world_x
            float y = skeleton.y + bone.world_y
            list uvs = self.uvs
            list vertices = self.vertices
            int vertices_count = len(vertices)
            int i, j, delta
        m00, m01, m10, m11 = bone.m00, bone.m01, bone.m10, bone.m11
        if len(slot.attachment_vertices) == vertices_count:
            vertices = slot.attachment_vertices
        vertices_count <<= 1
        delta = len(world_vertices) - vertices_count
        if delta < 0:
            for i in range(-delta):
                world_vertices.append(0.0)
        elif delta > 0:
            del world_vertices[vertices_count:]
        i = j = 0
        while i < vertices_count:
            vx = vertices[j]
            vy = vertices[j + 1]
            world_vertices[i] = vx * m00 + vy * m01 + x
            world_vertices[i + 1] = vx * m10 + vy * m11 + y
            world_vertices[i + 2] = uvs[j]
            world_vertices[i + 3] = uvs[j + 1]
            i += 4
            j += 2
