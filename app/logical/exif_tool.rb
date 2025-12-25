# frozen_string_literal: true

require "shellwords"

# A wrapper for the exiftool command.
class ExifTool
  extend Memoist

  # @see https://exiftool.org/exiftool_pod.html#OPTIONS
  DEFAULT_OPTIONS = %q(
    -G1 -duplicates -unknown -struct --binary
    -x 'System:*' -x ExifToolVersion -x FileTypeExtension
    -x MIMEType -x ImageSize -x MegaPixels
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
    json = output.parse_json.first
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

    def merge(...)
      Metadata.new(metadata.merge(...))
    end

    def reject(...)
      Metadata.new(metadata.reject(...))
    end

    def is_animated?
      frame_count.to_i > 1 || is_animated_webp? || is_animated_avif?
    end

    def is_animated_gif?
      file_ext == :gif && is_animated?
    end

    def is_animated_png?
      file_ext == :png && is_animated?
    end

    def is_animated_webp?
      file_ext == :webp && metadata["RIFF:Duration"].present?
    end

    def is_animated_avif?
      file_ext == :avif && metadata["QuickTime:CompatibleBrands"].to_a.include?("avis")
    end

    # @see https://exiftool.org/TagNames/JPEG.html
    # @see https://exiftool.org/TagNames/PNG.html
    # @see https://danbooru.donmai.us/posts?tags=exif:File:ColorComponents=1
    # @see https://danbooru.donmai.us/posts?tags=exif:PNG:ColorType=Grayscale
    def is_greyscale?
      metadata["File:ColorComponents"] == 1 ||
        metadata["PNG:ColorType"] == "Grayscale" ||
        metadata["PNG:ColorType"] == "Grayscale with Alpha" ||
        metadata["QuickTime:ChromaFormat"].to_s.match?(/Monochrome/) # "Monochrome 4:0:0"
    end

    # https://exiftool.org/TagNames/EXIF.html
    def is_rotated?
      case file_ext
      when :jpg
        metadata["IFD0:Orientation"].in?(["Rotate 90 CW", "Rotate 270 CW", "Rotate 180"])
      when :avif
        metadata["QuickTime:Rotation"].present?
      else
        false
      end
    end

    # AVIF files can be cropped with the "CleanAperture" (aka "clap") tag.
    def is_cropped?
      file_ext == :avif && metadata["QuickTime:CleanAperture"].present?
    end

    # AVIF files can be a collection of smaller images combined in a grid to
    # form a larger image. This is done to reduce memory usage during encoding.
    #
    # https://0xc0000054.github.io/pdn-avif/using-image-grids.html
    def is_grid_image?
      file_ext == :avif && metadata["Meta:MetaImageSize"].present?
    end

    # Some animations technically have a finite loop count, but loop for hundreds
    # or thousands of times. Only count animations with a low loop count as non-repeating.
    def is_non_repeating_animation?
      loop_count.in?(0..10)
    end

    # https://danbooru.donmai.us/posts?tags=exif:PNG:Software=NovelAI
    # https://danbooru.donmai.us/posts?tags=exif:"PNG:Title=AI generated image"
    # https://danbooru.donmai.us/posts?tags=exif:PNG:Parameters
    # https://danbooru.donmai.us/posts?tags=exif:PNG:Sd-metadata
    # https://danbooru.donmai.us/posts?tags=exif:PNG:Dream
    def is_ai_generated?
      metadata["PNG:Software"] == "NovelAI" ||
        metadata["PNG:Title"] == "AI generated image" ||
        metadata["PNG:Description"]&.match?(/masterpiece|best quality/) ||
        metadata.has_key?("PNG:Parameters") ||
        metadata.has_key?("PNG:Sd-metadata") ||
        metadata.has_key?("PNG:Dream")
    end

    # True if the video has audible sound. False if the video doesn't have an audio track, or the audio track is inaudible.
    def has_sound?
      metadata["FFmpeg:AudioPeakLoudness"].to_f >= 0.0003 # -70 dB
    end

    def width
      metadata.find { |name, value| name.match?(/\A(File|PNG|GIF|RIFF|Flash|Track\d+):ImageWidth\z/) }&.second
    end

    def height
      metadata.find { |name, value| name.match?(/\A(File|PNG|GIF|RIFF|Flash|Track\d+):ImageHeight\z/) }&.second
    end

    # @see http://www.vurdalakov.net/misc/gif/netscape-looping-application-extension
    # @see https://wiki.mozilla.org/APNG_Specification#.60acTL.60:_The_Animation_Control_Chunk
    # @see https://danbooru.donmai.us/posts?tags=-exif:GIF:AnimationIterations=Infinite+animated_gif
    # @see https://danbooru.donmai.us/posts?tags=-exif:PNG:AnimationPlays=inf+animated_png
    def loop_count
      return Float::INFINITY if metadata["GIF:AnimationIterations"] == "Infinite"
      return Float::INFINITY if metadata["PNG:AnimationPlays"] == "inf"
      return Float::INFINITY if metadata["RIFF:AnimationLoopCount"] == "inf"
      return metadata["GIF:AnimationIterations"] if has_key?("GIF:AnimationIterations")
      return metadata["PNG:AnimationPlays"] if has_key?("PNG:AnimationPlays")
      return metadata["RIFF:AnimationLoopCount"] if has_key?("RIFF:AnimationLoopCount")

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
      elsif metadata["QuickTime:CompatibleBrands"].to_a.include?("avif") || metadata["QuickTime:CompatibleBrands"].to_a.include?("avis")
        :avif
      elsif has_key?("QuickTime:MovieHeaderVersion")
        :mp4
      elsif keys.grep(/\ARIFF:/).any?
        :webp
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
