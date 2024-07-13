# Aestus

An experimental encoding-agnostic string library for MoonBit. **Under heavy construction, not yet usable.**

## Rationale

UTF-16 isn't really a good choice for strings. You lose compatibility with ASCII like UTF-8, and you lose direct codepoint indexing like UTF-32. It's in the middleground for compatibility with legacy systems nobody love, so we might as well just don't use UTF-16, or at least, enclose it into something that we can easily swap away.

## Design

Design reference: https://swiftdoc.org/v5.1/type/string/

For Aestus, a string is a list of Unicode code points (`Char`s). The user should make no assumptions about the underlying encoding.

You can view the string as:
- A collection of Unicode scalars (default)
- A collection of UTF-16 code points
- A collection of UTF-8 code points

A string is _not_ indexable, unless you get the index from one of the three views, which are only iterable.

## License

Copyright (c) 2024 Rynco Maekawa under MIT.

---

Aestus is named after [Sinus Aestuum](https://en.m.wikipedia.org/wiki/Sinus_Aestuum).
