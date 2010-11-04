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
-- Name: advertisement_hits; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE advertisement_hits (
    id integer NOT NULL,
    advertisement_id integer NOT NULL,
    ip_addr inet NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: advertisement_hits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE advertisement_hits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: advertisement_hits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE advertisement_hits_id_seq OWNED BY advertisement_hits.id;


--
-- Name: advertisements; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE advertisements (
    id integer NOT NULL,
    referral_url text NOT NULL,
    ad_type character varying(255) NOT NULL,
    status character varying(255) NOT NULL,
    hit_count integer DEFAULT 0 NOT NULL,
    width integer NOT NULL,
    height integer NOT NULL,
    file_name character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: advertisements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE advertisements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: advertisements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE advertisements_id_seq OWNED BY advertisements.id;


--
-- Name: artist_urls; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE artist_urls (
    id integer NOT NULL,
    artist_id integer NOT NULL,
    url text NOT NULL,
    normalized_url text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: artist_urls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE artist_urls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: artist_urls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE artist_urls_id_seq OWNED BY artist_urls.id;


--
-- Name: artist_versions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE artist_versions (
    id integer NOT NULL,
    artist_id integer NOT NULL,
    name character varying(255) NOT NULL,
    updater_id integer NOT NULL,
    updater_ip_addr inet NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    other_names text,
    group_name character varying(255),
    url_string text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: artist_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE artist_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: artist_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE artist_versions_id_seq OWNED BY artist_versions.id;


--
-- Name: artists; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE artists (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    creator_id integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    is_banned boolean DEFAULT false NOT NULL,
    other_names text,
    other_names_index tsvector,
    group_name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: artists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE artists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: artists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE artists_id_seq OWNED BY artists.id;


--
-- Name: bans; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE bans (
    id integer NOT NULL,
    user_id integer,
    reason text NOT NULL,
    banner_id integer NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: bans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: bans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bans_id_seq OWNED BY bans.id;


--
-- Name: comment_votes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE comment_votes (
    id integer NOT NULL,
    comment_id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: comment_votes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE comment_votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: comment_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE comment_votes_id_seq OWNED BY comment_votes.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    post_id integer NOT NULL,
    creator_id integer NOT NULL,
    body text NOT NULL,
    ip_addr inet NOT NULL,
    body_index tsvector NOT NULL,
    score integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

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


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delayed_jobs_id_seq OWNED BY delayed_jobs.id;


--
-- Name: dmails; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE dmails (
    id integer NOT NULL,
    owner_id integer NOT NULL,
    from_id integer NOT NULL,
    to_id integer NOT NULL,
    parent_id integer,
    title character varying(255) NOT NULL,
    body text NOT NULL,
    message_index tsvector NOT NULL,
    is_read boolean DEFAULT false NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: dmails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE dmails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: dmails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE dmails_id_seq OWNED BY dmails.id;


--
-- Name: favorites_0; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_0 (
    id integer NOT NULL,
    post_id integer,
    user_id integer
);


--
-- Name: favorites_0_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_0_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_0_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_0_id_seq OWNED BY favorites_0.id;


--
-- Name: favorites_1; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_1 (
    id integer NOT NULL,
    post_id integer,
    user_id integer
);


--
-- Name: favorites_1_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_1_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_1_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_1_id_seq OWNED BY favorites_1.id;


--
-- Name: favorites_2; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_2 (
    id integer NOT NULL,
    post_id integer,
    user_id integer
);


--
-- Name: favorites_2_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_2_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_2_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_2_id_seq OWNED BY favorites_2.id;


--
-- Name: favorites_3; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_3 (
    id integer NOT NULL,
    post_id integer,
    user_id integer
);


--
-- Name: favorites_3_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_3_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_3_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_3_id_seq OWNED BY favorites_3.id;


--
-- Name: favorites_4; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_4 (
    id integer NOT NULL,
    post_id integer,
    user_id integer
);


--
-- Name: favorites_4_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_4_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_4_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_4_id_seq OWNED BY favorites_4.id;


--
-- Name: favorites_5; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_5 (
    id integer NOT NULL,
    post_id integer,
    user_id integer
);


--
-- Name: favorites_5_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_5_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_5_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_5_id_seq OWNED BY favorites_5.id;


--
-- Name: favorites_6; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_6 (
    id integer NOT NULL,
    post_id integer,
    user_id integer
);


--
-- Name: favorites_6_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_6_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_6_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_6_id_seq OWNED BY favorites_6.id;


--
-- Name: favorites_7; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_7 (
    id integer NOT NULL,
    post_id integer,
    user_id integer
);


--
-- Name: favorites_7_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_7_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_7_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_7_id_seq OWNED BY favorites_7.id;


--
-- Name: favorites_8; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_8 (
    id integer NOT NULL,
    post_id integer,
    user_id integer
);


--
-- Name: favorites_8_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_8_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_8_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_8_id_seq OWNED BY favorites_8.id;


--
-- Name: favorites_9; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_9 (
    id integer NOT NULL,
    post_id integer,
    user_id integer
);


--
-- Name: favorites_9_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_9_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_9_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_9_id_seq OWNED BY favorites_9.id;


--
-- Name: forum_posts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE forum_posts (
    id integer NOT NULL,
    topic_id integer NOT NULL,
    creator_id integer NOT NULL,
    body text NOT NULL,
    text_index tsvector NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: forum_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE forum_posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: forum_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE forum_posts_id_seq OWNED BY forum_posts.id;


--
-- Name: forum_topics; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE forum_topics (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    title character varying(255) NOT NULL,
    response_count integer DEFAULT 0 NOT NULL,
    is_sticky boolean DEFAULT false NOT NULL,
    is_locked boolean DEFAULT false NOT NULL,
    text_index tsvector NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: forum_topics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE forum_topics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: forum_topics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE forum_topics_id_seq OWNED BY forum_topics.id;


--
-- Name: ip_bans; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ip_bans (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    ip_addr inet NOT NULL,
    reason text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: ip_bans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ip_bans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: ip_bans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ip_bans_id_seq OWNED BY ip_bans.id;


--
-- Name: janitor_trials; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE janitor_trials (
    id integer NOT NULL,
    user_id integer NOT NULL,
    promoted_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: janitor_trials_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE janitor_trials_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: janitor_trials_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE janitor_trials_id_seq OWNED BY janitor_trials.id;


--
-- Name: note_versions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE note_versions (
    id integer NOT NULL,
    note_id integer NOT NULL,
    updater_id integer NOT NULL,
    updater_ip_addr inet NOT NULL,
    x integer NOT NULL,
    y integer NOT NULL,
    width integer NOT NULL,
    height integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    body text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: note_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE note_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: note_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE note_versions_id_seq OWNED BY note_versions.id;


--
-- Name: notes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE notes (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    post_id integer NOT NULL,
    x integer NOT NULL,
    y integer NOT NULL,
    width integer NOT NULL,
    height integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    body text NOT NULL,
    text_index tsvector NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE notes_id_seq OWNED BY notes.id;


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
-- Name: post_histories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE post_histories (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    post_id integer NOT NULL,
    revisions text NOT NULL
);


--
-- Name: post_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE post_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: post_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE post_histories_id_seq OWNED BY post_histories.id;


--
-- Name: post_moderation_details; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE post_moderation_details (
    id integer NOT NULL,
    user_id integer NOT NULL,
    post_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: post_moderation_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE post_moderation_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: post_moderation_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE post_moderation_details_id_seq OWNED BY post_moderation_details.id;


--
-- Name: post_votes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE post_votes (
    id integer NOT NULL,
    post_id integer NOT NULL,
    user_id integer NOT NULL,
    score integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: post_votes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE post_votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: post_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE post_votes_id_seq OWNED BY post_votes.id;


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
    image_height integer NOT NULL,
    parent_id integer,
    has_children boolean DEFAULT false NOT NULL
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
-- Name: removed_posts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE removed_posts (
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
    image_height integer NOT NULL,
    parent_id integer,
    has_children boolean DEFAULT false NOT NULL
);


--
-- Name: removed_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE removed_posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: removed_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE removed_posts_id_seq OWNED BY removed_posts.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: tag_aliases; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tag_aliases (
    id integer NOT NULL,
    antecedent_name character varying(255) NOT NULL,
    consequent_name character varying(255) NOT NULL,
    creator_id integer NOT NULL,
    forum_topic_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: tag_aliases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tag_aliases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: tag_aliases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tag_aliases_id_seq OWNED BY tag_aliases.id;


--
-- Name: tag_implications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tag_implications (
    id integer NOT NULL,
    antecedent_name character varying(255) NOT NULL,
    consequent_name character varying(255) NOT NULL,
    descendant_names text NOT NULL,
    creator_id integer NOT NULL,
    forum_topic_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: tag_implications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tag_implications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: tag_implications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tag_implications_id_seq OWNED BY tag_implications.id;


--
-- Name: tag_subscriptions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tag_subscriptions (
    id integer NOT NULL,
    owner_id integer NOT NULL,
    name character varying(255) NOT NULL,
    tag_query character varying(255) NOT NULL,
    post_ids text NOT NULL,
    is_visible_on_profile boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: tag_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tag_subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: tag_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tag_subscriptions_id_seq OWNED BY tag_subscriptions.id;


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
    related_tags_updated_at timestamp without time zone,
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
-- Name: uploads; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE uploads (
    id integer NOT NULL,
    source character varying(255),
    file_path character varying(255),
    content_type character varying(255),
    rating character(1) NOT NULL,
    uploader_id integer NOT NULL,
    uploader_ip_addr inet NOT NULL,
    tag_string text NOT NULL,
    status character varying(255) DEFAULT 'pending'::character varying NOT NULL,
    post_id integer,
    md5_confirmation character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: uploads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE uploads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE uploads_id_seq OWNED BY uploads.id;


--
-- Name: user_feedback; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_feedback (
    id integer NOT NULL,
    user_id integer NOT NULL,
    creator_id integer NOT NULL,
    is_positive boolean NOT NULL,
    body text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: user_feedback_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_feedback_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: user_feedback_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_feedback_id_seq OWNED BY user_feedback.id;


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
    email_verification_key character varying(255),
    inviter_id integer,
    is_banned boolean DEFAULT false NOT NULL,
    is_privileged boolean DEFAULT false NOT NULL,
    is_contributor boolean DEFAULT false NOT NULL,
    is_janitor boolean DEFAULT false NOT NULL,
    is_moderator boolean DEFAULT false NOT NULL,
    is_admin boolean DEFAULT false NOT NULL,
    base_upload_limit integer DEFAULT 10 NOT NULL,
    last_logged_in_at timestamp without time zone,
    last_forum_read_at timestamp without time zone,
    has_mail boolean DEFAULT false NOT NULL,
    receive_email_notifications boolean DEFAULT false NOT NULL,
    comment_threshold integer DEFAULT (-1) NOT NULL,
    always_resize_images boolean DEFAULT false NOT NULL,
    default_image_size character varying(255) DEFAULT 'medium'::character varying NOT NULL,
    favorite_tags text,
    blacklisted_tags text,
    time_zone character varying(255) DEFAULT 'Eastern Time (US & Canada)'::character varying NOT NULL
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
-- Name: wiki_page_versions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE wiki_page_versions (
    id integer NOT NULL,
    wiki_page_id integer NOT NULL,
    updater_id integer NOT NULL,
    updater_ip_addr inet NOT NULL,
    title character varying(255) NOT NULL,
    body text NOT NULL,
    is_locked boolean NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: wiki_page_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE wiki_page_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: wiki_page_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE wiki_page_versions_id_seq OWNED BY wiki_page_versions.id;


--
-- Name: wiki_pages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE wiki_pages (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    title character varying(255) NOT NULL,
    body text NOT NULL,
    body_index tsvector NOT NULL,
    is_locked boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: wiki_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE wiki_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: wiki_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE wiki_pages_id_seq OWNED BY wiki_pages.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE advertisement_hits ALTER COLUMN id SET DEFAULT nextval('advertisement_hits_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE advertisements ALTER COLUMN id SET DEFAULT nextval('advertisements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE artist_urls ALTER COLUMN id SET DEFAULT nextval('artist_urls_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE artist_versions ALTER COLUMN id SET DEFAULT nextval('artist_versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE artists ALTER COLUMN id SET DEFAULT nextval('artists_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE bans ALTER COLUMN id SET DEFAULT nextval('bans_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE comment_votes ALTER COLUMN id SET DEFAULT nextval('comment_votes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE delayed_jobs ALTER COLUMN id SET DEFAULT nextval('delayed_jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE dmails ALTER COLUMN id SET DEFAULT nextval('dmails_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_0 ALTER COLUMN id SET DEFAULT nextval('favorites_0_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_1 ALTER COLUMN id SET DEFAULT nextval('favorites_1_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_2 ALTER COLUMN id SET DEFAULT nextval('favorites_2_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_3 ALTER COLUMN id SET DEFAULT nextval('favorites_3_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_4 ALTER COLUMN id SET DEFAULT nextval('favorites_4_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_5 ALTER COLUMN id SET DEFAULT nextval('favorites_5_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_6 ALTER COLUMN id SET DEFAULT nextval('favorites_6_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_7 ALTER COLUMN id SET DEFAULT nextval('favorites_7_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_8 ALTER COLUMN id SET DEFAULT nextval('favorites_8_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_9 ALTER COLUMN id SET DEFAULT nextval('favorites_9_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE forum_posts ALTER COLUMN id SET DEFAULT nextval('forum_posts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE forum_topics ALTER COLUMN id SET DEFAULT nextval('forum_topics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ip_bans ALTER COLUMN id SET DEFAULT nextval('ip_bans_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE janitor_trials ALTER COLUMN id SET DEFAULT nextval('janitor_trials_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE note_versions ALTER COLUMN id SET DEFAULT nextval('note_versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE notes ALTER COLUMN id SET DEFAULT nextval('notes_id_seq'::regclass);


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

ALTER TABLE post_histories ALTER COLUMN id SET DEFAULT nextval('post_histories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE post_moderation_details ALTER COLUMN id SET DEFAULT nextval('post_moderation_details_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE post_votes ALTER COLUMN id SET DEFAULT nextval('post_votes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE posts ALTER COLUMN id SET DEFAULT nextval('posts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE removed_posts ALTER COLUMN id SET DEFAULT nextval('removed_posts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE tag_aliases ALTER COLUMN id SET DEFAULT nextval('tag_aliases_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE tag_implications ALTER COLUMN id SET DEFAULT nextval('tag_implications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE tag_subscriptions ALTER COLUMN id SET DEFAULT nextval('tag_subscriptions_id_seq'::regclass);


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

ALTER TABLE uploads ALTER COLUMN id SET DEFAULT nextval('uploads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE user_feedback ALTER COLUMN id SET DEFAULT nextval('user_feedback_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE wiki_page_versions ALTER COLUMN id SET DEFAULT nextval('wiki_page_versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE wiki_pages ALTER COLUMN id SET DEFAULT nextval('wiki_pages_id_seq'::regclass);


--
-- Name: advertisement_hits_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY advertisement_hits
    ADD CONSTRAINT advertisement_hits_pkey PRIMARY KEY (id);


--
-- Name: advertisements_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY advertisements
    ADD CONSTRAINT advertisements_pkey PRIMARY KEY (id);


--
-- Name: artist_urls_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY artist_urls
    ADD CONSTRAINT artist_urls_pkey PRIMARY KEY (id);


--
-- Name: artist_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY artist_versions
    ADD CONSTRAINT artist_versions_pkey PRIMARY KEY (id);


--
-- Name: artists_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY artists
    ADD CONSTRAINT artists_pkey PRIMARY KEY (id);


--
-- Name: bans_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bans
    ADD CONSTRAINT bans_pkey PRIMARY KEY (id);


--
-- Name: comment_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comment_votes
    ADD CONSTRAINT comment_votes_pkey PRIMARY KEY (id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: dmails_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY dmails
    ADD CONSTRAINT dmails_pkey PRIMARY KEY (id);


--
-- Name: favorites_0_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_0
    ADD CONSTRAINT favorites_0_pkey PRIMARY KEY (id);


--
-- Name: favorites_1_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_1
    ADD CONSTRAINT favorites_1_pkey PRIMARY KEY (id);


--
-- Name: favorites_2_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_2
    ADD CONSTRAINT favorites_2_pkey PRIMARY KEY (id);


--
-- Name: favorites_3_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_3
    ADD CONSTRAINT favorites_3_pkey PRIMARY KEY (id);


--
-- Name: favorites_4_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_4
    ADD CONSTRAINT favorites_4_pkey PRIMARY KEY (id);


--
-- Name: favorites_5_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_5
    ADD CONSTRAINT favorites_5_pkey PRIMARY KEY (id);


--
-- Name: favorites_6_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_6
    ADD CONSTRAINT favorites_6_pkey PRIMARY KEY (id);


--
-- Name: favorites_7_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_7
    ADD CONSTRAINT favorites_7_pkey PRIMARY KEY (id);


--
-- Name: favorites_8_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_8
    ADD CONSTRAINT favorites_8_pkey PRIMARY KEY (id);


--
-- Name: favorites_9_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_9
    ADD CONSTRAINT favorites_9_pkey PRIMARY KEY (id);


--
-- Name: forum_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY forum_posts
    ADD CONSTRAINT forum_posts_pkey PRIMARY KEY (id);


--
-- Name: forum_topics_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY forum_topics
    ADD CONSTRAINT forum_topics_pkey PRIMARY KEY (id);


--
-- Name: ip_bans_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ip_bans
    ADD CONSTRAINT ip_bans_pkey PRIMARY KEY (id);


--
-- Name: janitor_trials_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY janitor_trials
    ADD CONSTRAINT janitor_trials_pkey PRIMARY KEY (id);


--
-- Name: note_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY note_versions
    ADD CONSTRAINT note_versions_pkey PRIMARY KEY (id);


--
-- Name: notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notes
    ADD CONSTRAINT notes_pkey PRIMARY KEY (id);


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
-- Name: post_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY post_histories
    ADD CONSTRAINT post_histories_pkey PRIMARY KEY (id);


--
-- Name: post_moderation_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY post_moderation_details
    ADD CONSTRAINT post_moderation_details_pkey PRIMARY KEY (id);


--
-- Name: post_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY post_votes
    ADD CONSTRAINT post_votes_pkey PRIMARY KEY (id);


--
-- Name: posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: removed_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY removed_posts
    ADD CONSTRAINT removed_posts_pkey PRIMARY KEY (id);


--
-- Name: tag_aliases_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tag_aliases
    ADD CONSTRAINT tag_aliases_pkey PRIMARY KEY (id);


--
-- Name: tag_implications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tag_implications
    ADD CONSTRAINT tag_implications_pkey PRIMARY KEY (id);


--
-- Name: tag_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tag_subscriptions
    ADD CONSTRAINT tag_subscriptions_pkey PRIMARY KEY (id);


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
-- Name: uploads_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY uploads
    ADD CONSTRAINT uploads_pkey PRIMARY KEY (id);


--
-- Name: user_feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_feedback
    ADD CONSTRAINT user_feedback_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: wiki_page_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY wiki_page_versions
    ADD CONSTRAINT wiki_page_versions_pkey PRIMARY KEY (id);


--
-- Name: wiki_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY wiki_pages
    ADD CONSTRAINT wiki_pages_pkey PRIMARY KEY (id);


--
-- Name: index_advertisement_hits_on_advertisement_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_advertisement_hits_on_advertisement_id ON advertisement_hits USING btree (advertisement_id);


--
-- Name: index_advertisement_hits_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_advertisement_hits_on_created_at ON advertisement_hits USING btree (created_at);


--
-- Name: index_advertisements_on_ad_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_advertisements_on_ad_type ON advertisements USING btree (ad_type);


--
-- Name: index_artist_urls_on_artist_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_artist_urls_on_artist_id ON artist_urls USING btree (artist_id);


--
-- Name: index_artist_urls_on_normalized_url; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_artist_urls_on_normalized_url ON artist_urls USING btree (normalized_url);


--
-- Name: index_artist_versions_on_artist_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_artist_versions_on_artist_id ON artist_versions USING btree (artist_id);


--
-- Name: index_artist_versions_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_artist_versions_on_name ON artist_versions USING btree (name);


--
-- Name: index_artist_versions_on_updater_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_artist_versions_on_updater_id ON artist_versions USING btree (updater_id);


--
-- Name: index_artists_on_group_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_artists_on_group_name ON artists USING btree (group_name);


--
-- Name: index_artists_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_artists_on_name ON artists USING btree (name);


--
-- Name: index_artists_on_other_names_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_artists_on_other_names_index ON artists USING gin (other_names_index);


--
-- Name: index_bans_on_expires_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bans_on_expires_at ON bans USING btree (expires_at);


--
-- Name: index_bans_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bans_on_user_id ON bans USING btree (user_id);


--
-- Name: index_comment_votes_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comment_votes_on_user_id ON comment_votes USING btree (user_id);


--
-- Name: index_comments_on_body_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_body_index ON comments USING gin (body_index);


--
-- Name: index_comments_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_post_id ON comments USING btree (post_id);


--
-- Name: index_delayed_jobs_on_run_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_delayed_jobs_on_run_at ON delayed_jobs USING btree (run_at);


--
-- Name: index_dmails_on_message_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_dmails_on_message_index ON dmails USING gin (message_index);


--
-- Name: index_dmails_on_owner_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_dmails_on_owner_id ON dmails USING btree (owner_id);


--
-- Name: index_dmails_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_dmails_on_parent_id ON dmails USING btree (parent_id);


--
-- Name: index_favorites_0_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_0_on_post_id ON favorites_0 USING btree (post_id);


--
-- Name: index_favorites_0_on_post_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_favorites_0_on_post_id_and_user_id ON favorites_0 USING btree (post_id, user_id);


--
-- Name: index_favorites_0_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_0_on_user_id ON favorites_0 USING btree (user_id);


--
-- Name: index_favorites_1_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_1_on_post_id ON favorites_1 USING btree (post_id);


--
-- Name: index_favorites_1_on_post_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_favorites_1_on_post_id_and_user_id ON favorites_1 USING btree (post_id, user_id);


--
-- Name: index_favorites_1_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_1_on_user_id ON favorites_1 USING btree (user_id);


--
-- Name: index_favorites_2_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_2_on_post_id ON favorites_2 USING btree (post_id);


--
-- Name: index_favorites_2_on_post_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_favorites_2_on_post_id_and_user_id ON favorites_2 USING btree (post_id, user_id);


--
-- Name: index_favorites_2_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_2_on_user_id ON favorites_2 USING btree (user_id);


--
-- Name: index_favorites_3_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_3_on_post_id ON favorites_3 USING btree (post_id);


--
-- Name: index_favorites_3_on_post_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_favorites_3_on_post_id_and_user_id ON favorites_3 USING btree (post_id, user_id);


--
-- Name: index_favorites_3_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_3_on_user_id ON favorites_3 USING btree (user_id);


--
-- Name: index_favorites_4_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_4_on_post_id ON favorites_4 USING btree (post_id);


--
-- Name: index_favorites_4_on_post_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_favorites_4_on_post_id_and_user_id ON favorites_4 USING btree (post_id, user_id);


--
-- Name: index_favorites_4_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_4_on_user_id ON favorites_4 USING btree (user_id);


--
-- Name: index_favorites_5_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_5_on_post_id ON favorites_5 USING btree (post_id);


--
-- Name: index_favorites_5_on_post_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_favorites_5_on_post_id_and_user_id ON favorites_5 USING btree (post_id, user_id);


--
-- Name: index_favorites_5_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_5_on_user_id ON favorites_5 USING btree (user_id);


--
-- Name: index_favorites_6_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_6_on_post_id ON favorites_6 USING btree (post_id);


--
-- Name: index_favorites_6_on_post_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_favorites_6_on_post_id_and_user_id ON favorites_6 USING btree (post_id, user_id);


--
-- Name: index_favorites_6_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_6_on_user_id ON favorites_6 USING btree (user_id);


--
-- Name: index_favorites_7_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_7_on_post_id ON favorites_7 USING btree (post_id);


--
-- Name: index_favorites_7_on_post_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_favorites_7_on_post_id_and_user_id ON favorites_7 USING btree (post_id, user_id);


--
-- Name: index_favorites_7_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_7_on_user_id ON favorites_7 USING btree (user_id);


--
-- Name: index_favorites_8_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_8_on_post_id ON favorites_8 USING btree (post_id);


--
-- Name: index_favorites_8_on_post_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_favorites_8_on_post_id_and_user_id ON favorites_8 USING btree (post_id, user_id);


--
-- Name: index_favorites_8_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_8_on_user_id ON favorites_8 USING btree (user_id);


--
-- Name: index_favorites_9_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_9_on_post_id ON favorites_9 USING btree (post_id);


--
-- Name: index_favorites_9_on_post_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_favorites_9_on_post_id_and_user_id ON favorites_9 USING btree (post_id, user_id);


--
-- Name: index_favorites_9_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_9_on_user_id ON favorites_9 USING btree (user_id);


--
-- Name: index_forum_posts_on_creator_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_forum_posts_on_creator_id ON forum_posts USING btree (creator_id);


--
-- Name: index_forum_posts_on_text_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_forum_posts_on_text_index ON forum_posts USING gin (text_index);


--
-- Name: index_forum_posts_on_topic_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_forum_posts_on_topic_id ON forum_posts USING btree (topic_id);


--
-- Name: index_forum_topics_on_creator_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_forum_topics_on_creator_id ON forum_topics USING btree (creator_id);


--
-- Name: index_forum_topics_on_text_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_forum_topics_on_text_index ON forum_topics USING gin (text_index);


--
-- Name: index_ip_bans_on_ip_addr; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_ip_bans_on_ip_addr ON ip_bans USING btree (ip_addr);


--
-- Name: index_janitor_trials_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_janitor_trials_on_user_id ON janitor_trials USING btree (user_id);


--
-- Name: index_note_versions_on_note_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_note_versions_on_note_id ON note_versions USING btree (note_id);


--
-- Name: index_note_versions_on_updater_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_note_versions_on_updater_id ON note_versions USING btree (updater_id);


--
-- Name: index_notes_on_creator_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_notes_on_creator_id ON notes USING btree (creator_id);


--
-- Name: index_notes_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_notes_on_post_id ON notes USING btree (post_id);


--
-- Name: index_notes_on_text_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_notes_on_text_index ON notes USING gin (text_index);


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
-- Name: index_post_histories_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_post_histories_on_post_id ON post_histories USING btree (post_id);


--
-- Name: index_post_moderation_details_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_post_moderation_details_on_post_id ON post_moderation_details USING btree (post_id);


--
-- Name: index_post_moderation_details_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_post_moderation_details_on_user_id ON post_moderation_details USING btree (user_id);


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
-- Name: index_posts_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_posts_on_parent_id ON posts USING btree (parent_id);


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
-- Name: index_removed_posts_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_removed_posts_on_created_at ON removed_posts USING btree (created_at);


--
-- Name: index_removed_posts_on_file_size; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_removed_posts_on_file_size ON removed_posts USING btree (file_size);


--
-- Name: index_removed_posts_on_image_height; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_removed_posts_on_image_height ON removed_posts USING btree (image_height);


--
-- Name: index_removed_posts_on_image_width; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_removed_posts_on_image_width ON removed_posts USING btree (image_width);


--
-- Name: index_removed_posts_on_last_commented_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_removed_posts_on_last_commented_at ON removed_posts USING btree (last_commented_at);


--
-- Name: index_removed_posts_on_last_noted_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_removed_posts_on_last_noted_at ON removed_posts USING btree (last_noted_at);


--
-- Name: index_removed_posts_on_md5; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_removed_posts_on_md5 ON removed_posts USING btree (md5);


--
-- Name: index_removed_posts_on_mpixels; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_removed_posts_on_mpixels ON posts USING btree (((((image_width * image_height))::numeric / 1000000.0)));


--
-- Name: index_removed_posts_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_removed_posts_on_parent_id ON removed_posts USING btree (parent_id);


--
-- Name: index_removed_posts_on_source; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_removed_posts_on_source ON removed_posts USING btree (source);


--
-- Name: index_removed_posts_on_tags_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_removed_posts_on_tags_index ON posts USING gin (tag_index);


--
-- Name: index_removed_posts_on_view_count; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_removed_posts_on_view_count ON removed_posts USING btree (view_count);


--
-- Name: index_tag_aliases_on_antecedent_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_tag_aliases_on_antecedent_name ON tag_aliases USING btree (antecedent_name);


--
-- Name: index_tag_aliases_on_consequent_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_tag_aliases_on_consequent_name ON tag_aliases USING btree (consequent_name);


--
-- Name: index_tag_implications_on_antecedent_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_tag_implications_on_antecedent_name ON tag_implications USING btree (antecedent_name);


--
-- Name: index_tag_implications_on_consequent_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_tag_implications_on_consequent_name ON tag_implications USING btree (consequent_name);


--
-- Name: index_tag_subscriptions_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_tag_subscriptions_on_name ON tag_subscriptions USING btree (name);


--
-- Name: index_tag_subscriptions_on_owner_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_tag_subscriptions_on_owner_id ON tag_subscriptions USING btree (owner_id);


--
-- Name: index_tags_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_tags_on_name ON tags USING btree (name);


--
-- Name: index_unapprovals_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_unapprovals_on_post_id ON unapprovals USING btree (post_id);


--
-- Name: index_user_feedback_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_feedback_on_user_id ON user_feedback USING btree (user_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_name ON users USING btree (lower((name)::text));


--
-- Name: index_wiki_page_versions_on_wiki_page_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_wiki_page_versions_on_wiki_page_id ON wiki_page_versions USING btree (wiki_page_id);


--
-- Name: index_wiki_pages_on_body_index_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_wiki_pages_on_body_index_index ON wiki_pages USING gin (body_index);


--
-- Name: index_wiki_pages_on_title; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_wiki_pages_on_title ON wiki_pages USING btree (title);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: trigger_artists_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_artists_on_update
    BEFORE INSERT OR UPDATE ON artists
    FOR EACH ROW
    EXECUTE PROCEDURE tsvector_update_trigger('other_names_index', 'public.danbooru', 'other_names');


--
-- Name: trigger_comments_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_comments_on_update
    BEFORE INSERT OR UPDATE ON comments
    FOR EACH ROW
    EXECUTE PROCEDURE tsvector_update_trigger('body_index', 'pg_catalog.english', 'body');


--
-- Name: trigger_dmails_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_dmails_on_update
    BEFORE INSERT OR UPDATE ON dmails
    FOR EACH ROW
    EXECUTE PROCEDURE tsvector_update_trigger('message_index', 'pg_catalog.english', 'title', 'body');


--
-- Name: trigger_forum_posts_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_forum_posts_on_update
    BEFORE INSERT OR UPDATE ON forum_posts
    FOR EACH ROW
    EXECUTE PROCEDURE tsvector_update_trigger('text_index', 'pg_catalog.english', 'body');


--
-- Name: trigger_forum_topics_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_forum_topics_on_update
    BEFORE INSERT OR UPDATE ON forum_topics
    FOR EACH ROW
    EXECUTE PROCEDURE tsvector_update_trigger('text_index', 'pg_catalog.english', 'title');


--
-- Name: trigger_notes_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_notes_on_update
    BEFORE INSERT OR UPDATE ON notes
    FOR EACH ROW
    EXECUTE PROCEDURE tsvector_update_trigger('text_index', 'pg_catalog.english', 'body');


--
-- Name: trigger_posts_on_tag_index_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_posts_on_tag_index_update
    BEFORE INSERT OR UPDATE ON posts
    FOR EACH ROW
    EXECUTE PROCEDURE tsvector_update_trigger('tag_index', 'public.danbooru', 'tag_string', 'fav_string', 'pool_string', 'uploader_string', 'approver_string');


--
-- Name: trigger_removed_posts_on_tag_index_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_removed_posts_on_tag_index_update
    BEFORE INSERT OR UPDATE ON removed_posts
    FOR EACH ROW
    EXECUTE PROCEDURE tsvector_update_trigger('tag_index', 'public.danbooru', 'tag_string', 'fav_string', 'pool_string', 'uploader_string', 'approver_string');


--
-- Name: trigger_wiki_pages_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_wiki_pages_on_update
    BEFORE INSERT OR UPDATE ON wiki_pages
    FOR EACH ROW
    EXECUTE PROCEDURE tsvector_update_trigger('body_index', 'public.danbooru', 'body', 'title');


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

INSERT INTO schema_migrations (version) VALUES ('20100211181944');

INSERT INTO schema_migrations (version) VALUES ('20100211191709');

INSERT INTO schema_migrations (version) VALUES ('20100211191716');

INSERT INTO schema_migrations (version) VALUES ('20100213181847');

INSERT INTO schema_migrations (version) VALUES ('20100213183712');

INSERT INTO schema_migrations (version) VALUES ('20100214080549');

INSERT INTO schema_migrations (version) VALUES ('20100214080557');

INSERT INTO schema_migrations (version) VALUES ('20100214080605');

INSERT INTO schema_migrations (version) VALUES ('20100215182234');

INSERT INTO schema_migrations (version) VALUES ('20100215213756');

INSERT INTO schema_migrations (version) VALUES ('20100215223541');

INSERT INTO schema_migrations (version) VALUES ('20100215224629');

INSERT INTO schema_migrations (version) VALUES ('20100215224635');

INSERT INTO schema_migrations (version) VALUES ('20100215225710');

INSERT INTO schema_migrations (version) VALUES ('20100215230642');

INSERT INTO schema_migrations (version) VALUES ('20100219230537');

INSERT INTO schema_migrations (version) VALUES ('20100221003655');

INSERT INTO schema_migrations (version) VALUES ('20100221005812');

INSERT INTO schema_migrations (version) VALUES ('20100223001012');

INSERT INTO schema_migrations (version) VALUES ('20100224171915');

INSERT INTO schema_migrations (version) VALUES ('20100224172146');

INSERT INTO schema_migrations (version) VALUES ('20100307073438');

INSERT INTO schema_migrations (version) VALUES ('20100309211553');

INSERT INTO schema_migrations (version) VALUES ('20100318213503');

INSERT INTO schema_migrations (version) VALUES ('20100818180317');

INSERT INTO schema_migrations (version) VALUES ('20100826232512');