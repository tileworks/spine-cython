from cpython cimport bool

from spine.animation.trackentry cimport TrackEntry
from spine.skeleton.skeleton cimport Skeleton
from spine.spineevent cimport Event


cdef class AnimationState(object):

    def __init__(self, state_data):
        self.data = state_data
        self.tracks = []
        self.events = []
        self.on_start = None
        self.on_end = None
        self.on_complete = None
        self.on_event = None
        self.time_scale = 1.0
        
    cpdef update(AnimationState self, float dt):
        cdef:
            TrackEntry current, current_next
            float previous_dt
            int i = 0

        dt *= self.time_scale
        for current in self.tracks:
            if current is None:
                i += 1
                continue

            current.time += dt * current.time_scale
            if current.previous is not None:
                previous_dt = dt * current.previous.time_scale
                current.previous.time += previous_dt
                current.mix_time += previous_dt
            
            current_next = current.next
            if current_next is not None:
                current_next.time = current.last_time - current_next.delay
                if current_next.time >= 0.0:
                    self.set_current(i, current_next)
                else:
                    if current.loop is False and \
                            (current.last_time >= current.end_time):
                        self.clear_track(i)
            i += 1

    cpdef apply(AnimationState self, Skeleton skeleton):
        cdef:
            list events = self.events
            float time, last_time, end_time, previous_time, alpha
            bool loop, condition
            TrackEntry current, previous
            Event event
            int i, j, count = 0

        for current in self.tracks:
            if current is None:
                i += 1
                continue
            del events[:]
            time = current.time
            last_time = current.last_time
            end_time = current.end_time
            loop = current.loop
            if loop is False and time > end_time:
                time = end_time

            previous = current.previous
            if previous is None:
                if current.mix == 1.0:
                    current.animation.apply(skeleton, last_time,
                                            time, loop, events)
                else:
                    current.animation.mix(skeleton, last_time,
                                          time, loop, events, current.mix)

            else:
                previous_time = previous.time
                if previous.loop is False and \
                        (previous_time > previous.end_time):
                    previous_time = previous.end_time
                previous.animation.apply(skeleton, previous_time,
                                         previous_time, previous.loop, None)

                alpha = current.mix_time / current.mix_duration * current.mix
                if alpha >= 1.0:
                    alpha = 1.0
                    current.previous = None
                current.animation.mix(skeleton, last_time,
                                      time, loop, events, alpha)

            j = 0
            for event in events:
                if current.on_event is not None:
                    current.on_event(j, event)
                if self.on_event is not None:
                    self.on_event(j, event)
                j += 1

            # Check if completed the animation or a loop iteration.
            if loop is True:
                condition = last_time % end_time > time % end_time
            else:
                condition = last_time < end_time <= time
            if condition is True:
                count = int(time / end_time)
                if current.on_complete is not None:
                    current.on_complete(i, count)
                if self.on_complete is not None:
                    self.on_complete(i, count)

            current.last_time = current.time
            i += 1

    cpdef clear_tracks(AnimationState self):
        cdef:
            int index = 0
            TrackEntry track
        for track in self.tracks:
            self.clear_track(index)
            index += 1
        del self.tracks[:]

    cpdef clear_track(AnimationState self, int track_index):
        cdef list tracks = self.tracks
        if track_index >= len(tracks):
            return
        cdef TrackEntry current = tracks[track_index]
        if current is None:
            return
        if current.on_end is not None:
            current.on_end(track_index)
        tracks[track_index] = None

    def get_current(self, track_index):
        try:
            return self.tracks[track_index]
        except IndexError:
            return None

    def set_current(self, index, entry):
        current = self._expand_to_index(index)
        if current is not None:
            previous = current.previous
            current.previous = None
            if current.on_end is not None:
                current.on_end(index)
            if self.on_end is not None:
                self.on_end(index)

            entry.mix_duration = self.data.get_mix(current.animation,
                                                   entry.animation)
            if entry.mix_duration > 0.0:
                entry.mix_time = 0.0
                # If a mix is in progress, mix from the closest animation.
                if previous is not None and \
                        ((current.mix_time / current.mix_duration) < 0.5):
                    entry.previous = previous
                else:
                    entry.previous = current
        self.tracks[index] = entry
        if entry.on_start is not None:
            entry.on_start(index)
        if self.on_start is not None:
            self.on_start(index)

    def _expand_to_index(self, index):
        tracks = self.tracks
        if index < len(tracks):
            return tracks[index]
        tracks_append = tracks.append
        while index >= len(tracks):
            tracks_append(None)
        return None

    def set_animation_by_name(self, track_index, animation_name, loop):
        animation = self.data.skeleton_data.find_animation(animation_name)
        if animation is None:
            raise ValueError('Animation not found: {}'.format(animation_name))
        return self.set_animation(track_index, animation, loop)

    def set_animation(self, track_index, animation, loop):
        """
        Set the current animation. Any queued animations are cleared.
        """
        entry = TrackEntry()
        entry.animation = animation
        entry.loop = loop
        entry.end_time = animation.duration
        self.set_current(track_index, entry)
        return entry

    def add_animation_by_name(self, track_index, animation_name, loop, delay):
        animation = self.data.skeleton_data.find_animation(animation_name)
        if animation is None:
            raise ValueError('Animation not found: {}'.format(animation_name))
        return self.add_animation(track_index, animation, loop, delay)

    def add_animation(self, track_index, animation, loop, delay):
        """
        Adds an animation to be played delay seconds after the current
        or last queued animation. Param delay may be <= 0 to use duration
        of previous animation minus any mix duration plus the negative delay.
        """
        entry = TrackEntry()
        entry.animation = animation
        entry.loop = loop
        entry.end_time = animation.duration
        last = self._expand_to_index(track_index)

        if last is not None:
            while last.next is not None:
                last = last.next
            last.next = entry
        else:
            self.tracks[track_index] = entry

        if delay <= 0.0:
            if last is not None:
                delay += last.end_time - self.data.get_mix(last.animation,
                                                           animation)
            else:
                delay = 0.0

        entry.delay = delay
        return entry
