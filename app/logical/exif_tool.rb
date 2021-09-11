require "shellwords"

# A wrapper for the exiftool command.
class ExifTool
  extend Memoist

  class Error < StandardError; end

  # @see https://exiftool.org/exiftool_pod.html#OPTIONS
  DEFAULT_OPTIONS = %q(
    -G1 -duplicates -unknown -struct --binary
    -x 'System:*' -x ExifToolVersion -x FileType -x FileTypeExtension
    -x MIMEType -x ImageWidth -x ImageHeight -x ImageSize -x MegaPixels
  ).squish

  attr_reader :file

  # Open a file with ExifTool.
  # @param file [File, String] an image or video file
  def initialize(file)
    @file = file.is_a?(String) ? File.open(file) : file
  end

  # Get the file's metadata.
  # @see https://exiftool.org/TagNames/index.html
  # @param options [String] the options to pass to exiftool
  # @return [Hash] the file's metadata
  def metadata(options: DEFAULT_OPTIONS)
    output = shell!("exiftool #{options} -json #{file.path.shellescape}")
    json = JSON.parse(output).first
    json = json.except("SourceFile")
    json.with_indifferent_access
  end

  def shell!(command)
    output, status = Open3.capture2e(command)
    raise Error, "#{command}` failed: #{output}" if !status.success?
    output
  end

  memoize :metadata
end
