class AtlasReader(object):

    def __init__(self, atlas_text):
        self.lines = atlas_text.splitlines()
        self.index = 0

    def read_line(self):
        if self.index >= len(self.lines):
            return None
        line = self.lines[self.index].strip()
        self.index += 1
        return line

    def read_value(self):
        line = self.read_line()
        try:
            colon = line.index(':')
        except ValueError:
            raise ValueError('Invalid line: {}'.format(line))
        return line[(colon + 1):].strip()

    def read_tuple(self, a_list):
        line = self.read_line()
        try:
            colon = line.index(':')
        except ValueError:
            raise ValueError('Invalid line: {}'.format(line))
        i = 0
        last_match = colon + 1
        while i < 3:
            try:
                comma = line.index(',', last_match)
            except ValueError:
                break
            a_list[i] = line[last_match:comma].strip()
            last_match = comma + 1
            i += 1
        a_list[i] = line[last_match:].strip()
        return i + 1
