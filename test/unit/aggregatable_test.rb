require "test_helper"

class AggregatableTest < ActiveSupport::TestCase
  context "Aggregatable#timeseries" do
    should "include the last, partial bucket when the end date falls early inside it" do
      travel_to(Time.utc(2026, 3, 21)) do
        create(:post, created_at: Time.utc(2026, 1, 15))

        dataframe = Post.timeseries(period: "year", from: Date.new(2005, 5, 24), to: Date.new(2026, 3, 21))

        assert_includes dataframe["date"].to_a, Time.utc(2026, 1, 1)

        last_bucket = dataframe.each_row.find { |row| row["date"] == Time.utc(2026, 1, 1) }
        assert_equal 1, last_bucket["count"]
      end
    end

    should "include the first, partial bucket when the start date falls late inside it" do
      create(:post, created_at: Time.utc(2005, 5, 24))

      dataframe = Post.timeseries(period: "year", from: Date.new(2005, 5, 24), to: Date.new(2026, 3, 21))

      assert_includes dataframe["date"].to_a, Time.utc(2005, 1, 1)

      first_bucket = dataframe.each_row.find { |row| row["date"] == Time.utc(2005, 1, 1) }
      assert_equal 1, first_bucket["count"]
    end

    should "not count posts created before the start date in the first bucket" do
      create(:post, created_at: Time.utc(2005, 1, 1)) # before `from`, must not be counted
      create(:post, created_at: Time.utc(2005, 6, 1)) # after `from`, must be counted

      dataframe = Post.timeseries(period: "year", from: Date.new(2005, 5, 24), to: Date.new(2026, 3, 21))

      first_bucket = dataframe.each_row.find { |row| row["date"] == Time.utc(2005, 1, 1) }
      assert_equal 1, first_bucket["count"]
    end

    should "not count posts created after the end date in the last bucket" do
      travel_to(Time.utc(2026, 3, 21)) do
        create(:post, created_at: Time.utc(2026, 1, 15)) # before `to`, must be counted
        create(:post, created_at: Time.utc(2026, 6, 1)) # after `to`, must not be counted

        dataframe = Post.timeseries(period: "year", from: Date.new(2005, 5, 24), to: Date.new(2026, 3, 21))

        last_bucket = dataframe.each_row.find { |row| row["date"] == Time.utc(2026, 1, 1) }
        assert_equal 1, last_bucket["count"]
      end
    end

    should "not generate buckets outside of the from/to range" do
      dataframe = Post.timeseries(period: "year", from: Date.new(2020, 5, 24), to: Date.new(2022, 3, 21))

      assert_equal [Time.utc(2022, 1, 1), Time.utc(2021, 1, 1), Time.utc(2020, 1, 1)], dataframe["date"].to_a
    end

    should "respect partial buckets for periods other than year" do
      create(:post, created_at: Time.utc(2026, 3, 5)) # in the first, partial week
      create(:post, created_at: Time.utc(2026, 3, 19)) # in the last, partial week

      # 2026-03-02 is a Monday, 2026-03-16 is the Monday of the week containing 2026-03-19
      dataframe = Post.timeseries(period: "week", from: Date.new(2026, 3, 4), to: Date.new(2026, 3, 19))

      assert_equal [Time.utc(2026, 3, 16), Time.utc(2026, 3, 9), Time.utc(2026, 3, 2)], dataframe["date"].to_a
      assert_equal 1, dataframe.each_row.find { |row| row["date"] == Time.utc(2026, 3, 2) }["count"]
      assert_equal 1, dataframe.each_row.find { |row| row["date"] == Time.utc(2026, 3, 16) }["count"]
    end
  end
end
