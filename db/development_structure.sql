--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

--
-- Name: testprs_end(internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION testprs_end(internal) RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/test_parser', 'testprs_end';


--
-- Name: testprs_getlexeme(internal, internal, internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION testprs_getlexeme(internal, internal, internal) RETURNS internal
    LANGUAGE c STRICT
    AS '$libdir/test_parser', 'testprs_getlexeme';


--
-- Name: testprs_lextype(internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION testprs_lextype(internal) RETURNS internal
    LANGUAGE c STRICT
    AS '$libdir/test_parser', 'testprs_lextype';


--
-- Name: testprs_start(internal, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION testprs_start(internal, integer) RETURNS internal
    LANGUAGE c STRICT
    AS '$libdir/test_parser', 'testprs_start';


--
-- Name: testparser; Type: TEXT SEARCH PARSER; Schema: public; Owner: -
--

CREATE TEXT SEARCH PARSER testparser (
    START = testprs_start,
    GETTOKEN = testprs_getlexeme,
    END = testprs_end,
    HEADLINE = prsd_headline,
    LEXTYPES = testprs_lextype );


--
-- Name: danbooru; Type: TEXT SEARCH CONFIGURATION; Schema: public; Owner: -
--

CREATE TEXT SEARCH CONFIGURATION danbooru (
    PARSER = testparser );

ALTER TEXT SEARCH CONFIGURATION danbooru
    ADD MAPPING FOR word WITH simple;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: pending_posts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pending_posts (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    source character varying(255),
    file_path character varying(255),
    content_type character varying(255),
    rating character(1) NOT NULL,
    uploader_id integer NOT NULL,
    uploader_ip_addr inet NOT NULL,
    tag_string text NOT NULL,
    status character varying(255) DEFAULT 'pending'::character varying NOT NULL,
    post_id integer
);


--
-- Name: pending_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pending_posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: pending_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pending_posts_id_seq OWNED BY pending_posts.id;


--
-- Name: pool_versions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pool_versions (
    id integer NOT NULL,
    pool_id integer,
    post_ids text DEFAULT ''::text NOT NULL,
    updater_id integer NOT NULL,
    updater_ip_addr inet NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: pool_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pool_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: pool_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pool_versions_id_seq OWNED BY pool_versions.id;


--
-- Name: pools; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pools (
    id integer NOT NULL,
    name character varying(255),
    creator_id integer NOT NULL,
    description text,
    is_public boolean DEFAULT true NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    post_ids text DEFAULT ''::text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: pools_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pools_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: pools_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pools_id_seq OWNED BY pools.id;


--
-- Name: post_versions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE post_versions (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    post_id integer NOT NULL,
    source character varying(255),
    rating character(1) DEFAULT 'q'::bpchar NOT NULL,
    tag_string text NOT NULL,
    updater_id integer NOT NULL,
    updater_ip_addr inet NOT NULL
);


--
-- Name: post_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE post_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: post_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE post_versions_id_seq OWNED BY post_versions.id;


--
-- Name: posts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE posts (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    score integer DEFAULT 0 NOT NULL,
    source character varying(255),
    md5 character varying(255) NOT NULL,
    rating character(1) DEFAULT 'q'::bpchar NOT NULL,
    is_note_locked boolean DEFAULT false NOT NULL,
    is_rating_locked boolean DEFAULT false NOT NULL,
    is_pending boolean DEFAULT false NOT NULL,
    is_flagged boolean DEFAULT false NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    uploader_string character varying(255) NOT NULL,
    uploader_ip_addr inet NOT NULL,
    approver_string character varying(255) DEFAULT ''::character varying NOT NULL,
    fav_string text DEFAULT ''::text NOT NULL,
    pool_string text DEFAULT ''::text NOT NULL,
    view_count integer DEFAULT 0 NOT NULL,
    last_noted_at timestamp without time zone,
    last_commented_at timestamp without time zone,
    tag_string text DEFAULT ''::text NOT NULL,
    tag_index tsvector,
    tag_count integer DEFAULT 0 NOT NULL,
    tag_count_general integer DEFAULT 0 NOT NULL,
    tag_count_artist integer DEFAULT 0 NOT NULL,
    tag_count_character integer DEFAULT 0 NOT NULL,
    tag_count_copyright integer DEFAULT 0 NOT NULL,
    file_ext character varying(255) NOT NULL,
    file_size integer NOT NULL,
    image_width integer NOT NULL,
    image_height integer NOT NULL
);


--
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE posts_id_seq OWNED BY posts.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    post_count integer DEFAULT 0 NOT NULL,
    view_count integer DEFAULT 0 NOT NULL,
    category integer DEFAULT 0 NOT NULL,
    related_tags text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: unapprovals; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE unapprovals (
    id integer NOT NULL,
    post_id integer NOT NULL,
    reason text,
    unapprover_id integer NOT NULL,
    unapprover_ip_addr inet NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: unapprovals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE unapprovals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: unapprovals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE unapprovals_id_seq OWNED BY unapprovals.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    email character varying(255),
    invited_by integer,
    is_banned boolean DEFAULT false NOT NULL,
    is_privileged boolean DEFAULT false NOT NULL,
    is_contributor boolean DEFAULT false NOT NULL,
    is_janitor boolean DEFAULT false NOT NULL,
    is_moderator boolean DEFAULT false NOT NULL,
    is_admin boolean DEFAULT false NOT NULL,
    last_logged_in_at timestamp without time zone,
    last_forum_read_at timestamp without time zone,
    has_mail boolean DEFAULT false NOT NULL,
    receive_email_notifications boolean DEFAULT false NOT NULL,
    comment_threshold integer DEFAULT (-1) NOT NULL,
    always_resize_images boolean DEFAULT false NOT NULL,
    default_image_size character varying(255) DEFAULT 'medium'::character varying NOT NULL,
    favorite_tags text,
    blacklisted_tags text
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE pending_posts ALTER COLUMN id SET DEFAULT nextval('pending_posts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE pool_versions ALTER COLUMN id SET DEFAULT nextval('pool_versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE pools ALTER COLUMN id SET DEFAULT nextval('pools_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE post_versions ALTER COLUMN id SET DEFAULT nextval('post_versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE posts ALTER COLUMN id SET DEFAULT nextval('posts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE unapprovals ALTER COLUMN id SET DEFAULT nextval('unapprovals_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: pending_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pending_posts
    ADD CONSTRAINT pending_posts_pkey PRIMARY KEY (id);


--
-- Name: pool_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pool_versions
    ADD CONSTRAINT pool_versions_pkey PRIMARY KEY (id);


--
-- Name: pools_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pools
    ADD CONSTRAINT pools_pkey PRIMARY KEY (id);


--
-- Name: post_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY post_versions
    ADD CONSTRAINT post_versions_pkey PRIMARY KEY (id);


--
-- Name: posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: unapprovals_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY unapprovals
    ADD CONSTRAINT unapprovals_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_pool_versions_on_pool_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_pool_versions_on_pool_id ON pool_versions USING btree (pool_id);


--
-- Name: index_pools_on_creator_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_pools_on_creator_id ON pools USING btree (creator_id);


--
-- Name: index_pools_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_pools_on_name ON pools USING btree (name);


--
-- Name: index_post_versions_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_post_versions_on_post_id ON post_versions USING btree (post_id);


--
-- Name: index_post_versions_on_updater_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_post_versions_on_updater_id ON post_versions USING btree (updater_id);


--
-- Name: index_posts_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_posts_on_created_at ON posts USING btree (created_at);


--
-- Name: index_posts_on_file_size; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_posts_on_file_size ON posts USING btree (file_size);


--
-- Name: index_posts_on_image_height; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_posts_on_image_height ON posts USING btree (image_height);


--
-- Name: index_posts_on_image_width; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_posts_on_image_width ON posts USING btree (image_width);


--
-- Name: index_posts_on_last_commented_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_posts_on_last_commented_at ON posts USING btree (last_commented_at);


--
-- Name: index_posts_on_last_noted_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_posts_on_last_noted_at ON posts USING btree (last_noted_at);


--
-- Name: index_posts_on_md5; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_posts_on_md5 ON posts USING btree (md5);


--
-- Name: index_posts_on_mpixels; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_posts_on_mpixels ON posts USING btree (((((image_width * image_height))::numeric / 1000000.0)));


--
-- Name: index_posts_on_source; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_posts_on_source ON posts USING btree (source);


--
-- Name: index_posts_on_tags_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_posts_on_tags_index ON posts USING gin (tag_index);


--
-- Name: index_posts_on_view_count; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_posts_on_view_count ON posts USING btree (view_count);


--
-- Name: index_tags_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_tags_on_name ON tags USING btree (name);


--
-- Name: index_unapprovals_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_unapprovals_on_post_id ON unapprovals USING btree (post_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_name ON users USING btree (lower((name)::text));


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: trigger_posts_on_tag_index_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_posts_on_tag_index_update
    BEFORE INSERT OR UPDATE ON posts
    FOR EACH ROW
    EXECUTE PROCEDURE tsvector_update_trigger('tag_index', 'public.danbooru', 'tag_string', 'fav_string', 'pool_string', 'uploader_string', 'approver_string');


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('20100204211522');

INSERT INTO schema_migrations (version) VALUES ('20100204214746');

INSERT INTO schema_migrations (version) VALUES ('20100205162521');

INSERT INTO schema_migrations (version) VALUES ('20100205163027');

INSERT INTO schema_migrations (version) VALUES ('20100205224030');

INSERT INTO schema_migrations (version) VALUES ('20100209201251');

INSERT INTO schema_migrations (version) VALUES ('20100211025616');