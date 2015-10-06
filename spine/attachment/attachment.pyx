class AttachmentType(object):

    region = 0
    boundingbox = 1
    mesh = 2
    skinnedmesh = 3

    @classmethod
    def get_type(cls, type_name):
        return cls.__dict__.get(type_name)


cdef class Attachment(object):

    def __init__(self, name):
        assert name is not None, 'Name cannot be None'
        self.name = name
