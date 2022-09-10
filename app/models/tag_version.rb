# frozen_string_literal: true

class TagVersion < ApplicationRecord
  include VersionFor

  version_for :tag
end
