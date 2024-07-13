fn len_utf8(ch : Char) -> Int {
  let ch = ch.to_int()
  if ch < 0x80 {
    1
  } else if ch < 0x800 {
    2
  } else if ch < 0x10000 {
    3
  } else if ch < 0x110000 {
    4
  } else {
    abort("invalid rune")
  }
}

fn len_utf16(ch : Char) -> Int {
  let ch = ch.to_int()
  if ch < 0x10000 {
    2
  } else {
    4
  }
}

fn len_utf32(ch : Char) -> Int {
  4
}

let max_char_len = 4

fn read_rune_utf8(buf : Bytes, idx : Int) -> (Int, Char)! {
  let b = buf[idx]
  if b.land(0x80) == 0 {
    (1, Char::from_int(b))
  } else if b.land(0xE0) == 0xC0 {
    (2, Char::from_int(b.land(0x1F).lsl(6).lor(buf[idx + 1].land(0x3F))))
  } else if b.land(0xF0) == 0xE0 {
    (
      3,
      Char::from_int(
        b.land(0x0F).lsl(12).lor(
          buf[idx + 1].land(0x3F).lsl(6).lor(buf[idx + 2].land(0x3F)),
        ),
      ),
    )
  } else if b.land(0xF8) == 0xF0 {
    (
      4,
      Char::from_int(
        b.land(0x07).lsl(18).lor(
          buf[idx + 1].land(0x3F).lsl(12).lor(
            buf[idx + 2].land(0x3F).lsl(6).lor(buf[idx + 3].land(0x3F)),
          ),
        ),
      ),
    )
  } else {
    raise "invalid utf8"
  }
}

fn read_rune_utf16(buf : Bytes, idx : Int) -> (Int, Char)! {
  let b1 = buf[idx]
  let b2 = buf[idx + 1]
  if b1 < 0xD8 || b1 >= 0xE0 {
    (2, Char::from_int(b1.lsl(8).lor(b2)))
  } else {
    let b3 = buf[idx + 2]
    let b4 = buf[idx + 3]
    (4, Char::from_int(b1.lsl(8).lor(b2).lsl(10).lor(b3.lsl(8).lor(b4))))
  }
}

fn read_rune_utf32(buf : Bytes, idx : Int) -> (Int, Char) {
  let c = Char::from_int(
    buf[idx].lsl(24).lor(
      buf[idx + 1].lsl(16).lor(buf[idx + 2].lsl(8).lor(buf[idx + 3])),
    ),
  )
  (4, c)
}

fn read_rune_encoding(
  buf : Bytes,
  idx : Int,
  encoding : Encoding
) -> (Int, Char) {
  match encoding {
    Encoding::Utf8 => read_rune_utf8(buf, idx)
    Encoding::Utf16 => read_rune_utf16(buf, idx)
    Encoding::Utf32 => read_rune_utf32(buf, idx)
  }
}

fn write_rune_utf8(buf : Bytes, idx : Int, r : Char) -> Int {
  let r = r.to_int()
  if r < 0x80 {
    buf[idx] = r
    1
  } else if r < 0x800 {
    buf[idx] = (0xC0).lor(r.lsr(6))
    buf[idx + 1] = (0x80).lor(r.land(0x3F))
    2
  } else if r < 0x10000 {
    buf[idx] = (0xE0).lor(r.lsr(12))
    buf[idx + 1] = (0x80).lor(r.lsr(6).land(0x3F))
    buf[idx + 2] = (0x80).lor(r.land(0x3F))
    3
  } else if r < 0x110000 {
    buf[idx] = (0xF0).lor(r.lsr(18))
    buf[idx + 1] = (0x80).lor(r.lsr(12).land(0x3F))
    buf[idx + 2] = (0x80).lor(r.lsr(6).land(0x3F))
    buf[idx + 3] = (0x80).lor(r.land(0x3F))
    4
  } else {
    abort("invalid rune")
  }
}

fn write_rune_utf16(buf : Bytes, idx : Int, r : Char) -> Int {
  let r = r.to_int()
  if r < 0x10000 {
    buf[idx] = r.lsr(8)
    buf[idx + 1] = r.land(0xFF)
    2
  } else {
    let r = r - 0x10000
    buf[idx] = (0xD8).lor(r.lsr(18))
    buf[idx + 1] = (0xDC).lor(r.lsr(10).land(0x3F))
    buf[idx + 2] = r.lsr(8).land(0xFF)
    buf[idx + 3] = r.land(0xFF)
    4
  }
}

fn write_rune_utf32(buf : Bytes, idx : Int, r : Char) -> Int {
  let r = r.to_int()
  buf[idx] = r.lsr(24)
  buf[idx + 1] = r.lsr(16).land(0xFF)
  buf[idx + 2] = r.lsr(8).land(0xFF)
  buf[idx + 3] = r.land(0xFF)
  4
}

fn write_rune_encoding(
  buf : Bytes,
  idx : Int,
  r : Char,
  encoding : Encoding
) -> Int {
  match encoding {
    Encoding::Utf8 => write_rune_utf8(buf, idx, r)
    Encoding::Utf16 => write_rune_utf16(buf, idx, r)
    Encoding::Utf32 => write_rune_utf32(buf, idx, r)
  }
}

fn reencode_bytes(
  s : Bytes,
  s_len : Int,
  src_encoding : Encoding,
  dst_encoding : Encoding
) -> (Bytes, Int) {
  if src_encoding == dst_encoding {
    return (s, s_len)
  }
  let buf = ABuffer::empty()
  let src_len = s_len
  let mut src_idx = 0
  let mut dst_idx = 0
  while src_idx < src_len {
    let (src_diff, r) = read_rune_encoding(s, src_idx, src_encoding)
    src_idx += src_diff
    buf.reserve(dst_idx + max_char_len)
    let dst_diff = write_rune_encoding(buf.bytes(), dst_idx, r, dst_encoding)
    buf.set_len(dst_idx + dst_diff)
    dst_idx += dst_diff
  }
  (buf.bytes(), buf.len())
}
