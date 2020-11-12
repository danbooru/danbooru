class TagAlias < TagRelationship
  after_save :create_mod_action
  validates_uniqueness_of :antecedent_name, scope: :status, conditions: -> { active }
  validate :absence_of_transitive_relation

  def approve!(approver)
    ProcessTagAliasJob.perform_later(self, approver)
  end

  def self.to_aliased(names)
    names = Array(names).map(&:to_s)
    return [] if names.empty?
    aliases = active.where(antecedent_name: names).map { |ta| [ta.antecedent_name, ta.consequent_name] }.to_h
    names.map { |name| aliases[name] || name }
  end

  def process!(approver)
    update!(approver: approver, status: "processing")
    TagMover.new(antecedent_name, consequent_name, user: User.system).move!
    update!(status: "active")
  rescue Exception => e
    update!(status: "error: #{e}")
    DanbooruLogger.log(e, tag_alias_id: id, antecedent_name: antecedent_name, consequent_name: consequent_name)
  end

  def absence_of_transitive_relation
    return if is_rejected?

    # We don't want a -> b && b -> c chains if the b -> c alias was created first.
    # If the a -> b alias was created first, the new one will be allowed and the old one will be moved automatically instead.
    if TagAlias.active.exists?(antecedent_name: consequent_name)
      errors[:base] << "A tag alias for #{consequent_name} already exists"
    end
  end

  def create_mod_action
    alias_desc = %("tag alias ##{id}":[#{Rails.application.routes.url_helpers.tag_alias_path(self)}]: [[#{antecedent_name}]] -> [[#{consequent_name}]])

    if saved_change_to_id?
      ModAction.log("created #{status} #{alias_desc}", :tag_alias_create)
    else
      # format the changes hash more nicely.
      change_desc = saved_changes.except(:updated_at).map do |attribute, values|
        old, new = values[0], values[1]
        if old.nil?
          %(set #{attribute} to "#{new}")
        else
          %(changed #{attribute} from "#{old}" to "#{new}")
        end
      end.join(", ")

      ModAction.log("updated #{alias_desc}\n#{change_desc}", :tag_alias_update)
    end
  end
end
