require 'test_helper'

module Downloads
  class NicoSeigaTest < ActiveSupport::TestCase
    context "a download for a nico seiga image" do
      setup do
        # @source = "http://img.tinami.com/illust2/img/330/4e85ecd880a8f.jpg"
        # @tempfile = Tempfile.new("danbooru-test")
        # @download = Downloads::File.new(@source, @tempfile.path)
      end

      should "work" do
        # @download.download!
        # assert_equal(201248, ::File.size(@tempfile.path))
      end
    end
  end
end
