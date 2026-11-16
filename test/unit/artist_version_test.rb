require "test_helper"

class ArtistVersionTest < ActiveSupport::TestCase
  context "An artist version" do
    setup do
      CurrentUser.user = create(:user)
      @artist = travel_to(2.days.ago) { create(:artist, name: "v1") }
      travel_to(1.day.ago) { @artist.update!(name: "v2") }
      @artist.update!(name: "v3")
      @v1, @v2, @v3 = @artist.versions.order(:created_at).to_a
    end

    teardown do
      CurrentUser.user = nil
    end

    should "return the correct previous and current versions" do
      assert_equal(@v1, @v2.previous)
      assert_equal(@v3, @v2.current)
      assert_equal(@v1, @v2.previous)
    end
  end
end
