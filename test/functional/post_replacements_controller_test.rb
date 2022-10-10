require 'test_helper'

class PostReplacementsControllerTest < ActionDispatch::IntegrationTest
  context "The post replacements controller" do
    context "create action" do
      context "replacing a post from a source url" do
        should "replace the post" do
          assert_difference("PostReplacement.count") do
            @post = create(:post, tag_string: "image_sample")

            post_auth post_replacements_path, create(:moderator_user), params: {
              format: :json,
              post_id: @post.id,
              post_replacement: {
                replacement_url: "https://cdn.donmai.us/original/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg",
                tags: "replaced -image_sample"
              }
            }

            assert_response :success
          end

          @replacement = PostReplacement.last
          assert_equal(459, @replacement.image_width)
          assert_equal(650, @replacement.image_height)
          assert_equal(127_238, @replacement.file_size)
          assert_equal("jpg", @replacement.file_ext)
          assert_equal("d34e4cf0a437a5d65f8e82b7bcd02606", @replacement.md5)

          assert_equal(@post.image_width, @replacement.old_image_width)
          assert_equal(@post.image_height, @replacement.old_image_height)
          assert_equal(@post.file_size, @replacement.old_file_size)
          assert_equal(@post.file_ext, @replacement.old_file_ext)
          assert_equal(@post.md5, @replacement.old_md5)
          assert_equal(@post.tag_string, "image_sample")

          @post.reload
          assert_equal("d34e4cf0a437a5d65f8e82b7bcd02606", @post.md5)
          assert_equal("d34e4cf0a437a5d65f8e82b7bcd02606", @post.media_asset.variant(:original).open_file.md5)
          assert_equal("https://cdn.donmai.us/original/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg", @post.source)
          assert_equal(459, @post.image_width)
          assert_equal(650, @post.image_height)
          assert_equal(127_238, @post.file_size)
          assert_equal("jpg", @post.file_ext)
          assert_equal("replaced", @post.tag_string)
        end
      end

      context "replacing a post with the same file" do
        should "only change the source to the final source" do
          @post = create(:post)

          post_auth post_replacements_path, create(:moderator_user), params: {
            format: :json,
            post_id: @post.id,
            post_replacement: {
              replacement_file: Rack::Test::UploadedFile.new("test/files/test.png"),
              final_source: "blah",
            }
          }

          assert_response :success
          assert_equal("blah", @post.reload.source)
        end
      end

      context "when a post with the same MD5 already exists" do
        should "return an error" do
          @post1 = create(:post, md5: "ecef68c44edb8a0d6a3070b5f8e8ee76", file_size: 1234)
          @post2 = create(:post, file_size: 789)

          post_auth post_replacements_path, create(:moderator_user), params: {
            format: :json,
            post_id: @post2.id,
            post_replacement: {
              replacement_file: Rack::Test::UploadedFile.new("test/files/test.jpg"),
            }
          }

          assert_response 422
          assert_equal(789, @post2.reload.file_size)
        end
      end

      context "replacing a post with a Pixiv page URL" do
        should "replace with the full size image" do
          @post = create(:post)

          post_auth post_replacements_path, create(:moderator_user), params: {
            format: :json,
            post_id: @post.id,
            post_replacement: {
              replacement_url: "https://www.pixiv.net/en/artworks/62247350",
            }
          }

          assert_response :success
          assert_equal(80, @post.reload.image_width)
          assert_equal(82, @post.image_height)
          assert_equal(16_275, @post.file_size)
          assert_equal("png", @post.file_ext)
          assert_equal("4ceadc314938bc27f3574053a3e1459a", @post.md5)
          assert_equal("4ceadc314938bc27f3574053a3e1459a", Digest::MD5.file(@post.file).hexdigest)
          assert_equal("https://i.pximg.net/img-original/img/2017/04/04/08/54/15/62247350_p0.png", @post.replacements.last.replacement_url)
          assert_equal("https://i.pximg.net/img-original/img/2017/04/04/08/54/15/62247350_p0.png", @post.source)
        end
      end

      context "replacing a post with a Pixiv ugoira" do
        should "save the frame data" do
          skip "Pixiv credentials not configured" unless Source::Extractor::Pixiv.enabled?

          @post = create(:post)
          post_auth post_replacements_path, create(:moderator_user), params: {
            format: :json,
            post_id: @post.id,
            post_replacement: {
              replacement_url: "https://www.pixiv.net/en/artworks/62247364",
            }
          }

          assert_response :success
          assert_equal(80, @post.reload.image_width)
          assert_equal(82, @post.image_height)
          assert_equal(2804, @post.file_size)
          assert_equal("zip", @post.file_ext)
          assert_equal("cad1da177ef309bf40a117c17b8eecf5", @post.md5)
          assert_equal("cad1da177ef309bf40a117c17b8eecf5", @post.media_asset.variant(:original).open_file.md5)

          assert_equal("https://i.pximg.net/img-zip-ugoira/img/2017/04/04/08/57/38/62247364_ugoira1920x1080.zip", @post.source)
          assert_equal([125, 125], @post.media_asset.frame_delays)
        end
      end

      context "replacing a post with notes" do
        should "rescale the notes" do
          skip "Pixiv credentials not configured" unless Source::Extractor::Pixiv.enabled?

          as(create(:user)) do
            @post = create(:post, image_width: 160, image_height: 164)
            @note = @post.notes.create!(x: 80, y: 82, width: 80, height: 82, body: "test", created_at: 1.day.ago)
          end

          post_auth post_replacements_path, create(:moderator_user), params: {
            format: :json,
            post_id: @post.id,
            post_replacement: {
              replacement_url: "https://i.pximg.net/img-original/img/2017/04/04/08/54/15/62247350_p0.png",
            }
          }

          assert_response :success
          @note.reload

          # replacement image is 80x82, so we're downscaling by 50% (160x164 -> 80x82).
          assert_equal([40, 41, 40, 41], [@note.x, @note.y, @note.width, @note.height])
        end
      end

      context "a replacement that fails" do
        should "not create a post replacement record" do
          @post = create(:post)

          assert_no_difference("PostReplacement.count") do
            post_auth post_replacements_path, create(:moderator_user), params: {
              post_id: @post.id,
              post_replacement: {
                replacement_file: Rack::Test::UploadedFile.new("test/files/ugoira.json"),
              }
            }

            assert_redirected_to @post
          end
        end
      end

      should "not allow non-mods to replace posts" do
        assert_difference("PostReplacement.count", 0) do
          @post = create(:post)
          post_auth post_replacements_path(post_id: @post.id), create(:user), params: { post_replacement: { replacement_url: "https://cdn.donmai.us/original/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg" }}
          assert_response 403
        end
      end
    end

    context "update action" do
      should "update the replacement" do
        @post_replacement = create(:post_replacement)

        put_auth post_replacement_path(@post_replacement), create(:moderator_user), params: {
          format: :json,
          id: @post_replacement.id,
          post_replacement: {
            old_file_size: 23,
            file_size: 42,
          }
        }

        assert_response :success
        assert_equal(23, @post_replacement.reload.old_file_size)
        assert_equal(42, @post_replacement.file_size)
      end
    end

    context "index action" do
      setup do
        @admin = create(:admin_user)
        @mod = create(:moderator_user, name: "yukari")

        @post_replacement = create(:post_replacement, creator: @mod, post: create(:post, tag_string: "touhou"), replacement_file: Rack::Test::UploadedFile.new("test/files/test.png"))
        @admin_replacement = create(:post_replacement, creator: @admin, replacement_file: Rack::Test::UploadedFile.new("test/files/test.jpg"))
      end

      should "render" do
        get post_replacements_path
        assert_response :success
      end

      should respond_to_search({}).with { [@admin_replacement, @post_replacement] }

      context "using includes" do
        should respond_to_search(post_tags_match: "touhou").with { @post_replacement }
        should respond_to_search(creator: {level: User::Levels::ADMIN}).with { @admin_replacement }
        should respond_to_search(creator_name: "yukari").with { @post_replacement }
      end
    end

    context "show action" do
      setup do
        @replacement = create(:post_replacement)
      end

      should "render for html" do
        get post_replacement_path(@replacement)

        assert_redirected_to post_replacements_path(search: { id: @replacement.id })
      end

      should "render for json" do
        get post_replacement_path(@replacement), as: :json

        assert_response :success
      end
    end
  end
end
