require 'test_helper'

class ApplicationRecordTest < ActiveSupport::TestCase
  setup do
    @tags = FactoryBot.create_list(:tag, 3, post_count: 1)
  end

  context "ApplicationRecord#search" do
    should "support the id param" do
      assert_equal([@tags.first], Tag.search(id: @tags.first.id))
    end

    should "support ranges in the id param" do
      assert_equal(@tags.reverse, Tag.search(id: ">=1"))
      assert_equal(@tags.reverse, Tag.search(id: "#{@tags[0].id}..#{@tags[2].id}"))
      assert_equal(@tags.reverse, Tag.search(id: @tags.map(&:id).join(",")))
    end

    should "support the created_at and updated_at params" do
      assert_equal(@tags.reverse, Tag.search(created_at: ">=#{@tags.first.created_at}"))
      assert_equal(@tags.reverse, Tag.search(updated_at: ">=#{@tags.first.updated_at}"))
    end
  end
end
