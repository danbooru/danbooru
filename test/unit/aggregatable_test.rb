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

    should "count records created at any time on the end date" do
      create(:post, created_at: Time.utc(2026, 3, 3, 23, 59)) # on the end date, must be counted
      create(:post, created_at: Time.utc(2026, 3, 4)) # after the end date, must not be counted

      dataframe = Post.timeseries(period: "day", from: Date.new(2026, 3, 2), to: Date.new(2026, 3, 3))

      assert_equal [Time.utc(2026, 3, 3), Time.utc(2026, 3, 2)], dataframe["date"].to_a
      assert_equal [1, 0], dataframe["count"].to_a
    end

    context "with groups" do
      setup do
        @alice = create(:user)
        @bob = create(:builder_user)
        create(:post, uploader: @alice, created_at: Time.utc(2026, 3, 2, 1))
        create(:post, uploader: @alice, created_at: Time.utc(2026, 3, 2, 2))
        create(:post, uploader: @bob, created_at: Time.utc(2026, 3, 3, 1))
      end

      should "count each group's records in each bucket" do
        dataframe = Post.timeseries(period: "day", from: Date.new(2026, 3, 2), to: Date.new(2026, 3, 3), groups: ["uploader"], columns: { posts: Arel.sql("COUNT(*)"), uploaders: Arel.sql("COUNT(distinct uploader_id)") })
        rows = dataframe.each_row.map { |row| [row["date"], row["uploader"].id, row["posts"], row["uploaders"]] }

        assert_equal([
          [Time.utc(2026, 3, 2), @alice.id, 2, 1],
          [Time.utc(2026, 3, 2), @bob.id, 0, 0],
          [Time.utc(2026, 3, 3), @alice.id, 0, 0],
          [Time.utc(2026, 3, 3), @bob.id, 1, 1],
        ], rows.sort)
      end

      should "count each group's records when grouping by an associated attribute" do
        dataframe = Post.timeseries(period: "day", from: Date.new(2026, 3, 2), to: Date.new(2026, 3, 3), groups: ["uploader.level"])
        rows = dataframe.each_row.map { |row| [row["date"], row["level"], row["count"]] }

        assert_equal([
          [Time.utc(2026, 3, 2), User::Levels::MEMBER, 2],
          [Time.utc(2026, 3, 2), User::Levels::BUILDER, 0],
          [Time.utc(2026, 3, 3), User::Levels::MEMBER, 0],
          [Time.utc(2026, 3, 3), User::Levels::BUILDER, 1],
        ].sort, rows.sort)
      end

      should "only include the top groups when there's a group limit" do
        dataframe = Post.timeseries(period: "day", from: Date.new(2026, 3, 2), to: Date.new(2026, 3, 3), groups: ["uploader"], group_limit: 1)

        assert_equal([@alice, @alice], dataframe["uploader"].to_a)
        assert_equal([0, 2], dataframe["count"].to_a)
      end
    end

    should "aggregate structured columns" do
      travel_to(Time.utc(2026, 3, 21)) do
        uploader = create(:user)
        create(:post, uploader: uploader, file_size: 100, created_at: Time.utc(2026, 3, 20))
        create(:post, uploader: uploader, file_size: 200, created_at: Time.utc(2026, 3, 20))
        create(:post, file_size: 300, created_at: Time.utc(2026, 3, 20))

        columns = { posts: :count, uploaders: [:count_distinct, :uploader_id], size: [:sum, :file_size] }
        dataframe = Post.timeseries(period: "day", from: Date.new(2026, 3, 20), to: Date.new(2026, 3, 20), columns: columns)

        assert_equal [3], dataframe["posts"].to_a
        assert_equal [2], dataframe["uploaders"].to_a
        assert_equal [600], dataframe["size"].to_a
      end
    end

    should "raise an error for unknown aggregate functions" do
      assert_raises(ArgumentError) do
        Post.timeseries(period: "day", from: Date.new(2026, 3, 20), to: Date.new(2026, 3, 20), columns: { count: "COUNT(*)" })
      end
    end
  end

  context "Aggregatable#aggregate" do
    setup do
      @alice = create(:user)
      @bob = create(:builder_user)
      create(:post, uploader: @alice, created_at: Time.utc(2026, 3, 2))
      create(:post, uploader: @alice, created_at: Time.utc(2026, 3, 2))
      create(:post, uploader: @bob, created_at: Time.utc(2026, 3, 3))
      create(:post, uploader: @bob, created_at: Time.utc(2026, 1, 1)) # outside the date range
    end

    should "count each group's records, ordered by the first column" do
      dataframe = Post.aggregate(from: Date.new(2026, 3, 1), to: Date.new(2026, 3, 4), groups: ["uploader"], columns: { posts: Arel.sql("COUNT(*)"), days: Arel.sql("COUNT(distinct date_trunc('day', created_at))") })

      assert_equal([@alice, @bob], dataframe["uploader"].to_a)
      assert_equal([2, 1], dataframe["posts"].to_a)
      assert_equal([1, 1], dataframe["days"].to_a)
    end

    should "count each group's records when grouping by an associated attribute" do
      dataframe = Post.aggregate(from: Date.new(2026, 3, 1), to: Date.new(2026, 3, 4), groups: ["uploader.level"])

      assert_equal([User::Levels::MEMBER, User::Levels::BUILDER], dataframe["level"].to_a)
      assert_equal([2, 1], dataframe["count"].to_a)
    end

    should "respect the limit" do
      dataframe = Post.aggregate(from: Date.new(2026, 3, 1), to: Date.new(2026, 3, 4), groups: ["uploader"], limit: 1)

      assert_equal([@alice], dataframe["uploader"].to_a)
    end

    should "count records created at any time on the end date" do
      create(:post, uploader: @bob, created_at: Time.utc(2026, 3, 4, 23, 59)) # on the end date, must be counted
      create(:post, uploader: @bob, created_at: Time.utc(2026, 3, 5)) # after the end date, must not be counted

      dataframe = Post.aggregate(from: Date.new(2026, 3, 1), to: Date.new(2026, 3, 4), groups: ["uploader"])

      assert_equal([@alice, @bob], dataframe["uploader"].to_a)
      assert_equal([2, 2], dataframe["count"].to_a)
    end

    should "not count records created after the end time when the end is a time" do
      create(:post, uploader: @bob, created_at: Time.utc(2026, 3, 3, 6)) # after the end time, must not be counted

      dataframe = Post.aggregate(from: Date.new(2026, 3, 1), to: Time.utc(2026, 3, 3, 1), groups: ["uploader"])

      assert_equal([@alice, @bob], dataframe["uploader"].to_a)
      assert_equal([2, 1], dataframe["count"].to_a)
    end

    should "aggregate structured columns" do
      uploader = create(:user)
      create(:post, uploader: uploader, file_size: 100)
      create(:post, uploader: uploader, file_size: 200)
      create(:post, file_size: 300)

      columns = { posts: :count, uploaders: [:count_distinct, :uploader_id], size: [:sum, :file_size] }
      dataframe = Post.aggregate(from: 1.day.ago, to: 1.day.from_now, columns: columns)

      assert_equal [3], dataframe["posts"].to_a
      assert_equal [2], dataframe["uploaders"].to_a
      assert_equal [600], dataframe["size"].to_a
    end

    should "order by the first column when grouping" do
      uploader = create(:user)
      create_list(:post, 2, uploader: uploader)
      create(:post)

      dataframe = Post.aggregate(from: 1.day.ago, to: 1.day.from_now, groups: ["uploader"], columns: { posts: :count })

      assert_equal [2, 1], dataframe["posts"].to_a
      assert_equal uploader, dataframe["uploader"].first
    end
  end

  context "Aggregatable" do
    should "not allow raw SQL strings as columns" do
      assert_raises(ArgumentError) { Post.timeseries(from: Date.new(2026, 3, 1), to: Date.new(2026, 3, 4), columns: { count: "COUNT(*)" }) }
      assert_raises(ArgumentError) { Post.aggregate(from: Date.new(2026, 3, 1), to: Date.new(2026, 3, 4), columns: { count: "COUNT(*)" }) }
    end

    should "not allow grouping by anything other than a column or an association's column" do
      ["id; SELECT 1", "1", "uploader.id; SELECT 1", "uploader.password_hash ", "nonexistent.id"].each do |group|
        assert_raises(ArgumentError) { Post.timeseries(from: Date.new(2026, 3, 1), to: Date.new(2026, 3, 4), groups: [group]) }
        assert_raises(ArgumentError) { Post.aggregate(from: Date.new(2026, 3, 1), to: Date.new(2026, 3, 4), groups: [group]) }
      end
    end

    should "quote column aliases" do
      dataframe = Post.aggregate(from: Date.new(2026, 3, 1), to: Date.new(2026, 3, 4), columns: { 'a" b': Arel.sql("COUNT(*)") })

      assert_equal(['a" b'], dataframe.names)
    end
  end
end
