class BlendMode(object):

                    # (source, source_premultiplied_alpha, destination)
    normal = 0      # (GL_SRC_ALPHA, GL_ONE, GL_ONE_MINUS_SRC_ALPHA)
    additive = 1    # (GL_SRC_ALPHA, GL_ONE, GL_ONE)
    multiply = 2    # (GL_DST_COLOR, GL_DST_COLOR, GL_ONE_MINUS_SRC_ALPHA)
    screen = 3      # (GL_ONE, GL_ONE, GL_ONE_MINUS_SRC_COLOR)

    _mode_types = {
        'normal': 0,
        'additive': 1,
        'multiply': 2,
        'screen': 3
    }

    @classmethod
    def get_mode(cls, mode_name):
        return cls._mode_types[mode_name]
