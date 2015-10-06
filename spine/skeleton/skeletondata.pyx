cdef class SkeletonData(object):

    def __init__(self):
        self.bones = []             # list of BoneData
        self.slots = []             # list of SlotData
        self.skins = []             # list of Skin
        self.events = []            # list of EventData
        self.animations = []        # list of Animation
        self.ik_constraints = []    # list of IkConstraintData
        self.name = None
        self.default_skin = None
        self.width = 0
        self.height = 0
        self.version = None
        self.hash = None

    def find_bone(self, bone_name):
        for bone in self.bones:
            if bone.name == bone_name:
                return bone
        return None

    def find_bone_index(self, bone_name):
        for index, bone in enumerate(self.bones):
            if bone.name == bone_name:
                return index
        return -1

    def find_slot(self, slot_name):
        for slot in self.slots:
            if slot.name == slot_name:
                return slot
        return None

    def find_slot_index(self, slot_name):
        for index, slot in enumerate(self.slots):
            if slot.name == slot_name:
                return index
        return -1

    def find_skin(self, skin_name):
        for skin in self.skins:
            if skin.name == skin_name:
                return skin
        return None

    def find_event(self, event_name):
        for event in self.events:
            if event.name == event_name:
                return event
        return None

    def find_animation(self, animation_name):
        for animation in self.animations:
            if animation.name == animation_name:
                return animation
        return None

    def find_ik_constraint(self, ik_constraint_name):
        for ik_constraint in self.ik_constraints:
            if ik_constraint.name == ik_constraint_name:
                return ik_constraint
        return None
