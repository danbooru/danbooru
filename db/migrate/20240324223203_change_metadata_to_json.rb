class ChangeMetadataToJson < ActiveRecord::Migration[7.1]
  def change
    add_column :ai_metadata, :parameters, :jsonb, default: {}, null: false
    add_column :ai_metadata_versions, :parameters, :jsonb, default: {}, null: false

    reversible do |dir|
      dir.up do
        execute <<~SQL
        CREATE FUNCTION object_keys(jsonb) RETURNS text[] LANGUAGE SQL IMMUTABLE AS $$
          SELECT array_agg(jsonb_object_keys) FROM jsonb_object_keys($1)
        $$;
        CREATE INDEX "index_ai_metadata_on_parameters" ON "ai_metadata" USING GIN (object_keys(parameters));
        SQL
      end
      dir.down do
        execute <<~SQL
        DROP INDEX "index_ai_metadata_on_parameters";
        DROP FUNCTION object_keys;
        SQL
      end
    end
  end
end
