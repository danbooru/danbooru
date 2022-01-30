require 'test_helper'

class UploadServiceTest < ActiveSupport::TestCase
  context "::Replacer" do
    context "for a file replacement" do
      setup do
        @new_file = upload_file("test/files/test.jpg")
        @old_file = upload_file("test/files/test.png")
        travel_to(1.month.ago) do
          @user = FactoryBot.create(:user)
        end
        as(@user) do
          @post = FactoryBot.create(:post, md5: Digest::MD5.hexdigest(@old_file.read))
          @old_md5 = @post.md5
          @replacement = FactoryBot.create(:post_replacement, post: @post, replacement_url: "", replacement_file: @new_file)
        end
      end

      context "#process!" do
        should "not create a new post" do
          assert_difference(-> { Post.count }, 0) do
            as(@user) { @post.reload.replace!(replacement_url: "", replacement_file: @new_file) }
          end
        end

        should "update the post's MD5" do
          assert_changes(-> { @post.reload.md5 }) do
            as(@user) { @post.reload.replace!(replacement_url: "", replacement_file: @new_file) }
          end
        end

        should "preserve the old values" do
          as(@user) { @post.reload.replace!(replacement_url: "", replacement_file: @new_file) }
          @replacement = @post.replacements.last

          assert_equal(1500, @replacement.old_image_width)
          assert_equal(1000, @replacement.old_image_height)
          assert_equal(2000, @replacement.old_file_size)
          assert_equal("jpg", @replacement.old_file_ext)
          assert_equal(@old_md5, @replacement.old_md5)
        end

        should "record the new values" do
          as(@user) { @post.reload.replace!(replacement_url: "", replacement_file: @new_file) }
          @replacement = @post.replacements.last

          assert_equal(500, @replacement.reload.image_width)
          assert_equal(335, @replacement.image_height)
          assert_equal(28086, @replacement.file_size)
          assert_equal("jpg", @replacement.file_ext)
          assert_equal("ecef68c44edb8a0d6a3070b5f8e8ee76", @replacement.md5)
        end

        should "correctly update the attributes" do
          as(@user) { @post.reload.replace!(replacement_url: "", replacement_file: @new_file) }
          @replacement = @post.replacements.last

          assert_equal(500, @post.image_width)
          assert_equal(335, @post.image_height)
          assert_equal(28086, @post.file_size)
          assert_equal("jpg", @post.file_ext)
          assert_equal("ecef68c44edb8a0d6a3070b5f8e8ee76", @post.md5)
          assert(File.exist?(@post.file.path))
        end
      end

      context "a post with the same file" do
        should "update the source" do
          upload_file("test/files/test.png") do |file|
            as(@user) { @post.reload.replace!(replacement_file: file, replacement_url: "", final_source: "blah") }

            assert_equal("blah", @post.reload.source)
          end
        end
      end
    end

    context "for a twitter source replacement" do
      setup do
        skip "Twitter credentials not configured" unless Sources::Strategies::Twitter.enabled?

        @new_url = "https://pbs.twimg.com/media/B4HSEP5CUAA4xyu.png:orig"

        travel_to(1.month.ago) do
          @user = FactoryBot.create(:user)
        end

        as(@user) do
          @post = FactoryBot.create(:post, source: "http://blah", file_ext: "jpg", md5: "something", uploader_ip_addr: "127.0.0.2")
          @replacement = FactoryBot.create(:post_replacement, post: @post, replacement_url: @new_url)
        end
      end

      should "replace the post" do
        as(@user) { @post.reload.replace!(replacement_url: @new_url) }

        assert_equal(@new_url, @post.reload.replacements.last.replacement_url)
      end
    end

    context "for a source replacement" do
      setup do
        @new_url = "https://cdn.donmai.us/original/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg"
        @new_md5 = "d34e4cf0a437a5d65f8e82b7bcd02606"
        travel_to(1.month.ago) do
          @user = FactoryBot.create(:user)
        end
        as(@user) do
          @post_md5 = "710fd9cba4ef37260f9152ffa9d154d8"
          @post_source = "https://cdn.donmai.us/original/71/0f/#{@post_md5}.png"
          @post = FactoryBot.create(:post, source: @post_source, file_ext: "png", md5: @post_md5, uploader_ip_addr: "127.0.0.2")
          @replacement = FactoryBot.create(:post_replacement, post: @post, replacement_url: @new_url)
        end
      end

      context "when replacing a post with the same file as itself" do
        should "update the source" do
          @post.update!(source: "blah")

          as(@user) { @post.reload.replace!(replacement_url: @post_source) }
          assert_equal(@post_source, @post.reload.source)
        end
      end

      context "when an upload with the same MD5 already exists" do
        setup do
          @post.update(md5: @new_md5)
          as(@user) do
            @post2 = FactoryBot.create(:post)
          end
        end

        should "throw an error" do
          assert_raises(UploadService::Replacer::Error) do
            as(@user) { @post2.reload.replace!(replacement_url: @new_url) }
          end
        end
      end

      context "a post when given a final_source" do
        should "change the source to the final_source" do
          replacement_url = "https://cdn.donmai.us/original/fd/b4/fdb47f79fb8da82e66eeb1d84a1cae8d.jpg"
          final_source = "https://cdn.donmai.us/original/71/0f/710fd9cba4ef37260f9152ffa9d154d8.png"

          as(@user) { @post.reload.replace!(replacement_url: replacement_url, final_source: final_source) }

          assert_equal(final_source, @post.source)
        end
      end

      context "a post when replaced with a HTML source" do
        should "record the image URL as the replacement URL, not the HTML source" do
          skip "Twitter key not set" unless Danbooru.config.twitter_api_key
          replacement_url = "https://twitter.com/nounproject/status/540944400767922176"
          image_url = "https://pbs.twimg.com/media/B4HSEP5CUAA4xyu.png:orig"
          as(@user) { @post.reload.replace!(replacement_url: replacement_url) }

          assert_equal(replacement_url, @post.replacements.last.replacement_url)
        end
      end

      context "#undo!" do
        setup do
          @user = travel_to(1.month.ago) { FactoryBot.create(:user) }
          as(@user) do
            @post = FactoryBot.create(:post, source: "https://cdn.donmai.us/original/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg")
            @new_url = "https://cdn.donmai.us/original/fd/b4/fdb47f79fb8da82e66eeb1d84a1cae8d.jpg"
            @post.reload.replace!(replacement_url: @new_url, tags: "-tag1 tag2")
          end

          @replacement = @post.replacements.last
        end

        should "update the attributes" do
          as(@user) do
            replacer = UploadService::Replacer.new(post: @post.reload, replacement: @replacement)
            replacer.undo!
          end

          assert_equal("tag2", @post.tag_string)
          assert_equal(459, @post.image_width)
          assert_equal(650, @post.image_height)
          assert_equal(127238, @post.file_size)
          assert_equal("jpg", @post.file_ext)
          assert_equal("d34e4cf0a437a5d65f8e82b7bcd02606", @post.md5)
          assert_equal("d34e4cf0a437a5d65f8e82b7bcd02606", Digest::MD5.file(@post.file).hexdigest)
          assert_equal("https://cdn.donmai.us/original/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg", @post.source)
        end
      end

      context "#process!" do
        should "not create a new post" do
          assert_difference(-> { Post.count }, 0) do
            as(@user) { @post.reload.replace!(replacement_url: @new_url) }
          end
        end

        should "update the post's MD5" do
          assert_changes(-> { @post.reload.md5 }) do
            as(@user) { @post.reload.replace!(replacement_url: @new_url) }
          end
        end

        should "update the post's source" do
          assert_changes(-> { @post.reload.source }, nil, from: @post.source, to: @new_url) do
            as(@user) { @post.reload.replace!(replacement_url: @new_url) }
            @post.reload
          end
        end

        should "not change the post status or uploader" do
          assert_no_changes(-> { {ip_addr: @post.uploader_ip_addr.to_s, uploader: @post.uploader_id, pending: @post.is_pending?} }) do
            as(@user) { @post.reload.replace!(replacement_url: @new_url) }
            @post.reload
          end
        end
      end

      context "a post with a pixiv html source" do
        setup do
          skip "Pixiv credentials not configured" unless Sources::Strategies::Pixiv.enabled?
        end

        should "replace with the full size image" do
          as(@user) do
            @post.reload.replace!(replacement_url: "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247350")
          end

          assert_equal(80, @post.image_width)
          assert_equal(82, @post.image_height)
          assert_equal(16275, @post.file_size)
          assert_equal("png", @post.file_ext)
          assert_equal("4ceadc314938bc27f3574053a3e1459a", @post.md5)
          assert_equal("4ceadc314938bc27f3574053a3e1459a", Digest::MD5.file(@post.file).hexdigest)
          assert_equal("https://i.pximg.net/img-original/img/2017/04/04/08/54/15/62247350_p0.png", @post.replacements.last.replacement_url)
          assert_equal("https://i.pximg.net/img-original/img/2017/04/04/08/54/15/62247350_p0.png", @post.source)
        end
      end

      context "a post that is replaced by a ugoira" do
        should "save the frame data" do
          skip unless MediaFile::Ugoira.videos_enabled?
          skip "Pixiv credentials not configured" unless Sources::Strategies::Pixiv.enabled?

          begin
            as(@user) { @post.reload.replace!(replacement_url: "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247364") }
            @post.reload

            assert_equal(80, @post.image_width)
            assert_equal(82, @post.image_height)
            assert_equal(2804, @post.file_size)
            assert_equal("zip", @post.file_ext)
            assert_equal("cad1da177ef309bf40a117c17b8eecf5", @post.md5)
            assert_equal("cad1da177ef309bf40a117c17b8eecf5", Digest::MD5.file(@post.file).hexdigest)

            assert_equal("https://i.pximg.net/img-zip-ugoira/img/2017/04/04/08/57/38/62247364_ugoira1920x1080.zip", @post.source)
            assert_equal([{"delay" => 125, "file" => "000000.jpg"}, {"delay" => 125, "file" => "000001.jpg"}], @post.pixiv_ugoira_frame_data.data)
          end
        end
      end

      context "a post with notes" do
        setup do
          skip "Pixiv credentials not configured" unless Sources::Strategies::Pixiv.enabled?

          Note.any_instance.stubs(:merge_version?).returns(false)

          as(@user) do
            @post.update(image_width: 160, image_height: 164)
            @note = @post.notes.create(x: 80, y: 82, width: 80, height: 82, body: "test")
            @note.reload
          end
        end

        should "rescale the notes" do
          assert_equal([80, 82, 80, 82], [@note.x, @note.y, @note.width, @note.height])

          begin
            assert_difference(-> { @note.versions.count }) do
              # replacement image is 80x82, so we're downscaling by 50% (160x164 -> 80x82).
              as(@user) do
                @post.reload.replace!(
                  replacement_url: "https://i.pximg.net/img-original/img/2017/04/04/08/54/15/62247350_p0.png",
                  final_source: "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247350"
                )
              end
              @note.reload
            end

            assert_equal([40, 41, 40, 41], [@note.x, @note.y, @note.width, @note.height])
            assert_equal("https://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247350", @post.source)
          end
        end
      end
    end
  end

  context "#start!" do
    subject { UploadService }

    setup do
      @source = "https://cdn.donmai.us/original/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg"
      CurrentUser.user = travel_to(1.month.ago) do
        FactoryBot.create(:user)
      end
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "with a preprocessed predecessor" do
      setup do
        @predecessor = FactoryBot.create(:source_upload, status: "preprocessed", source: @source, image_height: 0, image_width: 0, file_size: 1, md5: 'd34e4cf0a437a5d65f8e82b7bcd02606', file_ext: "jpg")
        @tags = 'hello world'
      end

      context "when the file has already been uploaded" do
        setup do
          @asset = MediaAsset.find_by_md5("d34e4cf0a437a5d65f8e82b7bcd02606")
          @post = create(:post, md5: "d34e4cf0a437a5d65f8e82b7bcd02606", media_asset: @asset)
          @service = subject.new(source: @source)
        end

        should "point to the dup post in the upload" do
          @upload = subject.new(source: @source, tag_string: @tags).start!
          @predecessor.reload
          assert_equal("error: ActiveRecord::RecordInvalid - Validation failed: Md5 duplicate: #{@post.id}", @predecessor.status)
        end
      end
    end

    context "with a source containing unicode characters" do
      should "normalize unicode characters in the source field" do
        source1 = "poke\u0301mon" # pokémon (nfd form)
        source2 = "pok\u00e9mon"  # pokémon (nfc form)
        service = subject.new(source: source1, rating: "s", file: upload_file("test/files/test.jpg"))

        assert_nothing_raised { @upload = service.start! }
        assert_equal(source2, @upload.source)
      end
    end
  end
end
