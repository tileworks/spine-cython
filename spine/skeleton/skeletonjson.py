from __future__ import division

import json
from collections import Sequence

from spine.blendmode import BlendMode
from spine.animation.animation import Animation
from spine.animation.attachmenttimeline import AttachmentTimeline
from spine.animation.colortimeline import ColorTimeline
from spine.animation.drawordertimeline import DrawOrderTimeline
from spine.animation.eventtimeline import EventTimeline
from spine.animation.ffdtimeline import FfdTimeline
from spine.animation.flipxtimeline import FlipXTimeline
from spine.animation.flipytimeline import FlipYTimeline
from spine.animation.ikconstrainttimeline import IkConstraintTimeline
from spine.animation.rotatetimeline import RotateTimeline
from spine.animation.scaletimeline import ScaleTimeline
from spine.animation.translatetimeline import TranslateTimeline
from spine.attachment.attachment import AttachmentType
from spine.bone import BoneData
from spine.event import EventData, Event
from spine.ikconstraint import IkConstraintData
from spine.skeleton.skeletondata import SkeletonData
from spine.skin import Skin
from spine.slot import SlotData


class SkeletonJson(object):

    def __init__(self, attachment_loader):
        self.attachment_loader = attachment_loader
        self.scale = 1.0

    def read_data(self, json_text, skeleton_name):
        root_dict = json.loads(json_text)
        scale = self.scale
        skeleton_data = SkeletonData()
        skeleton_data.name = skeleton_name

        # Skeleton.
        skeleton_dict = root_dict.get('skeleton')
        if skeleton_dict:
            skeleton_data.hash = skeleton_dict.get('hash')
            skeleton_data.version = skeleton_dict.get('version')
            skeleton_data.width = skeleton_dict.get('width', 0)
            skeleton_data.height = skeleton_dict.get('height', 0)

        # Bones.
        bones = root_dict.get('bones')
        for bone_dict in bones:
            parent = None
            parent_bone_name = bone_dict.get('parent', None)
            if parent_bone_name is not None:
                parent = skeleton_data.find_bone(parent_bone_name)
                if parent is None:
                    raise ValueError(
                        'Parent bone not found: {}'.format(parent_bone_name))
            bone_data = BoneData(bone_dict.get('name'), parent)
            bone_data.length = bone_dict.get('length', 0) * scale
            bone_data.x = bone_dict.get('x', 0) * scale
            bone_data.y = bone_dict.get('y', 0) * scale
            bone_data.rotation = bone_dict.get('rotation', 0.0)
            bone_data.scale_x = bone_dict.get('scaleX', 1.0)
            bone_data.scale_y = bone_dict.get('scaleY', 1.0)
            bone_data.inherit_scale = bone_dict.get('inheritScale', True)
            bone_data.inherit_rotation = bone_dict\
                .get('inheritRotation', True)
            skeleton_data.bones.append(bone_data)

        # IK constraints
        iks = root_dict.get('ik', [])
        for ik_dict in iks:
            ik_constraint_data = IkConstraintData(ik_dict.get('name'))
            bone_names = ik_dict.get('bones')
            for bone_name in bone_names:
                bone = skeleton_data.find_bone(bone_name)
                if bone is None:
                    raise ValueError(
                        'Ik bone not found: {}'.format(bone_name))
                ik_constraint_data.bones.append(bone)
            target_bone_name = ik_dict.get('target')
            ik_constraint_data.target = skeleton_data\
                .find_bone(target_bone_name)
            if ik_constraint_data.target is None:
                raise ValueError(
                    'Target bone not found: {}'.format(target_bone_name))
            bend_positive = ik_dict.get('bendPositive', True)
            bend_direction = 1 if bend_positive is True else -1
            ik_constraint_data.bend_direction = bend_direction
            ik_constraint_data.mix = ik_dict.get('mix', 1.0)
            skeleton_data.ik_constraints.append(ik_constraint_data)

        # Slots.
        slots = root_dict.get('slots', [])
        get_blend_mode = BlendMode.get_mode
        to_color = SkeletonJson.to_color
        for slot_dict in slots:
            slot_name = slot_dict.get('name')
            bone_name = slot_dict.get('bone')
            bone_data = skeleton_data.find_bone(bone_name)
            if bone_data is None:
                raise ValueError(
                    'Slot bone not found: {}'.format(bone_name))
            slot_data = SlotData(slot_name, bone_data)
            color = slot_dict.get('color', None)
            if color is not None:
                slot_data.r = to_color(color, 0)
                slot_data.g = to_color(color, 1)
                slot_data.b = to_color(color, 2)
                slot_data.a = to_color(color, 3)
            slot_data.attachment_name = slot_dict.get('attachment')
            slot_data.blend_mode = get_blend_mode(
                slot_dict.get('blend', 'normal'))
            skeleton_data.slots.append(slot_data)

        # Skins.
        skins = root_dict.get('skins', {})
        read_attachment = self.read_attachment
        for skin_name, skin_dict in skins.iteritems():
            skin = Skin(skin_name)
            for slot_name, slot_entry in skin_dict.iteritems():
                slot_index = skeleton_data.find_slot_index(slot_name)
                for attachment_name, attachment_dict in slot_entry.iteritems():
                    attachment = read_attachment(
                        skin, attachment_name, attachment_dict)
                    if attachment is not None:
                        skin.add_attachment(
                            slot_index, attachment_name, attachment)
            skeleton_data.skins.append(skin)
            if skin.name == 'default':
                skeleton_data.default_skin = skin

        # Events.
        events = root_dict.get('events', {})
        for event_name, event_dict in events.iteritems():
            event_dict = events.get(event_name)
            event_data = EventData(event_name)
            event_data.int_value = event_dict.get('int', 0)
            event_data.float_value = event_dict.get('float', 0.0)
            event_data.string_value = event_dict.get('string', None)
            skeleton_data.events.append(event_data)

        # Animations.
        animations = root_dict.get('animations', {})
        read_animation = self.read_animation
        for animation_name, animation_dict in animations.iteritems():
            read_animation(animation_name, animation_dict, skeleton_data)

        return skeleton_data

    def read_attachment(self, skin, attachment_name, attachment_dict):
        name = attachment_dict.get('name', attachment_name)
        attachment_type = AttachmentType.get_type(
            attachment_dict.get('type', 'region'))
        path = attachment_dict.get('path', name)
        scale = self.scale
        to_color = SkeletonJson.to_color
        get_float_list = SkeletonJson.get_float_list
        get_int_list = SkeletonJson.get_int_list

        if attachment_type == AttachmentType.region:
            region = self.attachment_loader.\
                new_region_attachment(skin, name, path)
            if region is None:
                return None
            region.path = path
            region.x = attachment_dict.get('x', 0) * scale
            region.y = attachment_dict.get('y', 0) * scale
            region.scale_x = attachment_dict.get('scaleX', 1.0)
            region.scale_y = attachment_dict.get('scaleY', 1.0)
            region.rotation = attachment_dict.get('rotation', 0.0)
            region.width = attachment_dict.get('width', 0) * scale
            region.height = attachment_dict.get('height', 0) * scale
            color = attachment_dict.get('color', None)
            if color is not None:
                region.r = to_color(color, 0)
                region.g = to_color(color, 1)
                region.b = to_color(color, 2)
                region.a = to_color(color, 3)
            region.update_offset()
            return region

        elif attachment_type == AttachmentType.mesh:
            mesh = self.attachment_loader\
                .new_mesh_attachment(skin, name, path)
            if mesh is None:
                return None
            mesh.path = path
            mesh.vertices = get_float_list(
                attachment_dict, 'vertices', scale)
            mesh.triangles = get_int_list(attachment_dict, 'triangles')
            mesh.region_uvs = get_float_list(attachment_dict, 'uvs', 1.0)
            mesh.update_uvs()
            color = attachment_dict.get('color', None)
            if color is not None:
                mesh.r = to_color(color, 0)
                mesh.g = to_color(color, 1)
                mesh.b = to_color(color, 2)
                mesh.a = to_color(color, 3)
            mesh.hull_length = attachment_dict.get('hull', 0) * 2
            if 'edges' in attachment_dict:
                mesh.edges = get_int_list(attachment_dict, 'edges')
            mesh.width = attachment_dict.get('width', 0) * scale
            mesh.height = attachment_dict.get('height', 0) * scale
            return mesh

        elif attachment_type == AttachmentType.skinnedmesh:
            mesh = self.attachment_loader\
                .new_skinned_mesh_attachment(skin, name, path)
            if mesh is None:
                return None
            mesh.path = path
            uvs = get_float_list(attachment_dict, 'uvs', 1.0)
            vertices = get_float_list(attachment_dict, 'vertices', 1.0)
            weights = []
            bones = []
            n = len(vertices)
            i = 0
            while i < n:
                bone_count = int(vertices[i])
                i += 1
                bones.append(bone_count)
                nn = i + bone_count * 4
                while i < nn:
                    bones.append(vertices[i])
                    weights.append(vertices[i + 1] * scale)
                    weights.append(vertices[i + 2] * scale)
                    weights.append(vertices[i + 3])
                    i += 4

            mesh.bones = bones
            mesh.weights = weights
            mesh.triangles = get_int_list(attachment_dict, 'triangles')
            mesh.region_uvs = uvs
            mesh.update_uvs()
            color = attachment_dict.get('color', None)
            if color is not None:
                mesh.r = to_color(color, 0)
                mesh.g = to_color(color, 1)
                mesh.b = to_color(color, 2)
                mesh.a = to_color(color, 3)
            mesh.hull_length = attachment_dict.get('hull', 0) * 2
            if 'edges' in attachment_dict:
                mesh.edges = get_int_list(attachment_dict, 'edges')
            mesh.width = attachment_dict.get('width', 0) * scale
            mesh.height = attachment_dict.get('height', 0) * scale
            return mesh

        elif attachment_type == AttachmentType.boundingbox:
            attachment = self.attachment_loader\
                .new_bounding_box_attachment(skin, name)
            vertices = attachment_dict.get('vertices', [])
            for vertex in vertices:
                attachment.vertices.append(vertex * scale)
            return attachment

        raise TypeError('Unknown attachment type: {}'.format(attachment_type))

    def read_animation(self, animation_name, animation_dict, skeleton_data):
        timelines = []
        duration = 0.0
        scale = self.scale
        read_curve = SkeletonJson.read_curve
        to_color = SkeletonJson.to_color
        slots_dict = animation_dict.get('slots', {})
        for slot_name, slot_dict in slots_dict.iteritems():
            slot_index = skeleton_data.find_slot_index(slot_name)
            for timeline_name, values in slot_dict.iteritems():
                if timeline_name == 'color':
                    timeline = ColorTimeline(len(values))
                    timeline.slot_index = slot_index
                    frame_index = 0
                    for value_dict in values:
                        color = value_dict.get('color')
                        r = to_color(color, 0)
                        g = to_color(color, 1)
                        b = to_color(color, 2)
                        a = to_color(color, 3)
                        timeline.set_frame(frame_index,
                                           value_dict.get('time'),
                                           r, g, b, a)
                        read_curve(timeline, frame_index, value_dict)
                        frame_index += 1
                    timelines.append(timeline)
                    duration = max(
                        duration,
                        timeline.frames[timeline.get_frame_count() * 5 - 5])
                elif timeline_name == 'attachment':
                    timeline = AttachmentTimeline(len(values))
                    timeline.slot_index = slot_index
                    frame_index = 0
                    for value_dict in values:
                        timeline.set_frame(frame_index,
                                           value_dict.get('time'),
                                           value_dict.get('name'))
                        frame_index += 1
                    timelines.append(timeline)
                    duration = max(
                        duration,
                        timeline.frames[timeline.get_frame_count() - 1])
                else:
                    raise TypeError(
                        'Invalid timeline type for a slot: {} ({})'
                        .format(timeline_name, slot_name)
                    )

        bones_dict = animation_dict.get('bones', {})
        for bone_name, bone_dict in bones_dict.iteritems():
            bone_index = skeleton_data.find_bone_index(bone_name)
            if bone_index == -1:
                raise ValueError('Bone not found: {}'.format(bone_name))
            for timeline_name, values in bone_dict.iteritems():
                if timeline_name == 'rotate':
                    timeline = RotateTimeline(len(values))
                    timeline.bone_index = bone_index
                    frame_index = 0
                    for value_dict in values:
                        timeline.set_frame(frame_index,
                                           value_dict.get('time'),
                                           value_dict.get('angle'))
                        read_curve(timeline, frame_index, value_dict)
                        frame_index += 1
                    timelines.append(timeline)
                    duration = max(
                        duration,
                        timeline.frames[timeline.get_frame_count() * 2 - 2])

                elif timeline_name == 'translate' or timeline_name == 'scale':
                    timeline_scale = 1.0
                    if timeline_name == 'scale':
                        timeline = ScaleTimeline(len(values))
                    else:
                        timeline = TranslateTimeline(len(values))
                        timeline_scale = scale

                    timeline.bone_index = bone_index
                    frame_index = 0
                    for value_dict in values:
                        x = value_dict.get('x', 0) * timeline_scale
                        y = value_dict.get('y', 0) * timeline_scale
                        timeline.set_frame(frame_index,
                                           value_dict.get('time'),
                                           x, y)
                        read_curve(timeline, frame_index, value_dict)
                        frame_index += 1
                    timelines.append(timeline)
                    duration = max(
                        duration,
                        timeline.frames[timeline.get_frame_count() * 3 - 3])

                elif timeline_name == 'flipX' or timeline_name == 'flipY':
                    x = timeline_name == 'flipX'
                    if x is True:
                        timeline = FlipXTimeline(len(values))
                    else:
                        timeline = FlipYTimeline(len(values))
                    timeline.bone_index = bone_index
                    field = 'x' if x is True else 'y'
                    frame_index = 0
                    for value_dict in values:
                        timeline.set_frame(frame_index,
                                           value_dict.get('time'),
                                           value_dict.get(field, False))
                        frame_index += 1
                    timelines.append(timeline)
                    duration = max(
                        duration,
                        timeline.frames[timeline.get_frame_count() * 2 - 2])
                else:
                    raise TypeError(
                        'Invalid timeline type for bone: {} ({})'
                        .format(timeline_name, bone_name)
                    )

        ik_dict = animation_dict.get('ik', {})
        for ik_constraint_name, values in ik_dict.iteritems():
            ik_constraint = skeleton_data\
                .find_ik_constraint(ik_constraint_name)
            timeline = IkConstraintTimeline(len(values))
            timeline.ik_constraint_index = skeleton_data\
                .ik_constraints.index(ik_constraint)
            frame_index = 0
            for value_dict in values:
                mix = value_dict.get('mix', 1.0)
                bend_positive = value_dict.get('bendPositive', True)
                bend_direction = 1 if bend_positive is True else -1
                timeline.set_frame(frame_index,
                                   value_dict.get('time'),
                                   mix,
                                   bend_direction)
                read_curve(timeline, frame_index, value_dict)
                frame_index += 1
            timelines.append(timeline)
            duration = max(
                duration,
                timeline.frames[timeline.get_frame_count() * 3 - 3])

        ffd_dict = animation_dict.get('ffd', {})
        for skin_name, slot_dict in ffd_dict.iteritems():
            skin = skeleton_data.find_skin(skin_name)
            for slot_name, mesh_dict in slot_dict.iteritems():
                slot_index = skeleton_data.find_slot_index(slot_name)
                for mesh_name, values in mesh_dict.iteritems():
                    timeline = FfdTimeline(len(values))
                    attachment = skin.get_attachment(slot_index, mesh_name)
                    if attachment is None:
                        raise ValueError(
                            'FFD attachment not found: {}'.format(mesh_name))
                    timeline.slot_index = slot_index
                    timeline.attachment = attachment
                    is_mesh = attachment.type == AttachmentType.mesh
                    if is_mesh is True:
                        vertex_count = len(attachment.vertices)
                    else:
                        vertex_count = int(len(attachment.weights) // 3 * 2)
                    frame_index = 0
                    for value_dict in values:
                        if not value_dict.get('vertices', []):
                            if is_mesh is True:
                                vertices = attachment.vertices
                            else:
                                vertices = [0.0] * vertex_count
                        else:
                            vertices_value = value_dict.get('vertices', [])
                            vertices = [0.0] * vertex_count
                            start = value_dict.get('offset', 0)
                            nn = len(vertices_value)
                            if scale == 1.0:
                                ii = 0
                                while ii < nn:
                                    vertices[ii + start] = vertices_value[ii]
                                    ii += 1
                            else:
                                ii = 0
                                while ii < nn:
                                    vertices[ii + start] = \
                                        vertices_value[ii] * scale
                                    ii += 1
                            if is_mesh is True:
                                mesh_vertices = attachment.vertices
                                ii = 0
                                while ii < vertex_count:
                                    vertices[ii] += mesh_vertices[ii]
                                    ii += 1
                        timeline.set_frame(frame_index,
                                           value_dict.get('time'),
                                           vertices)
                        read_curve(timeline, frame_index, value_dict)
                        frame_index += 1
                    timelines.append(timeline)
                    duration = max(
                        duration,
                        timeline.frames[timeline.get_frame_count() - 1])

        draw_orders_dict = animation_dict\
            .get('drawOrder', animation_dict.get('draworder', {}))
        if draw_orders_dict:
            timeline = DrawOrderTimeline(len(draw_orders_dict))
            slot_count = len(skeleton_data.slots)
            frame_index = 0
            for draw_order_dict in draw_orders_dict:
                draw_order = []
                offsets = draw_order_dict.get('offsets', [])
                if offsets:
                    nn = len(offsets)
                    draw_order = [-1] * slot_count
                    unchanged = [0] * (slot_count - nn)
                    original_index = 0
                    unchanged_index = 0
                    ii = 0
                    while ii < nn:
                        offset_dict = offsets[ii]
                        slot_name = offset_dict.get('slot')
                        slot_index = skeleton_data.find_slot_index(slot_name)
                        if slot_index == -1:
                            raise ValueError(
                                'Slot not found: {}'.format(slot_name))
                        # Collect unchanged items
                        while original_index != slot_index:
                            unchanged[unchanged_index] = original_index
                            unchanged_index += 1
                            original_index += 1
                        key_index = original_index + offset_dict.get('offset')
                        draw_order[key_index] = original_index
                        original_index += 1
                        ii += 1
                    # Collect remaining unchanged items.
                    while original_index < slot_count:
                        unchanged[unchanged_index] = original_index
                        unchanged_index += 1
                        original_index += 1
                    ii = slot_count - 1
                    while ii >= 0:
                        if draw_order[ii] == -1:
                            unchanged_index -= 1
                            draw_order[ii] = unchanged[unchanged_index]
                        ii -= 1
                timeline.set_frame(frame_index,
                                   draw_order_dict.get('time'),
                                   draw_order)
                frame_index += 1
            timelines.append(timeline)
            duration = max(
                duration,
                timeline.frames[timeline.get_frame_count() - 1])

        events = animation_dict.get('events', [])
        if events:
            timeline = EventTimeline(len(events))
            frame_index = 0
            for event_dict in events:
                event_name = event_dict.get('name')
                event_data = skeleton_data.find_event(event_name)
                if event_data is None:
                    raise ValueError('Event not found: {}'.format(event_name))
                event = Event(event_data)
                event.int_value = event_dict.get('int', event.int_value)
                event.float_value = event_dict.get('float', event.float_value)
                event.string_value = event_dict.get('string',
                                                    event.string_value)
                timeline.set_frame(frame_index,
                                   event_dict.get('time'),
                                   event)
                frame_index += 1
            timelines.append(timeline)
            duration = max(
                duration,
                timeline.frames[timeline.get_frame_count() - 1])

        skeleton_data.animations.append(
            Animation(animation_name, timelines, duration))

    @staticmethod
    def read_curve(timeline, frame_index, value_dict):
        curve = value_dict.get('curve', None)
        if curve is None:
            timeline.set_linear(frame_index)
        elif curve == 'stepped':
            timeline.set_stepped(frame_index)
        elif isinstance(curve, Sequence):
            timeline.set_curve(
                frame_index, curve[0], curve[1], curve[2], curve[3])

    @staticmethod
    def to_color(hex_string, color_index):
        if len(hex_string) != 8:
            raise ValueError(
                'Color hexadecimal digit must be 8, received: {}'
                .format(len(hex_string))
            )
        value = int(hex_string[color_index * 2:color_index * 2 + 2], 16)
        return value / 255.0

    @staticmethod
    def get_float_list(a_dict, name, scale):
        a_list = a_dict.get(name)
        if scale == 1.0:
            return a_list[:]
        else:
            return map(lambda x: x * scale, a_list)

    @staticmethod
    def get_int_list(a_dict, name):
        a_list = a_dict.get(name)
        return map(int, a_list)
