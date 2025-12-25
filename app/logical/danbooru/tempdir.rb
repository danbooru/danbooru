# frozen_string_literal: true

# Danbooru::Tempdir.create is like `Dir.mktmpdir`, except if it's used without a block it automatically cleans up the
# directory when the object is garbage collected.
module Danbooru
  class Tempdir
    attr_reader :path

    def self.create(*args, &block)
      return new(*args) unless block_given?

      tmpdir = new(*args)
      yield tmpdir
    ensure
      tmpdir&.close
    end

    def initialize(*args, &block)
      @path = Dir.mktmpdir(*args, &block)
      ObjectSpace.define_finalizer(self, self.class.finalizer(@path))
    end

    def close
      FileUtils.rm_rf(path, secure: true)
      ObjectSpace.undefine_finalizer(self)
    end

    def self.finalizer(path)
      proc do
        FileUtils.rm_rf(path, secure: true)
      end
    end
  end
end
