require "test_helper"

class DmcaRequestTest < ActiveSupport::TestCase
  context "A DMCA request" do
    should "get a random base36 public id" do
      dmca_requests = create_list(:dmca_request, 2)

      assert_match(/\A[0-9a-z]{16}\z/, dmca_requests.first.public_id)
      assert_not_equal(dmca_requests.first.public_id, dmca_requests.second.public_id)
    end

    context "on a site with its own domains" do
      setup do
        Danbooru.config.stubs(:canonical_url).returns("https://booru.example.com")
        Danbooru.config.stubs(:alternate_domains).returns(["Alt.Example.com"])
        Danbooru.config.stubs(:storage_manager).returns(StorageManager::Local.new(base_url: "https://cdn.example.com/data", base_dir: Dir.tmpdir))
      end

      should "save the URLs on the site's domains from the infringing URLs" do
        dmca_request = create(:dmca_request, infringing_urls: <<~EOS)
          https://booru.example.com/posts/1234
          https://BOORU.example.com/posts/5678
          https://alt.example.com/posts/1234
          https://cdn.example.com/data/original/8d/81/8d819da4871c3ca39f428999df8220ce.jpg
          https://danbooru.donmai.us/posts/1234
          https://cdn.donmai.us/original/8d/81/8d819da4871c3ca39f428999df8220ce.jpg
          https://example.com/1.html
          https://booru.example.com.evil.com/posts/1234
          javascript:alert(1)
        EOS

        assert_equal(%w[
          https://booru.example.com/posts/1234
          https://BOORU.example.com/posts/5678
          https://alt.example.com/posts/1234
          https://cdn.example.com/data/original/8d/81/8d819da4871c3ca39f428999df8220ce.jpg
        ], dmca_request.danbooru_urls)
      end

      should "save the IDs of the posts in the site's URLs" do
        post1 = create(:post)
        post2 = create(:post)
        post3 = create(:post)
        post4 = create(:post)
        dmca_request = create(:dmca_request, infringing_urls: <<~EOS)
          https://booru.example.com/posts/#{post1.id}
          https://booru.example.com/posts/#{post1.id}?q=touhou
          https://cdn.example.com/data/original/#{post2.md5[0..1]}/#{post2.md5[2..3]}/#{post2.md5}.jpg
          https://booru.example.com/posts?md5=#{post2.md5}
          https://alt.example.com/media_assets/#{post3.media_asset.id}
          https://booru.example.com/posts/999999999
          https://booru.example.com/posts/99999999999999999999
          https://cdn.example.com/data/original/00/00/00000000000000000000000000000000.jpg
          https://danbooru.donmai.us/posts/#{post4.id}
          https://example.com/posts/#{post4.id}
        EOS

        assert_equal([post1.id, post2.id, post3.id], dmca_request.post_ids)
        assert_equal([post1, post2, post3], dmca_request.posts.order(:id).to_a)
      end

      should "be searchable by post ID" do
        post = create(:post)
        dmca_request = create(:dmca_request, infringing_urls: "https://booru.example.com/posts/#{post.id}")
        create(:dmca_request)

        assert_equal([dmca_request], DmcaRequest.search({ post_ids_include_any: post.id.to_s }, create(:superadmin_user)).to_a)
      end
    end

    should "save no URLs or post IDs when there are none from this site" do
      dmca_request = create(:dmca_request)

      assert_equal([], dmca_request.danbooru_urls)
      assert_equal([], dmca_request.post_ids)
    end

    should "encrypt the personal info in the database" do
      dmca_request = create(:dmca_request, name: "John Doe", email: "test@gmail.com", address: "123 Fake Street", proof: "source: me", signature: "John Doe")
      row = DmcaRequest.connection.select_one("SELECT name, email, address, proof, signature FROM dmca_requests WHERE id = #{dmca_request.id}")

      assert_equal(["John Doe", "test@gmail.com", "123 Fake Street", "source: me", "John Doe"], dmca_request.reload.values_at(:name, :email, :address, :proof, :signature))
      row.each_value { |value| assert_no_match(/John Doe|test@gmail\.com|123 Fake Street|source: me/, value) }
    end

    context "validations" do
      should "require the name, email, signature, and URLs" do
        %i[name email signature infringing_urls original_urls].each do |field|
          [nil, "", " \n "].each do |value|
            dmca_request = build(:dmca_request, field => value)

            assert_equal(false, dmca_request.valid?)
            assert_equal(["can't be blank"], dmca_request.errors[field])
          end
        end
      end

      should "not require the address or proof" do
        assert_equal(true, build(:dmca_request, address: "", proof: nil).valid?)
      end

      should "limit the length of each field" do
        { name: 200, email: 200, signature: 200, address: 1000, proof: 10_000, infringing_urls: 50_000, original_urls: 50_000 }.each do |field, max|
          dmca_request = build(:dmca_request, field => "x" * (max + 1))

          assert_equal(false, dmca_request.valid?)
          assert_includes(dmca_request.errors[field], "is too long (maximum is #{max} characters)")
        end
      end

      should "reject invalid email addresses" do
        ["not an email", "a@gmail.com, b@gmail.com", "a@gmail.com\nBcc: b@gmail.com", "<a@gmail.com>", "a@localhost"].each do |email|
          dmca_request = build(:dmca_request, email: email)

          assert_equal(false, dmca_request.valid?)
          assert_equal(["is invalid"], dmca_request.errors[:email])
        end
      end
    end

    context "when pruned" do
      setup do
        @old_handled = create(:dmca_request, status: :handled, created_at: DmcaRequest::PERSONAL_INFO_RETENTION.ago - 1.day)
        @old_rejected = create(:dmca_request, status: :rejected, created_at: DmcaRequest::PERSONAL_INFO_RETENTION.ago - 1.day)
        @old_pending = create(:dmca_request, status: :pending, created_at: DmcaRequest::PERSONAL_INFO_RETENTION.ago - 1.day)
        @new_handled = create(:dmca_request, status: :handled)

        DmcaRequest.prune!
      end

      should "purge the personal info of old handled or rejected requests" do
        [@old_handled, @old_rejected].each do |dmca_request|
          dmca_request.reload

          assert_equal([nil, nil, nil, nil, nil], dmca_request.values_at(:name, :email, :address, :proof, :signature))
          assert_equal(true, dmca_request.purged?)
          assert_equal("https://example.com/1.html\nhttps://example.com/2.html", dmca_request.infringing_urls)
          assert_equal("https://google.com/1.html\nhttps://google.com/2.html", dmca_request.original_urls)
        end
      end

      should "keep the personal info of pending or recent requests" do
        assert_equal("John Doe", @old_pending.reload.name)
        assert_equal("John Doe", @new_handled.reload.name)
      end
    end
  end
end
