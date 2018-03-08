require "test_helper"

module Downloads
  class NicoSeigaTest < ActiveSupport::TestCase
    context "downloading a 'http://seiga.nicovideo.jp/seiga/:id' url" do
      should "download the original file" do
        @source = "http://seiga.nicovideo.jp/seiga/im4937663"
        @rewrite = %r!http://lohas.nicoseiga.jp/priv/\h{40}/\d+/4937663!
        assert_rewritten(@rewrite, @source)
        assert_downloaded(2032, @source)
      end
    end

    context "downloading a 'http://lohas.nicoseiga.jp/o/:hash/:id' url" do
      should "download the original file" do
        @source = "http://lohas.nicoseiga.jp/o/910aecf08e542285862954017f8a33a8c32a8aec/1433298801/4937663"
        @rewrite = %r!http://lohas.nicoseiga.jp/priv/\h{40}/\d+/4937663!
        assert_rewritten(@rewrite, @source)
        assert_downloaded(2032, @source)
      end
    end

    context "downloading a 'https://lohas.nicoseiga.jp/thumb/:id' url" do
      should "download the original file" do
        @source = "https://lohas.nicoseiga.jp/thumb/4937663i"
        @rewrite = %r!http://lohas.nicoseiga.jp/priv/\h{40}/\d+/4937663!
        assert_rewritten(@rewrite, @source)
        assert_downloaded(2032, @source)
      end
    end
  end
end
