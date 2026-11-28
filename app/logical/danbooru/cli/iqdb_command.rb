# frozen_string_literal: true

# `bin/booructl iqdb` commands for managing the IQDB reverse image search index.
class Danbooru::CLI::IqdbCommand < Danbooru::CLI::Command
  namespace "iqdb"

  desc "reindex [SEARCH]", "Add posts to IQDB"
  long_desc <<~EOS
    Add all posts matching the search to IQDB, or all posts if no search is given. Deleted posts are included unless
    the search says otherwise. Run this after restoring a backup to rebuild the IQDB index.

    Example: bin/booructl iqdb reindex "id:>100000"
  EOS
  option :dry_run, type: :boolean, default: false, desc: "List the posts to reindex without reindexing them"
  def reindex(search = "")
    iqdb = IqdbClient.new
    raise Thor::Error, "IQDB isn't enabled. Set `iqdb_url` in config/danbooru_local_config.rb first." unless iqdb.enabled?

    posts = PostQuery.search("status:any #{search}", current_user: User.system)
    process_each(posts, "post") { |post| iqdb.add_post(post) }
  end
end
