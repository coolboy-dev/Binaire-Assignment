import struct
import zlib

PNG_SIG = bytes([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])

CODE_START = 0x4300
CODE_END = 0x8000
VERSION_ADDR = 0x8000

PXA_HEADER = bytes([0x00, ord('p'), ord('x'), ord('a')])
OLD_HEADER = bytes([ord(':'), ord('c'), ord(':'), 0x00])

COMPRESSED_LUA_CHAR_TABLE = b"#\n 0123456789abcdefghijklmnopqrstuvwxyz!#%(){}[]<>+=/*:;.,~_"

FUTURE_CODE_1 = b"if(_update60)_update=function()_update60()_update60()end"
FUTURE_CODE_2 = b"if(_update60)_update=function()_update60()_update_buttons()_update60()end"


def _paeth(a, b, c):
    p = a + b - c
    pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
    if pa <= pb and pa <= pc:
        return a
    if pb <= pc:
        return b
    return c


def decode_png(data):
    """Return (width, height, raw_rgba_bytes) for an 8-bit RGBA, non-interlaced PNG."""
    if data[:8] != PNG_SIG:
        raise ValueError("not a PNG file")
    pos = 8
    width = height = bit_depth = color_type = interlace = None
    idat = bytearray()
    while pos < len(data):
        length = struct.unpack(">I", data[pos:pos + 4])[0]
        ctype = data[pos + 4:pos + 8]
        chunk = data[pos + 8:pos + 8 + length]
        if ctype == b"IHDR":
            width, height, bit_depth, color_type, _cm, _fm, interlace = struct.unpack(
                ">IIBBBBB", chunk
            )
        elif ctype == b"IDAT":
            idat.extend(chunk)
        elif ctype == b"IEND":
            break
        pos += 8 + length + 4

    if bit_depth != 8 or color_type != 6 or interlace != 0:
        raise ValueError(
            f"unsupported PNG variant (bit_depth={bit_depth}, color_type={color_type}, interlace={interlace})"
        )

    raw = zlib.decompress(bytes(idat))
    bpp = 4
    stride = width * bpp
    out = bytearray(height * stride)
    pos = 0
    prev_row = bytearray(stride)
    for y in range(height):
        ftype = raw[pos]
        pos += 1
        row = bytearray(raw[pos:pos + stride])
        pos += stride
        if ftype == 0:
            pass
        elif ftype == 1:
            for x in range(stride):
                a = row[x - bpp] if x >= bpp else 0
                row[x] = (row[x] + a) & 0xFF
        elif ftype == 2:
            for x in range(stride):
                row[x] = (row[x] + prev_row[x]) & 0xFF
        elif ftype == 3:
            for x in range(stride):
                a = row[x - bpp] if x >= bpp else 0
                b = prev_row[x]
                row[x] = (row[x] + ((a + b) // 2)) & 0xFF
        elif ftype == 4:
            for x in range(stride):
                a = row[x - bpp] if x >= bpp else 0
                b = prev_row[x]
                c = prev_row[x - bpp] if x >= bpp else 0
                row[x] = (row[x] + _paeth(a, b, c)) & 0xFF
        else:
            raise ValueError(f"bad PNG filter type {ftype}")
        out[y * stride:(y + 1) * stride] = row
        prev_row = row
    return width, height, bytes(out)


def extract_rom(width, height, rgba):
    """2 LSBs of A,R,G,B per pixel -> 1 byte per pixel, raster order."""
    rom = bytearray(width * height)
    for i in range(width * height):
        r, g, b, a = rgba[i * 4], rgba[i * 4 + 1], rgba[i * 4 + 2], rgba[i * 4 + 3]
        rom[i] = ((a & 3) << 6) | ((r & 3) << 4) | ((g & 3) << 2) | (b & 3)
    return bytes(rom)


def _decompress_pxa(data):
    length = data[4] * 256 + data[5]
    compressed = data[6] * 256 + data[7]

    pos = 8 * 8

    def get_bits(count):
        nonlocal pos
        n = 0
        i = 0
        while i < count and pos < compressed * 8:
            n |= ((data[pos >> 3] >> (pos & 7)) & 1) << i
            i += 1
            pos += 1
        return n

    state = list(range(256))

    def mtf_get(n):
        ch = state[n]
        del state[n]
        state.insert(0, ch)
        return ch

    ret = bytearray()
    while len(ret) < length and pos < compressed * 8:
        if get_bits(1) != 0:
            nbits = 4
            while get_bits(1) != 0:
                nbits += 1
            n = get_bits(nbits) + (1 << nbits) - 16
            ch = mtf_get(n)
            if ch == 0:
                break
            ret.append(ch)
            continue

        if get_bits(1) != 0:
            nbits = 5 if get_bits(1) != 0 else 10
        else:
            nbits = 15
        offset = get_bits(nbits) + 1

        if nbits == 10 and offset == 1:
            while True:
                ch = get_bits(8)
                if ch == 0:
                    break
                ret.append(ch)
            continue

        ln = 3
        while True:
            n = get_bits(3)
            ln += n
            if n != 7:
                break
        for _ in range(ln):
            ret.append(ret[len(ret) - offset])
    return bytes(ret)


def _strip_future_code(code, trailer):
    if not code.endswith(trailer):
        return code
    code = code[:-len(trailer)]
    if code.endswith(b"\n"):
        code = code[:-1]
    return code


def _decompress_old(code):
    code_length = (code[4] << 8) | code[5]
    out = bytearray()
    in_i = 8
    n = len(code)
    while len(out) < code_length and in_i < n:
        b = code[in_i]
        if b == 0x00:
            in_i += 1
            if in_i < n:
                out.append(code[in_i])
        elif b <= 0x3B:
            out.append(COMPRESSED_LUA_CHAR_TABLE[b])
        else:
            in_i += 1
            if in_i >= n:
                break
            b2 = code[in_i]
            offset = (b - 0x3C) * 16 + (b2 & 0x0F)
            length = (b2 >> 4) + 2
            for _ in range(length):
                out.append(out[len(out) - offset])
        in_i += 1

    out = bytes(out).strip(b"\x00")
    out = _strip_future_code(out, FUTURE_CODE_1)
    out = _strip_future_code(out, FUTURE_CODE_2)
    return out


def extract_code(code_region, version):
    if version != 0 and code_region.startswith(PXA_HEADER):
        out = _decompress_pxa(code_region)
    elif version != 0 and code_region.startswith(OLD_HEADER):
        out = _decompress_old(code_region)
    else:
        n = code_region.find(0)
        if n < 0:
            n = len(code_region)
        out = code_region[:n] + b"\n"
    return out.replace(b"\r", b" ")


# P8SCII 0x00-0xFF -> UTF-8 text. 0x00-0x1F and 0x7F-0xFF hold PICO-8's custom
# glyphs; 0x20-0x7E match ASCII. Only the non-ASCII entries need spelling out.
_P8SCII_SPECIAL = {
    0x10: "▮", 0x11: "■", 0x12: "□", 0x13: "⁙",
    0x14: "⁘", 0x15: "‖", 0x16: "◀", 0x17: "▶",
    0x18: "「", 0x19: "」", 0x1a: "¥", 0x1b: "•",
    0x1c: "、", 0x1d: "。", 0x1e: "゛", 0x1f: "゜",
    0x7f: "○", 0x80: "█", 0x81: "▒",
    0x82: "\U0001f431", 0x83: "⬇️", 0x84: "░",
    0x85: "✕", 0x86: "●", 0x87: "♥", 0x88: "☉",
    0x89: "웃", 0x8a: "⌂", 0x8b: "⬅️", 0x8c: "\U0001f610",
    0x8d: "♪", 0x8e: "\U0001f17e️", 0x8f: "◆", 0x90: "…",
    0x91: "➡️", 0x92: "★", 0x93: "⧗", 0x94: "⬆️",
    0x95: "ˇ", 0x96: "∧", 0x97: "❘", 0x98: "▤",
    0x99: "▥",
}


def p8scii_to_utf8(code_bytes):
    chars = []
    for b in code_bytes:
        if 0x20 <= b <= 0x7E:
            chars.append(chr(b))
        elif b in _P8SCII_SPECIAL:
            chars.append(_P8SCII_SPECIAL[b])
        elif b in (0x09, 0x0A):
            chars.append(chr(b))
        else:
            chars.append(chr(b) if b < 0x20 else "?")
    return "".join(chars)


def decode_cart(png_bytes):
    """Return the Lua source (str) embedded in a .p8.png cartridge's bytes."""
    width, height, rgba = decode_png(png_bytes)
    rom = extract_rom(width, height, rgba)
    if len(rom) <= VERSION_ADDR:
        raise ValueError(f"cart ROM too small: {len(rom)} bytes")
    version = rom[VERSION_ADDR]
    code = extract_code(rom[CODE_START:CODE_END], version)
    return p8scii_to_utf8(code)
