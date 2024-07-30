type AString Bytes

pub fn AString::from_string(s : String) -> AString {
  let res = @encoding.reencode_bytes_lossy()
  abort("todo")
}
