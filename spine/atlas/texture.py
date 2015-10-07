class TextureFilter(object):

    Nearest = 0
    Linear = 1
    MipMap = 2
    MipMapNearestNearest = 3
    MipMapLinearNearest = 4
    MipMapNearestLinear = 5
    MipMapLinearLinear = 6

    _filter_types = {
        'Nearest': 0,
        'Linear': 1,
        'MipMap': 2,
        'MipMapNearestNearest': 3,
        'MipMapLinearNearest': 4,
        'MipMapNearestLinear': 5,
        'MipMapLinearLinear': 6
    }

    @classmethod
    def get_type(cls, type_name):
        return cls._filter_types[type_name]


class TextureWrap(object):

    MirroredRepeat = 0
    ClampToEdge = 1
    Repeat = 2

    _wrap_types = {
        'MirroredRepeat': 0,
        'ClampToEdge': 1,
        'Repeat': 2
    }

    @classmethod
    def get_type(cls, type_name):
        return cls._wrap_types[type_name]


class AbstractTextureLoader(object):

    images_path = ''
    """Path to atlas images.
    """

    def __init__(self, images_path):
        self.images_path = images_path

    def load(self, atlas_page, image_name):
        """Load image texture from images_path/image_name

        Must set:
        atlas_page.renderer_object to image texture,
        atlas_page.width to texture width,
        atlas_page.height to texture height

        Optional set (if available to texture object):
        texture.mag_filter to atlas_page.mag_filter
        texture.min_filter to atlas_page.min_filter
        texture.u_wrap to atlas_page.u_wrap
        texture.v_wrap to atlas_page.v_wrap
        texture.color_format to atlas_page.format

        :return None
        """
        raise NotImplementedError()

    def unload(self, renderer_object):
        """Unload renderer_object (texture) from memory.

        :return None
        """
        raise NotImplementedError()
