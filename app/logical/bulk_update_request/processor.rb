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
  validate :validate_edited_pools
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
  #
  # On approval, each line's approval level is checked again after simulating the lines before it, since an earlier
  # line (e.g. a category change or implication) can change what a later line does.
  def validate_script
    CurrentUser.scoped(User.system) do
      BulkUpdateRequest.transaction(requires_new: true) do
        commands.each do |command|
          if validation_context == :approval && approver.level < command.approval_level
            errors.add(:base, "Can't approve #{command.to_dtext} (requires #{User.level_string(command.approval_level)})")
          end

          command.validate(context: validation_context, errors: errors, approver: approver)
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

  # A line can't search a pool changed by an earlier line, or the earlier line could sneak posts into it. For example,
  # `update tag -> pool:123` followed by `update pool:123 -> foo` would add `foo` to every post with `tag`, not just the
  # posts the approver saw in the pool. Searching a pool in several lines, or before the line that changes it, is fine.
  def validate_edited_pools
    edited_pools = []

    commands.each do |command|
      (command.searched_pools & edited_pools).each do |pool|
        errors.add(:base, "Can't use {{pool:#{pool.name}}} after an earlier line changes it (move this line before the change, or split it into separate requests)")
      end

      (command.edited_pools & edited_pools).each do |pool|
        errors.add(:base, "Can't change {{pool:#{pool.name}}} in more than one line (split it into separate requests)")
      end

      edited_pools += command.edited_pools
    end
  end

  # Schedule the bulk update request to be processed later, in the background.
  def process_later!
    ProcessBulkUpdateRequestJob.perform_later(bulk_update_request)
  end

  # Process the bulk update request immediately.
  def process!
    CurrentUser.scoped(User.system) do
      # Read this before updating the status, which changes `updated_at` if the BUR wasn't already marked as processing.
      approved_at = bulk_update_request.updated_at
      bulk_update_request.update!(status: "processing")

      commands.each do |command|
        command.process!(approver: approver, forum_topic: forum_topic, approved_at: approved_at)
      end

      bulk_update_request.update!(status: "approved")
    rescue Error => e
      bulk_update_request.update!(status: "failed")
      if forum_topic.present? && bulk_update_request.forum_post.present?
        bulk_update_request.forum_updater.update("The #{bulk_update_request.bulk_update_request_link} (forum ##{bulk_update_request.forum_post.id}) failed: #{e.message}.")
      end
      raise
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

  # The pools searched or changed by the script. Used to avoid approving BURs that touch the same pool at the same time.
  # @return [Array<Pool>] the list of pools
  def affected_pools
    commands.flat_map { |command| command.searched_pools + command.edited_pools }.uniq
  end

  # Convert the BUR to DText format.
  # @return [String]
  def to_dtext
    commands.map(&:to_dtext).join("\n")
  end

  # @param tags [Array<Tag>, nil] preloaded tags to look up instead of querying individually. Used to filter for approvable BURs by the controller without hitting n+1 issues.
  # @return [Integer] the minimum level required to approve this BUR.
  # @see User::Levels
  def approval_level(tags: nil)
    commands.map { |command| command.approval_level(tags:) }.max
  end
end
