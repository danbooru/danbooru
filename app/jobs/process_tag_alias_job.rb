class ProcessTagAliasJob < ApplicationJob
  queue_as :bulk_update

  def perform(tag_alias, approver)
    tag_alias.process!(approver)
  end
end
