# DText

A Ruby library for parsing [DText](https://danbooru.donmai.us/wiki_pages/help:dtext),
[Danbooru](https://github.com/danbooru/danbooru)'s text formatting language.

# Installation

```bash
sudo apt-get install build-essential ragel libglib2.0-dev
bundle exec rake install
```

# Usage

```bash
ruby -rdtext -e 'puts DTextRagel.parse("hello world")
# => <p>hello world</p>
```

# Development

```bash
bundle exec rake compile
bundle exec rake test
```
