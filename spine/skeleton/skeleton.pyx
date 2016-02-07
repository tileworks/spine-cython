from spine.bone cimport Bone
from spine.ikconstraint cimport IkConstraint
from spine.slot cimport Slot


cdef class Skeleton(object):

    def __init__(self, skeleton_data):
        self.data = skeleton_data
        self.bones = []
        self.bone_cache = []
        self.slots = []
        self.draw_order = []
        self.ik_constraints = []
        self.skin = None
        self.x = 0.0
        self.y = 0.0
        self.z = 0.0
        self.r = 1.0
        self.g = 1.0
        self.b = 1.0
        self.a = 1.0
        self.time = 0.0
        self.flip_x = False
        self.flip_y = False
        self.init_bones(skeleton_data)
        self.init_slots(skeleton_data)
        self.init_ik_constraints(skeleton_data)
        self.update_cache()

    def init_bones(self, skeleton_data):
        bones = self.bones
        skeleton_data_bones = skeleton_data.bones
        for bone_data in skeleton_data_bones:
            parent = None
            if bone_data.parent is not None:
                parent = bones[skeleton_data_bones.index(bone_data.parent)]
            bones.append(Bone(bone_data, self, parent))

    def init_slots(self, skeleton_data):
        skeleton_data_bones = skeleton_data.bones
        slots = self.slots
        bones = self.bones
        draw_order = self.draw_order
        for slot_data in skeleton_data.slots:
            bone = bones[skeleton_data_bones.index(slot_data.bone_data)]
            slot = Slot(slot_data, bone)
            slots.append(slot)
            draw_order.append(slot)

    def init_ik_constraints(self, skeleton_data):
        ik_constraints = self.ik_constraints
        for ik_constraint_data in skeleton_data.ik_constraints:
            ik_constraints.append(IkConstraint(ik_constraint_data, self))

    def update_cache(self):
        """
        Caches information about bones and IK constraints.
        Must be called if bones or IK constraints are added or removed.
        """
        ik_constraints = self.ik_constraints
        ik_constraints_count = len(ik_constraints)
        array_count = ik_constraints_count + 1
        bone_cache = self.bone_cache
        bone_cache_count = len(bone_cache)

        if bone_cache_count > array_count:
            bone_cache[:] = bone_cache[0:array_count]
            bone_cache_count = len(bone_cache)

        for cache_bones in bone_cache:
            del cache_bones[:]

        i = bone_cache_count
        while i < array_count:
            bone_cache.append([])
            i += 1

        non_ik_bones = bone_cache[0]
        continue_outer = False
        for bone in self.bones:
            current = bone
            while True:
                ii = 0
                while ii < ik_constraints_count:
                    ik_constraint = ik_constraints[ii]
                    parent = ik_constraint.bones[0]
                    child = ik_constraint.bones[len(ik_constraint.bones) - 1]
                    while True:
                        if current == child:
                            bone_cache[ii].append(bone)
                            bone_cache[ii + 1].append(bone)
                            continue_outer = True
                            break
                        if child == parent:
                            break
                        child = child.parent
                    if continue_outer is True:
                        break
                    ii += 1
                if continue_outer is True:
                    break
                current = current.parent
                if current is None:
                    break
            if continue_outer is True:
                continue_outer = False
                continue
            non_ik_bones.append(bone)

    cpdef update_world_transform(Skeleton self):
        cdef:
            Bone bone, cache_bone
            list bone_cache = self.bone_cache
            list ik_constraints = self.ik_constraints
            int index = 0
            int last = len(bone_cache) - 1
            list cache_bones

        for bone in self.bones:
            bone.rotation_ik = bone.rotation
        while True:
            cache_bones = bone_cache[index]
            for cache_bone in cache_bones:
                cache_bone.update_world_transform()
            if index == last:
                break
            ik_constraints[index].apply()
            index += 1

    def set_to_setup_pose(self):
        self.set_bones_to_setup_pose()
        self.set_slots_to_setup_pose()

    def set_bones_to_setup_pose(self):
        for bone in self.bones:
            bone.set_to_setup_pose()
        for ik_constraint in self.ik_constraints:
            ik_constraint.bend_direction = ik_constraint.data.bend_direction
            ik_constraint.mix = ik_constraint.data.mix

    def set_slots_to_setup_pose(self):
        slots = self.slots
        self.draw_order[:] = slots
        for slot in slots:
            slot.set_to_setup_pose()

    def get_root_bone(self):
        try:
            return self.bones[0]
        except IndexError:
            return

    def find_bone(self, bone_name):
        for bone in self.bones:
            if bone.data.name == bone_name:
                return bone
        return None

    def find_bone_index(self, bone_name):
        for index, bone in enumerate(self.bones):
            if bone.data.name == bone_name:
                return index
        return -1

    def find_slot(self, slot_name):
        for slot in self.slots:
            if slot.data.name == slot_name:
                return slot
        return None

    def find_slot_index(self, slot_name):
        for index, slot in enumerate(self.slots):
            if slot.data.name == slot_name:
                return index
        return -1

    def set_skin_by_name(self, skin_name):
        skin = self.data.find_skin(skin_name)
        if skin is None:
            raise ValueError('Skin not found: {}'.format(skin_name))
        self.set_skin(skin)

    def set_skin(self, new_skin):
        if new_skin is not None:
            if self.skin is not None:
                new_skin.attach_all(self, self.skin)
            else:
                for index, slot in enumerate(self.slots):
                    name = slot.data.attachment_name
                    if name is not None:
                        attachment = new_skin.get_attachment(index, name)
                        if attachment is not None:
                            slot.set_attachment(attachment)
        self.skin = new_skin

    def get_attachment_by_slot_name(self, slot_name, attachment_name):
        slot = self.data.find_slot_index(slot_name)
        return self.get_attachment_by_slot_index(slot, attachment_name)

    def get_attachment_by_slot_index(self, slot_index, attachment_name):
        if self.skin is not None:
            attachment = self.skin.get_attachment(slot_index, attachment_name)
            if attachment is not None:
                return attachment
        default_skin = self.data.default_skin
        if default_skin is not None:
            return default_skin.get_attachment(slot_index, attachment_name)
        return None

    def set_attachment(self, slot_name, attachment_name):
        for index, slot in enumerate(self.slots):
            if slot.data.name == slot_name:
                attachment = None
                if attachment_name is not None:
                    attachment = self\
                        .get_attachment_by_slot_index(index, attachment_name)
                    if attachment is None:
                        raise ValueError(
                            'Attachment not found: {}'.format(attachment_name))
                slot.set_attachment(attachment)
                return
        raise ValueError('Slot not found: {}'.format(slot_name))

    def find_ik_constraint(self, ik_constraint_name):
        for ik_constraint in self.ik_constraints:
            if ik_constraint.data.name == ik_constraint_name:
                return ik_constraint
        return None

    def update(self, dt):
        self.time += dt
