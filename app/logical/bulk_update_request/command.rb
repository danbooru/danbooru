# frozen_string_literal: true

# Abstract base class representing a single parsed line in a Bulk Update Request script.
#
# Subclasses must implement:
# * `#self.regex` — a Regexp with named captures matching the command syntax
# * `initialize(params)` — accepts a hash of named capture values from the regex match
# * `validate(context:, errors:)` — adds validation errors to `errors`
# * `to_dtext` — returns a dtext string representation of the command
# * `affected_tags` — returns an array of tag names touched by this command
# * `process!(**opts)` — executes the command
#
# The `self.parse` factory method tries each subclass regex against a raw script line
# and returns a new instance on the first match, or an `InvalidLine` if none match.
class BulkUpdateRequest::Command
  # True if all command subclasses have been loaded and don't need to be loaded again.
  class_attribute :subclasses_loaded, default: false

  # The autoloader used to load BulkUpdateRequest::Command subclasses.
  class_attribute :autoloader, default: Zeitwerk::Loader

  # @return [Regexp] the regex used to match this command's syntax; must use named captures
  def self.regex
    raise NotImplementedError
  end

  # @param params [Hash] named capture values from the regex match
  def initialize(params)
    raise NotImplementedError
  end

  # Validate the command and add any errors to `errors`.
  # @param context [:request, :approval] `:request` when the BUR is created or edited; `:approval` when it is approved. Some validations only run on `:request`.
  # @param errors [ActiveModel::Errors] error collector to add messages to
  def validate(context:, errors:)
    raise NotImplementedError
  end

  # Execute the command.
  # @param approver [User] the user approving the BUR (required by some commands)
  # @param forum_topic [ForumTopic] the forum topic associated with the BUR (required by some commands)
  def process!(**)
    raise NotImplementedError
  end

  # @return [String] a dtext representation of this command
  def to_dtext
    raise NotImplementedError
  end

  # @return [Array<String>] the names of all tags affected by this command
  def affected_tags
    raise NotImplementedError
  end

  # @return [Integer] the minimum level that can approve this command
  # @see User::Levels
  def approval_level
    User::Levels::ADMIN
  end

  # @param line [String] a single line from a BUR script
  # @return [BulkUpdateRequest::Command] a command instance, or InvalidLine if the line doesn't match
  def self.parse(line)
    commands.each do |command|
      match = command.regex.match(line)
      next unless match

      return command.new(match.named_captures.with_indifferent_access)
    end

    BulkUpdateRequest::Command::InvalidLine.new(line: line)
  end

  # @return [Array<BulkUpdateRequest::Command>] The set of parseable command subclasses, excluding InvalidLine. Loaded lazily on demand.
  def self.commands
    self.subclasses_loaded ||= autoloader&.eager_load_namespace(BulkUpdateRequest::Command).present?
    BulkUpdateRequest::Command.descendants.reject { |k| k == BulkUpdateRequest::Command::InvalidLine }
  end
end
