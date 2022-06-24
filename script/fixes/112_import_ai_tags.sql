create temporary table ai_tags_import (md5 text, tag text, score real);
\copy ai_tags_import (md5, tag, score) from program 'zcat tags.csv.gz' with (format csv, header off);

create unlogged table ai_tags_temp as (select ma.id::integer as media_asset_id, t.id::integer as tag_id, (score * 100)::smallint as score from media_assets ma join ai_tags_import mli on mli.md5 = ma.md5 join tags t on t.name = mli.tag);

alter table ai_tags_temp set logged;
create index index_ai_tags_temp_on_media_asset_id on ai_tags_temp (media_asset_id);
create index index_ai_tags_temp_on_tag_id on ai_tags_temp (tag_id);
create index index_ai_tags_temp_on_score on ai_tags_temp (score);

alter table ai_tags_temp alter column media_asset_id set not null;
alter table ai_tags_temp alter column tag_id set not null;
alter table ai_tags_temp alter column score set not null;

begin;
alter table ai_tags rename to ai_tags_old;
alter index index_ai_tags_on_media_asset_id rename to index_ai_tags_old_on_media_asset_id;
alter index index_ai_tags_on_tag_id rename to index_ai_tags_old_on_tag_id;
alter index index_ai_tags_on_score rename to index_ai_tags_old_on_score;

alter table ai_tags_temp rename to ai_tags;
alter index index_ai_tags_temp_on_media_asset_id rename to index_ai_tags_on_media_asset_id;
alter index index_ai_tags_temp_on_tag_id rename to index_ai_tags_on_tag_id;
alter index index_ai_tags_temp_on_score rename to index_ai_tags_on_score;
commit;

drop table ai_tags_old;
drop table ai_tags_import;
