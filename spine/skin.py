class Skin(object):

    def __init__(self, name):
        self.name = name
        self.attachments = {}

    def add_attachment(self, slot_index, name, attachment):
        self.attachments[(slot_index, name)] = attachment

    def get_attachment(self, slot_index, name):
        return self.attachments.get((slot_index, name), None)

    def attach_all(self, skeleton, old_skin):
        for slot_index, name in old_skin.attachments:
            slot = skeleton.slots[slot_index]
            if slot.attachment is not None and slot.attachment.name == name:
                attachment = self.get_attachment(slot_index, name)
                if attachment is not None:
                    slot.set_attachment(attachment)
