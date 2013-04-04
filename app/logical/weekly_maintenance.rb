class DailyMaintenance
  def run
    ActiveRecord::Base.connection.execute("set statement_timeout = 0")
    ApiCacheGenerator.new.generate_tag_cache
    UserPasswordResetNonce.prune!
  end
end
