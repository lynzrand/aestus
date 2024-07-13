struct ABuffer {
  mut data : Bytes
  mut len : Int
}

let min_abuffer_len = 16

pub fn ABuffer::make(capacity : Int) -> ABuffer {
  { data: Bytes::make(capacity, init=(0).to_byte()), len: 0 }
}

pub fn ABuffer::empty() -> ABuffer {
  ABuffer::make(0)
}

pub fn ABuffer::reserve(self : ABuffer, new_capacity : Int) -> Unit {
  if new_capacity <= self.data.length() {
    return
  }
  let old_data = self.data
  let new_data_len = old_data.length() * 3 / 2 + min_abuffer_len
  let new_data = Bytes::make(new_data_len, init=(0).to_byte())
  new_data.blit(0, old_data, 0, self.len)
  self.data = new_data
}

pub fn ABuffer::push_byte(self : ABuffer, byte : Byte) -> Unit {
  self.reserve(self.len + 1)
  self.data[self.len] = byte
  self.len = self.len + 1
}

pub fn ABuffer::push_bytes(self : ABuffer, bytes : Bytes) -> Unit {
  self.reserve(self.len + bytes.length())
  self.data.blit(self.len, bytes, 0, bytes.length())
  self.len = self.len + bytes.length()
}

pub fn ABuffer::bytes(self : ABuffer) -> Bytes {
  self.data
}

pub fn ABuffer::len(self : ABuffer) -> Int {
  self.len
}

pub fn ABuffer::set_len(self : ABuffer, len : Int) -> Unit {
  if len > self.data.length() {
    abort("ABuffer::set_len: len > capacity")
  }
  self.len = len
}
