class ProcessTagRelationshipJob < ApplicationJob
  queue_as :bulk_update
  retry_on Exception, attempts: 0

  def perform(class_name:, approver:, antecedent_name:, consequent_name:, forum_topic: nil)
    relation_class = Kernel.const_get(class_name)
    tag_relationship = relation_class.create!(creator: approver, approver: approver, antecedent_name: antecedent_name, consequent_name: consequent_name, forum_topic: forum_topic)
    tag_relationship.process!
  end
end
