class Skin(object):

    def __init__(self, name):
        self.name = name
        self.attachments = {}

    def add_attachment(self, slot_index, name, attachment):
        self.attachments[(slot_index, name)] = attachment

    def get_attachment(self, slot_index, name):
        return self.attachments.get((slot_index, name), None)

    def attach_all(self, skeleton, old_skin):
        for entry, attachment in old_skin.attachments.iteritems():
            slot_index, name = entry
            slot = skeleton.slots[slot_index]
            if slot.attachment == attachment:
                new_attachment = self.get_attachment(slot_index, name)
                if new_attachment is not None:
                    slot.attachment = attachment
