class UpdateAliasedImplicationAntecedents < ActiveRecord::Migration
  def change
    execute "set statement_timeout = 0"
    TagImplication.find_each do |ti|
      ta = TagAlias.where("antecedent_name = ? AND status != ?", ti.antecedent_name, "pending").first
      if ta
        if ta.consequent_name == ti.consequent_name
          ti.destroy
        elsif TagImplication.where("antecedent_name = ? AND consequent_name = ?", ta.consequent_name, ti.consequent_name).exists?
          ti.destroy
        else
          ti.antecedent_name = ta.consequent_name
          ti.save
        end
        ta.update_posts
      end
    end
  end
end
