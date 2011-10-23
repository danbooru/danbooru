create index index_advertisements_on_ad_type on advertisements (ad_type);

alter table artist_urls drop constraint artist_urls_artist_id_fkey;
alter table artist_urls add column created_at timestamp not null default now();
alter table artist_urls add column updated_at timestamp not null default now();

alter table artist_versions drop column version;
alter table artist_versions add column updater_ip_addr inet default '127.0.0.1';
alter table artist_versions add column other_names text default '';
update artist_versions set other_names = array_to_string(other_names_array, ' ');
alter table artist_versions drop column other_names_array;
alter table artist_versions rename column cached_urls to url_string;

alter table artists drop column version;
alter table artists add column updater_ip_addr inet default '127.0.0.1';
alter table artists add column other_names text default '';
update artists set other_names = array_to_string(other_names_array, ' ');
alter table artists drop column other_names_array;
alter table artists drop constraint artists_updater_id_fkey;
alter index artists_name_uniq rename to index_artists_on_name;
alter table artists add column other_names_index tsvector;
CREATE INDEX index_artists_on_other_names_index ON artists USING GIN (other_names_index);
CREATE TRIGGER trigger_artists_on_update BEFORE INSERT OR UPDATE ON artists FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('other_names_index', 'public.danbooru', 'other_names');

alter table banned_ips rename to ip_bans;
alter index index_banned_ips_on_ip_addr rename to index_ip_bans_on_ip_addr;
alter table ip_bans drop column id;
alter table ip_bans add column id serial primary key;

alter table bans drop constraint bans_banned_by_fkey;
alter table bans drop constraint bans_user_id_fkey;
alter table bans rename column banned_by to banner_id;
create index index_bans_on_banner_id on bans (banner_id);
create index index_bans_on_expires_at on bans (expires_at);
alter table bans drop column old_level;
alter table bans add column created_at timestamp not null default now();
alter table bans add column updated_at timestamp not null default now();

alter table comment_votes add column score integer not null default 0;
alter table comment_votes drop constraint comment_votes_comment_id_fkey;
alter table comment_votes drop constraint comment_votes_user_id_fkey;

alter index idx_comments__post rename to index_comments_on_post_id;
alter table comments drop constraint fk_comments__post;
alter table comments drop constraint fk_comments__user;
alter table comments rename column text_search_index to body_index;
alter table comments add column updated_at timestamp;
alter table comments rename column user_id to creator_id;
alter index index_comments_on_user_id rename to index_comments_on_creator_id;
drop trigger trg_comment_search_update on comments;
CREATE TRIGGER trigger_comments_on_update BEFORE INSERT OR UPDATE ON comments FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('body_index', 'pg_catalog.english', 'body');

CREATE TABLE delayed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0,
    attempts integer DEFAULT 0,
    handler text,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
CREATE SEQUENCE delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;
ALTER SEQUENCE delayed_jobs_id_seq OWNED BY delayed_jobs.id;
ALTER TABLE delayed_jobs ALTER COLUMN id SET DEFAULT nextval('delayed_jobs_id_seq'::regclass);
ALTER TABLE ONLY delayed_jobs ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);
CREATE INDEX index_delayed_jobs_on_run_at ON delayed_jobs USING btree (run_at);

alter table dmails rename to dmails_orig;
alter table dmails_orig drop constraint dmails_from_id_fkey;
alter table dmails_orig drop constraint dmails_parent_id_fkey;
alter table dmails_orig drop constraint dmails_to_id_fkey;
alter table dmails_orig drop column id;
CREATE TABLE dmails (
    id integer NOT NULL,
    owner_id integer NOT NULL,
    from_id integer NOT NULL,
    to_id integer NOT NULL,
    title character varying(255) NOT NULL,
    body text NOT NULL,
    message_index tsvector NOT NULL,
    is_read boolean DEFAULT false NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
CREATE SEQUENCE dmails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;
ALTER SEQUENCE dmails_id_seq OWNED BY dmails.id;
ALTER TABLE dmails ALTER COLUMN id SET DEFAULT nextval('dmails_id_seq'::regclass);
ALTER TABLE ONLY dmails ADD CONSTRAINT dmails_pkey PRIMARY KEY (id);
CREATE INDEX index_dmails_on_message_index ON dmails USING gin (message_index);
CREATE INDEX index_dmails_on_owner_id ON dmails USING btree (owner_id);
insert into dmails (owner_id, from_id, to_id, title, body, is_read, is_deleted, created_at, updated_at) select dmails_orig.from_id, dmails_orig.from_id, dmails_orig.to_id, dmails_orig.title, dmails_orig.body, dmails_orig.has_seen, false, dmails_orig.created_at, dmails_orig.created_at from dmails_orig;
insert into dmails (owner_id, from_id, to_id, title, body, is_read, is_deleted, created_at, updated_at) select dmails_orig.to_id, dmails_orig.from_id, dmails_orig.to_id, dmails_orig.title, dmails_orig.body, dmails_orig.has_seen, false, dmails_orig.created_at, dmails_orig.created_at from dmails_orig;

alter table favorites drop column id;
drop sequence favorite_tags_id_seq;
alter table favorites rename to favorites_orig;
alter table favorites_orig drop constraint fk_favorites__post;
alter table favorites_orig drop constraint fk_favorites__user;
alter table favorites_orig drop column created_at;

-- create favorites
-- convert favorites

alter table flagged_post_details rename to post_flags;
alter table post_flags rename column user_id to creator_id;
alter table post_flags add column creator_ip_addr inet not null default '127.0.0.1';
alter table post_flags add column updated_at timestamp not null default now();
alter table post_flags drop constraint flagged_post_details_post_id_fkey;
alter table post_flags drop constraint flagged_post_details_user_id_fkey;
alter index flagged_post_details_pkey rename to post_flags_pkey;
alter index index_flagged_post_details_on_post_id rename to index_post_flags_on_post_id;
alter table post_flags drop column id;
alter table post_flags add column id serial primary key;

CREATE TABLE forum_topics (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    updater_id integer NOT NULL,
    title character varying(255) NOT NULL,
    response_count integer DEFAULT 0 NOT NULL,
    is_sticky boolean DEFAULT false NOT NULL,
    is_locked boolean DEFAULT false NOT NULL,
    text_index tsvector NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    original_post_id integer not null
);
CREATE SEQUENCE forum_topics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;
ALTER SEQUENCE forum_topics_id_seq OWNED BY forum_topics.id;
ALTER TABLE forum_topics ALTER COLUMN id SET DEFAULT nextval('forum_topics_id_seq'::regclass);
ALTER TABLE ONLY forum_topics
    ADD CONSTRAINT forum_topics_pkey PRIMARY KEY (id);
CREATE INDEX index_forum_topics_on_creator_id ON forum_topics USING btree (creator_id);
CREATE INDEX index_forum_topics_on_original_post_id ON forum_topics USING btree (original_post_id);
CREATE INDEX index_forum_topics_on_text_index ON forum_topics USING gin (text_index);
CREATE TRIGGER trigger_forum_topics_on_update
    BEFORE INSERT OR UPDATE ON forum_topics
    FOR EACH ROW
    EXECUTE PROCEDURE tsvector_update_trigger('text_index', 'pg_catalog.english', 'title');
insert into forum_topics (creator_id, updater_id, title, response_count, is_sticky, is_locked, text_index, created_at, updated_at, original_post_id) select forum_posts.creator_id, forum_posts.creator_id, forum_posts.title, forum_posts.response_count, forum_posts.is_sticky, forum_posts.is_locked, forum_posts.text_search_index, forum_posts.created_at, forum_posts.updated_at, forum_posts.id from forum_posts where parent_id is null;

alter table forum_posts drop constraint forum_posts_creator_id_fkey;
alter table forum_posts drop constraint forum_posts_last_updated_by_fkey;
alter table forum_posts drop constraint forum_posts_parent_id_fkey;
alter table forum_posts rename column text_search_index to text_index;
alter index forum_posts_search_idx rename to index_forum_posts_on_text_index;
drop trigger trg_forum_post_search_update on forum_posts;
CREATE TRIGGER trigger_forum_posts_on_update
    BEFORE INSERT OR UPDATE ON forum_posts
    FOR EACH ROW
    EXECUTE PROCEDURE tsvector_update_trigger('text_index', 'pg_catalog.english', 'body');
alter table forum_posts add column topic_id integer;
update forum_posts set topic_id = (select forum_topics.id from forum_topics where forum_topics.original_post_id = forum_posts.parent_id) where forum_posts.parent_id is not null;
update forum_posts set topic_id = (select forum_topics.id from forum_topics where forum_topics.original_post_id = forum_posts.id) where forum_posts.parent_id is null;
alter table forum_posts drop column parent_id;
alter table forum_topics drop column original_post_id;
alter table forum_posts drop column is_sticky;
alter table forum_posts drop column is_locked;
alter table forum_posts drop column title;
alter table forum_posts drop column response_count;
alter table forum_posts drop column last_updated_by;
alter table forum_posts add column updater_id integer;
create index index_forum_posts_on_topic_id on forum_posts (topic_id);

drop table job_tasks;

alter table mod_actions rename column user_id to creator_id;
alter index index_mod_actions_on_user_id rename to index_mod_actions_on_creator_id;

alter table mod_queue_posts rename to post_disapprovals;
alter table post_disapprovals add column created_at timestamp default now();
alter table post_disapprovals add column updated_at timestamp default now();
alter table post_disapprovals drop constraint mod_queue_posts_post_id_fkey;
alter table post_disapprovals drop constraint mod_queue_posts_user_id_fkey;
alter table post_disapprovals drop column id;
alter table post_disapprovals add column id serial primary key;
create index index_post_disapprovals_on_user_id on post_disapprovals (user_id);
create index index_post_disapprovals_on_post_id on post_disapprovals (post_id);

alter table note_versions drop constraint fk_note_versions__note;
alter table note_versions drop constraint fk_note_versions__post;
alter table note_versions drop constraint fk_note_versions__user;
alter table note_versions drop column version;
alter table note_versions rename column ip_addr to updater_ip_addr;
alter table note_versions rename column user_id to updater_id;
alter table note_versions drop column text_search_index;
alter index idx_note_versions__post rename to index_note_versions_on_post_id;
alter index idx_notes__note rename to index_note_versions_on_note_id;
alter index index_note_versions_on_user_id rename to index_note_versions_on_updater_id;
create index index_note_versions_on_updater_ip_addr on note_versions (updater_ip_addr);

alter table notes drop constraint fk_notes__post;
alter table notes drop constraint fk_notes__user;
drop trigger trg_note_search_update on notes;
alter table notes rename column user_id to creator_id;
alter table notes rename column text_search_index to body_index;
alter index comments_text_search_idx rename to index_notes_on_body_index;
alter index idx_notes__post rename to index_notes_on_post_id;
drop index notes_text_search_idx;
CREATE TRIGGER trigger_notes_on_update BEFORE INSERT OR UPDATE ON notes FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('body_index', 'pg_catalog.english', 'body');
create index index_notes_on_creator_id on notes (creator_id);
alter table notes drop column ip_addr;
alter table notes drop column version;

drop table pixiv_proxies;

alter table pool_updates drop constraint pool_updates_pool_id_fkey;
alter table pool_updates rename to pool_versions;
alter table pool_versions rename column user_id to updater_id;
alter table pool_versions rename column ip_addr to updater_ip_addr;
alter index index_pool_updates_on_pool_id rename to index_pool_versions_on_pool_id;
alter index index_pool_updates_on_user_id rename to index_pool_versions_on_updater_id;
create index index_pool_versions_on_updater_ip_addr on pool_versions (updater_ip_addr);
alter table pool_versions drop column id;
alter table pool_versions add column id serial primary key;

alter table pools drop constraint pools_user_id_fkey;
alter table pools rename column user_id to creator_id;
alter table pools drop column is_public;
alter table pools add column post_ids text not null default '';
alter index pools_user_id_idx rename to index_pools_on_creator_id;
-- update pools.post_ids

drop table post_change_seq;

alter table post_tag_histories rename to post_versions;
alter table post_versions drop constraint fk_post_tag_histories__post;
alter table post_versions drop constraint post_tag_histories_user_id_fkey;
alter table post_versions rename column created_at to updated_at;
alter table post_versions rename column user_id to updater_id;
alter table post_versions rename column ip_addr to updater_ip_addr;
alter table post_versions add column source text;
alter index idx_post_tag_histories__post rename to index_post_versions_on_post_id;
alter index index_post_tag_histories_on_user_id rename to index_post_versions_on_updater_id;
create index index_post_versions_on_updater_ip_addr on post_versions (updater_ip_addr);
alter table post_versions drop column id;
alter table post_versions add column id serial primary key;

alter table post_votes drop constraint post_votes_post_id_fkey;
alter table post_votes drop constraint post_votes_user_id_fkey;

drop trigger trg_posts_tags_index_update on posts;
alter table posts drop constraint fk_posts__user;
alter table posts drop constraint posts_approver_id_fkey;
alter table posts drop constraint posts_parent_id_fkey;
alter table posts add column up_score integer not null default 0;
alter table posts add column down_score integer not null default 0;
alter table posts rename column width to image_width;
alter table posts rename column height to image_height;
alter table posts rename column ip_addr to uploader_ip_addr;
alter table posts rename column user_id to uploader_id;
alter table posts rename column cached_tags to tag_string;
alter table posts add column is_pending boolean not null default false;
alter table posts add column is_flagged boolean not null default false;
alter table posts add column is_deleted boolean not null default false;
update posts set is_pending = true where status = 'pending';
update posts set is_flagged = true where status = 'flagged';
update posts set is_deleted = true where status = 'deleted';
alter table posts drop column status;
alter table posts drop column sample_width;
alter table posts drop column sample_height;
alter table posts drop column change_seq;
alter table posts rename column tags_index to tag_index;
alter table posts rename column general_tag_count to tag_count_general;
alter table posts rename column artist_tag_count to tag_count_artist;
alter table posts rename column character_tag_count to tag_count_character;
alter table posts rename column copyright_tag_count to tag_count_copyright;
alter table posts add column fav_string text not null default '';
alter table posts add column pool_string text not null default '';
CREATE TRIGGER trigger_posts_on_tag_index_update BEFORE INSERT OR UPDATE ON posts FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('tag_index', 'public.danbooru', 'tag_string', 'fav_string', 'pool_string');
alter index idx_posts__md5 rename to index_posts_on_md5;
alter index idx_posts__created_at rename to index_posts_on_created_at;
alter index idx_posts__last_commented_at rename to index_posts_on_last_commented_at;
alter index idx_posts__last_noted_at rename to index_posts_on_last_noted_at;
alter index idx_posts__users rename to index_posts_on_uploader_id;
alter index idx_posts_parent_id rename to index_posts_on_parent_id;
alter index index_posts_on_height rename to index_posts_on_image_height;
alter index index_posts_on_width rename to index_posts_on_image_width;
alter index index_posts_on_tags_index rename to index_posts_on_tag_index;
alter index posts_mpixels rename to index_posts_on_mpixels;
create index index_posts_on_uploader_ip_addr on posts (uploader_ip_addr);
-- update posts.fav_string
-- update posts.pool_string

drop table server_keys;
drop table table_data;

alter table tag_aliases drop constraint fk_tag_aliases__alias;
alter table tag_aliases drop constraint tag_aliases_creator_id_fkey;
alter table tag_aliases rename column name to antecedent_name;
alter table tag_aliases add column consequent_name varchar(255) not null default '';
alter table tag_aliases add column status varchar(255) not null default 'active';
alter table tag_aliases add column forum_topic_id integer;
alter table tag_aliases add column creator_ip_addr inet not null default '127.0.0.1';
alter index idx_tag_aliases__name rename to index_tag_aliases_on_antecedent_name;
create index index_tag_aliases_on_consequent_name on tag_aliases (consequent_name);
update tag_aliases set status = 'active' where is_pending = false;
update tag_aliases set status = 'pending' where is_pending = true;
alter table tag_aliases drop column is_pending;
update tag_aliases set consequent_name = (select _.name from tags _ where _.id = tag_aliases.alias_id);
alter table tag_aliases drop column alias_id;

alter table tag_implications drop constraint fk_tag_implications__child;
alter table tag_implications drop constraint fk_tag_implications__parent;
alter table tag_implications drop constraint tag_implications_creator_id_fkey;
alter table tag_implications add column antecedent_name varchar(255) not null default '';
alter table tag_implications add column consequent_name varchar(255) not null default '';
alter table tag_implications add column descendant_names text not null default '';
alter table tag_implications add column creator_ip_addr inet not null default '127.0.0.1';
alter table tag_implications add column status varchar(255) not null default 'active';
update tag_implications set status = 'active' where is_pending = false;
update tag_implications set status = 'pending' where is_pending = true;
alter table tag_implications drop column is_pending;
update tag_implications set antecedent_name = (select _.name from tags _ where _.id = tag_implications.predicate_id);
update tag_implications set conseuqent_name = (select _.name from tags _ where _.id = tag_implications.consequent_id);
alter table tag_implications drop column consequent_id;
alter table tag_implications drop column predicate_id;

alter table tag_subscriptions drop constraint tag_subscriptions_user_id_fkey;
alter table tag_subscriptions rename column user_id to creator_id;
alter table tag_subscriptions rename column cached_post_ids to post_ids;
alter table tag_subscriptions rename column is_visible_on_profile to is_public;
alter table tag_subscriptions add column created_at timestamp without time zone;
alter table tag_subscriptions add column updated_at timestamp without time zone;
alter table tag_subscriptions add column last_accessed_at timestamp without time zone;
alter index index_tag_subscriptions_on_user_id rename to index_tag_subscriptions_on_creator_id;

alter table tags rename column tag_type to category;
alter table tags drop column is_ambiguous;
alter table tags rename column cached_related to related_tags;
alter table tags rename column cached_related_expires_on to related_tags_updated_at;
alter table tags add column created_at timestamp without time zone;
alter table tags add column updated_at timestamp without time zone;
alter index idx_tags__name rename to index_tags_on_name;
alter index idx_tags__post_count rename to index_tags_on_post_count;

alter table test_janitors rename to janitor_trials;
alter table janitor_trials drop column id;
alter table janitor_trials add column id serial primary key;
alter table janitor_trials drop column promotion_date;
alter table janitor_trials drop column test_promotion_date;
alter table janitor_trials drop constraint test_janitors_user_id_fkey;
alter table janitor_trials rename column user_id to creator_id;
alter index index_test_janitors_on_user_id rename to index_janitor_trials_on_creator_id;

alter table user_records rename to user_feedback;
alter table user_feedback drop constraint user_records_reported_by_fkey;
alter table user_feedback drop constraint user_records_user_id_fkey;
alter table user_feedback rename column reported_by to creator_id;
alter table user_feedback add column category varchar(255) not null default '';
update user_feedback set category = 'negative' where is_positive = false;
update user_feedback set category = 'positive' where is_positive = true;
update user_feedback set category = 'neutral' where is_positive is null;
alter table user_feedback drop column is_positive;
create index index_user_feedback_on_user_id on user_feedback (user_id);
alter table user_feedback drop column id;
alter table user_feedback add column id serial primary key;

-- process user_blacklisted_tags

alter table users add column updated_at timestamp without time zone;
alter table users add column email_verification_key varchar(255);
alter table users rename column invited_by to inviter_id;
alter table users rename column last_forum_topic_read_at to last_forum_read_at;
alter table users rename column receive_dmails to receive_email_notifications;
alter table users add column is_banned boolean not null default false;
alter table users add column default_image_size varchar(255) not null default 'medium';
alter table users add column favorite_tags text;
alter table users add column blacklisted_tags text;
alter table users add column time_zone varchar(255) not null default 'Eastern Time (US & Canada)';
alter index idx_users__name rename to index_users_on_name;
create index index_users_on_email on users (email) where email is not null;
create index index_users_on_inviter_id on users (inviter_id) where inviter_id is not null;
-- update users.blacklisted_tags

alter table wiki_page_versions drop constraint fk_wiki_page_versions__user;
alter table wiki_page_versions drop constraint fk_wiki_page_versions__wiki_page;
alter table wiki_page_versions rename column user_id to updater_id;
alter table wiki_page_versions rename column ip_addr to updater_ip_addr;
alter table wiki_page_versions drop column version;
alter table wiki_page_versions drop column text_search_index;
alter index idx_wiki_page_versions__wiki_page rename to index_wiki_page_versions_on_wiki_page_id;
alter index index_wiki_page_versions_on_user_id rename to index_wiki_page_versions_on_updater_id;

alter table wiki_pages drop constraint fk_wiki_pages__user;

-- post processing
drop table dmails_orig;
drop table favorites_orig;
drop table pools_posts;
alter table users drop column show_samples;