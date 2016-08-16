from libc.math cimport cos, sin

from spine.attachment.attachment cimport Attachment
from spine.attachment.attachment import AttachmentType
from spine.skeleton.skeleton cimport Skeleton
from spine.bone cimport Bone
from spine.slot cimport Slot
from spine.utils cimport radians

cdef:
    int X1 = 0
    int Y1 = 1
    int X2 = 2
    int Y2 = 3
    int X3 = 4
    int Y3 = 5
    int X4 = 6
    int Y4 = 7


cdef class RegionAttachment(Attachment):

    def __init__(self, name):
        super(RegionAttachment, self).__init__(name)
        self.offset = [0.0] * 8
        self.uvs = [0.0] * 8
        self.type = AttachmentType.region
        self.x = 0
        self.y = 0
        self.rotation = 0.0
        self.scale_x = 1.0
        self.scale_y = 1.0
        self.width = 0
        self.height = 0
        self.r = 1.0
        self.g = 1.0
        self.b = 1.0
        self.a = 1.0
        self.path = None
        self.renderer_object = None
        self.region_offset_x = 0
        self.region_offset_y = 0
        self.region_width = 0
        self.region_height = 0
        self.region_original_width = 0
        self.region_original_height = 0

    def set_uvs(self, u, v, u2, v2, rotate):
        uvs = self.uvs
        if rotate:
            uvs[X2] = u
            uvs[Y2] = v2
            uvs[X3] = u
            uvs[Y3] = v
            uvs[X4] = u2
            uvs[Y4] = v
            uvs[X1] = u2
            uvs[Y1] = v2
        else:
            uvs[X1] = u
            uvs[Y1] = v2
            uvs[X2] = u
            uvs[Y2] = v
            uvs[X3] = u2
            uvs[Y3] = v
            uvs[X4] = u2
            uvs[Y4] = v2

    def update_offset(self):
        region_scale_x = (self.width / self.region_original_width *
                          self.scale_x)
        region_scale_y = (self.height / self.region_original_height *
                          self.scale_y)
        local_x = (-self.width / 2 * self.scale_x +
                   self.region_offset_x * region_scale_x)
        local_y = (-self.height / 2 * self.scale_y +
                   self.region_offset_y * region_scale_y)
        local_x2 = local_x + self.region_width * region_scale_x
        local_y2 = local_y + self.region_height * region_scale_y
        radians_value = radians(self.rotation)
        cos_value = cos(radians_value)
        sin_value = sin(radians_value)
        local_x_cos_value = local_x * cos_value + self.x
        local_x_sin_value = local_x * sin_value
        local_y_cos_value = local_y * cos_value + self.y
        local_y_sin_value = local_y * sin_value
        local_x2_cos_value = local_x2 * cos_value + self.x
        local_x2_sin_value = local_x2 * sin_value
        local_y2_cos_value = local_y2 * cos_value + self.y
        local_y2_sin_value = local_y2 * sin_value
        offset = self.offset
        offset[X1] = local_x_cos_value - local_y_sin_value
        offset[Y1] = local_y_cos_value + local_x_sin_value
        offset[X2] = local_x_cos_value - local_y2_sin_value
        offset[Y2] = local_y2_cos_value + local_x_sin_value
        offset[X3] = local_x2_cos_value - local_y2_sin_value
        offset[Y3] = local_y2_cos_value + local_x2_sin_value
        offset[X4] = local_x2_cos_value - local_y_sin_value
        offset[Y4] = local_y_cos_value + local_x2_sin_value

    cpdef compute_world_vertices(RegionAttachment self, Slot slot,
                                 list world_vertices):
        cdef:
            float m00, m01, m10, m11
            Bone bone = slot.bone
            Skeleton skeleton = bone.skeleton
            float x = skeleton.x + bone.world_x
            float y = skeleton.y + bone.world_y
            list offset = self.offset
            int delta = len(world_vertices) - 8
        if delta < 0:
            for i in range(-delta):
                world_vertices.append(0.0)
        elif delta > 0:
            del world_vertices[8:]
        m00, m01, m10, m11 = bone.m00, bone.m01, bone.m10, bone.m11
        world_vertices[X1] = offset[X1] * m00 + offset[Y1] * m01 + x
        world_vertices[Y1] = offset[X1] * m10 + offset[Y1] * m11 + y
        world_vertices[X2] = offset[X2] * m00 + offset[Y2] * m01 + x
        world_vertices[Y2] = offset[X2] * m10 + offset[Y2] * m11 + y
        world_vertices[X3] = offset[X3] * m00 + offset[Y3] * m01 + x
        world_vertices[Y3] = offset[X3] * m10 + offset[Y3] * m11 + y
        world_vertices[X4] = offset[X4] * m00 + offset[Y4] * m01 + x
        world_vertices[Y4] = offset[X4] * m10 + offset[Y4] * m11 + y

    cpdef compute_world_vertices_uvs(RegionAttachment self, Slot slot,
                                     list world_vertices):
        cdef:
            float m00, m01, m10, m11
            Bone bone = slot.bone
            Skeleton skeleton = bone.skeleton
            float x = skeleton.x + bone.world_x
            float y = skeleton.y + bone.world_y
            list offset = self.offset
            list uvs = self.uvs
            int delta = len(world_vertices) - 16
        m00, m01, m10, m11 = bone.m00, bone.m01, bone.m10, bone.m11
        if delta < 0:
            for i in range(-delta):
                world_vertices.append(0.0)
        elif delta > 0:
            del world_vertices[16:]
        world_vertices[0] = offset[X1] * m00 + offset[Y1] * m01 + x
        world_vertices[1] = offset[X1] * m10 + offset[Y1] * m11 + y
        world_vertices[2] = uvs[0]
        world_vertices[3] = uvs[1]
        world_vertices[4] = offset[X2] * m00 + offset[Y2] * m01 + x
        world_vertices[5] = offset[X2] * m10 + offset[Y2] * m11 + y
        world_vertices[6] = uvs[2]
        world_vertices[7] = uvs[3]
        world_vertices[8] = offset[X3] * m00 + offset[Y3] * m01 + x
        world_vertices[9] = offset[X3] * m10 + offset[Y3] * m11 + y
        world_vertices[10] = uvs[4]
        world_vertices[11] = uvs[5]
        world_vertices[12] = offset[X4] * m00 + offset[Y4] * m01 + x
        world_vertices[13] = offset[X4] * m10 + offset[Y4] * m11 + y
        world_vertices[14] = uvs[6]
        world_vertices[15] = uvs[7]
