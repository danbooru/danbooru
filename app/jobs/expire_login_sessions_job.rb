# frozen_string_literal: true

# A job that runs daily to mark idle login sessions as expired. Spawned by {DanbooruMaintenance}.
class ExpireLoginSessionsJob < ApplicationJob
  def perform
    LoginSession.expire!
  end
end
