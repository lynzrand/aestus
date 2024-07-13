pub fn len_utf8(ch : Char) -> Int {
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

pub fn len_utf16(ch : Char) -> Int {
  let ch = ch.to_int()
  if ch < 0x10000 {
    2
  } else {
    4
  }
}

pub fn len_utf32(_ch : Char) -> Int {
  4
}

let max_char_len = 4

fn read_rune_utf8(buf : Bytes, idx : Int) -> (Int, Char)! {
  let b = buf[idx].to_int()
  if b.land(0x80) == 0 {
    (1, Char::from_int(b))
  } else if b.land(0xE0) == 0xC0 {
    let b1 = b.land(0x1f)
    let b2 = buf[idx + 1].to_int().land(0x3f)
    let ch = b1.lsl(6).lor(b2)
    (2, Char::from_int(ch))
  } else if b.land(0xF0) == 0xE0 {
    let b1 = b.land(0x0F)
    let b2 = buf[idx + 1].to_int().land(0x3F)
    let b3 = buf[idx + 2].to_int().land(0x3F)
    let ch = b1.lsl(12).lor(b2.lsl(6).lor(b3))
    (3, Char::from_int(ch))
  } else if b.land(0xF8) == 0xF0 {
    let b1 = b.land(0x07)
    let b2 = buf[idx + 1].to_int().land(0x3F)
    let b3 = buf[idx + 2].to_int().land(0x3F)
    let b4 = buf[idx + 3].to_int().land(0x3F)
    let ch = b1.lsl(18).lor(b2.lsl(12).lor(b3.lsl(6).lor(b4)))
    (4, Char::from_int(ch))
  } else {
    raise "invalid utf8"
  }
}

fn combine_utf16_codepoints(hi : Int, lo : Int) -> Char! {
  // check validness
  if hi < 0xD800 || hi >= 0xDC00 {
    raise "invalid utf16: invalid high surrogate"
  }
  if lo < 0xDC00 || lo >= 0xE000 {
    raise "invalid utf16: invalid low surrogate"
  }
  Char::from_int(0x10000 + (hi - 0xD800) * 0x400 + (lo - 0xDC00))
}

fn read_rune_utf16be(buf : Bytes, idx : Int) -> (Int, Char)! {
  // check buffer length
  if buf.length() < idx + 2 {
    raise "invalid utf16"
  }
  let b1 = buf[idx].to_int()
  let b2 = buf[idx + 1].to_int()
  if b1 < 0xD8 || b1 >= 0xE0 {
    (2, Char::from_int(b1.lsl(8).lor(b2)))
  } else {
    // check buffer length
    if buf.length() < idx + 4 {
      raise "invalid utf16"
    }
    let b3 = buf[idx + 2].to_int()
    let b4 = buf[idx + 3].to_int()
    // convert to utf-16 codepoints
    let hi = b1.lsl(8).lor(b2)
    let lo = b3.lsl(8).lor(b4)
    (4, combine_utf16_codepoints(hi, lo)!)
  }
}

fn read_rune_utf16le(buf : Bytes, idx : Int) -> (Int, Char)! {
  // check buffer length
  if buf.length() < idx + 2 {
    raise "invalid utf16"
  }
  let b1 = buf[idx].to_int()
  let b2 = buf[idx + 1].to_int()
  if b2 < 0xD8 || b2 >= 0xE0 {
    (2, Char::from_int(b2.lsl(8).lor(b1)))
  } else {
    // check buffer length
    if buf.length() < idx + 4 {
      raise "invalid utf16"
    }
    let b3 = buf[idx + 2].to_int()
    let b4 = buf[idx + 3].to_int()
    // convert to utf-16 codepoints
    let hi = b2.lsl(8).lor(b1)
    let lo = b4.lsl(8).lor(b3)
    (4, combine_utf16_codepoints(hi, lo)!)
  }
}

fn read_rune_utf32be(buf : Bytes, idx : Int) -> (Int, Char)! {
  // check buffer length
  if buf.length() < idx + 4 {
    raise "invalid utf32"
  }
  let b1 = buf[idx].to_int()
  let b2 = buf[idx + 1].to_int()
  let b3 = buf[idx + 2].to_int()
  let b4 = buf[idx + 3].to_int()
  (4, Char::from_int(b1.lsl(24).lor(b2.lsl(16).lor(b3.lsl(8).lor(b4)))))
}

fn read_rune_utf32le(buf : Bytes, idx : Int) -> (Int, Char)! {
  // check buffer length
  if buf.length() < idx + 4 {
    raise "invalid utf32"
  }
  let b1 = buf[idx].to_int()
  let b2 = buf[idx + 1].to_int()
  let b3 = buf[idx + 2].to_int()
  let b4 = buf[idx + 3].to_int()
  (4, Char::from_int(b4.lsl(24).lor(b3.lsl(16).lor(b2.lsl(8).lor(b1)))))
}

fn read_rune_encoding(
  buf : Bytes,
  idx : Int,
  encoding : ByteEncoding
) -> (Int, Char)! {
  match encoding {
    ByteEncoding::Utf8 => read_rune_utf8(buf, idx)!
    ByteEncoding::Utf16BE => read_rune_utf16be(buf, idx)!
    ByteEncoding::Utf16LE => read_rune_utf16le(buf, idx)!
    ByteEncoding::Utf32BE => read_rune_utf32be(buf, idx)!
    ByteEncoding::Utf32LE => read_rune_utf32le(buf, idx)!
  }
}

// lossy
fn read_rune_utf8_lossy(buf : Bytes, idx : Int) -> (Int, Char) {
  match read_rune_utf8(buf, idx)!! {
    Ok(v) => v
    Err(_) => (1, Char::from_int(0xFFFD))
  }
}

fn read_rune_utf16be_lossy(buf : Bytes, idx : Int) -> (Int, Char) {
  match read_rune_utf16be(buf, idx)!! {
    Ok(v) => v
    Err(_) => (2, Char::from_int(0xFFFD))
  }
}

fn read_rune_utf16le_lossy(buf : Bytes, idx : Int) -> (Int, Char) {
  match read_rune_utf16le(buf, idx)!! {
    Ok(v) => v
    Err(_) => (2, Char::from_int(0xFFFD))
  }
}

fn read_rune_utf32be_lossy(buf : Bytes, idx : Int) -> (Int, Char) {
  match read_rune_utf32be(buf, idx)!! {
    Ok(v) => v
    Err(_) => (4, Char::from_int(0xFFFD))
  }
}

fn read_rune_utf32le_lossy(buf : Bytes, idx : Int) -> (Int, Char) {
  match read_rune_utf32le(buf, idx)!! {
    Ok(v) => v
    Err(_) => (4, Char::from_int(0xFFFD))
  }
}

fn read_rune_encoding_lossy(
  buf : Bytes,
  idx : Int,
  encoding : ByteEncoding
) -> (Int, Char) {
  match encoding {
    ByteEncoding::Utf8 => read_rune_utf8_lossy(buf, idx)
    ByteEncoding::Utf16BE => read_rune_utf16be_lossy(buf, idx)
    ByteEncoding::Utf16LE => read_rune_utf16le_lossy(buf, idx)
    ByteEncoding::Utf32BE => read_rune_utf32be_lossy(buf, idx)
    ByteEncoding::Utf32LE => read_rune_utf32le_lossy(buf, idx)
  }
}

fn write_rune_utf8(buf : Bytes, idx : Int, r : Char) -> Int {
  let r = r.to_int()
  if r < 0x80 {
    buf[idx] = r.to_byte()
    1
  } else if r < 0x800 {
    buf[idx] = (0xC0).lor(r.lsr(6)).to_byte()
    buf[idx + 1] = (0x80).lor(r.land(0x3F)).to_byte()
    2
  } else if r < 0x10000 {
    buf[idx] = (0xE0).lor(r.lsr(12)).to_byte()
    buf[idx + 1] = (0x80).lor(r.lsr(6).land(0x3F)).to_byte()
    buf[idx + 2] = (0x80).lor(r.land(0x3F)).to_byte()
    3
  } else if r < 0x110000 {
    buf[idx] = (0xF0).lor(r.lsr(18)).to_byte()
    buf[idx + 1] = (0x80).lor(r.lsr(12).land(0x3F)).to_byte()
    buf[idx + 2] = (0x80).lor(r.lsr(6).land(0x3F)).to_byte()
    buf[idx + 3] = (0x80).lor(r.land(0x3F)).to_byte()
    4
  } else {
    abort("invalid rune")
  }
}

fn decompose_utf16_codepoint(r : Int) -> (Int, Int) {
  let r = r - 0x10000
  let hi = 0xD800 + r.lsr(10)
  let lo = 0xDC00 + r.land(0x3FF)
  (hi, lo)
}

fn write_rune_utf16be(buf : Bytes, idx : Int, r : Char) -> Int {
  let r = r.to_int()
  if r < 0x10000 {
    buf[idx] = r.lsr(8).to_byte()
    buf[idx + 1] = r.land(0xFF).to_byte()
    2
  } else {
    let (hi, lo) = decompose_utf16_codepoint(r)
    buf[idx] = hi.lsr(8).to_byte()
    buf[idx + 1] = hi.land(0xFF).to_byte()
    buf[idx + 2] = lo.lsr(8).to_byte()
    buf[idx + 3] = lo.land(0xFF).to_byte()
    4
  }
}

fn write_rune_utf16le(buf : Bytes, idx : Int, r : Char) -> Int {
  let r = r.to_int()
  if r < 0x10000 {
    buf[idx] = r.land(0xFF).to_byte()
    buf[idx + 1] = r.lsr(8).to_byte()
    2
  } else {
    let (hi, lo) = decompose_utf16_codepoint(r)
    buf[idx] = hi.land(0xFF).to_byte()
    buf[idx + 1] = hi.lsr(8).to_byte()
    buf[idx + 2] = lo.land(0xFF).to_byte()
    buf[idx + 3] = lo.lsr(8).to_byte()
    4
  }
}

fn write_rune_utf32be(buf : Bytes, idx : Int, r : Char) -> Int {
  let r = r.to_int()
  buf[idx] = r.lsr(24).to_byte()
  buf[idx + 1] = r.lsr(16).land(0xFF).to_byte()
  buf[idx + 2] = r.lsr(8).land(0xFF).to_byte()
  buf[idx + 3] = r.land(0xFF).to_byte()
  4
}

fn write_rune_utf32le(buf : Bytes, idx : Int, r : Char) -> Int {
  let r = r.to_int()
  buf[idx] = r.land(0xFF).to_byte()
  buf[idx + 1] = r.lsr(8).land(0xFF).to_byte()
  buf[idx + 2] = r.lsr(16).land(0xFF).to_byte()
  buf[idx + 3] = r.lsr(24).to_byte()
  4
}

fn write_rune_encoding(
  buf : Bytes,
  idx : Int,
  r : Char,
  encoding : ByteEncoding
) -> Int {
  match encoding {
    ByteEncoding::Utf8 => write_rune_utf8(buf, idx, r)
    ByteEncoding::Utf16BE => write_rune_utf16be(buf, idx, r)
    ByteEncoding::Utf16LE => write_rune_utf16le(buf, idx, r)
    ByteEncoding::Utf32BE => write_rune_utf32be(buf, idx, r)
    ByteEncoding::Utf32LE => write_rune_utf32le(buf, idx, r)
  }
}

fn minimum_encoding_length(encoding : ByteEncoding) -> Int {
  match encoding {
    ByteEncoding::Utf8 => 1
    ByteEncoding::Utf16BE => 2
    ByteEncoding::Utf16LE => 2
    ByteEncoding::Utf32BE => 4
    ByteEncoding::Utf32LE => 4
  }
}

/// Reencode a byte slice from one encoding to another. This function checks for invalid encoding,
/// and replaces invalid runes with the Unicode replacement character U+FFFD.
pub fn reencode_bytes_lossy(
  s : Bytes,
  s_len : Int,
  src_encoding : ByteEncoding,
  dst_encoding : ByteEncoding
) -> (Bytes, Int) {
  if src_encoding == dst_encoding {
    return (s, s_len)
  }
  let buf = @abuf.ABuffer::empty()
  let src_len = s_len
  let mut src_idx = 0
  let mut dst_idx = 0
  while src_idx < src_len {
    let (src_diff, r) = read_rune_encoding_lossy(s, src_idx, src_encoding)
    src_idx += src_diff
    buf.reserve(dst_idx + max_char_len)
    let dst_diff = write_rune_encoding(buf.bytes(), dst_idx, r, dst_encoding)
    buf.set_len(dst_idx + dst_diff)
    dst_idx += dst_diff
  }
  (buf.bytes(), buf.len())
}

/// Reencode a byte slice from one encoding to another. This function returns an error if an invalid
/// rune is encountered.
pub fn reencode_bytes(
  s : Bytes,
  s_len : Int,
  src_encoding : ByteEncoding,
  dst_encoding : ByteEncoding
) -> (Bytes, Int)! {
  if src_encoding == dst_encoding {
    return (s, s_len)
  }
  let buf = @abuf.ABuffer::empty()
  let src_len = s_len
  let mut src_idx = 0
  let mut dst_idx = 0
  while src_idx < src_len {
    let (src_diff, r) = read_rune_encoding(s, src_idx, src_encoding)!
    src_idx += src_diff
    buf.reserve(dst_idx + max_char_len)
    let dst_diff = write_rune_encoding(buf.bytes(), dst_idx, r, dst_encoding)
    buf.set_len(dst_idx + dst_diff)
    dst_idx += dst_diff
  }
  (buf.bytes(), buf.len())
}
