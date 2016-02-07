from sys import maxsize as max_integer

from spine.animation.animation cimport binary_search1
from spine.animation.timeline cimport Timeline
from spine.attachment.attachment cimport Attachment
from spine.skeleton.skeleton cimport Skeleton

cdef long MAX_INTEGER = max_integer


cdef class AttachmentTimeline(Timeline):

    def __init__(self, frame_count):
        self.frames = [0.0] * frame_count
        self.attachment_names = [None] * frame_count
        self.slot_index = 0

    def get_frame_count(self):
        return len(self.frames)

    def set_frame(self, frame_index, time, attachment_name):
        self.frames[frame_index] = time
        self.attachment_names[frame_index] = attachment_name

    cpdef apply(AttachmentTimeline self, Skeleton skeleton,
                float last_time, float time, list fired_events, float alpha):
        cdef list frames = self.frames
        if time < frames[0]:
            if last_time > time:
                self.apply(skeleton, last_time, max_integer, None, 0)
            return
        elif last_time > time:
            last_time = -1
        cdef:
            int frames_count = len(frames)
            int frame_index = frames_count - 1
        if time < frames[frames_count - 1]:
            frame_index = binary_search1(frames, time) - 1
        if frames[frame_index] < last_time:
            return
        cdef:
            basestring attachment_name
            Attachment attachment = None
        attachment_name = self.attachment_names[frame_index]
        if attachment_name:
            attachment = skeleton\
                .get_attachment_by_slot_index(self.slot_index, attachment_name)
        skeleton.slots[self.slot_index].set_attachment(attachment)
