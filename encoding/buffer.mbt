trait UnderlyingBuffer {
  read_u8(Self, Int) -> Byte?
  read_u16_be(Self, Int) -> Int?
  read_u16_le(Self, Int) -> Int?
}

impl UnderlyingBuffer for Bytes with read_u8(self : Bytes, idx : Int) -> Byte? {
  if idx < 0 || idx >= self.length() {
    return None
  }
  Some(self[idx])
}

impl UnderlyingBuffer for Bytes with read_u16_be(self : Bytes, idx : Int) -> Int? {
  let b1 = UnderlyingBuffer::read_u8(self, idx)
  let b1 = match b1 {
    None => return None
    Some(x) => x
  }
  let b2 = UnderlyingBuffer::read_u8(self, idx + 1)
  let b2 = match b2 {
    None => return None
    Some(x) => x
  }
  Some(b1.to_int().lsl(8).lor(b2.to_int()))
}

impl UnderlyingBuffer for Bytes with read_u16_le(self : Bytes, idx : Int) -> Int? {
  let b1 = UnderlyingBuffer::read_u8(self, idx)
  let b1 = match b1 {
    None => return None
    Some(x) => x
  }
  let b2 = UnderlyingBuffer::read_u8(self, idx + 1)
  let b2 = match b2 {
    None => return None
    Some(x) => x
  }
  Some(b2.to_int().lsl(8).lor(b1.to_int()))
}

impl UnderlyingBuffer for String with read_u8(self : String, idx : Int) -> Byte? {
  return None
}

// strings are currently UTF-16 encoded, so no BE/LE distinction

impl UnderlyingBuffer for String with read_u16_be(self : String, idx : Int) -> Int? {
  let idx = idx / 2
  Some(self[idx].to_int())
}

impl UnderlyingBuffer for String with read_u16_le(self : String, idx : Int) -> Int? {
  let idx = idx / 2
  Some(self[idx].to_int())
}
