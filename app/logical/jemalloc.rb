# frozen_string_literal: true

# Interface to the jemalloc library. Used to get memory usage statistics.
#
# https://jemalloc.net/jemalloc.3.html
# https://github.com/jemalloc/jemalloc/Wiki/Use-Case:-Introspection-Via-mallctl*()
module Jemalloc
  class Error < StandardError; end

  extend FFI::Library

  begin
    ffi_lib FFI::CURRENT_PROCESS

    # int mallctl(const char *name, void *oldp, size_t *oldlenp, void *newp, size_t newlen);
    attach_function :mallctl, [:string, :buffer_in, :pointer, :buffer_out, :size_t], :int

    def self.mallctl!(name, oldp, oldlenp, newp, newlen)
      ret = mallctl(name, oldp, oldlenp, newp, newlen)
      raise Error if ret != 0
    end
  rescue FFI::NotFoundError
    def self.mallctl!(...)
      raise Error
    end
  end

  def self.enabled?
    version.present?
  end

  def self.version
    get("version", :string)
  end

  def self.thread_count
    get("stats.background_thread.num_threads")
  end

  def self.allocated
    get("stats.allocated")
  end

  def self.active
    get("stats.active")
  end

  def self.metadata
    get("stats.metadata")
  end

  def self.resident
    get("stats.resident")
  end

  def self.mapped
    get("stats.mapped")
  end

  def self.retained
    get("stats.retained")
  end

  # Get the value of a stat. This will return the same value every time until `update_stats!` is called.
  #
  # @param name [String] The name of the stat.
  # @param type [Symbol] The type of the stat.
  # @return [Integer] The value of the stat.
  def self.get(name, type = :size_t)
    stat = FFI::MemoryPointer.new(type, 1)
    size = FFI::MemoryPointer.new(:size_t, 1)
    size.write(:size_t, stat.size)

    mallctl!(name, stat, size, nil, 0)
    stat.read(type)
  rescue Error
    nil
  end

  # Update cached stats. This must be called before collecting stats to generate new stats.
  #
  # @return [Integer] The number of times stats have been updated.
  def self.update_stats!
    stat = FFI::MemoryPointer.new(:uint64_t, 1)
    size = FFI::MemoryPointer.new(:size_t, 1)
    size.write(:size_t, stat.size)

    mallctl!("epoch", stat, size, stat, size.size)
    stat.read(:uint64_t)
  rescue Error
    nil
  end
end
