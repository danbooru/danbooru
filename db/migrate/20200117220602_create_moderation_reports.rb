class CreateModerationReports < ActiveRecord::Migration[6.0]
  def change
    create_table :moderation_reports do |t|
      t.timestamps
      t.references :model, polymorphic: true, null: false
      t.integer :creator_id, null: false
      t.text :reason, null: false
    end

    add_index :moderation_reports, :creator_id
  end
end
