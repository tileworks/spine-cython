class AtlasRegion(object):

    def __init__(self):
        self.page = None
        self.name = None
        self.x = 0
        self.y = 0
        self.width = 0
        self.height = 0
        self.u = 0.0
        self.v = 0.0
        self.u2 = 0.0
        self.v2 = 0.0
        self.offset_x = 0.0
        self.offset_y = 0.0
        self.original_width = 0
        self.original_height = 0
        self.index = 0
        self.rotate = False
        self.splits = []
        self.pads = []
