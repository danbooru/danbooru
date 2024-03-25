require_relative "base"

metadata = AIMetadata.find_by_sql(<<~SQL)
UPDATE "ai_metadata"
SET "parameters" = jsonb_build_object('Sampler', sampler, 'Seed', seed, 'Steps', steps, 'Cfg Scale', cfg_scale, 'Model Hash', model_hash)
RETURNING "ai_metadata".*;
SQL

versions = AIMetadataVersion.find_by_sql(<<~SQL)
UPDATE "ai_metadata_versions"
SET "parameters" = jsonb_build_object('Sampler', sampler, 'Seed', seed, 'Steps', steps, 'Cfg Scale', cfg_scale, 'Model Hash', model_hash)
RETURNING "ai_metadata_versions".*;
SQL
