require 'test_helper'

class PostReplacementTest < ActiveSupport::TestCase
  def upload_file(path, filename, &block)
    Tempfile.open do |file|
      file.write(File.read(path))
      file.seek(0)
      uploaded_file = ActionDispatch::Http::UploadedFile.new(tempfile: file, filename: filename)
      yield uploaded_file
    end
  end

  def setup
    super

    mock_iqdb_service!
    Delayed::Worker.delay_jobs = true # don't delete the old images right away

    @system = FactoryGirl.create(:user, created_at: 2.weeks.ago)
    User.stubs(:system).returns(@system)

    @uploader = FactoryGirl.create(:user, created_at: 2.weeks.ago, can_upload_free: true)
    @replacer = FactoryGirl.create(:user, created_at: 2.weeks.ago, can_approve_posts: true)
    CurrentUser.user = @replacer
    CurrentUser.ip_addr = "127.0.0.1"
  end

  def teardown
    super

    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
    Delayed::Worker.delay_jobs = false
  end

  context "Replacing" do
    setup do
      CurrentUser.scoped(@uploader, "127.0.0.2") do
        upload = FactoryGirl.create(:jpg_upload, as_pending: "0", tag_string: "lowres tag1")
        upload.process!
        @post = upload.post
      end
    end

    context "a post from a generic source" do
      setup do
        @post.update(source: "https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png")
        @post.replace!(replacement_url: "https://www.google.com/intl/en_ALL/images/logo.gif", tags: "-tag1 tag2")
        @replacement = @post.replacements.last
        @upload = Upload.last
      end

      context "that is then undone" do
        setup do
          Timecop.travel(Time.now + PostReplacement::DELETION_GRACE_PERIOD + 1.day) do
            Delayed::Worker.new.work_off
          end

          @replacement = @post.replacements.first
          @replacement.undo!
          @post.reload
        end

        should "update the attributes" do
          assert_equal("lowres tag2", @post.tag_string)
          assert_equal(272, @post.image_width)
          assert_equal(92, @post.image_height)
          assert_equal(5969, @post.file_size)
          assert_equal("png", @post.file_ext)
          assert_equal("8f9327db2597fa57d2f42b4a6c5a9855", @post.md5)
          assert_equal("8f9327db2597fa57d2f42b4a6c5a9855", Digest::MD5.file(@post.file_path).hexdigest)
          assert_equal("https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png", @post.source)
        end
      end

      should "create a post replacement record" do
        assert_equal(@post.id, PostReplacement.last.post_id)
      end

      should "record the old file metadata" do
        assert_equal(500, @replacement.image_width_was)
        assert_equal(335, @replacement.image_height_was)
        assert_equal(28086, @replacement.file_size_was)
        assert_equal("jpg", @replacement.file_ext_was)
        assert_equal("ecef68c44edb8a0d6a3070b5f8e8ee76", @replacement.md5_was)
      end

      should "record the new file metadata" do
        assert_equal(276, @replacement.image_width)
        assert_equal(110, @replacement.image_height)
        assert_equal(8558, @replacement.file_size)
        assert_equal("gif", @replacement.file_ext)
        assert_equal("e80d1c59a673f560785784fb1ac10959", @replacement.md5)
      end

      should "correctly update the attributes" do
        assert_equal(@post.id, @upload.post.id)
        assert_equal("completed", @upload.status)

        assert_equal(276, @post.image_width)
        assert_equal(110, @post.image_height)
        assert_equal(8558, @post.file_size)
        assert_equal("gif", @post.file_ext)
        assert_equal("e80d1c59a673f560785784fb1ac10959", @post.md5)
        assert_equal("e80d1c59a673f560785784fb1ac10959", Digest::MD5.file(@post.file_path).hexdigest)
        assert_equal("https://www.google.com/intl/en_ALL/images/logo.gif", @post.source)
      end

      should "not change the post status or uploader" do
        assert_equal("127.0.0.2", @post.uploader_ip_addr.to_s)
        assert_equal(@uploader.id, @post.uploader_id)
        assert_equal(false, @post.is_pending)
      end

      should "leave a system comment" do
        comment = @post.comments.last

        assert_not_nil(comment)
        assert_equal(User.system.id, comment.creator_id)
        assert_match(/replaced this post/, comment.body)
      end

      should "not send an @mention to the replacer" do
        assert_equal(0, @replacer.dmails.size)
      end
    end

    context "a post with notes" do
      setup do
        @post.update(image_width: 160, image_height: 164)
        CurrentUser.scoped(@uploader, "127.0.0.1") do
          @note = @post.notes.create(x: 80, y: 82, width: 80, height: 82, body: "test")
        end
      end

      should "rescale the notes" do
        assert_equal([80, 82, 80, 82], [@note.x, @note.y, @note.width, @note.height])

        assert_difference("@replacer.note_versions.count") do
          # replacement image is 80x82, so we're downscaling by 50% (160x164 -> 80x82).
          @post.replace!(replacement_url: "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247350")
          @note.reload
        end

        assert_equal([40, 41, 40, 41], [@note.x, @note.y, @note.width, @note.height])
      end
    end

    context "a post with a pixiv html source" do
      should "replace with the full size image" do
        @post.replace!(replacement_url: "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247350")

        assert_equal(80, @post.image_width)
        assert_equal(82, @post.image_height)
        assert_equal(16275, @post.file_size)
        assert_equal("png", @post.file_ext)
        assert_equal("4ceadc314938bc27f3574053a3e1459a", @post.md5)
        assert_equal("4ceadc314938bc27f3574053a3e1459a", Digest::MD5.file(@post.file_path).hexdigest)
        assert_equal("https://i.pximg.net/img-original/img/2017/04/04/08/54/15/62247350_p0.png", @post.source)
        assert_equal("https://i.pximg.net/img-original/img/2017/04/04/08/54/15/62247350_p0.png", @post.replacements.last.replacement_url)
      end

      should "delete the old files after three days" do
        old_file_path, old_preview_file_path, old_large_file_path = @post.file_path, @post.preview_file_path, @post.large_file_path
        @post.replace!(replacement_url: "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247350")

        assert(File.exists?(old_file_path))
        assert(File.exists?(old_preview_file_path))
        assert(File.exists?(old_large_file_path))

        Timecop.travel(Time.now + PostReplacement::DELETION_GRACE_PERIOD + 1.day) do
          Delayed::Worker.new.work_off
        end

        assert_not(File.exists?(old_file_path))
        assert_not(File.exists?(old_preview_file_path))
        assert_not(File.exists?(old_large_file_path))
      end
    end

    context "a post that is replaced by a ugoira" do
      should "save the frame data" do
        @post.replace!(replacement_url: "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247364")
        @post.reload

        assert_equal(80, @post.image_width)
        assert_equal(82, @post.image_height)
        assert_equal(2804, @post.file_size)
        assert_equal("zip", @post.file_ext)
        assert_equal("cad1da177ef309bf40a117c17b8eecf5", @post.md5)
        assert_equal("cad1da177ef309bf40a117c17b8eecf5", Digest::MD5.file(@post.file_path).hexdigest)

        assert_equal("https://i.pximg.net/img-zip-ugoira/img/2017/04/04/08/57/38/62247364_ugoira1920x1080.zip", @post.source)
        assert_equal([{"file"=>"000000.jpg", "delay"=>125}, {"file"=>"000001.jpg", "delay"=>125}], @post.pixiv_ugoira_frame_data.data)
      end
    end

    context "a post that is replaced to another file then replaced back to the original file" do
      should "not delete the original files" do
        @post.replace!(replacement_url: "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247350")
        @post.replace!(replacement_url: "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247364")
        @post.replace!(replacement_url: "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247350")

        assert(File.exists?(@post.file_path))
        assert(File.exists?(@post.preview_file_path))
        assert(File.exists?(@post.large_file_path))

        Timecop.travel(Time.now + PostReplacement::DELETION_GRACE_PERIOD + 1.day) do
          Delayed::Worker.new.work_off
        end

        assert(File.exists?(@post.file_path))
        assert(File.exists?(@post.preview_file_path))
        assert(File.exists?(@post.large_file_path))
      end
    end

    context "two posts that have had their files swapped" do
      should "not delete the still active files" do
        @post1 = FactoryGirl.create(:post)
        @post2 = FactoryGirl.create(:post)

        # swap the images between @post1 and @post2.
        @post1.replace!(replacement_url: "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247350")
        @post2.replace!(replacement_url: "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247364")
        @post2.replace!(replacement_url: "https://www.google.com/intl/en_ALL/images/logo.gif")
        @post1.replace!(replacement_url: "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247364")
        @post2.replace!(replacement_url: "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247350")

        Timecop.travel(Time.now + PostReplacement::DELETION_GRACE_PERIOD + 1.day) do
          Delayed::Worker.new.work_off
        end

        assert(File.exists?(@post1.file_path))
        assert(File.exists?(@post2.file_path))
      end
    end

    context "a post with an uploaded file" do
      should "work" do
        upload_file("#{Rails.root}/test/files/test.png", "test.png") do |file|
          @post.replace!(replacement_file: file, replacement_url: "")
          assert_equal(@post.md5, Digest::MD5.file(file.tempfile).hexdigest)
          assert_equal("file://test.png", @post.replacements.last.replacement_url)
        end
      end
    end

    context "a post when given a final_source" do
      should "change the source to the final_source" do
        replacement_url = "http://data.tumblr.com/afed9f5b3c33c39dc8c967e262955de2/tumblr_orwwptNBCE1wsfqepo1_raw.png"
        final_source = "https://noizave.tumblr.com/post/162094447052"
        @post.replace!(replacement_url: replacement_url, final_source: final_source)

        assert_equal(final_source, @post.source)
      end
    end

    context "a post when replaced with a HTML source" do
      should "record the image URL as the replacement URL, not the HTML source" do
        replacement_url = "https://twitter.com/nounproject/status/540944400767922176"
        image_url = "https://pbs.twimg.com/media/B4HSEP5CUAA4xyu.png:orig"
        @post.replace!(replacement_url: replacement_url)

        assert_equal(image_url, @post.replacements.last.replacement_url)
      end
    end

    context "a post with the same file" do
      should "not raise a duplicate error" do
        upload_file("#{Rails.root}/test/files/test.jpg", "test.jpg") do |file|
          assert_nothing_raised do
            @post.replace!(replacement_file: file, replacement_url: "")
          end
        end
      end

      should "not queue a deletion or log a comment" do
        upload_file("#{Rails.root}/test/files/test.jpg", "test.jpg") do |file|
          assert_no_difference(["@post.comments.count"]) do
            @post.replace!(replacement_file: file, replacement_url: "")
          end
        end
      end
    end
  end
end
