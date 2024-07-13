pub fn iterate_utf8_chars(buf : Bytes, start : Int, end : Int) -> Iter[Char] {
  Iter::new(
    fn(yield) {
      let mut curr = start
      while curr < end {
        let (size, ch) = read_rune_utf8_lossy(buf, curr)
        curr += size
        if yield(ch) == IterEnd {
          break IterEnd
        }
      } else {
        IterContinue
      }
    },
  )
}

pub fn iterate_utf16be_chars(buf : Bytes, start : Int, end : Int) -> Iter[Char] {
  Iter::new(
    fn(yield) {
      let mut curr = start
      while curr < end {
        let (size, ch) = read_rune_utf16be_lossy(buf, curr)
        curr += size
        if yield(ch) == IterEnd {
          break IterEnd
        }
      } else {
        IterContinue
      }
    },
  )
}

pub fn iterate_utf16le_chars(buf : Bytes, start : Int, end : Int) -> Iter[Char] {
  Iter::new(
    fn(yield) {
      let mut curr = start
      while curr < end {
        let (size, ch) = read_rune_utf16le_lossy(buf, curr)
        curr += size
        if yield(ch) == IterEnd {
          break IterEnd
        }
      } else {
        IterContinue
      }
    },
  )
}

pub fn iterate_utf32be_chars(buf : Bytes, start : Int, end : Int) -> Iter[Char] {
  Iter::new(
    fn(yield) {
      let mut curr = start
      while curr < end {
        let (size, ch) = read_rune_utf32be_lossy(buf, curr)
        curr += size
        if yield(ch) == IterEnd {
          break IterEnd
        }
      } else {
        IterContinue
      }
    },
  )
}

pub fn iterate_utf32le_chars(buf : Bytes, start : Int, end : Int) -> Iter[Char] {
  Iter::new(
    fn(yield) {
      let mut curr = start
      while curr < end {
        let (size, ch) = read_rune_utf32le_lossy(buf, curr)
        curr += size
        if yield(ch) == IterEnd {
          break IterEnd
        }
      } else {
        IterContinue
      }
    },
  )
}

pub fn iterate_chars_encoding(
  buf : Bytes,
  start : Int,
  end : Int,
  encoding : ByteEncoding
) -> Iter[Char] {
  match encoding {
    ByteEncoding::Utf8 => iterate_utf8_chars(buf, start, end)
    ByteEncoding::Utf16BE => iterate_utf16be_chars(buf, start, end)
    ByteEncoding::Utf16LE => iterate_utf16le_chars(buf, start, end)
    ByteEncoding::Utf32BE => iterate_utf32be_chars(buf, start, end)
    ByteEncoding::Utf32LE => iterate_utf32le_chars(buf, start, end)
  }
}
