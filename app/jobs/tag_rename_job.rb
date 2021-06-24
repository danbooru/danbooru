# A job that performs a tag rename or alias operation in a bulk update request.
# Jobs in the `bulk_update` queue are processed sequentially.
class TagRenameJob < ApplicationJob
  queue_as :bulk_update

  def perform(old_tag_name, new_tag_name)
    TagMover.new(old_tag_name, new_tag_name, user: User.system).move!
  end
end
