from cpython cimport bool
from libc.math cimport atan2, sqrt, acos, sin

from spine.bone cimport Bone
from spine.utils cimport degrees


cdef class IkConstraintData(object):

    def __init__(self, name):
        self.name = name
        self.bones = []
        self.target = None
        self.bend_direction = 1
        self.mix = 1.0


cdef class IkConstraint(object):

    def __init__(self, data, skeleton):
        self.data = data
        self.mix = data.mix
        self.bend_direction = data.bend_direction
        self.bones = self._find_bones(skeleton)
        self.target = skeleton.find_bone(data.target.name)

    def _find_bones(self, skeleton):
        bones = []
        for bone in self.data.bones:
            bones.append(skeleton.find_bone(bone.name))
        return bones

    cpdef apply(IkConstraint self):
        cdef:
            Bone target = self.target
            list bones = self.bones
            int bones_count = len(bones)
        if bones_count == 1:
            apply1(bones[0], target.world_x, target.world_y, self.mix)
        elif bones_count == 2:
            apply2(bones[0], bones[1],
                   target.world_x, target.world_y,
                   self.bend_direction, self.mix)


cdef inline apply1(Bone bone, float target_x, float target_y, float alpha):
    """Adjusts the bone rotation so the tip is as close to the target position
    as possible. The target is specified in the world coordinate system.
    """
    cdef:
        float parent_rotation = 0.0
        float rotation, rotation_ik
        bool y_down = Bone.y_down

    if bone.data.inherit_rotation is True and bone.parent is not None:
        parent_rotation = bone.parent.world_rotation
    rotation = bone.rotation
    rotation_ik = degrees(atan2(target_y - bone.world_y,
                                target_x - bone.world_x))
    if bone.world_flip_x != (bone.world_flip_y != y_down):
        rotation_ik = -rotation_ik
    rotation_ik -= parent_rotation
    bone.rotation_ik = rotation + (rotation_ik - rotation) * alpha


cdef inline apply2(Bone parent, Bone child, float target_x, float target_y,
                   int bend_direction, float alpha):
    """Adjusts the parent and child bone rotations so the tip of the child is
    as close to the target position as possible. The target is specified
    in the world coordinate system.
    """
    cdef:
        float child_rotation = child.rotation
        float parent_rotation = parent.rotation
        list temp_position = [0, 0]
        Bone parent_parent
        float child_x, child_y, offset, length1, length2
        float cos_denominator, cos_value, child_angle
        float adjacent, opposite, parent_angle, rotation

    if alpha == 0.0:
        child.rotation_ik = child_rotation
        parent.rotation_ik = parent_rotation
        return
    parent_parent = parent.parent
    if parent_parent is not None:
        temp_position[0] = target_x
        temp_position[1] = target_y
        parent_parent.world_to_local(temp_position)
        target_x = ((temp_position[0] - parent.x) *
                    parent_parent.world_scale_x)
        target_y = ((temp_position[1] - parent.y) *
                    parent_parent.world_scale_y)
    else:
        target_x -= parent.x
        target_y -= parent.y

    if child.parent == parent:
        temp_position[0] = child.x
        temp_position[1] = child.y
    else:
        temp_position[0] = child.x
        temp_position[1] = child.y
        child.parent.local_to_world(temp_position)
        parent.world_to_local(temp_position)

    child_x = temp_position[0] * parent.world_scale_x
    child_y = temp_position[1] * parent.world_scale_y
    offset = atan2(child_y, child_x)
    length1 = sqrt(child_x * child_x + child_y * child_y)
    length2 = child.data.length * child.world_scale_x

    # Based on code by Ryan Juckett
    # with permission: Copyright (c) 2008-2009 Ryan Juckett,
    # http://www.ryanjuckett.com/
    cos_denominator = 2 * length1 * length2
    if cos_denominator < 0.0001:
        child.rotation_ik = (child_rotation +
                             (degrees(atan2(target_y, target_x)) -
                              parent_rotation - child_rotation) * alpha)
        return

    cos_value = (target_x * target_x + target_y * target_y -
                 length1 * length1 - length2 * length2) / cos_denominator
    if cos_value < -1.0:
        cos_value = -1.0
    elif cos_value > 1.0:
        cos_value = 1.0

    child_angle = acos(cos_value) * bend_direction
    adjacent = length1 + length2 * cos_value
    opposite = length2 * sin(child_angle)
    parent_angle = atan2(target_y * adjacent - target_x * opposite,
                         target_x * adjacent + target_y * opposite)
    rotation = degrees(parent_angle - offset) - parent_rotation
    if rotation > 180.0:
        rotation -= 360.0
    elif rotation < -180.0:
        rotation += 360.0

    parent.rotation_ik = parent_rotation + rotation * alpha
    rotation = degrees(child_angle + offset) - child_rotation
    if rotation > 180.0:
        rotation -= 360.0
    elif rotation < -180.0:
        rotation += 360.0

    child.rotation_ik = (child_rotation +
                         (rotation + parent.world_rotation -
                          child.parent.world_rotation) * alpha)
