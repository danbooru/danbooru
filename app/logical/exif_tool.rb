# frozen_string_literal: true

require "shellwords"

# A wrapper for the exiftool command.
class ExifTool
  extend Memoist

  # @see https://exiftool.org/exiftool_pod.html#OPTIONS
  DEFAULT_OPTIONS = %q(
    -G1 -duplicates -unknown -struct --binary
    -x 'System:*' -x ExifToolVersion -x FileType -x FileTypeExtension
    -x MIMEType -x ImageWidth -x ImageHeight -x ImageSize -x MegaPixels
  ).squish

  attr_reader :file

  # Open a file with ExifTool.
  #
  # @param file [File, String] an image or video file
  def initialize(file)
    @file = file.is_a?(String) ? File.open(file) : file
  end

  # Get the file's metadata.
  #
  # @param options [String] the options to pass to exiftool
  # @return [ExifTool::Metadata] the file's metadata
  def metadata(options: DEFAULT_OPTIONS)
    output = %x(exiftool #{options} -json #{file.path.shellescape})
    json = JSON.parse(output).first
    json = json.except("SourceFile")
    ExifTool::Metadata.new(json.with_indifferent_access)
  end
  memoize :metadata

  # A class representing the set of metadata returned by ExifTool for a file.
  # Behaves like a Hash, but with extra helper methods for interpreting the metadata.
  #
  # @see https://exiftool.org/TagNames/index.html
  class Metadata
    attr_reader :metadata
    delegate_missing_to :metadata

    # @param [Hash] a hash of metadata as returned by ExifTool
    def initialize(metadata)
      @metadata = metadata
    end

    def is_animated?
      frame_count.to_i > 1
    end

    def is_animated_gif?
      file_ext == :gif && is_animated?
    end

    def is_animated_png?
      file_ext == :png && is_animated?
    end

    # @see https://exiftool.org/TagNames/JPEG.html
    # @see https://exiftool.org/TagNames/PNG.html
    # @see https://danbooru.donmai.us/posts?tags=exif:File:ColorComponents=1
    # @see https://danbooru.donmai.us/posts?tags=exif:PNG:ColorType=Grayscale
    def is_greyscale?
      metadata["File:ColorComponents"] == 1 ||
        metadata["PNG:ColorType"] == "Grayscale" ||
        metadata["PNG:ColorType"] == "Grayscale with Alpha"
    end

    # https://exiftool.org/TagNames/EXIF.html
    def is_rotated?
      file_ext == :jpg && metadata["IFD0:Orientation"].in?(["Rotate 90 CW", "Rotate 270 CW", "Rotate 180"])
    end

    # Some animations technically have a finite loop count, but loop for hundreds
    # or thousands of times. Only count animations with a low loop count as non-repeating.
    def is_non_repeating_animation?
      loop_count.in?(0..10)
    end

    # https://danbooru.donmai.us/posts?tags=exif:PNG:Software=NovelAI
    # https://danbooru.donmai.us/posts?tags=exif:PNG:Parameters
    # https://danbooru.donmai.us/posts?tags=exif:PNG:Sd-metadata
    # https://danbooru.donmai.us/posts?tags=exif:PNG:Dream
    def is_ai_generated?
      metadata["PNG:Software"] == "NovelAI" ||
        metadata.has_key?("PNG:Parameters") ||
        metadata.has_key?("PNG:Sd-metadata") ||
        metadata.has_key?("PNG:Dream")
    end

    # @see http://www.vurdalakov.net/misc/gif/netscape-looping-application-extension
    # @see https://wiki.mozilla.org/APNG_Specification#.60acTL.60:_The_Animation_Control_Chunk
    # @see https://danbooru.donmai.us/posts?tags=-exif:GIF:AnimationIterations=Infinite+animated_gif
    # @see https://danbooru.donmai.us/posts?tags=-exif:PNG:AnimationPlays=inf+animated_png
    def loop_count
      return Float::INFINITY if metadata["GIF:AnimationIterations"] == "Infinite"
      return Float::INFINITY if metadata["PNG:AnimationPlays"] == "inf"
      return metadata["GIF:AnimationIterations"] if has_key?("GIF:AnimationIterations")
      return metadata["PNG:AnimationPlays"] if has_key?("PNG:AnimationPlays")

      # If the AnimationIterations tag isn't present, then it's counted as a loop count of 0.
      return 0 if is_animated_gif? && !has_key?("GIF:AnimationIterations")

      nil
    end

    def frame_count
      if file_ext == :gif
        fetch("GIF:FrameCount", 1)
      elsif file_ext == :png
        fetch("PNG:AnimationFrames", 1)
      else
        nil
      end
    end

    def file_ext
      if has_key?("File:ColorComponents")
        :jpg
      elsif has_key?("PNG:ColorType")
        :png
      elsif has_key?("GIF:GIFVersion")
        :gif
      elsif has_key?("QuickTime:MovieHeaderVersion")
        :mp4
      elsif has_key?("Matroska:DocType")
        :webm
      elsif has_key?("Flash:FlashVersion")
        :swf
      elsif has_key?("ZIP:ZipCompression")
        :ugoira
      end
    end
  end
end
