# frozen_string_literal: true

# Represents a script line that did not match any known command syntax.
#
# Always fails validation with an "Invalid line" error. Used as the fallback
# by `BulkUpdateRequest::Command.parse` when no subclass regex matches.
class BulkUpdateRequest::Command::InvalidLine < BulkUpdateRequest::Command
  def initialize(params)
    super
    @line = params[:line]
  end

  def affected_tags
    []
  end

  def to_dtext
    @line
  end

  def validate(errors:, **)
    errors.add(:base, "Invalid line: #{@line}")
  end
end
