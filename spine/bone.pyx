from cpython cimport bool
from libc.math cimport sin, cos

from spine.utils cimport radians


cdef class BoneData(object):

    def __init__(self, name, parent):
        self.name = name
        self.parent = parent
        self.length = 0
        self.x = 0
        self.y = 0
        self.rotation = 0.0
        self.scale_x = 1.0
        self.scale_y = 1.0
        self.inherit_scale = True
        self.inherit_rotation = True
        self.flip_x = False
        self.flip_y = False


cdef class Bone(object):

    y_down = False

    def __init__(self, bone_data, skeleton, parent):
        self.data = bone_data
        self.skeleton = skeleton
        self.parent = parent
        self.x = 0
        self.y = 0
        self.rotation = 0.0
        self.rotation_ik = 0.0
        self.scale_x = 1.0
        self.scale_y = 1.0
        self.flip_x = False
        self.flip_y = False
        self.m00 = 0.0
        self.m01 = 0.0
        self.world_x = 0
        self.m10 = 0.0
        self.m11 = 0.0
        self.world_y = 0
        self.world_rotation = 0.0
        self.world_scale_x = 1.0
        self.world_scale_y = 1.0
        self.world_flip_x = False
        self.world_flip_y = False
        self.set_to_setup_pose()

    def set_to_setup_pose(self):
        data = self.data
        self.x = data.x
        self.y = data.y
        self.rotation = data.rotation
        self.rotation_ik = data.rotation
        self.scale_x = data.scale_x
        self.scale_y = data.scale_y
        self.flip_x = data.flip_x
        self.flip_y = data.flip_y

    cpdef world_to_local(Bone self, list world):
        cdef:
            bool y_down = Bone.y_down
            float dx = world[0] - self.world_x
            float dy = world[1] - self.world_y
            float m00, m01, m10, m11, inverse_det
        m00, m01, m10, m11 = self.m00, self.m01, self.m10, self.m11
        if self.world_flip_x != (self.world_flip_y != y_down):
            m00 = -m00
            m11 = -m11
        inverse_det = 1 / (m00 * m11 - m01 * m10)
        world[0] = dx * m00 * inverse_det - dy * m01 * inverse_det
        world[1] = dy * m11 * inverse_det - dx * m10 * inverse_det

    cpdef local_to_world(Bone self, list local):
        cdef:
            float local_x = local[0]
            float local_y = local[1]
        local[0] = local_x * self.m00 + local_y * self.m01 + self.world_x
        local[1] = local_x * self.m10 + local_y * self.m11 + self.world_y

    cpdef update_world_transform(Bone self):
        cdef:
            bool skeleton_flip_x, skeleton_flip_y
            Bone parent = self.parent
            bool y_down = Bone.y_down
        if parent is not None:
            self.world_x = (self.x * parent.m00 +
                            self.y * parent.m01 + parent.world_x)
            self.world_y = (self.x * parent.m10 +
                            self.y * parent.m11 + parent.world_y)
            if self.data.inherit_scale is True:
                self.world_scale_x = parent.world_scale_x * self.scale_x
                self.world_scale_y = parent.world_scale_y * self.scale_y
            else:
                self.world_scale_x = self.scale_x
                self.world_scale_y = self.scale_y
            if self.data.inherit_rotation is True:
                self.world_rotation = parent.world_rotation + self.rotation_ik
            else:
                self.world_rotation = self.rotation_ik
            self.world_flip_x = parent.world_flip_x != self.flip_x
            self.world_flip_y = parent.world_flip_y != self.flip_y
        else:
            skeleton_flip_x = self.skeleton.flip_x
            skeleton_flip_y = self.skeleton.flip_y
            if skeleton_flip_x is True:
                self.world_x = -self.x
            else:
                self.world_x = self.x
            if skeleton_flip_y != y_down:
                self.world_y = -self.y
            else:
                self.world_y = self.y
            self.world_scale_x = self.scale_x
            self.world_scale_y = self.scale_y
            self.world_rotation = self.rotation_ik
            self.world_flip_x = skeleton_flip_x != self.flip_x
            self.world_flip_y = skeleton_flip_y != self.flip_y

        cdef:
            float radian_value = radians(self.world_rotation)
            float cos_value = cos(radian_value)
            float sin_value = sin(radian_value)
            float world_scale_x = self.world_scale_x
            float world_scale_y = self.world_scale_y
        if self.world_flip_x is True:
            self.m00 = -cos_value * world_scale_x
            self.m01 = sin_value * world_scale_y
        else:
            self.m00 = cos_value * world_scale_x
            self.m01 = -sin_value * world_scale_y
        if self.world_flip_y != y_down:
            self.m10 = -sin_value * world_scale_x
            self.m11 = -cos_value * world_scale_y
        else:
            self.m10 = sin_value * world_scale_x
            self.m11 = cos_value * world_scale_y
