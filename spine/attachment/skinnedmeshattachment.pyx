from spine.attachment.attachment cimport Attachment
from spine.attachment.attachment import AttachmentType
from spine.skeleton.skeleton cimport Skeleton
from spine.bone cimport Bone
from spine.slot cimport Slot


cdef class SkinnedMeshAttachment(Attachment):

    def __init__(self, name):
        super(SkinnedMeshAttachment, self).__init__(name)
        self.type = AttachmentType.skinnedmesh
        self.bones = []
        self.weights = []
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
        region_uvs_count = len(region_uvs)
        if not uvs or len(uvs) != region_uvs_count:
            uvs[:] = [0.0] * region_uvs_count
        i = 0
        if self.region_rotate:
            while i < region_uvs_count:
                uvs[i] = region_u + region_uvs[i + 1] * width
                uvs[i + 1] = region_v + height - region_uvs[i] * height
                i += 2
        else:
            while i < region_uvs_count:
                uvs[i] = region_u + region_uvs[i] * width
                uvs[i + 1] = region_v + region_uvs[i + 1] * height
                i += 2

    cpdef compute_world_vertices(SkinnedMeshAttachment self, Slot slot,
                                 list world_vertices):
        cdef:
            Bone bone
            Skeleton skeleton = slot.bone.skeleton
            list skeleton_bones = skeleton.bones
            float x = skeleton.x
            float y = skeleton.y
            list uvs = self.uvs
            list weights = self.weights
            list bones = self.bones
            list ffd = slot.attachment_vertices
            int w, v, b, f, nn, delta
            int bones_count = len(bones)
            float wx, wy, weight
            int vertices_count = len(uvs)
        delta = len(world_vertices) - vertices_count
        if delta < 0:
            for i in range(-delta):
                world_vertices.append(0.0)
        elif delta > 0:
            del world_vertices[vertices_count:]
        w = v = b = f = 0
        if not slot.attachment_vertices:
            while v < bones_count:
                wx = 0.0
                wy = 0.0
                nn = bones[v] + v + 1
                v += 1
                while v < nn:
                    bone = skeleton_bones[bones[v]]
                    vx = weights[b]
                    vy = weights[b + 1]
                    weight = weights[b + 2]
                    wx += ((vx * bone.m00 + vy * bone.m01 + bone.world_x) *
                           weight)
                    wy += ((vx * bone.m10 + vy * bone.m11 + bone.world_y) *
                           weight)
                    b += 3
                    v += 1
                world_vertices[w] = wx + x
                world_vertices[w + 1] = wy + y
                w += 2
        else:
            ffd = slot.attachment_vertices
            while v < bones_count:
                wx = 0
                wy = 0
                nn = bones[v] + v + 1
                v += 1
                while v < nn:
                    bone = skeleton_bones[bones[v]]
                    vx = weights[b] + ffd[f]
                    vy = weights[b + 1] + ffd[f + 1]
                    weight = weights[b + 2]
                    wx += ((vx * bone.m00 + vy * bone.m01 + bone.world_x) *
                           weight)
                    wy += ((vx * bone.m10 + vy * bone.m11 + bone.world_y) *
                           weight)
                    f += 2
                    b += 3
                    v += 1
                world_vertices[w] = wx + x
                world_vertices[w + 1] = wy + y
                w += 2

    cpdef compute_world_vertices_uvs(SkinnedMeshAttachment self, Slot slot,
                                     list world_vertices):
        cdef:
            Bone bone
            Skeleton skeleton = slot.bone.skeleton
            list skeleton_bones = skeleton.bones
            float x = skeleton.x
            float y = skeleton.y
            list uvs = self.uvs
            list weights = self.weights
            list bones = self.bones
            list ffd = slot.attachment_vertices
            int w, v, b, f, j, nn, delta
            int bones_count = len(bones)
            float wx, wy, weight
            int vertices_count = len(uvs) << 1
        delta = len(world_vertices) - vertices_count
        if delta < 0:
            for i in range(-delta):
                world_vertices.append(0.0)
        elif delta > 0:
            del world_vertices[vertices_count:]
        w = v = b = f = j = 0
        if not ffd:
            while v < bones_count:
                wx = 0.0
                wy = 0.0
                nn = bones[v] + v + 1
                v += 1
                while v < nn:
                    bone = skeleton_bones[bones[v]]
                    vx = weights[b]
                    vy = weights[b + 1]
                    weight = weights[b + 2]
                    wx += ((vx * bone.m00 + vy * bone.m01 + bone.world_x) *
                           weight)
                    wy += ((vx * bone.m10 + vy * bone.m11 + bone.world_y) *
                           weight)
                    b += 3
                    v += 1
                world_vertices[w] = wx + x
                world_vertices[w + 1] = wy + y
                world_vertices[w + 2] = uvs[j]
                world_vertices[w + 3] = uvs[j + 1]
                w += 4
                j += 2
        else:
            while v < bones_count:
                wx = 0
                wy = 0
                nn = bones[v] + v + 1
                v += 1
                while v < nn:
                    bone = skeleton_bones[bones[v]]
                    vx = weights[b] + ffd[f]
                    vy = weights[b + 1] + ffd[f + 1]
                    weight = weights[b + 2]
                    wx += ((vx * bone.m00 + vy * bone.m01 + bone.world_x) *
                           weight)
                    wy += ((vx * bone.m10 + vy * bone.m11 + bone.world_y) *
                           weight)
                    f += 2
                    b += 3
                    v += 1
                world_vertices[w] = wx + x
                world_vertices[w + 1] = wy + y
                world_vertices[w + 2] = uvs[j]
                world_vertices[w + 3] = uvs[j + 1]
                w += 4
                j += 2
