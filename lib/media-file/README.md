# MediaFile

Danbooru's library for reading, validating, and resizing uploaded images, videos, and ugoiras. It doesn't depend on
Rails, so it can be used on its own.

Untrusted files are only parsed by external programs (ffmpeg, ffprobe, mkvmerge, exiftool, and the `bin/archive` and
`bin/image` helper scripts) running in a sandbox (see `MediaFile::ExternalCommand`). The sandbox needs Linux 5.13+ with
Landlock enabled. Set `MediaFile.config.sandbox = false` on kernels without it.

# Installation

Needs libvips, ffmpeg, mkvmerge, exiftool, libarchive, libseccomp, and setpriv. See the Dockerfile in the root of the
Danbooru repo for the versions we use.

```bash
bin/bundle install
bin/rake test
```

# Usage

```ruby
require "media_file"

MediaFile.configure do |config|
  config.max_image_resolution = 10_000 * 10_000
end

MediaFile.open("test/files/jpg/test.jpg") do |file|
  file.dimensions       # => [500, 335]
  file.md5              # => "ecef68c44edb8a0d6a3070b5f8e8ee76"
  file.preview!(150, 150, format: :webp, quality: 75)
end
```

```bash
bin/media-ls -l test/files/jpg     # List the properties of media files.
bin/media-conv -o out.webm test/files/ugoira/ugoira-95239241-danbooru.zip   # Convert a ugoira to a video.
```

# Development

```bash
bin/rake test
bin/rake test TEST=test/unit/media_file_jpg_test.rb
```
