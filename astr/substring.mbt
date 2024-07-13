struct AStr {
  str : AString
  start : Int
  end : Int
}

pub fn AString::sub(self : AString, start : Int, end : Int) -> AStr? {
  abort("todo")
}

pub fn AStr::sub(self : AStr, start : Int, end : Int) -> AStr? {
  if start < 0 || end > self.end - self.start || start > end {
    None
  } else {
    Some({ str: self.str, start: self.start + start, end: self.start + end })
  }
}
