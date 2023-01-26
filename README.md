# DText

A Ruby library for parsing [DText](https://danbooru.donmai.us/wiki_pages/help:dtext),
[Danbooru](https://github.com/danbooru/danbooru)'s text formatting language.

# Installation

```bash
sudo apt-get install build-essential ragel
bin/rake install
```

# Usage

```bash
ruby -rdtext -e 'puts DText.parse("hello world")'
# => <p>hello world</p>
```

# Development

```bash
bin/rake compile
bin/rake test
```
