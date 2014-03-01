class ArtistCommentary < ActiveRecord::Base
  attr_accessible :post_id, :original_description, :original_title, :translated_description, :translated_title
  validates_uniqueness_of :post_id
  belongs_to :post
  has_many :versions, :class_name => "ArtistCommentaryVersion", :dependent => :destroy, :foreign_key => :post_id, :primary_key => :post_id, :order => "artist_commentary_versions.id ASC"
  after_save :create_version

  def original_present?
    original_title.present? || original_description.present?
  end

  def translated_present?
    translated_title.present? || translated_description.present?
  end

  def any_field_present?
    original_present? || translated_present?
  end

  def create_version
    versions.create(
      :post_id => post_id,
      :original_title => original_title,
      :original_description => original_description,
      :translated_title => translated_title,
      :translated_description => translated_description
    )
  end

  def revert_to(version)
    self.original_description = version.original_description
    self.original_title = version.original_title
    self.translated_description = version.translated_description
    self.translated_title = version.translated_title
  end

  def revert_to!(version)
    revert_to(version)
    save!
  end
end
