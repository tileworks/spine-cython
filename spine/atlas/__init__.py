class AtlasFormat(object):

    Alpha = 0
    Intensity = 1
    LuminanceAlpha = 2
    RGB565 = 3
    RGBA4444 = 4
    RGB888 = 5
    RGBA8888 = 6

    @classmethod
    def get_type(cls, type_name):
        return cls.__dict__[type_name]


class TextureFilter(object):

    Nearest = 0
    Linear = 1
    MipMap = 2
    MipMapNearestNearest = 3
    MipMapLinearNearest = 4
    MipMapNearestLinear = 5
    MipMapLinearLinear = 6

    @classmethod
    def get_type(cls, type_name):
        return cls.__dict__[type_name]

class TextureWrap(object):

    MirroredRepeat = 0
    ClampToEdge = 1
    Repeat = 2

    @classmethod
    def get_type(cls, type_name):
        return cls.__dict__[type_name]


class BlendMode(object):

    normal = 0
    additive = 1
    multiply = 2
    screen = 3

    @classmethod
    def get_mode(cls, mode_name):
        return cls.__dict__.get(mode_name)
