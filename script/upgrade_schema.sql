alter table posts add column fav_string text not null default '';
alter table posts add column pool_string text not null default '';

-- TODO: REVERT
update posts set fav_string = (select coalesce(string_agg('fav:' || _.user_id, ' '), '') from favorites _ where _.post_id = posts.id) where posts.id < 1000;
  
-- TODO: REVERT
update posts set pool_string = (select coalesce(string_agg('pool:' || _.pool_id, ' '), '') from pools_posts _ where _.post_id = posts.id) where posts.id < 1000;

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
alter table artists drop column updater_ip_addr;
alter table artists rename column updater_id to creator_id;
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
    title text NOT NULL,
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
CREATE TRIGGER trigger_dmails_on_update BEFORE INSERT OR UPDATE ON dmails FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('message_index', 'pg_catalog.english', 'title', 'body');
insert into dmails (owner_id, from_id, to_id, title, body, is_read, is_deleted, created_at, updated_at) select dmails_orig.from_id, dmails_orig.from_id, dmails_orig.to_id, dmails_orig.title, dmails_orig.body, dmails_orig.has_seen, false, dmails_orig.created_at, dmails_orig.created_at from dmails_orig;
insert into dmails (owner_id, from_id, to_id, title, body, is_read, is_deleted, created_at, updated_at) select dmails_orig.to_id, dmails_orig.from_id, dmails_orig.to_id, dmails_orig.title, dmails_orig.body, dmails_orig.has_seen, false, dmails_orig.created_at, dmails_orig.created_at from dmails_orig;
drop table dmails_orig;

alter table tag_subscriptions drop column id;
alter table tag_subscriptions add column id serial primary key;

-- alter table favorites drop constraint fk_favorites__post;
-- alter table favorites drop constraint fk_favorites__user;
-- alter table favorites drop constraint favorites_pkey;
drop index idx_favorites__post;
drop index idx_favorites__user;
alter table favorites rename to favorites_orig;

CREATE FUNCTION favorites_insert_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      begin
        if (NEW.user_id % 100 = 0) then
          insert into favorites_0 values (NEW.*);
    
        elsif (NEW.user_id % 100 = 1) then
          insert into favorites_1 values (NEW.*);

        elsif (NEW.user_id % 100 = 2) then
          insert into favorites_2 values (NEW.*);

        elsif (NEW.user_id % 100 = 3) then
          insert into favorites_3 values (NEW.*);

        elsif (NEW.user_id % 100 = 4) then
          insert into favorites_4 values (NEW.*);

        elsif (NEW.user_id % 100 = 5) then
          insert into favorites_5 values (NEW.*);

        elsif (NEW.user_id % 100 = 6) then
          insert into favorites_6 values (NEW.*);

        elsif (NEW.user_id % 100 = 7) then
          insert into favorites_7 values (NEW.*);

        elsif (NEW.user_id % 100 = 8) then
          insert into favorites_8 values (NEW.*);

        elsif (NEW.user_id % 100 = 9) then
          insert into favorites_9 values (NEW.*);

        elsif (NEW.user_id % 100 = 10) then
          insert into favorites_10 values (NEW.*);

        elsif (NEW.user_id % 100 = 11) then
          insert into favorites_11 values (NEW.*);

        elsif (NEW.user_id % 100 = 12) then
          insert into favorites_12 values (NEW.*);

        elsif (NEW.user_id % 100 = 13) then
          insert into favorites_13 values (NEW.*);

        elsif (NEW.user_id % 100 = 14) then
          insert into favorites_14 values (NEW.*);

        elsif (NEW.user_id % 100 = 15) then
          insert into favorites_15 values (NEW.*);

        elsif (NEW.user_id % 100 = 16) then
          insert into favorites_16 values (NEW.*);

        elsif (NEW.user_id % 100 = 17) then
          insert into favorites_17 values (NEW.*);

        elsif (NEW.user_id % 100 = 18) then
          insert into favorites_18 values (NEW.*);

        elsif (NEW.user_id % 100 = 19) then
          insert into favorites_19 values (NEW.*);

        elsif (NEW.user_id % 100 = 20) then
          insert into favorites_20 values (NEW.*);

        elsif (NEW.user_id % 100 = 21) then
          insert into favorites_21 values (NEW.*);

        elsif (NEW.user_id % 100 = 22) then
          insert into favorites_22 values (NEW.*);

        elsif (NEW.user_id % 100 = 23) then
          insert into favorites_23 values (NEW.*);

        elsif (NEW.user_id % 100 = 24) then
          insert into favorites_24 values (NEW.*);

        elsif (NEW.user_id % 100 = 25) then
          insert into favorites_25 values (NEW.*);

        elsif (NEW.user_id % 100 = 26) then
          insert into favorites_26 values (NEW.*);

        elsif (NEW.user_id % 100 = 27) then
          insert into favorites_27 values (NEW.*);

        elsif (NEW.user_id % 100 = 28) then
          insert into favorites_28 values (NEW.*);

        elsif (NEW.user_id % 100 = 29) then
          insert into favorites_29 values (NEW.*);

        elsif (NEW.user_id % 100 = 30) then
          insert into favorites_30 values (NEW.*);

        elsif (NEW.user_id % 100 = 31) then
          insert into favorites_31 values (NEW.*);

        elsif (NEW.user_id % 100 = 32) then
          insert into favorites_32 values (NEW.*);

        elsif (NEW.user_id % 100 = 33) then
          insert into favorites_33 values (NEW.*);

        elsif (NEW.user_id % 100 = 34) then
          insert into favorites_34 values (NEW.*);

        elsif (NEW.user_id % 100 = 35) then
          insert into favorites_35 values (NEW.*);

        elsif (NEW.user_id % 100 = 36) then
          insert into favorites_36 values (NEW.*);

        elsif (NEW.user_id % 100 = 37) then
          insert into favorites_37 values (NEW.*);

        elsif (NEW.user_id % 100 = 38) then
          insert into favorites_38 values (NEW.*);

        elsif (NEW.user_id % 100 = 39) then
          insert into favorites_39 values (NEW.*);

        elsif (NEW.user_id % 100 = 40) then
          insert into favorites_40 values (NEW.*);

        elsif (NEW.user_id % 100 = 41) then
          insert into favorites_41 values (NEW.*);

        elsif (NEW.user_id % 100 = 42) then
          insert into favorites_42 values (NEW.*);

        elsif (NEW.user_id % 100 = 43) then
          insert into favorites_43 values (NEW.*);

        elsif (NEW.user_id % 100 = 44) then
          insert into favorites_44 values (NEW.*);

        elsif (NEW.user_id % 100 = 45) then
          insert into favorites_45 values (NEW.*);

        elsif (NEW.user_id % 100 = 46) then
          insert into favorites_46 values (NEW.*);

        elsif (NEW.user_id % 100 = 47) then
          insert into favorites_47 values (NEW.*);

        elsif (NEW.user_id % 100 = 48) then
          insert into favorites_48 values (NEW.*);

        elsif (NEW.user_id % 100 = 49) then
          insert into favorites_49 values (NEW.*);

        elsif (NEW.user_id % 100 = 50) then
          insert into favorites_50 values (NEW.*);

        elsif (NEW.user_id % 100 = 51) then
          insert into favorites_51 values (NEW.*);

        elsif (NEW.user_id % 100 = 52) then
          insert into favorites_52 values (NEW.*);

        elsif (NEW.user_id % 100 = 53) then
          insert into favorites_53 values (NEW.*);

        elsif (NEW.user_id % 100 = 54) then
          insert into favorites_54 values (NEW.*);

        elsif (NEW.user_id % 100 = 55) then
          insert into favorites_55 values (NEW.*);

        elsif (NEW.user_id % 100 = 56) then
          insert into favorites_56 values (NEW.*);

        elsif (NEW.user_id % 100 = 57) then
          insert into favorites_57 values (NEW.*);

        elsif (NEW.user_id % 100 = 58) then
          insert into favorites_58 values (NEW.*);

        elsif (NEW.user_id % 100 = 59) then
          insert into favorites_59 values (NEW.*);

        elsif (NEW.user_id % 100 = 60) then
          insert into favorites_60 values (NEW.*);

        elsif (NEW.user_id % 100 = 61) then
          insert into favorites_61 values (NEW.*);

        elsif (NEW.user_id % 100 = 62) then
          insert into favorites_62 values (NEW.*);

        elsif (NEW.user_id % 100 = 63) then
          insert into favorites_63 values (NEW.*);

        elsif (NEW.user_id % 100 = 64) then
          insert into favorites_64 values (NEW.*);

        elsif (NEW.user_id % 100 = 65) then
          insert into favorites_65 values (NEW.*);

        elsif (NEW.user_id % 100 = 66) then
          insert into favorites_66 values (NEW.*);

        elsif (NEW.user_id % 100 = 67) then
          insert into favorites_67 values (NEW.*);

        elsif (NEW.user_id % 100 = 68) then
          insert into favorites_68 values (NEW.*);

        elsif (NEW.user_id % 100 = 69) then
          insert into favorites_69 values (NEW.*);

        elsif (NEW.user_id % 100 = 70) then
          insert into favorites_70 values (NEW.*);

        elsif (NEW.user_id % 100 = 71) then
          insert into favorites_71 values (NEW.*);

        elsif (NEW.user_id % 100 = 72) then
          insert into favorites_72 values (NEW.*);

        elsif (NEW.user_id % 100 = 73) then
          insert into favorites_73 values (NEW.*);

        elsif (NEW.user_id % 100 = 74) then
          insert into favorites_74 values (NEW.*);

        elsif (NEW.user_id % 100 = 75) then
          insert into favorites_75 values (NEW.*);

        elsif (NEW.user_id % 100 = 76) then
          insert into favorites_76 values (NEW.*);

        elsif (NEW.user_id % 100 = 77) then
          insert into favorites_77 values (NEW.*);

        elsif (NEW.user_id % 100 = 78) then
          insert into favorites_78 values (NEW.*);

        elsif (NEW.user_id % 100 = 79) then
          insert into favorites_79 values (NEW.*);

        elsif (NEW.user_id % 100 = 80) then
          insert into favorites_80 values (NEW.*);

        elsif (NEW.user_id % 100 = 81) then
          insert into favorites_81 values (NEW.*);

        elsif (NEW.user_id % 100 = 82) then
          insert into favorites_82 values (NEW.*);

        elsif (NEW.user_id % 100 = 83) then
          insert into favorites_83 values (NEW.*);

        elsif (NEW.user_id % 100 = 84) then
          insert into favorites_84 values (NEW.*);

        elsif (NEW.user_id % 100 = 85) then
          insert into favorites_85 values (NEW.*);

        elsif (NEW.user_id % 100 = 86) then
          insert into favorites_86 values (NEW.*);

        elsif (NEW.user_id % 100 = 87) then
          insert into favorites_87 values (NEW.*);

        elsif (NEW.user_id % 100 = 88) then
          insert into favorites_88 values (NEW.*);

        elsif (NEW.user_id % 100 = 89) then
          insert into favorites_89 values (NEW.*);

        elsif (NEW.user_id % 100 = 90) then
          insert into favorites_90 values (NEW.*);

        elsif (NEW.user_id % 100 = 91) then
          insert into favorites_91 values (NEW.*);

        elsif (NEW.user_id % 100 = 92) then
          insert into favorites_92 values (NEW.*);

        elsif (NEW.user_id % 100 = 93) then
          insert into favorites_93 values (NEW.*);

        elsif (NEW.user_id % 100 = 94) then
          insert into favorites_94 values (NEW.*);

        elsif (NEW.user_id % 100 = 95) then
          insert into favorites_95 values (NEW.*);

        elsif (NEW.user_id % 100 = 96) then
          insert into favorites_96 values (NEW.*);

        elsif (NEW.user_id % 100 = 97) then
          insert into favorites_97 values (NEW.*);

        elsif (NEW.user_id % 100 = 98) then
          insert into favorites_98 values (NEW.*);

        elsif (NEW.user_id % 100 = 99) then
          insert into favorites_99 values (NEW.*);

        end if;
        return NULL;
      end;
      $$;


CREATE TABLE favorites (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);

--
-- Name: favorites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_id_seq OWNED BY favorites.id;


--
-- Name: favorites_0; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_0 (CONSTRAINT favorites_0_user_id_check CHECK (((user_id % 100) = 0))
)
INHERITS (favorites);


--
-- Name: favorites_1; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_1 (CONSTRAINT favorites_1_user_id_check CHECK (((user_id % 100) = 1))
)
INHERITS (favorites);


--
-- Name: favorites_10; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_10 (CONSTRAINT favorites_10_user_id_check CHECK (((user_id % 100) = 10))
)
INHERITS (favorites);


--
-- Name: favorites_11; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_11 (CONSTRAINT favorites_11_user_id_check CHECK (((user_id % 100) = 11))
)
INHERITS (favorites);


--
-- Name: favorites_12; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_12 (CONSTRAINT favorites_12_user_id_check CHECK (((user_id % 100) = 12))
)
INHERITS (favorites);


--
-- Name: favorites_13; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_13 (CONSTRAINT favorites_13_user_id_check CHECK (((user_id % 100) = 13))
)
INHERITS (favorites);


--
-- Name: favorites_14; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_14 (CONSTRAINT favorites_14_user_id_check CHECK (((user_id % 100) = 14))
)
INHERITS (favorites);


--
-- Name: favorites_15; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_15 (CONSTRAINT favorites_15_user_id_check CHECK (((user_id % 100) = 15))
)
INHERITS (favorites);


--
-- Name: favorites_16; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_16 (CONSTRAINT favorites_16_user_id_check CHECK (((user_id % 100) = 16))
)
INHERITS (favorites);


--
-- Name: favorites_17; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_17 (CONSTRAINT favorites_17_user_id_check CHECK (((user_id % 100) = 17))
)
INHERITS (favorites);


--
-- Name: favorites_18; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_18 (CONSTRAINT favorites_18_user_id_check CHECK (((user_id % 100) = 18))
)
INHERITS (favorites);


--
-- Name: favorites_19; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_19 (CONSTRAINT favorites_19_user_id_check CHECK (((user_id % 100) = 19))
)
INHERITS (favorites);


--
-- Name: favorites_2; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_2 (CONSTRAINT favorites_2_user_id_check CHECK (((user_id % 100) = 2))
)
INHERITS (favorites);


--
-- Name: favorites_20; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_20 (CONSTRAINT favorites_20_user_id_check CHECK (((user_id % 100) = 20))
)
INHERITS (favorites);


--
-- Name: favorites_21; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_21 (CONSTRAINT favorites_21_user_id_check CHECK (((user_id % 100) = 21))
)
INHERITS (favorites);


--
-- Name: favorites_22; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_22 (CONSTRAINT favorites_22_user_id_check CHECK (((user_id % 100) = 22))
)
INHERITS (favorites);


--
-- Name: favorites_23; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_23 (CONSTRAINT favorites_23_user_id_check CHECK (((user_id % 100) = 23))
)
INHERITS (favorites);


--
-- Name: favorites_24; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_24 (CONSTRAINT favorites_24_user_id_check CHECK (((user_id % 100) = 24))
)
INHERITS (favorites);


--
-- Name: favorites_25; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_25 (CONSTRAINT favorites_25_user_id_check CHECK (((user_id % 100) = 25))
)
INHERITS (favorites);


--
-- Name: favorites_26; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_26 (CONSTRAINT favorites_26_user_id_check CHECK (((user_id % 100) = 26))
)
INHERITS (favorites);


--
-- Name: favorites_27; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_27 (CONSTRAINT favorites_27_user_id_check CHECK (((user_id % 100) = 27))
)
INHERITS (favorites);


--
-- Name: favorites_28; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_28 (CONSTRAINT favorites_28_user_id_check CHECK (((user_id % 100) = 28))
)
INHERITS (favorites);


--
-- Name: favorites_29; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_29 (CONSTRAINT favorites_29_user_id_check CHECK (((user_id % 100) = 29))
)
INHERITS (favorites);


--
-- Name: favorites_3; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_3 (CONSTRAINT favorites_3_user_id_check CHECK (((user_id % 100) = 3))
)
INHERITS (favorites);


--
-- Name: favorites_30; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_30 (CONSTRAINT favorites_30_user_id_check CHECK (((user_id % 100) = 30))
)
INHERITS (favorites);


--
-- Name: favorites_31; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_31 (CONSTRAINT favorites_31_user_id_check CHECK (((user_id % 100) = 31))
)
INHERITS (favorites);


--
-- Name: favorites_32; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_32 (CONSTRAINT favorites_32_user_id_check CHECK (((user_id % 100) = 32))
)
INHERITS (favorites);


--
-- Name: favorites_33; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_33 (CONSTRAINT favorites_33_user_id_check CHECK (((user_id % 100) = 33))
)
INHERITS (favorites);


--
-- Name: favorites_34; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_34 (CONSTRAINT favorites_34_user_id_check CHECK (((user_id % 100) = 34))
)
INHERITS (favorites);


--
-- Name: favorites_35; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_35 (CONSTRAINT favorites_35_user_id_check CHECK (((user_id % 100) = 35))
)
INHERITS (favorites);


--
-- Name: favorites_36; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_36 (CONSTRAINT favorites_36_user_id_check CHECK (((user_id % 100) = 36))
)
INHERITS (favorites);


--
-- Name: favorites_37; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_37 (CONSTRAINT favorites_37_user_id_check CHECK (((user_id % 100) = 37))
)
INHERITS (favorites);


--
-- Name: favorites_38; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_38 (CONSTRAINT favorites_38_user_id_check CHECK (((user_id % 100) = 38))
)
INHERITS (favorites);


--
-- Name: favorites_39; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_39 (CONSTRAINT favorites_39_user_id_check CHECK (((user_id % 100) = 39))
)
INHERITS (favorites);


--
-- Name: favorites_4; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_4 (CONSTRAINT favorites_4_user_id_check CHECK (((user_id % 100) = 4))
)
INHERITS (favorites);


--
-- Name: favorites_40; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_40 (CONSTRAINT favorites_40_user_id_check CHECK (((user_id % 100) = 40))
)
INHERITS (favorites);


--
-- Name: favorites_41; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_41 (CONSTRAINT favorites_41_user_id_check CHECK (((user_id % 100) = 41))
)
INHERITS (favorites);


--
-- Name: favorites_42; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_42 (CONSTRAINT favorites_42_user_id_check CHECK (((user_id % 100) = 42))
)
INHERITS (favorites);


--
-- Name: favorites_43; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_43 (CONSTRAINT favorites_43_user_id_check CHECK (((user_id % 100) = 43))
)
INHERITS (favorites);


--
-- Name: favorites_44; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_44 (CONSTRAINT favorites_44_user_id_check CHECK (((user_id % 100) = 44))
)
INHERITS (favorites);


--
-- Name: favorites_45; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_45 (CONSTRAINT favorites_45_user_id_check CHECK (((user_id % 100) = 45))
)
INHERITS (favorites);


--
-- Name: favorites_46; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_46 (CONSTRAINT favorites_46_user_id_check CHECK (((user_id % 100) = 46))
)
INHERITS (favorites);


--
-- Name: favorites_47; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_47 (CONSTRAINT favorites_47_user_id_check CHECK (((user_id % 100) = 47))
)
INHERITS (favorites);


--
-- Name: favorites_48; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_48 (CONSTRAINT favorites_48_user_id_check CHECK (((user_id % 100) = 48))
)
INHERITS (favorites);


--
-- Name: favorites_49; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_49 (CONSTRAINT favorites_49_user_id_check CHECK (((user_id % 100) = 49))
)
INHERITS (favorites);


--
-- Name: favorites_5; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_5 (CONSTRAINT favorites_5_user_id_check CHECK (((user_id % 100) = 5))
)
INHERITS (favorites);


--
-- Name: favorites_50; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_50 (CONSTRAINT favorites_50_user_id_check CHECK (((user_id % 100) = 50))
)
INHERITS (favorites);


--
-- Name: favorites_51; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_51 (CONSTRAINT favorites_51_user_id_check CHECK (((user_id % 100) = 51))
)
INHERITS (favorites);


--
-- Name: favorites_52; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_52 (CONSTRAINT favorites_52_user_id_check CHECK (((user_id % 100) = 52))
)
INHERITS (favorites);


--
-- Name: favorites_53; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_53 (CONSTRAINT favorites_53_user_id_check CHECK (((user_id % 100) = 53))
)
INHERITS (favorites);


--
-- Name: favorites_54; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_54 (CONSTRAINT favorites_54_user_id_check CHECK (((user_id % 100) = 54))
)
INHERITS (favorites);


--
-- Name: favorites_55; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_55 (CONSTRAINT favorites_55_user_id_check CHECK (((user_id % 100) = 55))
)
INHERITS (favorites);


--
-- Name: favorites_56; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_56 (CONSTRAINT favorites_56_user_id_check CHECK (((user_id % 100) = 56))
)
INHERITS (favorites);


--
-- Name: favorites_57; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_57 (CONSTRAINT favorites_57_user_id_check CHECK (((user_id % 100) = 57))
)
INHERITS (favorites);


--
-- Name: favorites_58; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_58 (CONSTRAINT favorites_58_user_id_check CHECK (((user_id % 100) = 58))
)
INHERITS (favorites);


--
-- Name: favorites_59; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_59 (CONSTRAINT favorites_59_user_id_check CHECK (((user_id % 100) = 59))
)
INHERITS (favorites);


--
-- Name: favorites_6; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_6 (CONSTRAINT favorites_6_user_id_check CHECK (((user_id % 100) = 6))
)
INHERITS (favorites);


--
-- Name: favorites_60; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_60 (CONSTRAINT favorites_60_user_id_check CHECK (((user_id % 100) = 60))
)
INHERITS (favorites);


--
-- Name: favorites_61; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_61 (CONSTRAINT favorites_61_user_id_check CHECK (((user_id % 100) = 61))
)
INHERITS (favorites);


--
-- Name: favorites_62; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_62 (CONSTRAINT favorites_62_user_id_check CHECK (((user_id % 100) = 62))
)
INHERITS (favorites);


--
-- Name: favorites_63; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_63 (CONSTRAINT favorites_63_user_id_check CHECK (((user_id % 100) = 63))
)
INHERITS (favorites);


--
-- Name: favorites_64; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_64 (CONSTRAINT favorites_64_user_id_check CHECK (((user_id % 100) = 64))
)
INHERITS (favorites);


--
-- Name: favorites_65; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_65 (CONSTRAINT favorites_65_user_id_check CHECK (((user_id % 100) = 65))
)
INHERITS (favorites);


--
-- Name: favorites_66; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_66 (CONSTRAINT favorites_66_user_id_check CHECK (((user_id % 100) = 66))
)
INHERITS (favorites);


--
-- Name: favorites_67; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_67 (CONSTRAINT favorites_67_user_id_check CHECK (((user_id % 100) = 67))
)
INHERITS (favorites);


--
-- Name: favorites_68; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_68 (CONSTRAINT favorites_68_user_id_check CHECK (((user_id % 100) = 68))
)
INHERITS (favorites);


--
-- Name: favorites_69; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_69 (CONSTRAINT favorites_69_user_id_check CHECK (((user_id % 100) = 69))
)
INHERITS (favorites);


--
-- Name: favorites_7; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_7 (CONSTRAINT favorites_7_user_id_check CHECK (((user_id % 100) = 7))
)
INHERITS (favorites);


--
-- Name: favorites_70; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_70 (CONSTRAINT favorites_70_user_id_check CHECK (((user_id % 100) = 70))
)
INHERITS (favorites);


--
-- Name: favorites_71; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_71 (CONSTRAINT favorites_71_user_id_check CHECK (((user_id % 100) = 71))
)
INHERITS (favorites);


--
-- Name: favorites_72; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_72 (CONSTRAINT favorites_72_user_id_check CHECK (((user_id % 100) = 72))
)
INHERITS (favorites);


--
-- Name: favorites_73; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_73 (CONSTRAINT favorites_73_user_id_check CHECK (((user_id % 100) = 73))
)
INHERITS (favorites);


--
-- Name: favorites_74; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_74 (CONSTRAINT favorites_74_user_id_check CHECK (((user_id % 100) = 74))
)
INHERITS (favorites);


--
-- Name: favorites_75; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_75 (CONSTRAINT favorites_75_user_id_check CHECK (((user_id % 100) = 75))
)
INHERITS (favorites);


--
-- Name: favorites_76; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_76 (CONSTRAINT favorites_76_user_id_check CHECK (((user_id % 100) = 76))
)
INHERITS (favorites);


--
-- Name: favorites_77; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_77 (CONSTRAINT favorites_77_user_id_check CHECK (((user_id % 100) = 77))
)
INHERITS (favorites);


--
-- Name: favorites_78; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_78 (CONSTRAINT favorites_78_user_id_check CHECK (((user_id % 100) = 78))
)
INHERITS (favorites);


--
-- Name: favorites_79; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_79 (CONSTRAINT favorites_79_user_id_check CHECK (((user_id % 100) = 79))
)
INHERITS (favorites);


--
-- Name: favorites_8; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_8 (CONSTRAINT favorites_8_user_id_check CHECK (((user_id % 100) = 8))
)
INHERITS (favorites);


--
-- Name: favorites_80; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_80 (CONSTRAINT favorites_80_user_id_check CHECK (((user_id % 100) = 80))
)
INHERITS (favorites);


--
-- Name: favorites_81; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_81 (CONSTRAINT favorites_81_user_id_check CHECK (((user_id % 100) = 81))
)
INHERITS (favorites);


--
-- Name: favorites_82; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_82 (CONSTRAINT favorites_82_user_id_check CHECK (((user_id % 100) = 82))
)
INHERITS (favorites);


--
-- Name: favorites_83; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_83 (CONSTRAINT favorites_83_user_id_check CHECK (((user_id % 100) = 83))
)
INHERITS (favorites);


--
-- Name: favorites_84; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_84 (CONSTRAINT favorites_84_user_id_check CHECK (((user_id % 100) = 84))
)
INHERITS (favorites);


--
-- Name: favorites_85; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_85 (CONSTRAINT favorites_85_user_id_check CHECK (((user_id % 100) = 85))
)
INHERITS (favorites);


--
-- Name: favorites_86; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_86 (CONSTRAINT favorites_86_user_id_check CHECK (((user_id % 100) = 86))
)
INHERITS (favorites);


--
-- Name: favorites_87; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_87 (CONSTRAINT favorites_87_user_id_check CHECK (((user_id % 100) = 87))
)
INHERITS (favorites);


--
-- Name: favorites_88; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_88 (CONSTRAINT favorites_88_user_id_check CHECK (((user_id % 100) = 88))
)
INHERITS (favorites);


--
-- Name: favorites_89; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_89 (CONSTRAINT favorites_89_user_id_check CHECK (((user_id % 100) = 89))
)
INHERITS (favorites);


--
-- Name: favorites_9; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_9 (CONSTRAINT favorites_9_user_id_check CHECK (((user_id % 100) = 9))
)
INHERITS (favorites);


--
-- Name: favorites_90; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_90 (CONSTRAINT favorites_90_user_id_check CHECK (((user_id % 100) = 90))
)
INHERITS (favorites);


--
-- Name: favorites_91; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_91 (CONSTRAINT favorites_91_user_id_check CHECK (((user_id % 100) = 91))
)
INHERITS (favorites);


--
-- Name: favorites_92; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_92 (CONSTRAINT favorites_92_user_id_check CHECK (((user_id % 100) = 92))
)
INHERITS (favorites);


--
-- Name: favorites_93; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_93 (CONSTRAINT favorites_93_user_id_check CHECK (((user_id % 100) = 93))
)
INHERITS (favorites);


--
-- Name: favorites_94; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_94 (CONSTRAINT favorites_94_user_id_check CHECK (((user_id % 100) = 94))
)
INHERITS (favorites);


--
-- Name: favorites_95; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_95 (CONSTRAINT favorites_95_user_id_check CHECK (((user_id % 100) = 95))
)
INHERITS (favorites);


--
-- Name: favorites_96; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_96 (CONSTRAINT favorites_96_user_id_check CHECK (((user_id % 100) = 96))
)
INHERITS (favorites);


--
-- Name: favorites_97; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_97 (CONSTRAINT favorites_97_user_id_check CHECK (((user_id % 100) = 97))
)
INHERITS (favorites);


--
-- Name: favorites_98; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_98 (CONSTRAINT favorites_98_user_id_check CHECK (((user_id % 100) = 98))
)
INHERITS (favorites);


--
-- Name: favorites_99; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_99 (CONSTRAINT favorites_99_user_id_check CHECK (((user_id % 100) = 99))
)
INHERITS (favorites);

ALTER TABLE favorites ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);

ALTER TABLE ONLY favorites
    ADD CONSTRAINT favorites_pkey PRIMARY KEY (id);

CREATE INDEX index_favorites_0_on_post_id ON favorites_0 USING btree (post_id);


--
-- Name: index_favorites_0_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_0_on_user_id ON favorites_0 USING btree (user_id);


--
-- Name: index_favorites_10_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_10_on_post_id ON favorites_10 USING btree (post_id);


--
-- Name: index_favorites_10_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_10_on_user_id ON favorites_10 USING btree (user_id);


--
-- Name: index_favorites_11_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_11_on_post_id ON favorites_11 USING btree (post_id);


--
-- Name: index_favorites_11_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_11_on_user_id ON favorites_11 USING btree (user_id);


--
-- Name: index_favorites_12_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_12_on_post_id ON favorites_12 USING btree (post_id);


--
-- Name: index_favorites_12_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_12_on_user_id ON favorites_12 USING btree (user_id);


--
-- Name: index_favorites_13_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_13_on_post_id ON favorites_13 USING btree (post_id);


--
-- Name: index_favorites_13_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_13_on_user_id ON favorites_13 USING btree (user_id);


--
-- Name: index_favorites_14_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_14_on_post_id ON favorites_14 USING btree (post_id);


--
-- Name: index_favorites_14_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_14_on_user_id ON favorites_14 USING btree (user_id);


--
-- Name: index_favorites_15_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_15_on_post_id ON favorites_15 USING btree (post_id);


--
-- Name: index_favorites_15_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_15_on_user_id ON favorites_15 USING btree (user_id);


--
-- Name: index_favorites_16_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_16_on_post_id ON favorites_16 USING btree (post_id);


--
-- Name: index_favorites_16_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_16_on_user_id ON favorites_16 USING btree (user_id);


--
-- Name: index_favorites_17_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_17_on_post_id ON favorites_17 USING btree (post_id);


--
-- Name: index_favorites_17_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_17_on_user_id ON favorites_17 USING btree (user_id);


--
-- Name: index_favorites_18_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_18_on_post_id ON favorites_18 USING btree (post_id);


--
-- Name: index_favorites_18_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_18_on_user_id ON favorites_18 USING btree (user_id);


--
-- Name: index_favorites_19_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_19_on_post_id ON favorites_19 USING btree (post_id);


--
-- Name: index_favorites_19_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_19_on_user_id ON favorites_19 USING btree (user_id);


--
-- Name: index_favorites_1_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_1_on_post_id ON favorites_1 USING btree (post_id);


--
-- Name: index_favorites_1_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_1_on_user_id ON favorites_1 USING btree (user_id);


--
-- Name: index_favorites_20_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_20_on_post_id ON favorites_20 USING btree (post_id);


--
-- Name: index_favorites_20_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_20_on_user_id ON favorites_20 USING btree (user_id);


--
-- Name: index_favorites_21_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_21_on_post_id ON favorites_21 USING btree (post_id);


--
-- Name: index_favorites_21_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_21_on_user_id ON favorites_21 USING btree (user_id);


--
-- Name: index_favorites_22_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_22_on_post_id ON favorites_22 USING btree (post_id);


--
-- Name: index_favorites_22_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_22_on_user_id ON favorites_22 USING btree (user_id);


--
-- Name: index_favorites_23_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_23_on_post_id ON favorites_23 USING btree (post_id);


--
-- Name: index_favorites_23_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_23_on_user_id ON favorites_23 USING btree (user_id);


--
-- Name: index_favorites_24_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_24_on_post_id ON favorites_24 USING btree (post_id);


--
-- Name: index_favorites_24_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_24_on_user_id ON favorites_24 USING btree (user_id);


--
-- Name: index_favorites_25_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_25_on_post_id ON favorites_25 USING btree (post_id);


--
-- Name: index_favorites_25_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_25_on_user_id ON favorites_25 USING btree (user_id);


--
-- Name: index_favorites_26_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_26_on_post_id ON favorites_26 USING btree (post_id);


--
-- Name: index_favorites_26_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_26_on_user_id ON favorites_26 USING btree (user_id);


--
-- Name: index_favorites_27_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_27_on_post_id ON favorites_27 USING btree (post_id);


--
-- Name: index_favorites_27_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_27_on_user_id ON favorites_27 USING btree (user_id);


--
-- Name: index_favorites_28_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_28_on_post_id ON favorites_28 USING btree (post_id);


--
-- Name: index_favorites_28_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_28_on_user_id ON favorites_28 USING btree (user_id);


--
-- Name: index_favorites_29_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_29_on_post_id ON favorites_29 USING btree (post_id);


--
-- Name: index_favorites_29_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_29_on_user_id ON favorites_29 USING btree (user_id);


--
-- Name: index_favorites_2_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_2_on_post_id ON favorites_2 USING btree (post_id);


--
-- Name: index_favorites_2_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_2_on_user_id ON favorites_2 USING btree (user_id);


--
-- Name: index_favorites_30_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_30_on_post_id ON favorites_30 USING btree (post_id);


--
-- Name: index_favorites_30_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_30_on_user_id ON favorites_30 USING btree (user_id);


--
-- Name: index_favorites_31_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_31_on_post_id ON favorites_31 USING btree (post_id);


--
-- Name: index_favorites_31_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_31_on_user_id ON favorites_31 USING btree (user_id);


--
-- Name: index_favorites_32_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_32_on_post_id ON favorites_32 USING btree (post_id);


--
-- Name: index_favorites_32_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_32_on_user_id ON favorites_32 USING btree (user_id);


--
-- Name: index_favorites_33_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_33_on_post_id ON favorites_33 USING btree (post_id);


--
-- Name: index_favorites_33_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_33_on_user_id ON favorites_33 USING btree (user_id);


--
-- Name: index_favorites_34_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_34_on_post_id ON favorites_34 USING btree (post_id);


--
-- Name: index_favorites_34_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_34_on_user_id ON favorites_34 USING btree (user_id);


--
-- Name: index_favorites_35_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_35_on_post_id ON favorites_35 USING btree (post_id);


--
-- Name: index_favorites_35_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_35_on_user_id ON favorites_35 USING btree (user_id);


--
-- Name: index_favorites_36_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_36_on_post_id ON favorites_36 USING btree (post_id);


--
-- Name: index_favorites_36_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_36_on_user_id ON favorites_36 USING btree (user_id);


--
-- Name: index_favorites_37_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_37_on_post_id ON favorites_37 USING btree (post_id);


--
-- Name: index_favorites_37_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_37_on_user_id ON favorites_37 USING btree (user_id);


--
-- Name: index_favorites_38_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_38_on_post_id ON favorites_38 USING btree (post_id);


--
-- Name: index_favorites_38_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_38_on_user_id ON favorites_38 USING btree (user_id);


--
-- Name: index_favorites_39_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_39_on_post_id ON favorites_39 USING btree (post_id);


--
-- Name: index_favorites_39_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_39_on_user_id ON favorites_39 USING btree (user_id);


--
-- Name: index_favorites_3_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_3_on_post_id ON favorites_3 USING btree (post_id);


--
-- Name: index_favorites_3_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_3_on_user_id ON favorites_3 USING btree (user_id);


--
-- Name: index_favorites_40_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_40_on_post_id ON favorites_40 USING btree (post_id);


--
-- Name: index_favorites_40_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_40_on_user_id ON favorites_40 USING btree (user_id);


--
-- Name: index_favorites_41_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_41_on_post_id ON favorites_41 USING btree (post_id);


--
-- Name: index_favorites_41_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_41_on_user_id ON favorites_41 USING btree (user_id);


--
-- Name: index_favorites_42_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_42_on_post_id ON favorites_42 USING btree (post_id);


--
-- Name: index_favorites_42_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_42_on_user_id ON favorites_42 USING btree (user_id);


--
-- Name: index_favorites_43_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_43_on_post_id ON favorites_43 USING btree (post_id);


--
-- Name: index_favorites_43_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_43_on_user_id ON favorites_43 USING btree (user_id);


--
-- Name: index_favorites_44_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_44_on_post_id ON favorites_44 USING btree (post_id);


--
-- Name: index_favorites_44_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_44_on_user_id ON favorites_44 USING btree (user_id);


--
-- Name: index_favorites_45_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_45_on_post_id ON favorites_45 USING btree (post_id);


--
-- Name: index_favorites_45_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_45_on_user_id ON favorites_45 USING btree (user_id);


--
-- Name: index_favorites_46_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_46_on_post_id ON favorites_46 USING btree (post_id);


--
-- Name: index_favorites_46_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_46_on_user_id ON favorites_46 USING btree (user_id);


--
-- Name: index_favorites_47_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_47_on_post_id ON favorites_47 USING btree (post_id);


--
-- Name: index_favorites_47_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_47_on_user_id ON favorites_47 USING btree (user_id);


--
-- Name: index_favorites_48_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_48_on_post_id ON favorites_48 USING btree (post_id);


--
-- Name: index_favorites_48_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_48_on_user_id ON favorites_48 USING btree (user_id);


--
-- Name: index_favorites_49_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_49_on_post_id ON favorites_49 USING btree (post_id);


--
-- Name: index_favorites_49_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_49_on_user_id ON favorites_49 USING btree (user_id);


--
-- Name: index_favorites_4_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_4_on_post_id ON favorites_4 USING btree (post_id);


--
-- Name: index_favorites_4_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_4_on_user_id ON favorites_4 USING btree (user_id);


--
-- Name: index_favorites_50_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_50_on_post_id ON favorites_50 USING btree (post_id);


--
-- Name: index_favorites_50_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_50_on_user_id ON favorites_50 USING btree (user_id);


--
-- Name: index_favorites_51_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_51_on_post_id ON favorites_51 USING btree (post_id);


--
-- Name: index_favorites_51_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_51_on_user_id ON favorites_51 USING btree (user_id);


--
-- Name: index_favorites_52_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_52_on_post_id ON favorites_52 USING btree (post_id);


--
-- Name: index_favorites_52_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_52_on_user_id ON favorites_52 USING btree (user_id);


--
-- Name: index_favorites_53_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_53_on_post_id ON favorites_53 USING btree (post_id);


--
-- Name: index_favorites_53_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_53_on_user_id ON favorites_53 USING btree (user_id);


--
-- Name: index_favorites_54_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_54_on_post_id ON favorites_54 USING btree (post_id);


--
-- Name: index_favorites_54_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_54_on_user_id ON favorites_54 USING btree (user_id);


--
-- Name: index_favorites_55_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_55_on_post_id ON favorites_55 USING btree (post_id);


--
-- Name: index_favorites_55_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_55_on_user_id ON favorites_55 USING btree (user_id);


--
-- Name: index_favorites_56_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_56_on_post_id ON favorites_56 USING btree (post_id);


--
-- Name: index_favorites_56_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_56_on_user_id ON favorites_56 USING btree (user_id);


--
-- Name: index_favorites_57_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_57_on_post_id ON favorites_57 USING btree (post_id);


--
-- Name: index_favorites_57_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_57_on_user_id ON favorites_57 USING btree (user_id);


--
-- Name: index_favorites_58_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_58_on_post_id ON favorites_58 USING btree (post_id);


--
-- Name: index_favorites_58_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_58_on_user_id ON favorites_58 USING btree (user_id);


--
-- Name: index_favorites_59_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_59_on_post_id ON favorites_59 USING btree (post_id);


--
-- Name: index_favorites_59_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_59_on_user_id ON favorites_59 USING btree (user_id);


--
-- Name: index_favorites_5_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_5_on_post_id ON favorites_5 USING btree (post_id);


--
-- Name: index_favorites_5_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_5_on_user_id ON favorites_5 USING btree (user_id);


--
-- Name: index_favorites_60_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_60_on_post_id ON favorites_60 USING btree (post_id);


--
-- Name: index_favorites_60_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_60_on_user_id ON favorites_60 USING btree (user_id);


--
-- Name: index_favorites_61_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_61_on_post_id ON favorites_61 USING btree (post_id);


--
-- Name: index_favorites_61_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_61_on_user_id ON favorites_61 USING btree (user_id);


--
-- Name: index_favorites_62_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_62_on_post_id ON favorites_62 USING btree (post_id);


--
-- Name: index_favorites_62_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_62_on_user_id ON favorites_62 USING btree (user_id);


--
-- Name: index_favorites_63_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_63_on_post_id ON favorites_63 USING btree (post_id);


--
-- Name: index_favorites_63_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_63_on_user_id ON favorites_63 USING btree (user_id);


--
-- Name: index_favorites_64_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_64_on_post_id ON favorites_64 USING btree (post_id);


--
-- Name: index_favorites_64_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_64_on_user_id ON favorites_64 USING btree (user_id);


--
-- Name: index_favorites_65_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_65_on_post_id ON favorites_65 USING btree (post_id);


--
-- Name: index_favorites_65_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_65_on_user_id ON favorites_65 USING btree (user_id);


--
-- Name: index_favorites_66_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_66_on_post_id ON favorites_66 USING btree (post_id);


--
-- Name: index_favorites_66_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_66_on_user_id ON favorites_66 USING btree (user_id);


--
-- Name: index_favorites_67_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_67_on_post_id ON favorites_67 USING btree (post_id);


--
-- Name: index_favorites_67_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_67_on_user_id ON favorites_67 USING btree (user_id);


--
-- Name: index_favorites_68_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_68_on_post_id ON favorites_68 USING btree (post_id);


--
-- Name: index_favorites_68_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_68_on_user_id ON favorites_68 USING btree (user_id);


--
-- Name: index_favorites_69_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_69_on_post_id ON favorites_69 USING btree (post_id);


--
-- Name: index_favorites_69_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_69_on_user_id ON favorites_69 USING btree (user_id);


--
-- Name: index_favorites_6_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_6_on_post_id ON favorites_6 USING btree (post_id);


--
-- Name: index_favorites_6_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_6_on_user_id ON favorites_6 USING btree (user_id);


--
-- Name: index_favorites_70_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_70_on_post_id ON favorites_70 USING btree (post_id);


--
-- Name: index_favorites_70_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_70_on_user_id ON favorites_70 USING btree (user_id);


--
-- Name: index_favorites_71_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_71_on_post_id ON favorites_71 USING btree (post_id);


--
-- Name: index_favorites_71_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_71_on_user_id ON favorites_71 USING btree (user_id);


--
-- Name: index_favorites_72_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_72_on_post_id ON favorites_72 USING btree (post_id);


--
-- Name: index_favorites_72_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_72_on_user_id ON favorites_72 USING btree (user_id);


--
-- Name: index_favorites_73_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_73_on_post_id ON favorites_73 USING btree (post_id);


--
-- Name: index_favorites_73_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_73_on_user_id ON favorites_73 USING btree (user_id);


--
-- Name: index_favorites_74_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_74_on_post_id ON favorites_74 USING btree (post_id);


--
-- Name: index_favorites_74_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_74_on_user_id ON favorites_74 USING btree (user_id);


--
-- Name: index_favorites_75_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_75_on_post_id ON favorites_75 USING btree (post_id);


--
-- Name: index_favorites_75_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_75_on_user_id ON favorites_75 USING btree (user_id);


--
-- Name: index_favorites_76_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_76_on_post_id ON favorites_76 USING btree (post_id);


--
-- Name: index_favorites_76_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_76_on_user_id ON favorites_76 USING btree (user_id);


--
-- Name: index_favorites_77_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_77_on_post_id ON favorites_77 USING btree (post_id);


--
-- Name: index_favorites_77_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_77_on_user_id ON favorites_77 USING btree (user_id);


--
-- Name: index_favorites_78_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_78_on_post_id ON favorites_78 USING btree (post_id);


--
-- Name: index_favorites_78_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_78_on_user_id ON favorites_78 USING btree (user_id);


--
-- Name: index_favorites_79_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_79_on_post_id ON favorites_79 USING btree (post_id);


--
-- Name: index_favorites_79_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_79_on_user_id ON favorites_79 USING btree (user_id);


--
-- Name: index_favorites_7_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_7_on_post_id ON favorites_7 USING btree (post_id);


--
-- Name: index_favorites_7_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_7_on_user_id ON favorites_7 USING btree (user_id);


--
-- Name: index_favorites_80_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_80_on_post_id ON favorites_80 USING btree (post_id);


--
-- Name: index_favorites_80_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_80_on_user_id ON favorites_80 USING btree (user_id);


--
-- Name: index_favorites_81_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_81_on_post_id ON favorites_81 USING btree (post_id);


--
-- Name: index_favorites_81_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_81_on_user_id ON favorites_81 USING btree (user_id);


--
-- Name: index_favorites_82_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_82_on_post_id ON favorites_82 USING btree (post_id);


--
-- Name: index_favorites_82_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_82_on_user_id ON favorites_82 USING btree (user_id);


--
-- Name: index_favorites_83_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_83_on_post_id ON favorites_83 USING btree (post_id);


--
-- Name: index_favorites_83_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_83_on_user_id ON favorites_83 USING btree (user_id);


--
-- Name: index_favorites_84_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_84_on_post_id ON favorites_84 USING btree (post_id);


--
-- Name: index_favorites_84_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_84_on_user_id ON favorites_84 USING btree (user_id);


--
-- Name: index_favorites_85_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_85_on_post_id ON favorites_85 USING btree (post_id);


--
-- Name: index_favorites_85_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_85_on_user_id ON favorites_85 USING btree (user_id);


--
-- Name: index_favorites_86_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_86_on_post_id ON favorites_86 USING btree (post_id);


--
-- Name: index_favorites_86_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_86_on_user_id ON favorites_86 USING btree (user_id);


--
-- Name: index_favorites_87_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_87_on_post_id ON favorites_87 USING btree (post_id);


--
-- Name: index_favorites_87_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_87_on_user_id ON favorites_87 USING btree (user_id);


--
-- Name: index_favorites_88_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_88_on_post_id ON favorites_88 USING btree (post_id);


--
-- Name: index_favorites_88_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_88_on_user_id ON favorites_88 USING btree (user_id);


--
-- Name: index_favorites_89_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_89_on_post_id ON favorites_89 USING btree (post_id);


--
-- Name: index_favorites_89_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_89_on_user_id ON favorites_89 USING btree (user_id);


--
-- Name: index_favorites_8_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_8_on_post_id ON favorites_8 USING btree (post_id);


--
-- Name: index_favorites_8_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_8_on_user_id ON favorites_8 USING btree (user_id);


--
-- Name: index_favorites_90_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_90_on_post_id ON favorites_90 USING btree (post_id);


--
-- Name: index_favorites_90_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_90_on_user_id ON favorites_90 USING btree (user_id);


--
-- Name: index_favorites_91_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_91_on_post_id ON favorites_91 USING btree (post_id);


--
-- Name: index_favorites_91_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_91_on_user_id ON favorites_91 USING btree (user_id);


--
-- Name: index_favorites_92_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_92_on_post_id ON favorites_92 USING btree (post_id);


--
-- Name: index_favorites_92_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_92_on_user_id ON favorites_92 USING btree (user_id);


--
-- Name: index_favorites_93_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_93_on_post_id ON favorites_93 USING btree (post_id);


--
-- Name: index_favorites_93_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_93_on_user_id ON favorites_93 USING btree (user_id);


--
-- Name: index_favorites_94_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_94_on_post_id ON favorites_94 USING btree (post_id);


--
-- Name: index_favorites_94_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_94_on_user_id ON favorites_94 USING btree (user_id);


--
-- Name: index_favorites_95_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_95_on_post_id ON favorites_95 USING btree (post_id);


--
-- Name: index_favorites_95_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_95_on_user_id ON favorites_95 USING btree (user_id);


--
-- Name: index_favorites_96_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_96_on_post_id ON favorites_96 USING btree (post_id);


--
-- Name: index_favorites_96_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_96_on_user_id ON favorites_96 USING btree (user_id);


--
-- Name: index_favorites_97_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_97_on_post_id ON favorites_97 USING btree (post_id);


--
-- Name: index_favorites_97_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_97_on_user_id ON favorites_97 USING btree (user_id);


--
-- Name: index_favorites_98_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_98_on_post_id ON favorites_98 USING btree (post_id);


--
-- Name: index_favorites_98_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_98_on_user_id ON favorites_98 USING btree (user_id);


--
-- Name: index_favorites_99_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_99_on_post_id ON favorites_99 USING btree (post_id);


--
-- Name: index_favorites_99_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_99_on_user_id ON favorites_99 USING btree (user_id);


--
-- Name: index_favorites_9_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_9_on_post_id ON favorites_9 USING btree (post_id);


--
-- Name: index_favorites_9_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_9_on_user_id ON favorites_9 USING btree (user_id);

insert into favorites_0 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 0;
insert into favorites_1 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 1;
insert into favorites_2 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 2;
insert into favorites_3 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 3;
insert into favorites_4 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 4;
insert into favorites_5 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 5;
insert into favorites_6 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 6;
insert into favorites_7 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 7;
insert into favorites_8 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 8;
insert into favorites_9 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 9;
insert into favorites_10 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 10;
insert into favorites_11 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 11;
insert into favorites_12 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 12;
insert into favorites_13 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 13;
insert into favorites_14 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 14;
insert into favorites_15 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 15;
insert into favorites_16 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 16;
insert into favorites_17 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 17;
insert into favorites_18 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 18;
insert into favorites_19 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 19;
insert into favorites_20 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 20;
insert into favorites_21 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 21;
insert into favorites_22 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 22;
insert into favorites_23 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 23;
insert into favorites_24 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 24;
insert into favorites_25 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 25;
insert into favorites_26 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 26;
insert into favorites_27 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 27;
insert into favorites_28 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 28;
insert into favorites_29 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 29;
insert into favorites_30 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 30;
insert into favorites_31 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 31;
insert into favorites_32 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 32;
insert into favorites_33 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 33;
insert into favorites_34 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 34;
insert into favorites_35 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 35;
insert into favorites_36 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 36;
insert into favorites_37 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 37;
insert into favorites_38 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 38;
insert into favorites_39 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 39;
insert into favorites_40 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 40;
insert into favorites_41 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 41;
insert into favorites_42 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 42;
insert into favorites_43 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 43;
insert into favorites_44 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 44;
insert into favorites_45 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 45;
insert into favorites_46 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 46;
insert into favorites_47 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 47;
insert into favorites_48 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 48;
insert into favorites_49 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 49;
insert into favorites_50 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 50;
insert into favorites_51 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 51;
insert into favorites_52 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 52;
insert into favorites_53 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 53;
insert into favorites_54 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 54;
insert into favorites_55 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 55;
insert into favorites_56 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 56;
insert into favorites_57 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 57;
insert into favorites_58 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 58;
insert into favorites_59 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 59;
insert into favorites_60 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 60;
insert into favorites_61 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 61;
insert into favorites_62 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 62;
insert into favorites_63 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 63;
insert into favorites_64 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 64;
insert into favorites_65 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 65;
insert into favorites_66 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 66;
insert into favorites_67 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 67;
insert into favorites_68 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 68;
insert into favorites_69 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 69;
insert into favorites_70 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 70;
insert into favorites_71 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 71;
insert into favorites_72 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 72;
insert into favorites_73 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 73;
insert into favorites_74 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 74;
insert into favorites_75 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 75;
insert into favorites_76 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 76;
insert into favorites_77 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 77;
insert into favorites_78 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 78;
insert into favorites_79 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 79;
insert into favorites_80 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 80;
insert into favorites_81 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 81;
insert into favorites_82 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 82;
insert into favorites_83 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 83;
insert into favorites_84 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 84;
insert into favorites_85 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 85;
insert into favorites_86 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 86;
insert into favorites_87 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 87;
insert into favorites_88 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 88;
insert into favorites_89 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 89;
insert into favorites_90 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 90;
insert into favorites_91 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 91;
insert into favorites_92 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 92;
insert into favorites_93 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 93;
insert into favorites_94 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 94;
insert into favorites_95 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 95;
insert into favorites_96 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 96;
insert into favorites_97 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 97;
insert into favorites_98 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 98;
insert into favorites_99 (id, user_id, post_id) select _.id, _.user_id, _.post_id from favorites_orig _ where _.user_id % 100 = 99;
drop table favorites_orig;

CREATE TRIGGER insert_favorites_trigger
    BEFORE INSERT ON favorites
    FOR EACH ROW
    EXECUTE PROCEDURE favorites_insert_trigger();

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
update forum_posts set creator_id = 1 where creator_id is null;
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
alter table forum_posts rename column last_updated_by to updater_id;
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
update pools set post_ids = (select coalesce(string_agg(x.post_id, ' '), '') from (select _.post_id::text from pools_posts _ where _.pool_id = pools.id order by _.sequence) x);

alter table post_tag_histories rename to post_versions;
alter table post_versions drop constraint fk_post_tag_histories__post;
alter table post_versions drop constraint post_tag_histories_user_id_fkey;
alter table post_versions rename column created_at to updated_at;
alter table post_versions rename column user_id to updater_id;
alter table post_versions rename column ip_addr to updater_ip_addr;
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
alter table posts add column tag_count integer not null default 0;
update posts set tag_count = tag_count_general + tag_count_artist + tag_count_character + tag_count_copyright;
alter table posts add column updated_at timestamp without time zone;
update posts set updated_at = created_at;
alter table posts alter column source drop not null;
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
drop function trg_posts_tags__delete();
drop function trg_posts_tags__insert();

alter table post_appeals rename column user_id to creator_id;
alter index index_post_appeals_on_user_id rename to index_post_appeals_on_creator_id;
alter table post_appeals rename column ip_addr to creator_ip_addr;
alter index index_post_appeals_on_ip_addr rename to index_post_appeals_on_creator_ip_addr;

create index index_post_flags_on_creator_id on post_flags (creator_id);
create index index_post_flags_on_creator_ip_addr on post_flags (creator_ip_addr);

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
alter table tag_aliases add column created_at timestamp without time zone default now();
alter table tag_aliases add column updated_at timestamp without time zone default now();

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
update tag_implications set consequent_name = (select _.name from tags _ where _.id = tag_implications.consequent_id);
alter table tag_implications drop column consequent_id;
alter table tag_implications drop column predicate_id;
alter table tag_implications add column forum_topic_id integer;
alter table tag_implications add column created_at timestamp without time zone default now();
alter table tag_implications add column updated_at timestamp without time zone default now();

alter table tag_subscriptions drop constraint tag_subscriptions_user_id_fkey;
alter table tag_subscriptions rename column user_id to creator_id;
alter table tag_subscriptions rename column cached_post_ids to post_ids;
alter table tag_subscriptions rename column is_visible_on_profile to is_public;
alter table tag_subscriptions add column created_at timestamp without time zone;
alter table tag_subscriptions add column updated_at timestamp without time zone;
alter table tag_subscriptions add column last_accessed_at timestamp without time zone;
alter index index_tag_subscriptions_on_user_id rename to index_tag_subscriptions_on_creator_id;
alter table tag_subscriptions add column is_opted_in boolean not null default false;

alter table tags rename column tag_type to category;
alter table tags drop column is_ambiguous;
alter table tags rename column cached_related to related_tags;
alter table tags rename column cached_related_expires_on to related_tags_updated_at;
alter table tags add column created_at timestamp without time zone;
alter table tags add column updated_at timestamp without time zone;
alter index idx_tags__name rename to index_tags_on_name;
alter index idx_tags__post_count rename to index_tags_on_post_count;
alter table tags alter column related_tags drop not null;
alter table tags alter column related_tags_updated_at drop not null;

alter table test_janitors rename to janitor_trials;
alter table janitor_trials drop column id;
alter table janitor_trials add column id serial primary key;
alter table janitor_trials drop column promotion_date;
alter table janitor_trials drop column test_promotion_date;
alter table janitor_trials drop constraint test_janitors_user_id_fkey;
alter table janitor_trials add column creator_id integer not null default 1;
alter index index_test_janitors_on_user_id rename to index_janitor_trials_on_creator_id;

alter table user_records rename to user_feedback;
alter table user_feedback drop constraint user_records_reported_by_fkey;
alter table user_feedback drop constraint user_records_user_id_fkey;
alter table user_feedback rename column reported_by to creator_id;
alter table user_feedback add column category varchar(255) not null default '';
update user_feedback set category = 'negative' where score = -1;
update user_feedback set category = 'positive' where score = 1;
update user_feedback set category = 'neutral' where score = 0 or score is null;
alter table user_feedback drop column score;
create index index_user_feedback_on_user_id on user_feedback (user_id);
alter table user_feedback drop column id;
alter table user_feedback add column id serial primary key;

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
alter table users add column post_update_count integer not null default 0;
alter table users add column note_update_count integer not null default 0;
alter table users add column favorite_count integer not null default 0;
alter table users add column post_upload_count integer not null default 0;
alter table users drop column invite_count;
alter table users alter column last_logged_in_at drop not null;
alter table users alter column last_forum_read_at drop not null;
alter table users rename column upload_limit to base_upload_limit;
alter table users drop column uploaded_tags;
alter index idx_users__name rename to index_users_on_name;
create index index_users_on_email on users (email) where email is not null;
create index index_users_on_inviter_id on users (inviter_id) where inviter_id is not null;
update users set post_upload_count = (select count(*) from posts where uploader_id = users.id);
update users set blacklisted_tags = (select string_agg(_.tags, E'\n') from user_blacklisted_tags _ where _.user_id = users.id);
update users set post_update_count = (select count(*) from post_versions where updater_id = users.id);
update users set note_update_count = (select count(*) from note_versions where updater_id = users.id);
update users set favorite_count = (select count(*) from favorites where user_id = users.id);
drop table user_blacklisted_tags;

CREATE TABLE user_password_reset_nonces (
    id integer NOT NULL,
    key character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
ALTER TABLE public.user_password_reset_nonces OWNER TO ayi;
CREATE SEQUENCE user_password_reset_nonces_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE public.user_password_reset_nonces_id_seq OWNER TO ayi;
ALTER SEQUENCE user_password_reset_nonces_id_seq OWNED BY user_password_reset_nonces.id;
ALTER TABLE user_password_reset_nonces ALTER COLUMN id SET DEFAULT nextval('user_password_reset_nonces_id_seq'::regclass);
ALTER TABLE ONLY user_password_reset_nonces
    ADD CONSTRAINT user_password_reset_nonces_pkey PRIMARY KEY (id);

alter table user_feedback add column updated_at timestamp without time zone default now();

alter table wiki_page_versions drop constraint fk_wiki_page_versions__user;
alter table wiki_page_versions drop constraint fk_wiki_page_versions__wiki_page;
alter table wiki_page_versions rename column user_id to updater_id;
alter table wiki_page_versions rename column ip_addr to updater_ip_addr;
alter table wiki_page_versions drop column version;
alter table wiki_page_versions drop column text_search_index;
alter index idx_wiki_page_versions__wiki_page rename to index_wiki_page_versions_on_wiki_page_id;
alter index index_wiki_page_versions_on_user_id rename to index_wiki_page_versions_on_updater_id;

alter table wiki_pages drop constraint fk_wiki_pages__user;
drop trigger trg_wiki_page_search_update on wiki_pages;
alter table wiki_pages drop column version;
alter table wiki_pages drop column ip_addr;
alter table wiki_pages rename column text_search_index to body_index;
alter table wiki_pages rename column user_id to creator_id;
alter index idx_wiki_pages__title rename to index_wiki_pages_on_title;
alter index idx_wiki_pages__updated_at rename to index_wiki_pages_on_updated_at;
alter index wiki_pages_search_idx rename to index_wiki_pages_on_body_index;
CREATE TRIGGER trigger_wiki_pages_on_update BEFORE INSERT OR UPDATE ON wiki_pages FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('body_index', 'public.danbooru', 'body', 'title');

CREATE TABLE amazon_backups (
    id integer NOT NULL,
    last_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
CREATE SEQUENCE amazon_backups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE amazon_backups_id_seq OWNED BY amazon_backups.id;
ALTER TABLE amazon_backups ALTER COLUMN id SET DEFAULT nextval('amazon_backups_id_seq'::regclass);
ALTER TABLE ONLY amazon_backups
    ADD CONSTRAINT amazon_backups_pkey PRIMARY KEY (id);


CREATE TABLE uploads (
    id integer NOT NULL,
    source character varying(255),
    file_path character varying(255),
    content_type character varying(255),
    rating character(1) NOT NULL,
    uploader_id integer NOT NULL,
    uploader_ip_addr inet NOT NULL,
    tag_string text NOT NULL,
    status text DEFAULT 'pending' NOT NULL,
    backtrace text,
    post_id integer,
    md5_confirmation character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
CREATE SEQUENCE uploads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE uploads_id_seq OWNED BY uploads.id;
ALTER TABLE uploads ALTER COLUMN id SET DEFAULT nextval('uploads_id_seq'::regclass);
ALTER TABLE ONLY uploads
    ADD CONSTRAINT uploads_pkey PRIMARY KEY (id);
CREATE INDEX index_uploads_on_uploader_id ON uploads USING btree (uploader_id);
CREATE INDEX index_uploads_on_uploader_ip_addr ON uploads USING btree (uploader_ip_addr);

CREATE TABLE news_updates (
    id integer NOT NULL,
    message text NOT NULL,
    creator_id integer NOT NULL,
    updater_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
CREATE SEQUENCE news_updates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE news_updates_id_seq OWNED BY news_updates.id;
ALTER TABLE news_updates ALTER COLUMN id SET DEFAULT nextval('news_updates_id_seq'::regclass);
ALTER TABLE ONLY news_updates
    ADD CONSTRAINT news_updates_pkey PRIMARY KEY (id);
CREATE INDEX index_news_updates_on_created_at ON news_updates USING btree (created_at);


delete from schema_migrations;
COPY schema_migrations (version) FROM stdin;
20100204211522
20100204214746
20100205162521
20100205163027
20100205224030
20100211025616
20100211181944
20100211191709
20100211191716
20100213181847
20100213183712
20100214080549
20100214080557
20100214080605
20100215182234
20100215213756
20100215223541
20100215224629
20100215224635
20100215225710
20100215230642
20100219230537
20100221003655
20100221005812
20100223001012
20100224171915
20100224172146
20100307073438
20100309211553
20100318213503
20100826232512
20110328215652
20110328215701
20110607194023
20110717010705
20110722211855
20110815233456
20111101212358
\.

-- post processing
drop table pools_posts;
drop function pools_posts_delete_trg();
drop function pools_posts_insert_trg();
alter table users drop column show_samples;