# DText

A Ruby library for parsing [DText](https://danbooru.donmai.us/wiki_pages/help:dtext),
[Danbooru](https://github.com/danbooru/danbooru)'s text formatting language.

# Installation

```bash
sudo apt-get install ruby ruby-dev g++ libc-dev make patch xz-utils ragel
gem install bundler
bundle install
bin/rake
```

# Usage

```bash
ruby -Ilib -rdtext -e 'puts DText.parse("hello world")'
# => <p>hello world</p>
```

# Development

```bash
bin/rake clean
bin/rake compile
bin/rake test
bin/rake bench
```

To build in debug mode:

```bash
bin/rake clean
DTEXT_DEBUG=true bin/rake compile
```

To build with Clang:

```bash
MAKE="make --environment-overrides" CXX="/usr/bin/clang++" bin/rake
```

To count how much work the parser does, build it with `DTEXT_COUNT_WORK=true`. Then `DText.work` returns the work
done by the last parse: one unit for each byte the parser reads, including bytes read again after backtracking, plus
the elements examined by loops in the action code. Unlike timing, the count is exact, so it shows superlinear growth
even on small inputs. The work per byte should stay the same as the input grows:

```bash
bin/rake clean
DTEXT_COUNT_WORK=true bin/rake compile
ruby -Ilib -rdtext -e '[1000, 2000, 4000, 8000].each { |n| s = "a" + " " * n + "b"; DText.parse(s); p DText.work.fdiv(s.size) }'
```

When you add a loop to the action code whose cost depends on the input, count it with the `DTEXT_WORK` macro in
`dtext.cpp.rl`. Rebuild without `DTEXT_COUNT_WORK` when you're done.
