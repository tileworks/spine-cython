from spine.blendmode import BlendMode


cdef class SlotData(object):

    def __init__(self, name, bone_data):
        self.name = name
        self.bone_data = bone_data
        self.r = 1.0
        self.g = 1.0
        self.b = 1.0
        self.a = 1.0
        self.attachment_name = None
        self.blend_mode = BlendMode.normal


cdef class Slot(object):

    def __init__(self, slot_data, bone):
        self.data = slot_data
        self.bone = bone
        self.r = 1.0
        self.g = 1.0
        self.b = 1.0
        self.a = 1.0
        self._attachment_time = 0.0
        self.attachment = None
        self.attachment_vertices = []
        self.set_to_setup_pose()

    def set_attachment(self, attachment):
        self.attachment = attachment
        self._attachment_time = self.bone.skeleton.time
        del self.attachment_vertices[:]

    def get_attachment_time(self):
        return self.bone.skeleton.time - self._attachment_time

    def set_attachment_time(self, time):
        self._attachment_time = self.bone.skeleton.time - time

    def set_to_setup_pose(self):
        data = self.data
        self.r = data.r
        self.g = data.g
        self.b = data.b
        self.a = data.a
        bone_skeleton = self.bone.skeleton
        for i, slot_data in enumerate(bone_skeleton.data.slots):
            if slot_data == data:
                if data.attachment_name is None:
                    self.set_attachment(None)
                else:
                    attachment = bone_skeleton.\
                        get_attachment_by_slot_index(i, data.attachment_name)
                    self.set_attachment(attachment)
                break
