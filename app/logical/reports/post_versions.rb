module Reports
  class PostVersions
    attr_reader :tag, :query

    def initialize(tag, query_type)
      @tag = tag

      if query_type == "added"
        @query = GoogleBigQuery::PostVersion.new.find_added(tag)
      else
        @query = GoogleBigQuery::PostVersion.new.find_removed(tag)
      end
    end

    def mock_version(row)
      PostArchive.new.tap do |x|
        x.id = row["f"][0]["v"]
        x.post_id = row["f"][1]["v"]
        x.updated_at = Time.at(row["f"][2]["v"].to_f)
        x.updater_id = row["f"][3]["v"]
        x.updater_ip_addr = row["f"][4]["v"]
        x.tags = row["f"][5]["v"]
        # x.added_tags = row["f"][6]["v"]
        # x.removed_tags = row["f"][7]["v"]
        x.parent_id = row["f"][8]["v"]
        x.rating = row["f"][9]["v"]
        x.source = row["f"][10]["v"]
      end
    end

    def post_versions
      if query["rows"].present?
        query["rows"].map {|x| mock_version(x)}
      else
        []
      end
    end
  end
end
