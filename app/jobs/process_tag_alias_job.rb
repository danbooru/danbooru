class ProcessTagAliasJob < ApplicationJob
  queue_as :bulk_update

  def perform(tag_alias)
    tag_alias.process!
  end
end
