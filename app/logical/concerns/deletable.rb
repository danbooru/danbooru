module Deletable
  extend ActiveSupport::Concern

  class_methods do
    def deletable
      scope :active, -> { where(is_deleted: false) }
      scope :deleted, -> { where(is_deleted: true) }
      scope :undeleted, -> { where(is_deleted: false) }
    end
  end
end
