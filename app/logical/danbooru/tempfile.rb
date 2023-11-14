# frozen_string_literal: true

# Like Tempfile, but delete the tempfile when it's closed.
#
# The Tempfile class in the standard library doesn't delete the file immediately when you call `file.close`. Instead you
# have to call `file.close!` or `file.unlink` to delete the file, or wait until the object gets garbage collected, which
# can take a long time. This makes it so that Tempfiles are cleaned up immediately on close.
module Danbooru
  class Tempfile < ::Tempfile
    def close(unlink = true)
      super
    end
  end
end
