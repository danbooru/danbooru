class WeeklyMaintenance
  def run
    ActiveRecord::Base.connection.execute("set statement_timeout = 0")
    UserPasswordResetNonce.prune!
    ApproverPruner.prune!
    # JanitorPruner.new.prune!
  end
end
