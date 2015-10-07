from __future__ import division

from spine.atlas.texture import TextureFilter, TextureWrap
from spine.atlas.atlaspage import AtlasPage
from spine.atlas.atlasreader import AtlasReader
from spine.atlas.atlasregion import AtlasRegion


class AtlasFormat(object):

    Alpha = 0
    Intensity = 1
    LuminanceAlpha = 2
    RGB565 = 3
    RGBA4444 = 4
    RGB888 = 5
    RGBA8888 = 6

    _format_names = {
        'Alpha': 0,
        'Intensity': 1,
        'LuminanceAlpha': 2,
        'RGB565': 3,
        'RGBA4444': 4,
        'RGB888': 5,
        'RGBA8888': 6
    }

    @classmethod
    def get_type(cls, type_name):
        return cls._format_names[type_name]


class Atlas(object):

    def __init__(self, atlas_text, texture_loader):
        self.texture_loader = texture_loader
        self.pages = []
        self.regions = []
        self._init_atlas(atlas_text, texture_loader)

    def _init_atlas(self, atlas_text, texture_loader):
        reader = AtlasReader(atlas_text)
        pages = self.pages
        regions = self.regions
        a_list = [None, None, None, None]
        page = None
        while True:
            line = reader.read_line()
            if line is None:
                break
            line.strip()
            if len(line) == 0:
                page = None
            elif page is None:
                page = AtlasPage()
                page.name = line
                if reader.read_tuple(a_list) == 2:
                    # size is only optional for an atlas packed
                    # with an old TexturePacker
                    page.width = int(a_list[0])
                    page.height = int(a_list[1])
                    reader.read_tuple(a_list)

                page.format = AtlasFormat.get_type(a_list[0])
                reader.read_tuple(a_list)
                page.min_filter = TextureFilter.get_type(a_list[0])
                page.mag_filter = TextureFilter.get_type(a_list[1])

                direction = reader.read_value()
                page.u_wrap = TextureWrap.ClampToEdge
                page.v_wrap = TextureWrap.ClampToEdge
                if direction == 'x':
                    page.u_wrap = TextureWrap.Repeat
                elif direction == 'y':
                    page.v_wrap = TextureWrap.Repeat
                elif direction == 'xy':
                    page.u_wrap = page.v_wrap = TextureWrap.Repeat
                texture_loader.load(page, line)
                pages.append(page)
            else:
                region = AtlasRegion()
                region.name = line
                region.page = page
                region.rotate = reader.read_value() == 'true'

                reader.read_tuple(a_list)
                x = int(a_list[0])
                y = int(a_list[1])

                reader.read_tuple(a_list)
                width = int(a_list[0])
                height = int(a_list[1])

                region.u = x / page.width
                region.v = y / page.height
                if region.rotate is True:
                    region.u2 = (x + height) / page.width
                    region.v2 = (y + width) / page.height
                else:
                    region.u2 = (x + width) / page.width
                    region.v2 = (y + height) / page.height

                region.x = x
                region.y = y
                region.width = abs(width)
                region.height = abs(height)

                if reader.read_tuple(a_list) == 4:
                    # split is optional
                    region.splits = map(int, a_list)
                    if reader.read_tuple(a_list) == 4:
                        # pad is optional, but only present with splits
                        region.pads = map(int, a_list)
                        reader.read_tuple(a_list)

                region.original_width = int(a_list[0])
                region.original_height = int(a_list[1])

                reader.read_tuple(a_list)
                region.offset_x = int(a_list[0])
                region.offset_x = int(a_list[1])
                region.index = int(reader.read_value())
                regions.append(region)

    def find_region(self, name):
        for region in self.regions:
            if region.name == name:
                return region
        return None

    def dispose(self):
        for page in self.pages:
            self.texture_loader.unload(page.renderer_object)

    def update_uvs(self, page):
        for region in self.regions:
            if region.page != page:
                continue
            region.u = region.x / page.width
            region.v = region.y / page.height
            if region.rotate is True:
                region.u2 = (region.x + region.height) / page.width
                region.v2 = (region.y + region.width) / page.height
            else:
                region.u2 = (region.x + region.width) / page.width
                region.v2 = (region.y + region.height) / page.height
