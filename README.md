# Aestus

An experimental encoding-agnostic string library for MoonBit. **Under heavy construction, not yet usable.**

Design reference: https://swiftdoc.org/v5.1/type/string/

For Aestus, a string is a list of Unicode code points (`Char`s), irrelevant of the underlying encoding.

You can view the string as:
- A collection of Unicode scalars (default)
- A collection of UTF-16 code points
- A collection of UTF-8 code points

A string is _not_ indexable, unless you get the index from one of the three views, which are only iterable.

## License

Copyright (c) 2024 Rynco Maekawa under MIT.

---

Aestus is named after [Sinus Aestuum](https://en.m.wikipedia.org/wiki/Sinus_Aestuum).
