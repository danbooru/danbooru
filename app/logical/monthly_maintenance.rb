class MonthlyMaintenance
  def run
    ActiveRecord::Base.connection.execute("set statement_timeout = 0")
    JanitorTrial.message_candidates!
  end
end
