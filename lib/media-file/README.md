# MediaFile

Danbooru's library for reading, validating, and resizing uploaded images, videos, and ugoiras, and for reading and
extracting archives. It doesn't depend on Rails, so it can be used on its own, or from the command line with
`bin/media-cli`.

Untrusted files are only parsed by external programs (ffmpeg, ffprobe, mkvmerge, exiftool, and the `libexec/archive` and
`libexec/image` helper scripts) running in a sandbox (see `MediaFile::ExternalCommand`). The sandbox needs Linux 5.13+ with
Landlock enabled. On kernels without it, set `MediaFile.config.sandbox = false`, or set the
`MEDIA_FILE_DISABLE_SANDBOX=true` environment variable.

# Installation

Needs libvips, ffmpeg, mkvmerge, exiftool, libarchive, libseccomp, and setpriv. See the Dockerfile in the root of the
Danbooru repo for the versions we use. `bin/media-cli doctor` checks that they're installed.

```bash
bin/bundle install
bin/rake test
```

# Usage

## Reading files

`MediaFile.open` detects the file's type from its contents and returns a `MediaFile::Image`, `MediaFile::Video`,
`MediaFile::Ugoira`, or `MediaFile::Flash`, or a plain `MediaFile` for other files. With a block, the file is closed
afterwards.

```ruby
require "media_file"

MediaFile.open("test/files/jpg/test.jpg") do |file|
  file.file_ext         # => :jpg
  file.dimensions       # => [500, 335]
  file.md5              # => "ecef68c44edb8a0d6a3070b5f8e8ee76"
  file.pixel_hash       # => "01cb481ec7730b7cfced57ffa5abd196" (the same for images with the same pixels)
  file.metadata         # => The ExifTool metadata, plus ffmpeg's for videos and the frame delays for ugoiras.

  file.validate!(max_duration: 140)                           # Raises MediaFile::InvalidFileError if it's invalid.
  file.preview!(150, 150, format: :webp, quality: 75)         # Returns a MediaFile::Image.
end
```

Ugoiras without an `animation.json` file need their frame delays, in milliseconds:

```ruby
MediaFile.open("ugoira.zip", frame_delays: [100, 100, 200]).convert(format: :webm)
```

## Archives

```ruby
MediaFile::Archive.open!("upload.zip") do |archive|
  archive.validate!(max_files: 100, max_size: 100.megabytes) # Raises MediaFile::Archive::InvalidArchiveError.
  archive.extract! { |dir, files| ... }                       # Extracted to a temp directory, deleted afterwards.
end
```

## Errors

Every error the library raises is a `MediaFile::Error`.

* `MediaFile::InvalidFileError` and its subclasses are caused by the file itself, like a corrupt file or one over the
  limits. Their `user_message` is written for users.
* `MediaFile::TimeoutError` is an `InvalidFileError` for files that take too long to process.
* Other errors, like `MediaFile::FFmpeg::Error` or the sandbox's `MediaFile::ExternalCommand::Error`, aren't caused by
  the file. Their `message` may contain file paths or program output, so their `user_message` is generic.
* `MediaFile::ExternalCommand::SyscallError` means a program called a syscall the sandbox blocks. The file may be an
  attempt to exploit the program. `SyscallError.find_in(error)` finds it, even when it's wrapped in another error.

## Configuration

`lib/media_file/config.rb` has everything the library declares: the types it can read (`SUPPORTED_IMAGE_TYPES`,
`SUPPORTED_VIDEO_TYPES`, `SUPPORTED_ARCHIVE_TYPES`), their MIME types, and the settings apps can change:

```ruby
MediaFile.configure do |config|
  config.logger = Rails.logger
  config.sandbox = true
  config.max_file_size = 100.megabytes
  config.max_image_resolution = 21_000 * 21_000
  config.max_image_width = 40_000
  config.max_image_height = 40_000
  config.max_concurrency = 4
end
```

`MediaFile.dependency_versions` returns the versions of the programs the library runs.

## Command line

```bash
bin/media-cli --help                                     # List the commands.
bin/media-cli analyze -l test/files/jpg                  # List the properties of media files, like `ls`.
bin/media-cli analyze -d -j test/files/jpg/test.jpg      # Print all the properties, including the metadata, as JSON.
bin/media-cli analyze --test-case test/files/jpg/test.jpg  # Print a test that checks a file's properties.
bin/media-cli validate test/files/jpg/test.jpg           # Check that files can be processed safely.
bin/media-cli preview -s 300x300 test/files/jpg/test.jpg # Make a thumbnail.
bin/media-cli convert -o out.webm test/files/ugoira/ugoira-95239241-danbooru.zip   # Convert a ugoira to a video.
bin/media-cli hash test/files/jpg/test.jpg               # Print the MD5 and pixel hash.
bin/media-cli archive test/files/archive/ugoira.7z       # List an archive's files and check that it's safe.
bin/media-cli doctor                                     # Check that the programs the library needs are installed.
```

`analyze` and `validate` take `--frame-delays=100,100,200` for ugoiras without an `animation.json` file.

# Layout

* `lib/media_file.rb`: `MediaFile`, the base class, and its errors.
* `lib/media_file/config.rb`: the supported types and the settings.
* `lib/media_file/{image,video,ugoira,flash}.rb`: the subclasses for each type of file.
* `lib/media_file/{ffmpeg,exif_tool,archive}.rb`: wrappers for the programs that read the files.
* `lib/media_file/{external_command,landlock,seccomp}.rb`: the sandbox the programs run in.
* `lib/media_file/cli.rb`, `lib/media_file/cli/analyze.rb`: `bin/media-cli`.
* `libexec/`: the helper scripts that run libvips and libarchive inside the sandbox. They're run by the library, not
  by people.
* `test/files/`: the test files, also used by Danbooru's tests.

# Development

```bash
bin/rake test
bin/rake test TEST=test/unit/media_file_jpg_test.rb
```

To add a test for a new file, put it in `test/files/` and paste the output of `bin/media-cli analyze --test-case` into
the test for its type.
