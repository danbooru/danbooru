require "test_helper"

class PixivUgoiraConverterTest < ActiveSupport::TestCase
  context "An ugoira converter" do
    setup do
      @url = "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=46378654"
      @agent = begin
        mech = Mechanize.new

        phpsessid = Cache.get("pixiv-phpsessid")
        if phpsessid
          cookie = Mechanize::Cookie.new("PHPSESSID", phpsessid)
          cookie.domain = ".pixiv.net"
          cookie.path = "/"
          mech.cookie_jar.add(cookie)
        else
          mech.get("http://www.pixiv.net") do |page|
            page.form_with(:action => "/login.php") do |form|
              form['pixiv_id'] = Danbooru.config.pixiv_login
              form['pass'] = Danbooru.config.pixiv_password
            end.click_button
          end
          phpsessid = mech.cookie_jar.cookies.select{|c| c.name == "PHPSESSID"}.first
          Cache.put("pixiv-phpsessid", phpsessid.value, 1.month) if phpsessid
        end

        mech
      end
      @write_file = Tempfile.new("output")
    end

    teardown do
      @write_file.unlink
    end

    should "output to gif" do
      @converter = PixivUgoiraConverter.new(@agent, @url, @write_file.path, :gif)
      VCR.use_cassette("ugoira-converter", :record => :new_episodes) do
        @converter.process
      end
      assert_operator(File.size(@converter.write_path), :>, 1_000)
    end

    should "output to webm" do
      @converter = PixivUgoiraConverter.new(@agent, @url, @write_file.path, :webm)
      VCR.use_cassette("ugoira-converter", :record => :new_episodes) do
        @converter.process
      end
      assert_operator(File.size(@converter.write_path), :>, 1_000)
    end

    should "output to apng" do
      @converter = PixivUgoiraConverter.new(@agent, @url, @write_file.path, :apng)
      VCR.use_cassette("ugoira-converter", :record => :new_episodes) do
        @converter.process
      end
      assert_operator(File.size(@converter.write_path), :>, 1_000)
    end
  end
end