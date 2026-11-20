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

  context "An artist version with reordered other names" do
    setup do
      @user = create(:user)
      @artist = travel_to(2.days.ago) { as(@user) { create(:artist, other_names: ["aaa", "bbb"]) } }
      travel_to(1.day.ago) { as(@user) { @artist.update!(other_names: ["bbb", "aaa"]) } }
      as(@user) { @artist.update!(group_name: "group") }
      @first, @second, @third = @artist.versions.order(:id).to_a
    end

    should "count reordered other names as a change" do
      assert_equal(true, @second.other_names_changed("previous"))
      assert_equal(false, @third.other_names_changed("previous"))
    end
  end
end
