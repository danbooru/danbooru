# frozen_string_literal: true

module ReadOnlyMode
  LABEL = "danbooru"

  module_function

  def enabled?
    Danbooru.config.read_only_mode?
  end

  def pause_jobs!
    GoodJob::Setting.pause(label: LABEL) unless GoodJob::Setting.paused?(label: LABEL)
  end

  def unpause_jobs!
    GoodJob::Setting.unpause(label: LABEL) if GoodJob::Setting.paused?(label: LABEL)
  end
end
