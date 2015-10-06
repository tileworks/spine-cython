class AnimationStateData(object):

    def __init__(self, skeleton_data):
        self.skeleton_data = skeleton_data
        self.animation_to_mix_time = {}
        self.default_mix = 0

    def set_mix_by_name(self, from_name, to_name, duration):
        from_animation = self.skeleton_data.find_animation(from_name)
        if from_animation is None:
            raise ValueError('Animation not found: {}'.format(from_name))
        to_animation = self.skeleton_data.find_animation(to_name)
        if to_animation is None:
            raise ValueError('Animation not found: {}'.format(to_name))
        self.set_mix(from_animation, to_animation, duration)

    def set_mix(self, from_animation, to_animation, duration):
        key = (from_animation.name, to_animation.name)
        self.animation_to_mix_time[key] = duration

    def get_mix(self, from_animation, to_animation):
        key = (from_animation, to_animation)
        return self.animation_to_mix_time.get(key, self.default_mix)
