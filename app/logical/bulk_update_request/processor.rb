# frozen_string_literal: true

# Process a bulk update request. Parses the request and applies each line in
# sequence.
class BulkUpdateRequest::Processor
  # Maximum number of lines a BUR may have.
  MAXIMUM_SCRIPT_LENGTH = 100

  include ActiveModel::Validations

  class Error < StandardError; end

  attr_reader :bulk_update_request

  delegate :script, :forum_topic, :approver, to: :bulk_update_request
  validate :validate_script_length
  validate :validate_duplicate_lines
  validate :validate_script

  # @param bulk_update_request [BulkUpdateRequest] the BUR
  def initialize(bulk_update_request)
    @bulk_update_request = bulk_update_request
  end

  # Parse the script into a list of commands.
  def commands
    script.split(/\r\n|\r|\n/).compact_blank.map do |line|
      BulkUpdateRequest::Command.parse(line.gsub(/[[:space:]]+/, " ").strip)
    end
  end

  # Validate the bulk update request when it is created or approved.
  #
  # validation_context will be either :request (when the BUR is first created
  # or edited) or :approval (when the BUR is approved). Certain validations
  # only run when the BUR is requested, not when it's approved.
  def validate_script
    CurrentUser.scoped(User.system) do
      BulkUpdateRequest.transaction(requires_new: true) do
        commands.each do |command|
          command.validate(context: validation_context, errors: errors)
        end

        raise ActiveRecord::Rollback
      end
    end
  end

  # Validate that the script isn't too long.
  def validate_script_length
    if commands.size > MAXIMUM_SCRIPT_LENGTH
      errors.add(:base, "Bulk update request is too long (maximum size: #{MAXIMUM_SCRIPT_LENGTH} lines). Split your request into smaller chunks and try again.")
      throw :abort
    end
  end

  def validate_duplicate_lines
    commands.map(&:to_dtext).tally.filter { |_line, count| count > 1 }.each_key do |dupe|
      errors.add(:base, "Duplicate line found: #{dupe}")
    end
    throw :abort if errors.present?
  end

  # Schedule the bulk update request to be processed later, in the background.
  def process_later!
    ProcessBulkUpdateRequestJob.perform_later(bulk_update_request)
  end

  # Process the bulk update request immediately.
  def process!
    CurrentUser.scoped(User.system) do
      bulk_update_request.update!(status: "processing")

      commands.each do |command|
        command.process!(approver: approver, forum_topic: forum_topic)
      end

      bulk_update_request.update!(status: "approved")
    rescue StandardError
      bulk_update_request.update!(status: "failed")
      raise
    end
  end

  # The list of tags in the script. Used to search BURs by tag.
  # @return [Array<String>] the list of tags
  def affected_tags
    commands.flat_map(&:affected_tags).sort.uniq
  end

  # Convert the BUR to DText format.
  # @return [String]
  def to_dtext
    commands.map(&:to_dtext).join("\n")
  end

  # @return [Integer] the minimum level required to approve this BUR.
  # @see User::Levels
  def approval_level
    commands.map(&:approval_level).max
  end
end
