class DailyMaintenance
  def run
    ApiCacheGenerator.new.generate_tag_cache
  end
end
