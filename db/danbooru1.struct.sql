--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: albert
--

CREATE PROCEDURAL LANGUAGE plpgsql;


ALTER PROCEDURAL LANGUAGE plpgsql OWNER TO albert;

SET search_path = public, pg_catalog;

--
-- Name: post_status; Type: TYPE; Schema: public; Owner: albert
--

CREATE TYPE post_status AS ENUM (
    'deleted',
    'flagged',
    'pending',
    'active'
);


ALTER TYPE public.post_status OWNER TO albert;

--
-- Name: block_delete(); Type: FUNCTION; Schema: public; Owner: albert
--

CREATE FUNCTION block_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
			 RAISE EXCEPTION 'Attempted to delete from note table';
			 RETURN NULL;
end;
$$;


ALTER FUNCTION public.block_delete() OWNER TO albert;

--
-- Name: notes_block_delete(); Type: FUNCTION; Schema: public; Owner: albert
--

CREATE FUNCTION notes_block_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  raise exception 'cannot delete note';
end;
$$;


ALTER FUNCTION public.notes_block_delete() OWNER TO albert;

--
-- Name: pools_posts_delete_trg(); Type: FUNCTION; Schema: public; Owner: albert
--

CREATE FUNCTION pools_posts_delete_trg() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
				BEGIN
					UPDATE pools SET post_count = post_count - 1 WHERE id = OLD.pool_id;
					RETURN OLD;
				END;
				$$;


ALTER FUNCTION public.pools_posts_delete_trg() OWNER TO albert;

--
-- Name: pools_posts_insert_trg(); Type: FUNCTION; Schema: public; Owner: albert
--

CREATE FUNCTION pools_posts_insert_trg() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
				BEGIN
					UPDATE pools SET post_count = post_count + 1 WHERE id = NEW.pool_id;
					RETURN NEW;
				END;
				$$;


ALTER FUNCTION public.pools_posts_insert_trg() OWNER TO albert;

--
-- Name: rlike(text, text); Type: FUNCTION; Schema: public; Owner: albert
--

CREATE FUNCTION rlike(text, text) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$select $2 like $1$_$;


ALTER FUNCTION public.rlike(text, text) OWNER TO albert;

--
-- Name: testprs_end(internal); Type: FUNCTION; Schema: public; Owner: albert
--

CREATE FUNCTION testprs_end(internal) RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/test_parser', 'testprs_end';


ALTER FUNCTION public.testprs_end(internal) OWNER TO albert;

--
-- Name: testprs_getlexeme(internal, internal, internal); Type: FUNCTION; Schema: public; Owner: albert
--

CREATE FUNCTION testprs_getlexeme(internal, internal, internal) RETURNS internal
    LANGUAGE c STRICT
    AS '$libdir/test_parser', 'testprs_getlexeme';


ALTER FUNCTION public.testprs_getlexeme(internal, internal, internal) OWNER TO albert;

--
-- Name: testprs_lextype(internal); Type: FUNCTION; Schema: public; Owner: albert
--

CREATE FUNCTION testprs_lextype(internal) RETURNS internal
    LANGUAGE c STRICT
    AS '$libdir/test_parser', 'testprs_lextype';


ALTER FUNCTION public.testprs_lextype(internal) OWNER TO albert;

--
-- Name: testprs_start(internal, integer); Type: FUNCTION; Schema: public; Owner: albert
--

CREATE FUNCTION testprs_start(internal, integer) RETURNS internal
    LANGUAGE c STRICT
    AS '$libdir/test_parser', 'testprs_start';


ALTER FUNCTION public.testprs_start(internal, integer) OWNER TO albert;

--
-- Name: trg_posts_tags__delete(); Type: FUNCTION; Schema: public; Owner: albert
--

CREATE FUNCTION trg_posts_tags__delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        UPDATE tags SET post_count = post_count - 1 WHERE tags.id = OLD.tag_id;
        RETURN OLD;
      END;
      $$;


ALTER FUNCTION public.trg_posts_tags__delete() OWNER TO albert;

--
-- Name: trg_posts_tags__insert(); Type: FUNCTION; Schema: public; Owner: albert
--

CREATE FUNCTION trg_posts_tags__insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        UPDATE tags SET post_count = post_count + 1 WHERE tags.id = NEW.tag_id;
        RETURN NEW;
      END;
      $$;


ALTER FUNCTION public.trg_posts_tags__insert() OWNER TO albert;

--
-- Name: ~~~; Type: OPERATOR; Schema: public; Owner: albert
--

CREATE OPERATOR ~~~ (
    PROCEDURE = rlike,
    LEFTARG = text,
    RIGHTARG = text,
    COMMUTATOR = ~~
);


ALTER OPERATOR public.~~~ (text, text) OWNER TO albert;

--
-- Name: testparser; Type: TEXT SEARCH PARSER; Schema: public; Owner: 
--

CREATE TEXT SEARCH PARSER testparser (
    START = testprs_start,
    GETTOKEN = testprs_getlexeme,
    END = testprs_end,
    HEADLINE = prsd_headline,
    LEXTYPES = testprs_lextype );


--
-- Name: danbooru; Type: TEXT SEARCH CONFIGURATION; Schema: public; Owner: albert
--

CREATE TEXT SEARCH CONFIGURATION danbooru (
    PARSER = testparser );

ALTER TEXT SEARCH CONFIGURATION danbooru
    ADD MAPPING FOR word WITH simple;


ALTER TEXT SEARCH CONFIGURATION public.danbooru OWNER TO albert;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: advertisement_hits; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE advertisement_hits (
    id integer NOT NULL,
    advertisement_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    ip_addr inet
);


ALTER TABLE public.advertisement_hits OWNER TO albert;

--
-- Name: advertisement_hits_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE advertisement_hits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.advertisement_hits_id_seq OWNER TO albert;

--
-- Name: advertisement_hits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE advertisement_hits_id_seq OWNED BY advertisement_hits.id;


--
-- Name: advertisements; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE advertisements (
    id integer NOT NULL,
    referral_url character varying(1000) NOT NULL,
    ad_type character varying(255) NOT NULL,
    status character varying(255) NOT NULL,
    hit_count integer DEFAULT 0 NOT NULL,
    width integer NOT NULL,
    height integer NOT NULL,
    is_work_safe boolean DEFAULT false NOT NULL,
    file_name character varying(255),
    created_at timestamp without time zone
);


ALTER TABLE public.advertisements OWNER TO albert;

--
-- Name: advertisements_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE advertisements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.advertisements_id_seq OWNER TO albert;

--
-- Name: advertisements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE advertisements_id_seq OWNED BY advertisements.id;


--
-- Name: artist_urls; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE artist_urls (
    id integer NOT NULL,
    artist_id integer NOT NULL,
    url text NOT NULL,
    normalized_url text NOT NULL
);


ALTER TABLE public.artist_urls OWNER TO albert;

--
-- Name: artist_urls_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE artist_urls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.artist_urls_id_seq OWNER TO albert;

--
-- Name: artist_urls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE artist_urls_id_seq OWNED BY artist_urls.id;


--
-- Name: artist_versions; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE artist_versions (
    id integer NOT NULL,
    artist_id integer,
    version integer DEFAULT 0 NOT NULL,
    name text,
    updater_id integer,
    cached_urls text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    is_active boolean DEFAULT true NOT NULL,
    other_names_array text[],
    group_name character varying(255),
    is_banned boolean DEFAULT false NOT NULL
);


ALTER TABLE public.artist_versions OWNER TO albert;

--
-- Name: artist_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE artist_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.artist_versions_id_seq OWNER TO albert;

--
-- Name: artist_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE artist_versions_id_seq OWNED BY artist_versions.id;


--
-- Name: artists; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE artists (
    id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    name text NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    updater_id integer,
    version integer,
    is_active boolean DEFAULT true NOT NULL,
    other_names_array text[],
    group_name character varying(255),
    is_banned boolean DEFAULT false NOT NULL
);


ALTER TABLE public.artists OWNER TO albert;

--
-- Name: artists_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE artists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.artists_id_seq OWNER TO albert;

--
-- Name: artists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE artists_id_seq OWNED BY artists.id;


--
-- Name: banned_ips; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE banned_ips (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    ip_addr inet NOT NULL,
    reason text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.banned_ips OWNER TO albert;

--
-- Name: banned_ips_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE banned_ips_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.banned_ips_id_seq OWNER TO albert;

--
-- Name: banned_ips_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE banned_ips_id_seq OWNED BY banned_ips.id;


--
-- Name: bans; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE bans (
    id integer NOT NULL,
    user_id integer NOT NULL,
    reason text NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    banned_by integer NOT NULL,
    old_level integer
);


ALTER TABLE public.bans OWNER TO albert;

--
-- Name: bans_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE bans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.bans_id_seq OWNER TO albert;

--
-- Name: bans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE bans_id_seq OWNED BY bans.id;


--
-- Name: comment_votes; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE comment_votes (
    id integer NOT NULL,
    comment_id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.comment_votes OWNER TO albert;

--
-- Name: comment_votes_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE comment_votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.comment_votes_id_seq OWNER TO albert;

--
-- Name: comment_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE comment_votes_id_seq OWNED BY comment_votes.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    post_id integer NOT NULL,
    user_id integer,
    body text NOT NULL,
    ip_addr inet NOT NULL,
    text_search_index tsvector,
    score integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.comments OWNER TO albert;

--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.comments_id_seq OWNER TO albert;

--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: dmails; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE dmails (
    id integer NOT NULL,
    from_id integer NOT NULL,
    to_id integer NOT NULL,
    title text NOT NULL,
    body text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    has_seen boolean DEFAULT false NOT NULL,
    parent_id integer
);


ALTER TABLE public.dmails OWNER TO albert;

--
-- Name: dmails_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE dmails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.dmails_id_seq OWNER TO albert;

--
-- Name: dmails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE dmails_id_seq OWNED BY dmails.id;


--
-- Name: tag_subscriptions; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE tag_subscriptions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    tag_query text NOT NULL,
    cached_post_ids text DEFAULT ''::text NOT NULL,
    name character varying(255) DEFAULT 'General'::character varying NOT NULL,
    is_visible_on_profile boolean DEFAULT true NOT NULL
);


ALTER TABLE public.tag_subscriptions OWNER TO albert;

--
-- Name: favorite_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE favorite_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.favorite_tags_id_seq OWNER TO albert;

--
-- Name: favorite_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE favorite_tags_id_seq OWNED BY tag_subscriptions.id;


--
-- Name: favorites; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE favorites (
    id integer NOT NULL,
    post_id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.favorites OWNER TO albert;

--
-- Name: favorites_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE favorites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.favorites_id_seq OWNER TO albert;

--
-- Name: favorites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE favorites_id_seq OWNED BY favorites.id;


--
-- Name: flagged_post_details; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE flagged_post_details (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    post_id integer NOT NULL,
    reason text NOT NULL,
    user_id integer NOT NULL,
    is_resolved boolean NOT NULL
);


ALTER TABLE public.flagged_post_details OWNER TO albert;

--
-- Name: flagged_post_details_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE flagged_post_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.flagged_post_details_id_seq OWNER TO albert;

--
-- Name: flagged_post_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE flagged_post_details_id_seq OWNED BY flagged_post_details.id;


--
-- Name: forum_posts; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE forum_posts (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    parent_id integer,
    creator_id integer,
    body text NOT NULL,
    response_count integer DEFAULT 0 NOT NULL,
    title text NOT NULL,
    last_updated_by integer,
    is_sticky boolean DEFAULT false NOT NULL,
    is_locked boolean DEFAULT false NOT NULL,
    text_search_index tsvector
);


ALTER TABLE public.forum_posts OWNER TO albert;

--
-- Name: forum_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE forum_posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.forum_posts_id_seq OWNER TO albert;

--
-- Name: forum_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE forum_posts_id_seq OWNED BY forum_posts.id;


--
-- Name: job_tasks; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE job_tasks (
    id integer NOT NULL,
    task_type character varying(255) NOT NULL,
    status character varying(255) NOT NULL,
    status_message text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    data_as_json text DEFAULT '{}'::text NOT NULL,
    repeat_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.job_tasks OWNER TO albert;

--
-- Name: job_tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE job_tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.job_tasks_id_seq OWNER TO albert;

--
-- Name: job_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE job_tasks_id_seq OWNED BY job_tasks.id;


--
-- Name: mod_actions; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE mod_actions (
    id integer NOT NULL,
    user_id integer,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.mod_actions OWNER TO albert;

--
-- Name: mod_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE mod_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.mod_actions_id_seq OWNER TO albert;

--
-- Name: mod_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE mod_actions_id_seq OWNED BY mod_actions.id;


--
-- Name: mod_queue_posts; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE mod_queue_posts (
    id integer NOT NULL,
    user_id integer NOT NULL,
    post_id integer NOT NULL
);


ALTER TABLE public.mod_queue_posts OWNER TO albert;

--
-- Name: mod_queue_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE mod_queue_posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.mod_queue_posts_id_seq OWNER TO albert;

--
-- Name: mod_queue_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE mod_queue_posts_id_seq OWNED BY mod_queue_posts.id;


--
-- Name: note_versions; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE note_versions (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    x integer NOT NULL,
    y integer NOT NULL,
    width integer NOT NULL,
    height integer NOT NULL,
    body text NOT NULL,
    version integer NOT NULL,
    ip_addr inet NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    note_id integer NOT NULL,
    post_id integer NOT NULL,
    user_id integer,
    text_search_index tsvector
);


ALTER TABLE public.note_versions OWNER TO albert;

--
-- Name: note_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE note_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.note_versions_id_seq OWNER TO albert;

--
-- Name: note_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE note_versions_id_seq OWNED BY note_versions.id;


--
-- Name: notes; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE notes (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer,
    x integer NOT NULL,
    y integer NOT NULL,
    width integer NOT NULL,
    height integer NOT NULL,
    ip_addr inet NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    post_id integer NOT NULL,
    body text NOT NULL,
    text_search_index tsvector
);


ALTER TABLE public.notes OWNER TO albert;

--
-- Name: notes_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.notes_id_seq OWNER TO albert;

--
-- Name: notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE notes_id_seq OWNED BY notes.id;


--
-- Name: pixiv_proxies; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE pixiv_proxies (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.pixiv_proxies OWNER TO albert;

--
-- Name: pixiv_proxies_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE pixiv_proxies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.pixiv_proxies_id_seq OWNER TO albert;

--
-- Name: pixiv_proxies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE pixiv_proxies_id_seq OWNED BY pixiv_proxies.id;


--
-- Name: pool_updates; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE pool_updates (
    id integer NOT NULL,
    pool_id integer NOT NULL,
    post_ids text DEFAULT ''::text NOT NULL,
    user_id integer,
    ip_addr inet,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.pool_updates OWNER TO albert;

--
-- Name: pool_updates_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE pool_updates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.pool_updates_id_seq OWNER TO albert;

--
-- Name: pool_updates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE pool_updates_id_seq OWNED BY pool_updates.id;


--
-- Name: pools; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE pools (
    id integer NOT NULL,
    name text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer NOT NULL,
    is_public boolean DEFAULT false NOT NULL,
    post_count integer DEFAULT 0 NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    is_active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.pools OWNER TO albert;

--
-- Name: pools_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE pools_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.pools_id_seq OWNER TO albert;

--
-- Name: pools_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE pools_id_seq OWNED BY pools.id;


--
-- Name: pools_posts; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE pools_posts (
    id integer NOT NULL,
    sequence integer DEFAULT 0 NOT NULL,
    pool_id integer NOT NULL,
    post_id integer NOT NULL,
    next_post_id integer,
    prev_post_id integer
);


ALTER TABLE public.pools_posts OWNER TO albert;

--
-- Name: pools_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE pools_posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.pools_posts_id_seq OWNER TO albert;

--
-- Name: pools_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE pools_posts_id_seq OWNED BY pools_posts.id;


--
-- Name: post_appeals; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE post_appeals (
    id integer NOT NULL,
    post_id integer,
    user_id integer,
    reason character varying(255),
    ip_addr inet,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.post_appeals OWNER TO albert;

--
-- Name: post_appeals_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE post_appeals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.post_appeals_id_seq OWNER TO albert;

--
-- Name: post_appeals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE post_appeals_id_seq OWNED BY post_appeals.id;


--
-- Name: posts; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE posts (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    user_id integer,
    score integer DEFAULT 0 NOT NULL,
    source text NOT NULL,
    md5 text NOT NULL,
    last_commented_at timestamp without time zone,
    rating character(1) DEFAULT 'q'::bpchar NOT NULL,
    width integer,
    height integer,
    ip_addr inet NOT NULL,
    cached_tags text DEFAULT ''::text NOT NULL,
    is_note_locked boolean DEFAULT false NOT NULL,
    fav_count integer DEFAULT 0 NOT NULL,
    file_ext text DEFAULT ''::text NOT NULL,
    last_noted_at timestamp without time zone,
    is_rating_locked boolean DEFAULT false NOT NULL,
    parent_id integer,
    has_children boolean DEFAULT false NOT NULL,
    status post_status DEFAULT 'active'::post_status NOT NULL,
    sample_width integer,
    sample_height integer,
    change_seq integer,
    approver_id integer,
    tags_index tsvector,
    general_tag_count integer DEFAULT 0 NOT NULL,
    artist_tag_count integer DEFAULT 0 NOT NULL,
    character_tag_count integer DEFAULT 0 NOT NULL,
    copyright_tag_count integer DEFAULT 0 NOT NULL,
    file_size integer,
    is_status_locked boolean DEFAULT false NOT NULL
);


ALTER TABLE public.posts OWNER TO albert;

--
-- Name: post_change_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE post_change_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.post_change_seq OWNER TO albert;

--
-- Name: post_change_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE post_change_seq OWNED BY posts.change_seq;


--
-- Name: post_tag_histories; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE post_tag_histories (
    id integer NOT NULL,
    post_id integer NOT NULL,
    tags text NOT NULL,
    user_id integer,
    ip_addr inet NOT NULL,
    created_at timestamp without time zone NOT NULL,
    rating character(1),
    parent_id integer,
    source text
);


ALTER TABLE public.post_tag_histories OWNER TO albert;

--
-- Name: post_tag_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE post_tag_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.post_tag_histories_id_seq OWNER TO albert;

--
-- Name: post_tag_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE post_tag_histories_id_seq OWNED BY post_tag_histories.id;


--
-- Name: post_votes; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE post_votes (
    id integer NOT NULL,
    post_id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    score integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.post_votes OWNER TO albert;

--
-- Name: post_votes_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE post_votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.post_votes_id_seq OWNER TO albert;

--
-- Name: post_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE post_votes_id_seq OWNED BY post_votes.id;


--
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.posts_id_seq OWNER TO albert;

--
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE posts_id_seq OWNED BY posts.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO albert;

--
-- Name: server_keys; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE server_keys (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    value text
);


ALTER TABLE public.server_keys OWNER TO albert;

--
-- Name: server_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE server_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.server_keys_id_seq OWNER TO albert;

--
-- Name: server_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE server_keys_id_seq OWNED BY server_keys.id;


--
-- Name: table_data; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE table_data (
    name text NOT NULL,
    row_count integer NOT NULL
);


ALTER TABLE public.table_data OWNER TO albert;

--
-- Name: tag_aliases; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE tag_aliases (
    id integer NOT NULL,
    name text NOT NULL,
    alias_id integer NOT NULL,
    is_pending boolean DEFAULT false NOT NULL,
    reason text DEFAULT ''::text NOT NULL,
    creator_id integer
);


ALTER TABLE public.tag_aliases OWNER TO albert;

--
-- Name: tag_aliases_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE tag_aliases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.tag_aliases_id_seq OWNER TO albert;

--
-- Name: tag_aliases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE tag_aliases_id_seq OWNED BY tag_aliases.id;


--
-- Name: tag_implications; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE tag_implications (
    id integer NOT NULL,
    consequent_id integer NOT NULL,
    predicate_id integer NOT NULL,
    is_pending boolean DEFAULT false NOT NULL,
    reason text DEFAULT ''::text NOT NULL,
    creator_id integer
);


ALTER TABLE public.tag_implications OWNER TO albert;

--
-- Name: tag_implications_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE tag_implications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.tag_implications_id_seq OWNER TO albert;

--
-- Name: tag_implications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE tag_implications_id_seq OWNED BY tag_implications.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    name text NOT NULL,
    post_count integer DEFAULT 0 NOT NULL,
    cached_related text DEFAULT '[]'::text NOT NULL,
    cached_related_expires_on timestamp without time zone DEFAULT now() NOT NULL,
    tag_type smallint DEFAULT 0 NOT NULL,
    is_ambiguous boolean DEFAULT false NOT NULL
);


ALTER TABLE public.tags OWNER TO albert;

--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.tags_id_seq OWNER TO albert;

--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: test_janitors; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE test_janitors (
    id integer NOT NULL,
    user_id integer NOT NULL,
    test_promotion_date timestamp without time zone NOT NULL,
    promotion_date timestamp without time zone,
    original_level integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.test_janitors OWNER TO albert;

--
-- Name: test_janitors_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE test_janitors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.test_janitors_id_seq OWNER TO albert;

--
-- Name: test_janitors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE test_janitors_id_seq OWNED BY test_janitors.id;


--
-- Name: user_blacklisted_tags; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE user_blacklisted_tags (
    id integer NOT NULL,
    user_id integer NOT NULL,
    tags text NOT NULL
);


ALTER TABLE public.user_blacklisted_tags OWNER TO albert;

--
-- Name: user_blacklisted_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE user_blacklisted_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.user_blacklisted_tags_id_seq OWNER TO albert;

--
-- Name: user_blacklisted_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE user_blacklisted_tags_id_seq OWNED BY user_blacklisted_tags.id;


--
-- Name: user_records; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE user_records (
    id integer NOT NULL,
    user_id integer NOT NULL,
    reported_by integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    body text NOT NULL,
    score integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.user_records OWNER TO albert;

--
-- Name: user_records_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE user_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.user_records_id_seq OWNER TO albert;

--
-- Name: user_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE user_records_id_seq OWNED BY user_records.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    name text NOT NULL,
    password_hash text NOT NULL,
    level integer DEFAULT 0 NOT NULL,
    email text DEFAULT ''::text NOT NULL,
    recent_tags text DEFAULT ''::text NOT NULL,
    invite_count integer DEFAULT 0 NOT NULL,
    always_resize_images boolean DEFAULT false NOT NULL,
    invited_by integer,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    last_logged_in_at timestamp without time zone DEFAULT now() NOT NULL,
    last_forum_topic_read_at timestamp without time zone DEFAULT '1960-01-01 00:00:00'::timestamp without time zone NOT NULL,
    has_mail boolean DEFAULT false NOT NULL,
    receive_dmails boolean DEFAULT false NOT NULL,
    show_samples boolean,
    upload_limit integer,
    uploaded_tags text DEFAULT ''::text NOT NULL,
    comment_threshold integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.users OWNER TO albert;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO albert;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: wiki_page_versions; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE wiki_page_versions (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    title text NOT NULL,
    body text NOT NULL,
    user_id integer,
    ip_addr inet NOT NULL,
    wiki_page_id integer NOT NULL,
    is_locked boolean DEFAULT false NOT NULL,
    text_search_index tsvector
);


ALTER TABLE public.wiki_page_versions OWNER TO albert;

--
-- Name: wiki_page_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE wiki_page_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.wiki_page_versions_id_seq OWNER TO albert;

--
-- Name: wiki_page_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE wiki_page_versions_id_seq OWNED BY wiki_page_versions.id;


--
-- Name: wiki_pages; Type: TABLE; Schema: public; Owner: albert; Tablespace: 
--

CREATE TABLE wiki_pages (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    title text NOT NULL,
    body text NOT NULL,
    user_id integer,
    ip_addr inet NOT NULL,
    is_locked boolean DEFAULT false NOT NULL,
    text_search_index tsvector
);


ALTER TABLE public.wiki_pages OWNER TO albert;

--
-- Name: wiki_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: albert
--

CREATE SEQUENCE wiki_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.wiki_pages_id_seq OWNER TO albert;

--
-- Name: wiki_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: albert
--

ALTER SEQUENCE wiki_pages_id_seq OWNED BY wiki_pages.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE advertisement_hits ALTER COLUMN id SET DEFAULT nextval('advertisement_hits_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE advertisements ALTER COLUMN id SET DEFAULT nextval('advertisements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE artist_urls ALTER COLUMN id SET DEFAULT nextval('artist_urls_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE artist_versions ALTER COLUMN id SET DEFAULT nextval('artist_versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE artists ALTER COLUMN id SET DEFAULT nextval('artists_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE banned_ips ALTER COLUMN id SET DEFAULT nextval('banned_ips_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE bans ALTER COLUMN id SET DEFAULT nextval('bans_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE comment_votes ALTER COLUMN id SET DEFAULT nextval('comment_votes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE dmails ALTER COLUMN id SET DEFAULT nextval('dmails_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE favorites ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE flagged_post_details ALTER COLUMN id SET DEFAULT nextval('flagged_post_details_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE forum_posts ALTER COLUMN id SET DEFAULT nextval('forum_posts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE job_tasks ALTER COLUMN id SET DEFAULT nextval('job_tasks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE mod_actions ALTER COLUMN id SET DEFAULT nextval('mod_actions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE mod_queue_posts ALTER COLUMN id SET DEFAULT nextval('mod_queue_posts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE note_versions ALTER COLUMN id SET DEFAULT nextval('note_versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE notes ALTER COLUMN id SET DEFAULT nextval('notes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE pixiv_proxies ALTER COLUMN id SET DEFAULT nextval('pixiv_proxies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE pool_updates ALTER COLUMN id SET DEFAULT nextval('pool_updates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE pools ALTER COLUMN id SET DEFAULT nextval('pools_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE pools_posts ALTER COLUMN id SET DEFAULT nextval('pools_posts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE post_appeals ALTER COLUMN id SET DEFAULT nextval('post_appeals_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE post_tag_histories ALTER COLUMN id SET DEFAULT nextval('post_tag_histories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE post_votes ALTER COLUMN id SET DEFAULT nextval('post_votes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE posts ALTER COLUMN id SET DEFAULT nextval('posts_id_seq'::regclass);


--
-- Name: change_seq; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE posts ALTER COLUMN change_seq SET DEFAULT nextval('post_change_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE server_keys ALTER COLUMN id SET DEFAULT nextval('server_keys_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE tag_aliases ALTER COLUMN id SET DEFAULT nextval('tag_aliases_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE tag_implications ALTER COLUMN id SET DEFAULT nextval('tag_implications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE tag_subscriptions ALTER COLUMN id SET DEFAULT nextval('favorite_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE test_janitors ALTER COLUMN id SET DEFAULT nextval('test_janitors_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE user_blacklisted_tags ALTER COLUMN id SET DEFAULT nextval('user_blacklisted_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE user_records ALTER COLUMN id SET DEFAULT nextval('user_records_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE wiki_page_versions ALTER COLUMN id SET DEFAULT nextval('wiki_page_versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: albert
--

ALTER TABLE wiki_pages ALTER COLUMN id SET DEFAULT nextval('wiki_pages_id_seq'::regclass);


--
-- Name: advertisement_hits_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY advertisement_hits
    ADD CONSTRAINT advertisement_hits_pkey PRIMARY KEY (id);


--
-- Name: advertisements_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY advertisements
    ADD CONSTRAINT advertisements_pkey PRIMARY KEY (id);


--
-- Name: artist_urls_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY artist_urls
    ADD CONSTRAINT artist_urls_pkey PRIMARY KEY (id);


--
-- Name: artist_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY artist_versions
    ADD CONSTRAINT artist_versions_pkey PRIMARY KEY (id);


--
-- Name: artists_name_uniq; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY artists
    ADD CONSTRAINT artists_name_uniq UNIQUE (name);


--
-- Name: artists_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY artists
    ADD CONSTRAINT artists_pkey PRIMARY KEY (id);


--
-- Name: banned_ips_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY banned_ips
    ADD CONSTRAINT banned_ips_pkey PRIMARY KEY (id);


--
-- Name: bans_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY bans
    ADD CONSTRAINT bans_pkey PRIMARY KEY (id);


--
-- Name: comment_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY comment_votes
    ADD CONSTRAINT comment_votes_pkey PRIMARY KEY (id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: dmails_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY dmails
    ADD CONSTRAINT dmails_pkey PRIMARY KEY (id);


--
-- Name: favorite_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY tag_subscriptions
    ADD CONSTRAINT favorite_tags_pkey PRIMARY KEY (id);


--
-- Name: favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY favorites
    ADD CONSTRAINT favorites_pkey PRIMARY KEY (id);


--
-- Name: flagged_post_details_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY flagged_post_details
    ADD CONSTRAINT flagged_post_details_pkey PRIMARY KEY (id);


--
-- Name: forum_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY forum_posts
    ADD CONSTRAINT forum_posts_pkey PRIMARY KEY (id);


--
-- Name: job_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY job_tasks
    ADD CONSTRAINT job_tasks_pkey PRIMARY KEY (id);


--
-- Name: mod_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY mod_actions
    ADD CONSTRAINT mod_actions_pkey PRIMARY KEY (id);


--
-- Name: mod_queue_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY mod_queue_posts
    ADD CONSTRAINT mod_queue_posts_pkey PRIMARY KEY (id);


--
-- Name: note_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY note_versions
    ADD CONSTRAINT note_versions_pkey PRIMARY KEY (id);


--
-- Name: notes_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY notes
    ADD CONSTRAINT notes_pkey PRIMARY KEY (id);


--
-- Name: pixiv_proxies_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY pixiv_proxies
    ADD CONSTRAINT pixiv_proxies_pkey PRIMARY KEY (id);


--
-- Name: pool_updates_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY pool_updates
    ADD CONSTRAINT pool_updates_pkey PRIMARY KEY (id);


--
-- Name: pools_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY pools
    ADD CONSTRAINT pools_pkey PRIMARY KEY (id);


--
-- Name: pools_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY pools_posts
    ADD CONSTRAINT pools_posts_pkey PRIMARY KEY (id);


--
-- Name: post_appeals_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY post_appeals
    ADD CONSTRAINT post_appeals_pkey PRIMARY KEY (id);


--
-- Name: post_tag_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY post_tag_histories
    ADD CONSTRAINT post_tag_histories_pkey PRIMARY KEY (id);


--
-- Name: post_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY post_votes
    ADD CONSTRAINT post_votes_pkey PRIMARY KEY (id);


--
-- Name: posts_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: server_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY server_keys
    ADD CONSTRAINT server_keys_pkey PRIMARY KEY (id);


--
-- Name: table_data_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY table_data
    ADD CONSTRAINT table_data_pkey PRIMARY KEY (name);


--
-- Name: tag_aliases_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY tag_aliases
    ADD CONSTRAINT tag_aliases_pkey PRIMARY KEY (id);


--
-- Name: tag_implications_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY tag_implications
    ADD CONSTRAINT tag_implications_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: test_janitors_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY test_janitors
    ADD CONSTRAINT test_janitors_pkey PRIMARY KEY (id);


--
-- Name: user_blacklisted_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY user_blacklisted_tags
    ADD CONSTRAINT user_blacklisted_tags_pkey PRIMARY KEY (id);


--
-- Name: user_records_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY user_records
    ADD CONSTRAINT user_records_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: wiki_page_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY wiki_page_versions
    ADD CONSTRAINT wiki_page_versions_pkey PRIMARY KEY (id);


--
-- Name: wiki_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: albert; Tablespace: 
--

ALTER TABLE ONLY wiki_pages
    ADD CONSTRAINT wiki_pages_pkey PRIMARY KEY (id);


--
-- Name: comments_text_search_idx; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX comments_text_search_idx ON notes USING gin (text_search_index);


--
-- Name: forum_posts__parent_id_idx; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX forum_posts__parent_id_idx ON forum_posts USING btree (parent_id) WHERE (parent_id IS NULL);


--
-- Name: forum_posts_search_idx; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX forum_posts_search_idx ON forum_posts USING gin (text_search_index);


--
-- Name: idx_comments__post; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX idx_comments__post ON comments USING btree (post_id);


--
-- Name: idx_favorites__post; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX idx_favorites__post ON favorites USING btree (post_id);


--
-- Name: idx_favorites__user; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX idx_favorites__user ON favorites USING btree (user_id);


--
-- Name: idx_note_versions__post; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX idx_note_versions__post ON note_versions USING btree (post_id);


--
-- Name: idx_notes__note; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX idx_notes__note ON note_versions USING btree (note_id);


--
-- Name: idx_notes__post; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX idx_notes__post ON notes USING btree (post_id);


--
-- Name: idx_post_tag_histories__post; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX idx_post_tag_histories__post ON post_tag_histories USING btree (post_id);


--
-- Name: idx_posts__created_at; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX idx_posts__created_at ON posts USING btree (created_at);


--
-- Name: idx_posts__last_commented_at; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX idx_posts__last_commented_at ON posts USING btree (last_commented_at) WHERE (last_commented_at IS NOT NULL);


--
-- Name: idx_posts__last_noted_at; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX idx_posts__last_noted_at ON posts USING btree (last_noted_at) WHERE (last_noted_at IS NOT NULL);


--
-- Name: idx_posts__md5; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE UNIQUE INDEX idx_posts__md5 ON posts USING btree (md5);


--
-- Name: idx_posts__users; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX idx_posts__users ON posts USING btree (user_id) WHERE (user_id IS NOT NULL);


--
-- Name: idx_posts_parent_id; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX idx_posts_parent_id ON posts USING btree (parent_id) WHERE (parent_id IS NOT NULL);


--
-- Name: idx_tag_aliases__name; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE UNIQUE INDEX idx_tag_aliases__name ON tag_aliases USING btree (name);


--
-- Name: idx_tag_implications__child; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX idx_tag_implications__child ON tag_implications USING btree (predicate_id);


--
-- Name: idx_tag_implications__parent; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX idx_tag_implications__parent ON tag_implications USING btree (consequent_id);


--
-- Name: idx_tags__name; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE UNIQUE INDEX idx_tags__name ON tags USING btree (name);


--
-- Name: idx_tags__post_count; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX idx_tags__post_count ON tags USING btree (post_count);


--
-- Name: idx_users__name; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX idx_users__name ON users USING btree (lower(name));


--
-- Name: idx_wiki_page_versions__wiki_page; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX idx_wiki_page_versions__wiki_page ON wiki_page_versions USING btree (wiki_page_id);


--
-- Name: idx_wiki_pages__title; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE UNIQUE INDEX idx_wiki_pages__title ON wiki_pages USING btree (title);


--
-- Name: idx_wiki_pages__updated_at; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX idx_wiki_pages__updated_at ON wiki_pages USING btree (updated_at);


--
-- Name: index_advertisement_hits_on_advertisement_id; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_advertisement_hits_on_advertisement_id ON advertisement_hits USING btree (advertisement_id);


--
-- Name: index_advertisement_hits_on_created_at; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_advertisement_hits_on_created_at ON advertisement_hits USING btree (created_at);


--
-- Name: index_artist_urls_on_artist_id; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_artist_urls_on_artist_id ON artist_urls USING btree (artist_id);


--
-- Name: index_artist_urls_on_normalized_url; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_artist_urls_on_normalized_url ON artist_urls USING btree (normalized_url);


--
-- Name: index_artist_urls_on_url; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_artist_urls_on_url ON artist_urls USING btree (url);


--
-- Name: index_artist_versions_on_artist_id; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_artist_versions_on_artist_id ON artist_versions USING btree (artist_id);


--
-- Name: index_artist_versions_on_updater_id; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_artist_versions_on_updater_id ON artist_versions USING btree (updater_id);


--
-- Name: index_artists_on_other_names_array; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_artists_on_other_names_array ON artists USING btree (other_names_array);


--
-- Name: index_banned_ips_on_ip_addr; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_banned_ips_on_ip_addr ON banned_ips USING btree (ip_addr);


--
-- Name: index_bans_on_user_id; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_bans_on_user_id ON bans USING btree (user_id);


--
-- Name: index_comment_votes_on_comment_id; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_comment_votes_on_comment_id ON comment_votes USING btree (comment_id);


--
-- Name: index_comment_votes_on_created_at; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_comment_votes_on_created_at ON comment_votes USING btree (created_at);


--
-- Name: index_comment_votes_on_user_id; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_comment_votes_on_user_id ON comment_votes USING btree (user_id);


--
-- Name: index_comments_on_user_id; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_comments_on_user_id ON comments USING btree (user_id);


--
-- Name: index_dmails_on_from_id; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_dmails_on_from_id ON dmails USING btree (from_id);


--
-- Name: index_dmails_on_parent_id; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_dmails_on_parent_id ON dmails USING btree (parent_id);


--
-- Name: index_dmails_on_to_id; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_dmails_on_to_id ON dmails USING btree (to_id);


--
-- Name: index_flagged_post_details_on_post_id; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_flagged_post_details_on_post_id ON flagged_post_details USING btree (post_id);


--
-- Name: index_forum_posts_on_creator_id; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_forum_posts_on_creator_id ON forum_posts USING btree (creator_id);


--
-- Name: index_forum_posts_on_updated_at; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_forum_posts_on_updated_at ON forum_posts USING btree (updated_at);


--
-- Name: index_mod_actions_on_created_at; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_mod_actions_on_created_at ON mod_actions USING btree (created_at);


--
-- Name: index_mod_actions_on_user_id; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_mod_actions_on_user_id ON mod_actions USING btree (user_id);


--
-- Name: index_note_versions_on_user_id; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_note_versions_on_user_id ON note_versions USING btree (user_id);


--
-- Name: index_pool_updates_on_pool_id; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_pool_updates_on_pool_id ON pool_updates USING btree (pool_id);


--
-- Name: index_pool_updates_on_user_id; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_pool_updates_on_user_id ON pool_updates USING btree (user_id);


--
-- Name: index_post_appeals_on_created_at; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_post_appeals_on_created_at ON post_appeals USING btree (created_at);


--
-- Name: index_post_appeals_on_ip_addr; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_post_appeals_on_ip_addr ON post_appeals USING btree (ip_addr);


--
-- Name: index_post_appeals_on_post_id; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_post_appeals_on_post_id ON post_appeals USING btree (post_id);


--
-- Name: index_post_appeals_on_user_id; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_post_appeals_on_user_id ON post_appeals USING btree (user_id);


--
-- Name: index_post_tag_histories_on_user_id; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_post_tag_histories_on_user_id ON post_tag_histories USING btree (user_id);


--
-- Name: index_post_votes_on_created_at; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_post_votes_on_created_at ON post_votes USING btree (created_at);


--
-- Name: index_post_votes_on_post_id; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_post_votes_on_post_id ON post_votes USING btree (post_id);


--
-- Name: index_post_votes_on_user_id; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_post_votes_on_user_id ON post_votes USING btree (user_id);


--
-- Name: index_posts_on_approver_id; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_posts_on_approver_id ON posts USING btree (approver_id);


--
-- Name: index_posts_on_change_seq; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_posts_on_change_seq ON posts USING btree (change_seq);


--
-- Name: index_posts_on_file_size; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_posts_on_file_size ON posts USING btree (file_size);


--
-- Name: index_posts_on_height; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_posts_on_height ON posts USING btree (height);


--
-- Name: index_posts_on_source; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_posts_on_source ON posts USING btree (source);


--
-- Name: index_posts_on_tags_index; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_posts_on_tags_index ON posts USING gin (tags_index);


--
-- Name: index_posts_on_width; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_posts_on_width ON posts USING btree (width);


--
-- Name: index_server_keys_on_name; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE UNIQUE INDEX index_server_keys_on_name ON server_keys USING btree (name);


--
-- Name: index_tag_subscriptions_on_name; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_tag_subscriptions_on_name ON tag_subscriptions USING btree (name);


--
-- Name: index_tag_subscriptions_on_user_id; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_tag_subscriptions_on_user_id ON tag_subscriptions USING btree (user_id);


--
-- Name: index_test_janitors_on_user_id; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_test_janitors_on_user_id ON test_janitors USING btree (user_id);


--
-- Name: index_user_blacklisted_tags_on_user_id; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_user_blacklisted_tags_on_user_id ON user_blacklisted_tags USING btree (user_id);


--
-- Name: index_wiki_page_versions_on_user_id; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX index_wiki_page_versions_on_user_id ON wiki_page_versions USING btree (user_id);


--
-- Name: notes_text_search_idx; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX notes_text_search_idx ON notes USING gin (text_search_index);


--
-- Name: pools_posts_pool_id_idx; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX pools_posts_pool_id_idx ON pools_posts USING btree (pool_id);


--
-- Name: pools_posts_post_id_idx; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX pools_posts_post_id_idx ON pools_posts USING btree (post_id);


--
-- Name: pools_user_id_idx; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX pools_user_id_idx ON pools USING btree (user_id);


--
-- Name: post_status_idx; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX post_status_idx ON posts USING btree (status) WHERE (status < 'active'::post_status);


--
-- Name: posts_mpixels; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX posts_mpixels ON posts USING btree (((((width * height))::numeric / 1000000.0)));


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: wiki_pages_search_idx; Type: INDEX; Schema: public; Owner: albert; Tablespace: 
--

CREATE INDEX wiki_pages_search_idx ON wiki_pages USING gin (text_search_index);


--
-- Name: pools_posts_delete_trg; Type: TRIGGER; Schema: public; Owner: albert
--

CREATE TRIGGER pools_posts_delete_trg
    BEFORE DELETE ON pools_posts
    FOR EACH ROW
    EXECUTE PROCEDURE pools_posts_delete_trg();


--
-- Name: pools_posts_insert_trg; Type: TRIGGER; Schema: public; Owner: albert
--

CREATE TRIGGER pools_posts_insert_trg
    BEFORE INSERT ON pools_posts
    FOR EACH ROW
    EXECUTE PROCEDURE pools_posts_insert_trg();


--
-- Name: trg_comment_search_update; Type: TRIGGER; Schema: public; Owner: albert
--

CREATE TRIGGER trg_comment_search_update
    BEFORE INSERT OR UPDATE ON comments
    FOR EACH ROW
    EXECUTE PROCEDURE tsvector_update_trigger('text_search_index', 'pg_catalog.english', 'body');


--
-- Name: trg_forum_post_search_update; Type: TRIGGER; Schema: public; Owner: albert
--

CREATE TRIGGER trg_forum_post_search_update
    BEFORE INSERT OR UPDATE ON forum_posts
    FOR EACH ROW
    EXECUTE PROCEDURE tsvector_update_trigger('text_search_index', 'pg_catalog.english', 'title', 'body');


--
-- Name: trg_note_search_update; Type: TRIGGER; Schema: public; Owner: albert
--

CREATE TRIGGER trg_note_search_update
    BEFORE INSERT OR UPDATE ON notes
    FOR EACH ROW
    EXECUTE PROCEDURE tsvector_update_trigger('text_search_index', 'pg_catalog.english', 'body');


--
-- Name: trg_posts_tags_index_update; Type: TRIGGER; Schema: public; Owner: albert
--

CREATE TRIGGER trg_posts_tags_index_update
    BEFORE INSERT OR UPDATE ON posts
    FOR EACH ROW
    EXECUTE PROCEDURE tsvector_update_trigger('tags_index', 'public.danbooru', 'cached_tags');


--
-- Name: trg_wiki_page_search_update; Type: TRIGGER; Schema: public; Owner: albert
--

CREATE TRIGGER trg_wiki_page_search_update
    BEFORE INSERT OR UPDATE ON wiki_pages
    FOR EACH ROW
    EXECUTE PROCEDURE tsvector_update_trigger('text_search_index', 'pg_catalog.english', 'title', 'body');


--
-- Name: artist_urls_artist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY artist_urls
    ADD CONSTRAINT artist_urls_artist_id_fkey FOREIGN KEY (artist_id) REFERENCES artists(id) ON DELETE CASCADE;


--
-- Name: artists_updater_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY artists
    ADD CONSTRAINT artists_updater_id_fkey FOREIGN KEY (updater_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- Name: bans_banned_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY bans
    ADD CONSTRAINT bans_banned_by_fkey FOREIGN KEY (banned_by) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: bans_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY bans
    ADD CONSTRAINT bans_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: comment_votes_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY comment_votes
    ADD CONSTRAINT comment_votes_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES comments(id) ON DELETE CASCADE;


--
-- Name: comment_votes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY comment_votes
    ADD CONSTRAINT comment_votes_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: dmails_from_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY dmails
    ADD CONSTRAINT dmails_from_id_fkey FOREIGN KEY (from_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: dmails_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY dmails
    ADD CONSTRAINT dmails_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES dmails(id);


--
-- Name: dmails_to_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY dmails
    ADD CONSTRAINT dmails_to_id_fkey FOREIGN KEY (to_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: fk_comments__post; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT fk_comments__post FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE;


--
-- Name: fk_comments__user; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT fk_comments__user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- Name: fk_favorites__post; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY favorites
    ADD CONSTRAINT fk_favorites__post FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE;


--
-- Name: fk_favorites__user; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY favorites
    ADD CONSTRAINT fk_favorites__user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: fk_note_versions__note; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY note_versions
    ADD CONSTRAINT fk_note_versions__note FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE;


--
-- Name: fk_note_versions__post; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY note_versions
    ADD CONSTRAINT fk_note_versions__post FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE;


--
-- Name: fk_note_versions__user; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY note_versions
    ADD CONSTRAINT fk_note_versions__user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- Name: fk_notes__post; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY notes
    ADD CONSTRAINT fk_notes__post FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE;


--
-- Name: fk_notes__user; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY notes
    ADD CONSTRAINT fk_notes__user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- Name: fk_post_tag_histories__post; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY post_tag_histories
    ADD CONSTRAINT fk_post_tag_histories__post FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE;


--
-- Name: fk_posts__user; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT fk_posts__user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- Name: fk_tag_aliases__alias; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY tag_aliases
    ADD CONSTRAINT fk_tag_aliases__alias FOREIGN KEY (alias_id) REFERENCES tags(id) ON DELETE CASCADE;


--
-- Name: fk_tag_implications__child; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY tag_implications
    ADD CONSTRAINT fk_tag_implications__child FOREIGN KEY (predicate_id) REFERENCES tags(id) ON DELETE CASCADE;


--
-- Name: fk_tag_implications__parent; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY tag_implications
    ADD CONSTRAINT fk_tag_implications__parent FOREIGN KEY (consequent_id) REFERENCES tags(id) ON DELETE CASCADE;


--
-- Name: fk_wiki_page_versions__user; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY wiki_page_versions
    ADD CONSTRAINT fk_wiki_page_versions__user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- Name: fk_wiki_page_versions__wiki_page; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY wiki_page_versions
    ADD CONSTRAINT fk_wiki_page_versions__wiki_page FOREIGN KEY (wiki_page_id) REFERENCES wiki_pages(id) ON DELETE CASCADE;


--
-- Name: fk_wiki_pages__user; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY wiki_pages
    ADD CONSTRAINT fk_wiki_pages__user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- Name: flagged_post_details_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY flagged_post_details
    ADD CONSTRAINT flagged_post_details_post_id_fkey FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE;


--
-- Name: flagged_post_details_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY flagged_post_details
    ADD CONSTRAINT flagged_post_details_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: forum_posts_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY forum_posts
    ADD CONSTRAINT forum_posts_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- Name: forum_posts_last_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY forum_posts
    ADD CONSTRAINT forum_posts_last_updated_by_fkey FOREIGN KEY (last_updated_by) REFERENCES users(id) ON DELETE SET NULL;


--
-- Name: forum_posts_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY forum_posts
    ADD CONSTRAINT forum_posts_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES forum_posts(id) ON DELETE CASCADE;


--
-- Name: mod_queue_posts_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY mod_queue_posts
    ADD CONSTRAINT mod_queue_posts_post_id_fkey FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE;


--
-- Name: mod_queue_posts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY mod_queue_posts
    ADD CONSTRAINT mod_queue_posts_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: pool_updates_pool_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY pool_updates
    ADD CONSTRAINT pool_updates_pool_id_fkey FOREIGN KEY (pool_id) REFERENCES pools(id) ON DELETE CASCADE;


--
-- Name: pools_posts_next_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY pools_posts
    ADD CONSTRAINT pools_posts_next_post_id_fkey FOREIGN KEY (next_post_id) REFERENCES posts(id) ON DELETE SET NULL;


--
-- Name: pools_posts_pool_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY pools_posts
    ADD CONSTRAINT pools_posts_pool_id_fkey FOREIGN KEY (pool_id) REFERENCES pools(id) ON DELETE CASCADE;


--
-- Name: pools_posts_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY pools_posts
    ADD CONSTRAINT pools_posts_post_id_fkey FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE;


--
-- Name: pools_posts_prev_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY pools_posts
    ADD CONSTRAINT pools_posts_prev_post_id_fkey FOREIGN KEY (prev_post_id) REFERENCES posts(id) ON DELETE SET NULL;


--
-- Name: pools_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY pools
    ADD CONSTRAINT pools_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: post_tag_histories_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY post_tag_histories
    ADD CONSTRAINT post_tag_histories_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- Name: post_votes_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY post_votes
    ADD CONSTRAINT post_votes_post_id_fkey FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE;


--
-- Name: post_votes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY post_votes
    ADD CONSTRAINT post_votes_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: posts_approver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT posts_approver_id_fkey FOREIGN KEY (approver_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- Name: posts_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT posts_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES posts(id) ON DELETE SET NULL;


--
-- Name: tag_aliases_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY tag_aliases
    ADD CONSTRAINT tag_aliases_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: tag_implications_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY tag_implications
    ADD CONSTRAINT tag_implications_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: tag_subscriptions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY tag_subscriptions
    ADD CONSTRAINT tag_subscriptions_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: test_janitors_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY test_janitors
    ADD CONSTRAINT test_janitors_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: user_blacklisted_tags_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY user_blacklisted_tags
    ADD CONSTRAINT user_blacklisted_tags_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: user_records_reported_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY user_records
    ADD CONSTRAINT user_records_reported_by_fkey FOREIGN KEY (reported_by) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: user_records_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: albert
--

ALTER TABLE ONLY user_records
    ADD CONSTRAINT user_records_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

