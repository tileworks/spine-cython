from spine.attachment.boundingboxattachment import BoundingBoxAttachment
from spine.attachment.meshattachment import MeshAttachment
from spine.attachment.regionattachment import RegionAttachment
from spine.attachment.skinnedmeshattachment import SkinnedMeshAttachment


class AtlasAttachmentLoader(object):

    def __init__(self, atlas):
        self.atlas = atlas

    def new_region_attachment(self, skin, name, path):
        region = self.atlas.find_region(path)
        if region is None:
            raise ValueError(
                'Region not found in atlas: '
                '{} (region attachment {})'.format(path, name))
        attachment = RegionAttachment(name)
        attachment.renderer_object = region
        attachment.set_uvs(region.u, region.v,
                           region.u2, region.v2,
                           region.rotate)
        attachment.region_offset_x = region.offset_x
        attachment.region_offset_y = region.offset_y
        attachment.region_width = region.width
        attachment.region_height = region.height
        attachment.region_original_width = region.original_width
        attachment.region_original_height = region.original_height
        return attachment

    def new_mesh_attachment(self, skin, name, path):
        region = self.atlas.find_region(path)
        if region is None:
            raise ValueError(
                'Region not found in atlas: '
                '{} (mesh attachment {})'.format(path, name))
        attachment = MeshAttachment(name)
        attachment.renderer_object = region
        attachment.region_u = region.u
        attachment.region_v = region.v
        attachment.region_u2 = region.u2
        attachment.region_v2 = region.v2
        attachment.region_rotate = region.rotate
        attachment.region_offset_x = region.offset_x
        attachment.region_offset_y = region.offset_y
        attachment.region_width = region.width
        attachment.region_height = region.height
        attachment.region_original_width = region.original_width
        attachment.region_original_height = region.original_height
        return attachment

    def new_skinned_mesh_attachment(self, skin, name, path):
        region = self.atlas.find_region(path)
        if region is None:
            raise ValueError(
                'Region not found in atlas: '
                '{} (skinned mesh attachment: {})'.format(path, name))
        attachment = SkinnedMeshAttachment(name)
        attachment.renderer_object = region
        attachment.region_u = region.u
        attachment.region_v = region.v
        attachment.region_u2 = region.u2
        attachment.region_v2 = region.v2
        attachment.region_rotate = region.rotate
        attachment.region_offset_x = region.offset_x
        attachment.region_offset_y = region.offset_y
        attachment.region_width = region.width
        attachment.region_height = region.height
        attachment.region_original_width = region.original_width
        attachment.region_original_height = region.original_height
        return attachment

    def new_bounding_box_attachment(self, skin, name):
        return BoundingBoxAttachment(name)
