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

drop sequence favorite_tags_id_seq;
alter table favorites drop column id;
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

-- post processing
drop table dmails_orig;
drop table favorites_orig;
