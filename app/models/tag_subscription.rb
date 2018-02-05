class TagSubscription < ApplicationRecord
  belongs_to :creator, :class_name => "User"
  validates_presence_of :name, :tag_query, :creator_id

  def migrate_to_saved_searches
    tag_query.split(/\r\n|\r|\n/).each do |query|
      creator.saved_searches.create(query: query, labels: [name])
    end
  end

  def pretty_name
    name.tr("_", " ")
  end

  def pretty_tag_query
    tag_query_array.join(", ")
  end

  def tag_query_array
    tag_query.scan(/[^\r\n]+/).map(&:strip)
  end

  def editable_by?(user)
    user.is_moderator? || creator_id == user.id
  end

  module SearchMethods
    def visible_to(user)
      where("(is_public = TRUE OR creator_id = ? OR ?)", user.id, user.is_moderator?)
    end

    def owned_by(user)
      where("creator_id = ?", user.id)
    end

    def name_matches(name)
      where("lower(name) like ? escape E'\\\\'", name.to_escaped_for_sql_like)
    end

    def search(params)
      q = super

      if params[:creator_id]
        q = q.where("creator_id = ?", params[:creator_id].to_i)
      elsif params[:creator_name]
        q = q.where("creator_id = (select _.id from users _ where lower(_.name) = ?)", params[:creator_name].mb_chars.downcase.strip.tr(" ", "_"))
      else
        q = q.where("creator_id = ?", CurrentUser.user.id)
      end

      if params[:name_matches]
        q = q.name_matches(params[:name_matches].mb_chars.downcase.strip.tr(" ", "_"))
      end

      q = q.visible_to(CurrentUser.user)

      q.apply_default_order(params)
    end
  end

  extend SearchMethods
end
