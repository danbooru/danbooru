class UpdateAliasedImplicationConsequents < ActiveRecord::Migration[4.2]
  def change
    execute "set statement_timeout = 0"
    TagImplication.find_each do |ti|
      ta = TagAlias.where("antecedent_name = ? AND status != ?", ti.consequent_name, "pending").first
      if ta
        ti.consequent_name = ta.consequent_name
        ti.save
        ta.update_posts
      end
    end
  end
end
