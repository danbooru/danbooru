--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.6
-- Dumped by pg_dump version 9.6.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


SET search_path = public, pg_catalog;

--
-- Name: favorites_insert_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

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


--
-- Name: sourcepattern(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION sourcepattern(src text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $_$
               BEGIN
                 RETURN regexp_replace(src, '^[^/]*(//)?[^/]*.pixiv.net/img.*(/[^/]*/[^/]*)$', E'pixiv\\2');
               END;
             $_$;


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
-- Name: advertisement_hits; Type: TABLE; Schema: public; Owner: -
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
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: advertisement_hits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE advertisement_hits_id_seq OWNED BY advertisement_hits.id;


--
-- Name: advertisements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE advertisements (
    id integer NOT NULL,
    referral_url text NOT NULL,
    ad_type character varying NOT NULL,
    status character varying NOT NULL,
    hit_count integer DEFAULT 0 NOT NULL,
    width integer NOT NULL,
    height integer NOT NULL,
    file_name character varying NOT NULL,
    is_work_safe boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: advertisements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE advertisements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: advertisements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE advertisements_id_seq OWNED BY advertisements.id;


--
-- Name: amazon_backups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE amazon_backups (
    id integer NOT NULL,
    last_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: amazon_backups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE amazon_backups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: amazon_backups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE amazon_backups_id_seq OWNED BY amazon_backups.id;


--
-- Name: anti_voters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE anti_voters (
    id integer NOT NULL,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: anti_voters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE anti_voters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: anti_voters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE anti_voters_id_seq OWNED BY anti_voters.id;


--
-- Name: api_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE api_keys (
    id integer NOT NULL,
    user_id integer NOT NULL,
    key character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: api_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE api_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: api_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE api_keys_id_seq OWNED BY api_keys.id;


--
-- Name: artist_commentaries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE artist_commentaries (
    id integer NOT NULL,
    post_id integer NOT NULL,
    original_title text DEFAULT ''::text NOT NULL,
    original_description text DEFAULT ''::text NOT NULL,
    translated_title text DEFAULT ''::text NOT NULL,
    translated_description text DEFAULT ''::text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: artist_commentaries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE artist_commentaries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: artist_commentaries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE artist_commentaries_id_seq OWNED BY artist_commentaries.id;


--
-- Name: artist_commentary_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE artist_commentary_versions (
    id integer NOT NULL,
    post_id integer NOT NULL,
    updater_id integer NOT NULL,
    updater_ip_addr inet NOT NULL,
    original_title text,
    original_description text,
    translated_title text,
    translated_description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: artist_commentary_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE artist_commentary_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: artist_commentary_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE artist_commentary_versions_id_seq OWNED BY artist_commentary_versions.id;


--
-- Name: artist_urls; Type: TABLE; Schema: public; Owner: -
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
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: artist_urls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE artist_urls_id_seq OWNED BY artist_urls.id;


--
-- Name: artist_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE artist_versions (
    id integer NOT NULL,
    artist_id integer NOT NULL,
    name character varying NOT NULL,
    updater_id integer NOT NULL,
    updater_ip_addr inet NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    other_names text,
    group_name character varying,
    url_string text,
    is_banned boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: artist_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE artist_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: artist_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE artist_versions_id_seq OWNED BY artist_versions.id;


--
-- Name: artists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE artists (
    id integer NOT NULL,
    name character varying NOT NULL,
    creator_id integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    is_banned boolean DEFAULT false NOT NULL,
    other_names text,
    other_names_index tsvector,
    group_name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: artists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE artists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: artists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE artists_id_seq OWNED BY artists.id;


--
-- Name: bans; Type: TABLE; Schema: public; Owner: -
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
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bans_id_seq OWNED BY bans.id;


--
-- Name: bulk_update_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE bulk_update_requests (
    id integer NOT NULL,
    user_id integer NOT NULL,
    forum_topic_id integer,
    script text NOT NULL,
    status character varying DEFAULT 'pending'::character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    approver_id integer,
    forum_post_id integer,
    title text
);


--
-- Name: bulk_update_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bulk_update_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bulk_update_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bulk_update_requests_id_seq OWNED BY bulk_update_requests.id;


--
-- Name: comment_votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE comment_votes (
    id integer NOT NULL,
    comment_id integer NOT NULL,
    user_id integer NOT NULL,
    score integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: comment_votes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE comment_votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comment_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE comment_votes_id_seq OWNED BY comment_votes.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
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
    updated_at timestamp without time zone,
    updater_id integer,
    updater_ip_addr inet,
    do_not_bump_post boolean DEFAULT false NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    is_sticky boolean DEFAULT false NOT NULL
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -
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
    locked_by character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    queue character varying
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delayed_jobs_id_seq OWNED BY delayed_jobs.id;


--
-- Name: dmail_filters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE dmail_filters (
    id integer NOT NULL,
    user_id integer NOT NULL,
    words text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: dmail_filters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE dmail_filters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dmail_filters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE dmail_filters_id_seq OWNED BY dmail_filters.id;


--
-- Name: dmails; Type: TABLE; Schema: public; Owner: -
--

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
    updated_at timestamp without time zone,
    creator_ip_addr inet NOT NULL,
    is_spam boolean DEFAULT false
);


--
-- Name: dmails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE dmails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dmails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE dmails_id_seq OWNED BY dmails.id;


--
-- Name: favorite_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorite_groups (
    id integer NOT NULL,
    name text NOT NULL,
    creator_id integer NOT NULL,
    post_ids text DEFAULT ''::text NOT NULL,
    post_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    is_public boolean DEFAULT false NOT NULL
);


--
-- Name: favorite_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorite_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: favorite_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorite_groups_id_seq OWNED BY favorite_groups.id;


--
-- Name: favorites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_0; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_0 (
    CONSTRAINT favorites_0_user_id_check CHECK (((user_id % 100) = 0))
)
INHERITS (favorites);


--
-- Name: favorites_1; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_1 (
    CONSTRAINT favorites_1_user_id_check CHECK (((user_id % 100) = 1))
)
INHERITS (favorites);


--
-- Name: favorites_10; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_10 (
    CONSTRAINT favorites_10_user_id_check CHECK (((user_id % 100) = 10))
)
INHERITS (favorites);


--
-- Name: favorites_11; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_11 (
    CONSTRAINT favorites_11_user_id_check CHECK (((user_id % 100) = 11))
)
INHERITS (favorites);


--
-- Name: favorites_12; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_12 (
    CONSTRAINT favorites_12_user_id_check CHECK (((user_id % 100) = 12))
)
INHERITS (favorites);


--
-- Name: favorites_13; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_13 (
    CONSTRAINT favorites_13_user_id_check CHECK (((user_id % 100) = 13))
)
INHERITS (favorites);


--
-- Name: favorites_14; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_14 (
    CONSTRAINT favorites_14_user_id_check CHECK (((user_id % 100) = 14))
)
INHERITS (favorites);


--
-- Name: favorites_15; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_15 (
    CONSTRAINT favorites_15_user_id_check CHECK (((user_id % 100) = 15))
)
INHERITS (favorites);


--
-- Name: favorites_16; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_16 (
    CONSTRAINT favorites_16_user_id_check CHECK (((user_id % 100) = 16))
)
INHERITS (favorites);


--
-- Name: favorites_17; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_17 (
    CONSTRAINT favorites_17_user_id_check CHECK (((user_id % 100) = 17))
)
INHERITS (favorites);


--
-- Name: favorites_18; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_18 (
    CONSTRAINT favorites_18_user_id_check CHECK (((user_id % 100) = 18))
)
INHERITS (favorites);


--
-- Name: favorites_19; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_19 (
    CONSTRAINT favorites_19_user_id_check CHECK (((user_id % 100) = 19))
)
INHERITS (favorites);


--
-- Name: favorites_2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_2 (
    CONSTRAINT favorites_2_user_id_check CHECK (((user_id % 100) = 2))
)
INHERITS (favorites);


--
-- Name: favorites_20; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_20 (
    CONSTRAINT favorites_20_user_id_check CHECK (((user_id % 100) = 20))
)
INHERITS (favorites);


--
-- Name: favorites_21; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_21 (
    CONSTRAINT favorites_21_user_id_check CHECK (((user_id % 100) = 21))
)
INHERITS (favorites);


--
-- Name: favorites_22; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_22 (
    CONSTRAINT favorites_22_user_id_check CHECK (((user_id % 100) = 22))
)
INHERITS (favorites);


--
-- Name: favorites_23; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_23 (
    CONSTRAINT favorites_23_user_id_check CHECK (((user_id % 100) = 23))
)
INHERITS (favorites);


--
-- Name: favorites_24; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_24 (
    CONSTRAINT favorites_24_user_id_check CHECK (((user_id % 100) = 24))
)
INHERITS (favorites);


--
-- Name: favorites_25; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_25 (
    CONSTRAINT favorites_25_user_id_check CHECK (((user_id % 100) = 25))
)
INHERITS (favorites);


--
-- Name: favorites_26; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_26 (
    CONSTRAINT favorites_26_user_id_check CHECK (((user_id % 100) = 26))
)
INHERITS (favorites);


--
-- Name: favorites_27; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_27 (
    CONSTRAINT favorites_27_user_id_check CHECK (((user_id % 100) = 27))
)
INHERITS (favorites);


--
-- Name: favorites_28; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_28 (
    CONSTRAINT favorites_28_user_id_check CHECK (((user_id % 100) = 28))
)
INHERITS (favorites);


--
-- Name: favorites_29; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_29 (
    CONSTRAINT favorites_29_user_id_check CHECK (((user_id % 100) = 29))
)
INHERITS (favorites);


--
-- Name: favorites_3; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_3 (
    CONSTRAINT favorites_3_user_id_check CHECK (((user_id % 100) = 3))
)
INHERITS (favorites);


--
-- Name: favorites_30; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_30 (
    CONSTRAINT favorites_30_user_id_check CHECK (((user_id % 100) = 30))
)
INHERITS (favorites);


--
-- Name: favorites_31; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_31 (
    CONSTRAINT favorites_31_user_id_check CHECK (((user_id % 100) = 31))
)
INHERITS (favorites);


--
-- Name: favorites_32; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_32 (
    CONSTRAINT favorites_32_user_id_check CHECK (((user_id % 100) = 32))
)
INHERITS (favorites);


--
-- Name: favorites_33; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_33 (
    CONSTRAINT favorites_33_user_id_check CHECK (((user_id % 100) = 33))
)
INHERITS (favorites);


--
-- Name: favorites_34; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_34 (
    CONSTRAINT favorites_34_user_id_check CHECK (((user_id % 100) = 34))
)
INHERITS (favorites);


--
-- Name: favorites_35; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_35 (
    CONSTRAINT favorites_35_user_id_check CHECK (((user_id % 100) = 35))
)
INHERITS (favorites);


--
-- Name: favorites_36; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_36 (
    CONSTRAINT favorites_36_user_id_check CHECK (((user_id % 100) = 36))
)
INHERITS (favorites);


--
-- Name: favorites_37; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_37 (
    CONSTRAINT favorites_37_user_id_check CHECK (((user_id % 100) = 37))
)
INHERITS (favorites);


--
-- Name: favorites_38; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_38 (
    CONSTRAINT favorites_38_user_id_check CHECK (((user_id % 100) = 38))
)
INHERITS (favorites);


--
-- Name: favorites_39; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_39 (
    CONSTRAINT favorites_39_user_id_check CHECK (((user_id % 100) = 39))
)
INHERITS (favorites);


--
-- Name: favorites_4; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_4 (
    CONSTRAINT favorites_4_user_id_check CHECK (((user_id % 100) = 4))
)
INHERITS (favorites);


--
-- Name: favorites_40; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_40 (
    CONSTRAINT favorites_40_user_id_check CHECK (((user_id % 100) = 40))
)
INHERITS (favorites);


--
-- Name: favorites_41; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_41 (
    CONSTRAINT favorites_41_user_id_check CHECK (((user_id % 100) = 41))
)
INHERITS (favorites);


--
-- Name: favorites_42; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_42 (
    CONSTRAINT favorites_42_user_id_check CHECK (((user_id % 100) = 42))
)
INHERITS (favorites);


--
-- Name: favorites_43; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_43 (
    CONSTRAINT favorites_43_user_id_check CHECK (((user_id % 100) = 43))
)
INHERITS (favorites);


--
-- Name: favorites_44; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_44 (
    CONSTRAINT favorites_44_user_id_check CHECK (((user_id % 100) = 44))
)
INHERITS (favorites);


--
-- Name: favorites_45; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_45 (
    CONSTRAINT favorites_45_user_id_check CHECK (((user_id % 100) = 45))
)
INHERITS (favorites);


--
-- Name: favorites_46; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_46 (
    CONSTRAINT favorites_46_user_id_check CHECK (((user_id % 100) = 46))
)
INHERITS (favorites);


--
-- Name: favorites_47; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_47 (
    CONSTRAINT favorites_47_user_id_check CHECK (((user_id % 100) = 47))
)
INHERITS (favorites);


--
-- Name: favorites_48; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_48 (
    CONSTRAINT favorites_48_user_id_check CHECK (((user_id % 100) = 48))
)
INHERITS (favorites);


--
-- Name: favorites_49; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_49 (
    CONSTRAINT favorites_49_user_id_check CHECK (((user_id % 100) = 49))
)
INHERITS (favorites);


--
-- Name: favorites_5; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_5 (
    CONSTRAINT favorites_5_user_id_check CHECK (((user_id % 100) = 5))
)
INHERITS (favorites);


--
-- Name: favorites_50; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_50 (
    CONSTRAINT favorites_50_user_id_check CHECK (((user_id % 100) = 50))
)
INHERITS (favorites);


--
-- Name: favorites_51; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_51 (
    CONSTRAINT favorites_51_user_id_check CHECK (((user_id % 100) = 51))
)
INHERITS (favorites);


--
-- Name: favorites_52; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_52 (
    CONSTRAINT favorites_52_user_id_check CHECK (((user_id % 100) = 52))
)
INHERITS (favorites);


--
-- Name: favorites_53; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_53 (
    CONSTRAINT favorites_53_user_id_check CHECK (((user_id % 100) = 53))
)
INHERITS (favorites);


--
-- Name: favorites_54; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_54 (
    CONSTRAINT favorites_54_user_id_check CHECK (((user_id % 100) = 54))
)
INHERITS (favorites);


--
-- Name: favorites_55; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_55 (
    CONSTRAINT favorites_55_user_id_check CHECK (((user_id % 100) = 55))
)
INHERITS (favorites);


--
-- Name: favorites_56; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_56 (
    CONSTRAINT favorites_56_user_id_check CHECK (((user_id % 100) = 56))
)
INHERITS (favorites);


--
-- Name: favorites_57; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_57 (
    CONSTRAINT favorites_57_user_id_check CHECK (((user_id % 100) = 57))
)
INHERITS (favorites);


--
-- Name: favorites_58; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_58 (
    CONSTRAINT favorites_58_user_id_check CHECK (((user_id % 100) = 58))
)
INHERITS (favorites);


--
-- Name: favorites_59; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_59 (
    CONSTRAINT favorites_59_user_id_check CHECK (((user_id % 100) = 59))
)
INHERITS (favorites);


--
-- Name: favorites_6; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_6 (
    CONSTRAINT favorites_6_user_id_check CHECK (((user_id % 100) = 6))
)
INHERITS (favorites);


--
-- Name: favorites_60; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_60 (
    CONSTRAINT favorites_60_user_id_check CHECK (((user_id % 100) = 60))
)
INHERITS (favorites);


--
-- Name: favorites_61; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_61 (
    CONSTRAINT favorites_61_user_id_check CHECK (((user_id % 100) = 61))
)
INHERITS (favorites);


--
-- Name: favorites_62; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_62 (
    CONSTRAINT favorites_62_user_id_check CHECK (((user_id % 100) = 62))
)
INHERITS (favorites);


--
-- Name: favorites_63; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_63 (
    CONSTRAINT favorites_63_user_id_check CHECK (((user_id % 100) = 63))
)
INHERITS (favorites);


--
-- Name: favorites_64; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_64 (
    CONSTRAINT favorites_64_user_id_check CHECK (((user_id % 100) = 64))
)
INHERITS (favorites);


--
-- Name: favorites_65; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_65 (
    CONSTRAINT favorites_65_user_id_check CHECK (((user_id % 100) = 65))
)
INHERITS (favorites);


--
-- Name: favorites_66; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_66 (
    CONSTRAINT favorites_66_user_id_check CHECK (((user_id % 100) = 66))
)
INHERITS (favorites);


--
-- Name: favorites_67; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_67 (
    CONSTRAINT favorites_67_user_id_check CHECK (((user_id % 100) = 67))
)
INHERITS (favorites);


--
-- Name: favorites_68; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_68 (
    CONSTRAINT favorites_68_user_id_check CHECK (((user_id % 100) = 68))
)
INHERITS (favorites);


--
-- Name: favorites_69; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_69 (
    CONSTRAINT favorites_69_user_id_check CHECK (((user_id % 100) = 69))
)
INHERITS (favorites);


--
-- Name: favorites_7; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_7 (
    CONSTRAINT favorites_7_user_id_check CHECK (((user_id % 100) = 7))
)
INHERITS (favorites);


--
-- Name: favorites_70; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_70 (
    CONSTRAINT favorites_70_user_id_check CHECK (((user_id % 100) = 70))
)
INHERITS (favorites);


--
-- Name: favorites_71; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_71 (
    CONSTRAINT favorites_71_user_id_check CHECK (((user_id % 100) = 71))
)
INHERITS (favorites);


--
-- Name: favorites_72; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_72 (
    CONSTRAINT favorites_72_user_id_check CHECK (((user_id % 100) = 72))
)
INHERITS (favorites);


--
-- Name: favorites_73; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_73 (
    CONSTRAINT favorites_73_user_id_check CHECK (((user_id % 100) = 73))
)
INHERITS (favorites);


--
-- Name: favorites_74; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_74 (
    CONSTRAINT favorites_74_user_id_check CHECK (((user_id % 100) = 74))
)
INHERITS (favorites);


--
-- Name: favorites_75; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_75 (
    CONSTRAINT favorites_75_user_id_check CHECK (((user_id % 100) = 75))
)
INHERITS (favorites);


--
-- Name: favorites_76; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_76 (
    CONSTRAINT favorites_76_user_id_check CHECK (((user_id % 100) = 76))
)
INHERITS (favorites);


--
-- Name: favorites_77; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_77 (
    CONSTRAINT favorites_77_user_id_check CHECK (((user_id % 100) = 77))
)
INHERITS (favorites);


--
-- Name: favorites_78; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_78 (
    CONSTRAINT favorites_78_user_id_check CHECK (((user_id % 100) = 78))
)
INHERITS (favorites);


--
-- Name: favorites_79; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_79 (
    CONSTRAINT favorites_79_user_id_check CHECK (((user_id % 100) = 79))
)
INHERITS (favorites);


--
-- Name: favorites_8; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_8 (
    CONSTRAINT favorites_8_user_id_check CHECK (((user_id % 100) = 8))
)
INHERITS (favorites);


--
-- Name: favorites_80; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_80 (
    CONSTRAINT favorites_80_user_id_check CHECK (((user_id % 100) = 80))
)
INHERITS (favorites);


--
-- Name: favorites_81; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_81 (
    CONSTRAINT favorites_81_user_id_check CHECK (((user_id % 100) = 81))
)
INHERITS (favorites);


--
-- Name: favorites_82; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_82 (
    CONSTRAINT favorites_82_user_id_check CHECK (((user_id % 100) = 82))
)
INHERITS (favorites);


--
-- Name: favorites_83; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_83 (
    CONSTRAINT favorites_83_user_id_check CHECK (((user_id % 100) = 83))
)
INHERITS (favorites);


--
-- Name: favorites_84; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_84 (
    CONSTRAINT favorites_84_user_id_check CHECK (((user_id % 100) = 84))
)
INHERITS (favorites);


--
-- Name: favorites_85; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_85 (
    CONSTRAINT favorites_85_user_id_check CHECK (((user_id % 100) = 85))
)
INHERITS (favorites);


--
-- Name: favorites_86; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_86 (
    CONSTRAINT favorites_86_user_id_check CHECK (((user_id % 100) = 86))
)
INHERITS (favorites);


--
-- Name: favorites_87; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_87 (
    CONSTRAINT favorites_87_user_id_check CHECK (((user_id % 100) = 87))
)
INHERITS (favorites);


--
-- Name: favorites_88; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_88 (
    CONSTRAINT favorites_88_user_id_check CHECK (((user_id % 100) = 88))
)
INHERITS (favorites);


--
-- Name: favorites_89; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_89 (
    CONSTRAINT favorites_89_user_id_check CHECK (((user_id % 100) = 89))
)
INHERITS (favorites);


--
-- Name: favorites_9; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_9 (
    CONSTRAINT favorites_9_user_id_check CHECK (((user_id % 100) = 9))
)
INHERITS (favorites);


--
-- Name: favorites_90; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_90 (
    CONSTRAINT favorites_90_user_id_check CHECK (((user_id % 100) = 90))
)
INHERITS (favorites);


--
-- Name: favorites_91; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_91 (
    CONSTRAINT favorites_91_user_id_check CHECK (((user_id % 100) = 91))
)
INHERITS (favorites);


--
-- Name: favorites_92; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_92 (
    CONSTRAINT favorites_92_user_id_check CHECK (((user_id % 100) = 92))
)
INHERITS (favorites);


--
-- Name: favorites_93; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_93 (
    CONSTRAINT favorites_93_user_id_check CHECK (((user_id % 100) = 93))
)
INHERITS (favorites);


--
-- Name: favorites_94; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_94 (
    CONSTRAINT favorites_94_user_id_check CHECK (((user_id % 100) = 94))
)
INHERITS (favorites);


--
-- Name: favorites_95; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_95 (
    CONSTRAINT favorites_95_user_id_check CHECK (((user_id % 100) = 95))
)
INHERITS (favorites);


--
-- Name: favorites_96; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_96 (
    CONSTRAINT favorites_96_user_id_check CHECK (((user_id % 100) = 96))
)
INHERITS (favorites);


--
-- Name: favorites_97; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_97 (
    CONSTRAINT favorites_97_user_id_check CHECK (((user_id % 100) = 97))
)
INHERITS (favorites);


--
-- Name: favorites_98; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_98 (
    CONSTRAINT favorites_98_user_id_check CHECK (((user_id % 100) = 98))
)
INHERITS (favorites);


--
-- Name: favorites_99; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE favorites_99 (
    CONSTRAINT favorites_99_user_id_check CHECK (((user_id % 100) = 99))
)
INHERITS (favorites);


--
-- Name: favorites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: favorites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_id_seq OWNED BY favorites.id;


--
-- Name: forum_posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE forum_posts (
    id integer NOT NULL,
    topic_id integer NOT NULL,
    creator_id integer NOT NULL,
    updater_id integer NOT NULL,
    body text NOT NULL,
    text_index tsvector NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: forum_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE forum_posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forum_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE forum_posts_id_seq OWNED BY forum_posts.id;


--
-- Name: forum_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE forum_subscriptions (
    id integer NOT NULL,
    user_id integer,
    forum_topic_id integer,
    last_read_at timestamp without time zone,
    delete_key character varying
);


--
-- Name: forum_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE forum_subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forum_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE forum_subscriptions_id_seq OWNED BY forum_subscriptions.id;


--
-- Name: forum_topic_visits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE forum_topic_visits (
    id integer NOT NULL,
    user_id integer,
    forum_topic_id integer,
    last_read_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: forum_topic_visits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE forum_topic_visits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forum_topic_visits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE forum_topic_visits_id_seq OWNED BY forum_topic_visits.id;


--
-- Name: forum_topics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE forum_topics (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    updater_id integer NOT NULL,
    title character varying NOT NULL,
    response_count integer DEFAULT 0 NOT NULL,
    is_sticky boolean DEFAULT false NOT NULL,
    is_locked boolean DEFAULT false NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    text_index tsvector NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    category_id integer DEFAULT 0 NOT NULL,
    min_level integer DEFAULT 0 NOT NULL
);


--
-- Name: forum_topics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE forum_topics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forum_topics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE forum_topics_id_seq OWNED BY forum_topics.id;


--
-- Name: ip_bans; Type: TABLE; Schema: public; Owner: -
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
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ip_bans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ip_bans_id_seq OWNED BY ip_bans.id;


--
-- Name: janitor_trials; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE janitor_trials (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    user_id integer NOT NULL,
    original_level integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    status character varying DEFAULT 'active'::character varying NOT NULL
);


--
-- Name: janitor_trials_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE janitor_trials_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: janitor_trials_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE janitor_trials_id_seq OWNED BY janitor_trials.id;


--
-- Name: mod_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE mod_actions (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    description text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    category integer
);


--
-- Name: mod_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE mod_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mod_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE mod_actions_id_seq OWNED BY mod_actions.id;


--
-- Name: news_updates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE news_updates (
    id integer NOT NULL,
    message text NOT NULL,
    creator_id integer NOT NULL,
    updater_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: news_updates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE news_updates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: news_updates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE news_updates_id_seq OWNED BY news_updates.id;


--
-- Name: note_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE note_versions (
    id integer NOT NULL,
    note_id integer NOT NULL,
    post_id integer NOT NULL,
    updater_id integer NOT NULL,
    updater_ip_addr inet NOT NULL,
    x integer NOT NULL,
    y integer NOT NULL,
    width integer NOT NULL,
    height integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    body text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    version integer DEFAULT 0 NOT NULL
);


--
-- Name: note_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE note_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: note_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE note_versions_id_seq OWNED BY note_versions.id;


--
-- Name: notes; Type: TABLE; Schema: public; Owner: -
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
    body_index tsvector NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    version integer DEFAULT 0 NOT NULL
);


--
-- Name: notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE notes_id_seq OWNED BY notes.id;


--
-- Name: pixiv_ugoira_frame_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE pixiv_ugoira_frame_data (
    id integer NOT NULL,
    post_id integer,
    data text NOT NULL,
    content_type character varying NOT NULL
);


--
-- Name: pixiv_ugoira_frame_data_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pixiv_ugoira_frame_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pixiv_ugoira_frame_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pixiv_ugoira_frame_data_id_seq OWNED BY pixiv_ugoira_frame_data.id;


--
-- Name: pools; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE pools (
    id integer NOT NULL,
    name character varying,
    creator_id integer NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    post_ids text DEFAULT ''::text NOT NULL,
    post_count integer DEFAULT 0 NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    category character varying DEFAULT 'series'::character varying NOT NULL
);


--
-- Name: pools_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pools_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pools_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pools_id_seq OWNED BY pools.id;


--
-- Name: post_appeals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE post_appeals (
    id integer NOT NULL,
    post_id integer NOT NULL,
    creator_id integer NOT NULL,
    creator_ip_addr inet,
    reason text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: post_appeals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE post_appeals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_appeals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE post_appeals_id_seq OWNED BY post_appeals.id;


--
-- Name: post_approvals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE post_approvals (
    id integer NOT NULL,
    user_id integer NOT NULL,
    post_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: post_approvals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE post_approvals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_approvals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE post_approvals_id_seq OWNED BY post_approvals.id;


--
-- Name: post_disapprovals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE post_disapprovals (
    id integer NOT NULL,
    user_id integer NOT NULL,
    post_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    reason character varying DEFAULT 'legacy'::character varying,
    message text
);


--
-- Name: post_disapprovals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE post_disapprovals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_disapprovals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE post_disapprovals_id_seq OWNED BY post_disapprovals.id;


--
-- Name: post_flags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE post_flags (
    id integer NOT NULL,
    post_id integer NOT NULL,
    creator_id integer NOT NULL,
    creator_ip_addr inet NOT NULL,
    reason text,
    is_resolved boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: post_flags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE post_flags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_flags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE post_flags_id_seq OWNED BY post_flags.id;


--
-- Name: post_replacements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE post_replacements (
    id integer NOT NULL,
    post_id integer NOT NULL,
    creator_id integer NOT NULL,
    original_url text NOT NULL,
    replacement_url text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    file_ext_was character varying,
    file_size_was integer,
    image_width_was integer,
    image_height_was integer,
    md5_was character varying,
    file_ext character varying,
    file_size integer,
    image_width integer,
    image_height integer,
    md5 character varying
);


--
-- Name: post_replacements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE post_replacements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_replacements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE post_replacements_id_seq OWNED BY post_replacements.id;


--
-- Name: post_updates; Type: TABLE; Schema: public; Owner: -
--

CREATE UNLOGGED TABLE post_updates (
    post_id integer
);


--
-- Name: post_votes; Type: TABLE; Schema: public; Owner: -
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
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE post_votes_id_seq OWNED BY post_votes.id;


--
-- Name: posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE posts (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    up_score integer DEFAULT 0 NOT NULL,
    down_score integer DEFAULT 0 NOT NULL,
    score integer DEFAULT 0 NOT NULL,
    source character varying DEFAULT ''::character varying NOT NULL,
    md5 character varying NOT NULL,
    rating character(1) DEFAULT 'q'::bpchar NOT NULL,
    is_note_locked boolean DEFAULT false NOT NULL,
    is_rating_locked boolean DEFAULT false NOT NULL,
    is_status_locked boolean DEFAULT false NOT NULL,
    is_pending boolean DEFAULT false NOT NULL,
    is_flagged boolean DEFAULT false NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    uploader_id integer NOT NULL,
    uploader_ip_addr inet NOT NULL,
    approver_id integer,
    fav_string text DEFAULT ''::text NOT NULL,
    pool_string text DEFAULT ''::text NOT NULL,
    last_noted_at timestamp without time zone,
    last_comment_bumped_at timestamp without time zone,
    fav_count integer DEFAULT 0 NOT NULL,
    tag_string text DEFAULT ''::text NOT NULL,
    tag_index tsvector,
    tag_count integer DEFAULT 0 NOT NULL,
    tag_count_general integer DEFAULT 0 NOT NULL,
    tag_count_artist integer DEFAULT 0 NOT NULL,
    tag_count_character integer DEFAULT 0 NOT NULL,
    tag_count_copyright integer DEFAULT 0 NOT NULL,
    file_ext character varying NOT NULL,
    file_size integer NOT NULL,
    image_width integer NOT NULL,
    image_height integer NOT NULL,
    parent_id integer,
    has_children boolean DEFAULT false NOT NULL,
    is_banned boolean DEFAULT false NOT NULL,
    pixiv_id integer,
    last_commented_at timestamp without time zone,
    has_active_children boolean DEFAULT false,
    bit_flags bigint DEFAULT 0 NOT NULL,
    tag_count_meta integer DEFAULT 0 NOT NULL,
    keeper_data text
);


--
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE posts_id_seq OWNED BY posts.id;


--
-- Name: saved_searches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE saved_searches (
    id integer NOT NULL,
    user_id integer,
    query text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    labels text[] DEFAULT '{}'::text[] NOT NULL
);


--
-- Name: saved_searches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE saved_searches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: saved_searches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE saved_searches_id_seq OWNED BY saved_searches.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: super_voters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE super_voters (
    id integer NOT NULL,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: super_voters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE super_voters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: super_voters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE super_voters_id_seq OWNED BY super_voters.id;


--
-- Name: tag_aliases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tag_aliases (
    id integer NOT NULL,
    antecedent_name character varying NOT NULL,
    consequent_name character varying NOT NULL,
    creator_id integer NOT NULL,
    creator_ip_addr inet NOT NULL,
    forum_topic_id integer,
    status text DEFAULT 'pending'::text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    post_count integer DEFAULT 0 NOT NULL,
    approver_id integer,
    forum_post_id integer
);


--
-- Name: tag_aliases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tag_aliases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tag_aliases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tag_aliases_id_seq OWNED BY tag_aliases.id;


--
-- Name: tag_implications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tag_implications (
    id integer NOT NULL,
    antecedent_name character varying NOT NULL,
    consequent_name character varying NOT NULL,
    descendant_names text NOT NULL,
    creator_id integer NOT NULL,
    creator_ip_addr inet NOT NULL,
    forum_topic_id integer,
    status text DEFAULT 'pending'::text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    approver_id integer,
    forum_post_id integer
);


--
-- Name: tag_implications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tag_implications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tag_implications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tag_implications_id_seq OWNED BY tag_implications.id;


--
-- Name: tag_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tag_subscriptions (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    name character varying NOT NULL,
    tag_query text NOT NULL,
    post_ids text NOT NULL,
    is_public boolean DEFAULT true NOT NULL,
    last_accessed_at timestamp without time zone,
    is_opted_in boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: tag_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tag_subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tag_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tag_subscriptions_id_seq OWNED BY tag_subscriptions.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tags (
    id integer NOT NULL,
    name character varying NOT NULL,
    post_count integer DEFAULT 0 NOT NULL,
    category integer DEFAULT 0 NOT NULL,
    related_tags text,
    related_tags_updated_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_locked boolean DEFAULT false NOT NULL
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: token_buckets; Type: TABLE; Schema: public; Owner: -
--

CREATE UNLOGGED TABLE token_buckets (
    user_id integer,
    last_touched_at timestamp without time zone NOT NULL,
    token_count real NOT NULL
);


--
-- Name: uploads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE uploads (
    id integer NOT NULL,
    source text,
    file_path character varying,
    content_type character varying,
    rating character(1) NOT NULL,
    uploader_id integer NOT NULL,
    uploader_ip_addr inet NOT NULL,
    tag_string text NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    backtrace text,
    post_id integer,
    md5_confirmation character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    server text,
    parent_id integer
);


--
-- Name: uploads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE uploads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE uploads_id_seq OWNED BY uploads.id;


--
-- Name: user_feedback; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE user_feedback (
    id integer NOT NULL,
    user_id integer NOT NULL,
    creator_id integer NOT NULL,
    category character varying NOT NULL,
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
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_feedback_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_feedback_id_seq OWNED BY user_feedback.id;


--
-- Name: user_name_change_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE user_name_change_requests (
    id integer NOT NULL,
    status character varying DEFAULT 'pending'::character varying NOT NULL,
    user_id integer NOT NULL,
    approver_id integer,
    original_name character varying,
    desired_name character varying,
    change_reason text,
    rejection_reason text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: user_name_change_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_name_change_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_name_change_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_name_change_requests_id_seq OWNED BY user_name_change_requests.id;


--
-- Name: user_password_reset_nonces; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE user_password_reset_nonces (
    id integer NOT NULL,
    key character varying NOT NULL,
    email character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: user_password_reset_nonces_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_password_reset_nonces_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_password_reset_nonces_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_password_reset_nonces_id_seq OWNED BY user_password_reset_nonces.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name character varying NOT NULL,
    password_hash character varying NOT NULL,
    email character varying,
    email_verification_key character varying,
    inviter_id integer,
    level integer DEFAULT 0 NOT NULL,
    base_upload_limit integer DEFAULT 10 NOT NULL,
    last_logged_in_at timestamp without time zone,
    last_forum_read_at timestamp without time zone,
    recent_tags text,
    post_upload_count integer DEFAULT 0 NOT NULL,
    post_update_count integer DEFAULT 0 NOT NULL,
    note_update_count integer DEFAULT 0 NOT NULL,
    favorite_count integer DEFAULT 0 NOT NULL,
    comment_threshold integer DEFAULT '-1'::integer NOT NULL,
    default_image_size character varying DEFAULT 'large'::character varying NOT NULL,
    favorite_tags text,
    blacklisted_tags text DEFAULT 'spoilers
guro
scat
furry -rating:s'::text,
    time_zone character varying DEFAULT 'Eastern Time (US & Canada)'::character varying NOT NULL,
    bcrypt_password_hash text,
    per_page integer DEFAULT 20 NOT NULL,
    custom_style text,
    bit_prefs bigint DEFAULT 0 NOT NULL,
    last_ip_addr inet
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: wiki_page_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE wiki_page_versions (
    id integer NOT NULL,
    wiki_page_id integer NOT NULL,
    updater_id integer NOT NULL,
    updater_ip_addr inet NOT NULL,
    title character varying NOT NULL,
    body text NOT NULL,
    is_locked boolean NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    other_names text,
    is_deleted boolean DEFAULT false NOT NULL
);


--
-- Name: wiki_page_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE wiki_page_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wiki_page_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE wiki_page_versions_id_seq OWNED BY wiki_page_versions.id;


--
-- Name: wiki_pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE wiki_pages (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    title character varying NOT NULL,
    body text NOT NULL,
    body_index tsvector NOT NULL,
    is_locked boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    updater_id integer,
    other_names text,
    other_names_index tsvector,
    is_deleted boolean DEFAULT false NOT NULL
);


--
-- Name: wiki_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE wiki_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wiki_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE wiki_pages_id_seq OWNED BY wiki_pages.id;


--
-- Name: advertisement_hits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY advertisement_hits ALTER COLUMN id SET DEFAULT nextval('advertisement_hits_id_seq'::regclass);


--
-- Name: advertisements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY advertisements ALTER COLUMN id SET DEFAULT nextval('advertisements_id_seq'::regclass);


--
-- Name: amazon_backups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY amazon_backups ALTER COLUMN id SET DEFAULT nextval('amazon_backups_id_seq'::regclass);


--
-- Name: anti_voters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY anti_voters ALTER COLUMN id SET DEFAULT nextval('anti_voters_id_seq'::regclass);


--
-- Name: api_keys id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY api_keys ALTER COLUMN id SET DEFAULT nextval('api_keys_id_seq'::regclass);


--
-- Name: artist_commentaries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY artist_commentaries ALTER COLUMN id SET DEFAULT nextval('artist_commentaries_id_seq'::regclass);


--
-- Name: artist_commentary_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY artist_commentary_versions ALTER COLUMN id SET DEFAULT nextval('artist_commentary_versions_id_seq'::regclass);


--
-- Name: artist_urls id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY artist_urls ALTER COLUMN id SET DEFAULT nextval('artist_urls_id_seq'::regclass);


--
-- Name: artist_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY artist_versions ALTER COLUMN id SET DEFAULT nextval('artist_versions_id_seq'::regclass);


--
-- Name: artists id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY artists ALTER COLUMN id SET DEFAULT nextval('artists_id_seq'::regclass);


--
-- Name: bans id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY bans ALTER COLUMN id SET DEFAULT nextval('bans_id_seq'::regclass);


--
-- Name: bulk_update_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY bulk_update_requests ALTER COLUMN id SET DEFAULT nextval('bulk_update_requests_id_seq'::regclass);


--
-- Name: comment_votes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY comment_votes ALTER COLUMN id SET DEFAULT nextval('comment_votes_id_seq'::regclass);


--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: delayed_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs ALTER COLUMN id SET DEFAULT nextval('delayed_jobs_id_seq'::regclass);


--
-- Name: dmail_filters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY dmail_filters ALTER COLUMN id SET DEFAULT nextval('dmail_filters_id_seq'::regclass);


--
-- Name: dmails id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY dmails ALTER COLUMN id SET DEFAULT nextval('dmails_id_seq'::regclass);


--
-- Name: favorite_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorite_groups ALTER COLUMN id SET DEFAULT nextval('favorite_groups_id_seq'::regclass);


--
-- Name: favorites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_0 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_0 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_1 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_1 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_10 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_10 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_11 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_11 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_12 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_12 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_13 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_13 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_14 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_14 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_15 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_15 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_16 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_16 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_17 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_17 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_18 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_18 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_19 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_19 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_2 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_2 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_20 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_20 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_21 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_21 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_22 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_22 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_23 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_23 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_24 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_24 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_25 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_25 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_26 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_26 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_27 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_27 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_28 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_28 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_29 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_29 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_3 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_3 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_30 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_30 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_31 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_31 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_32 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_32 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_33 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_33 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_34 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_34 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_35 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_35 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_36 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_36 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_37 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_37 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_38 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_38 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_39 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_39 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_4 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_4 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_40 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_40 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_41 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_41 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_42 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_42 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_43 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_43 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_44 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_44 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_45 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_45 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_46 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_46 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_47 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_47 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_48 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_48 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_49 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_49 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_5 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_5 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_50 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_50 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_51 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_51 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_52 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_52 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_53 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_53 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_54 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_54 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_55 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_55 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_56 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_56 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_57 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_57 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_58 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_58 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_59 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_59 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_6 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_6 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_60 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_60 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_61 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_61 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_62 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_62 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_63 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_63 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_64 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_64 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_65 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_65 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_66 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_66 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_67 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_67 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_68 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_68 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_69 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_69 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_7 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_7 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_70 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_70 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_71 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_71 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_72 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_72 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_73 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_73 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_74 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_74 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_75 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_75 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_76 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_76 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_77 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_77 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_78 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_78 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_79 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_79 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_8 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_8 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_80 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_80 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_81 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_81 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_82 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_82 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_83 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_83 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_84 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_84 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_85 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_85 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_86 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_86 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_87 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_87 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_88 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_88 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_89 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_89 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_9 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_9 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_90 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_90 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_91 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_91 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_92 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_92 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_93 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_93 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_94 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_94 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_95 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_95 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_96 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_96 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_97 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_97 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_98 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_98 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: favorites_99 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites_99 ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: forum_posts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY forum_posts ALTER COLUMN id SET DEFAULT nextval('forum_posts_id_seq'::regclass);


--
-- Name: forum_subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY forum_subscriptions ALTER COLUMN id SET DEFAULT nextval('forum_subscriptions_id_seq'::regclass);


--
-- Name: forum_topic_visits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY forum_topic_visits ALTER COLUMN id SET DEFAULT nextval('forum_topic_visits_id_seq'::regclass);


--
-- Name: forum_topics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY forum_topics ALTER COLUMN id SET DEFAULT nextval('forum_topics_id_seq'::regclass);


--
-- Name: ip_bans id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY ip_bans ALTER COLUMN id SET DEFAULT nextval('ip_bans_id_seq'::regclass);


--
-- Name: janitor_trials id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY janitor_trials ALTER COLUMN id SET DEFAULT nextval('janitor_trials_id_seq'::regclass);


--
-- Name: mod_actions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY mod_actions ALTER COLUMN id SET DEFAULT nextval('mod_actions_id_seq'::regclass);


--
-- Name: news_updates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY news_updates ALTER COLUMN id SET DEFAULT nextval('news_updates_id_seq'::regclass);


--
-- Name: note_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY note_versions ALTER COLUMN id SET DEFAULT nextval('note_versions_id_seq'::regclass);


--
-- Name: notes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY notes ALTER COLUMN id SET DEFAULT nextval('notes_id_seq'::regclass);


--
-- Name: pixiv_ugoira_frame_data id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pixiv_ugoira_frame_data ALTER COLUMN id SET DEFAULT nextval('pixiv_ugoira_frame_data_id_seq'::regclass);


--
-- Name: pools id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pools ALTER COLUMN id SET DEFAULT nextval('pools_id_seq'::regclass);


--
-- Name: post_appeals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY post_appeals ALTER COLUMN id SET DEFAULT nextval('post_appeals_id_seq'::regclass);


--
-- Name: post_approvals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY post_approvals ALTER COLUMN id SET DEFAULT nextval('post_approvals_id_seq'::regclass);


--
-- Name: post_disapprovals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY post_disapprovals ALTER COLUMN id SET DEFAULT nextval('post_disapprovals_id_seq'::regclass);


--
-- Name: post_flags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY post_flags ALTER COLUMN id SET DEFAULT nextval('post_flags_id_seq'::regclass);


--
-- Name: post_replacements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY post_replacements ALTER COLUMN id SET DEFAULT nextval('post_replacements_id_seq'::regclass);


--
-- Name: post_votes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY post_votes ALTER COLUMN id SET DEFAULT nextval('post_votes_id_seq'::regclass);


--
-- Name: posts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY posts ALTER COLUMN id SET DEFAULT nextval('posts_id_seq'::regclass);


--
-- Name: saved_searches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY saved_searches ALTER COLUMN id SET DEFAULT nextval('saved_searches_id_seq'::regclass);


--
-- Name: super_voters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY super_voters ALTER COLUMN id SET DEFAULT nextval('super_voters_id_seq'::regclass);


--
-- Name: tag_aliases id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tag_aliases ALTER COLUMN id SET DEFAULT nextval('tag_aliases_id_seq'::regclass);


--
-- Name: tag_implications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tag_implications ALTER COLUMN id SET DEFAULT nextval('tag_implications_id_seq'::regclass);


--
-- Name: tag_subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tag_subscriptions ALTER COLUMN id SET DEFAULT nextval('tag_subscriptions_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: uploads id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY uploads ALTER COLUMN id SET DEFAULT nextval('uploads_id_seq'::regclass);


--
-- Name: user_feedback id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_feedback ALTER COLUMN id SET DEFAULT nextval('user_feedback_id_seq'::regclass);


--
-- Name: user_name_change_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_name_change_requests ALTER COLUMN id SET DEFAULT nextval('user_name_change_requests_id_seq'::regclass);


--
-- Name: user_password_reset_nonces id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_password_reset_nonces ALTER COLUMN id SET DEFAULT nextval('user_password_reset_nonces_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: wiki_page_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY wiki_page_versions ALTER COLUMN id SET DEFAULT nextval('wiki_page_versions_id_seq'::regclass);


--
-- Name: wiki_pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY wiki_pages ALTER COLUMN id SET DEFAULT nextval('wiki_pages_id_seq'::regclass);


--
-- Name: advertisement_hits advertisement_hits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY advertisement_hits
    ADD CONSTRAINT advertisement_hits_pkey PRIMARY KEY (id);


--
-- Name: advertisements advertisements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY advertisements
    ADD CONSTRAINT advertisements_pkey PRIMARY KEY (id);


--
-- Name: amazon_backups amazon_backups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY amazon_backups
    ADD CONSTRAINT amazon_backups_pkey PRIMARY KEY (id);


--
-- Name: anti_voters anti_voters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY anti_voters
    ADD CONSTRAINT anti_voters_pkey PRIMARY KEY (id);


--
-- Name: api_keys api_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY api_keys
    ADD CONSTRAINT api_keys_pkey PRIMARY KEY (id);


--
-- Name: artist_commentaries artist_commentaries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY artist_commentaries
    ADD CONSTRAINT artist_commentaries_pkey PRIMARY KEY (id);


--
-- Name: artist_commentary_versions artist_commentary_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY artist_commentary_versions
    ADD CONSTRAINT artist_commentary_versions_pkey PRIMARY KEY (id);


--
-- Name: artist_urls artist_urls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY artist_urls
    ADD CONSTRAINT artist_urls_pkey PRIMARY KEY (id);


--
-- Name: artist_versions artist_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY artist_versions
    ADD CONSTRAINT artist_versions_pkey PRIMARY KEY (id);


--
-- Name: artists artists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY artists
    ADD CONSTRAINT artists_pkey PRIMARY KEY (id);


--
-- Name: bans bans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bans
    ADD CONSTRAINT bans_pkey PRIMARY KEY (id);


--
-- Name: bulk_update_requests bulk_update_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bulk_update_requests
    ADD CONSTRAINT bulk_update_requests_pkey PRIMARY KEY (id);


--
-- Name: comment_votes comment_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY comment_votes
    ADD CONSTRAINT comment_votes_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: dmail_filters dmail_filters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY dmail_filters
    ADD CONSTRAINT dmail_filters_pkey PRIMARY KEY (id);


--
-- Name: dmails dmails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY dmails
    ADD CONSTRAINT dmails_pkey PRIMARY KEY (id);


--
-- Name: favorite_groups favorite_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorite_groups
    ADD CONSTRAINT favorite_groups_pkey PRIMARY KEY (id);


--
-- Name: favorites favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites
    ADD CONSTRAINT favorites_pkey PRIMARY KEY (id);


--
-- Name: forum_posts forum_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY forum_posts
    ADD CONSTRAINT forum_posts_pkey PRIMARY KEY (id);


--
-- Name: forum_subscriptions forum_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY forum_subscriptions
    ADD CONSTRAINT forum_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: forum_topic_visits forum_topic_visits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY forum_topic_visits
    ADD CONSTRAINT forum_topic_visits_pkey PRIMARY KEY (id);


--
-- Name: forum_topics forum_topics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY forum_topics
    ADD CONSTRAINT forum_topics_pkey PRIMARY KEY (id);


--
-- Name: ip_bans ip_bans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ip_bans
    ADD CONSTRAINT ip_bans_pkey PRIMARY KEY (id);


--
-- Name: janitor_trials janitor_trials_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY janitor_trials
    ADD CONSTRAINT janitor_trials_pkey PRIMARY KEY (id);


--
-- Name: mod_actions mod_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY mod_actions
    ADD CONSTRAINT mod_actions_pkey PRIMARY KEY (id);


--
-- Name: news_updates news_updates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY news_updates
    ADD CONSTRAINT news_updates_pkey PRIMARY KEY (id);


--
-- Name: note_versions note_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY note_versions
    ADD CONSTRAINT note_versions_pkey PRIMARY KEY (id);


--
-- Name: notes notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY notes
    ADD CONSTRAINT notes_pkey PRIMARY KEY (id);


--
-- Name: pixiv_ugoira_frame_data pixiv_ugoira_frame_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pixiv_ugoira_frame_data
    ADD CONSTRAINT pixiv_ugoira_frame_data_pkey PRIMARY KEY (id);


--
-- Name: pools pools_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pools
    ADD CONSTRAINT pools_pkey PRIMARY KEY (id);


--
-- Name: post_appeals post_appeals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY post_appeals
    ADD CONSTRAINT post_appeals_pkey PRIMARY KEY (id);


--
-- Name: post_approvals post_approvals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY post_approvals
    ADD CONSTRAINT post_approvals_pkey PRIMARY KEY (id);


--
-- Name: post_disapprovals post_disapprovals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY post_disapprovals
    ADD CONSTRAINT post_disapprovals_pkey PRIMARY KEY (id);


--
-- Name: post_flags post_flags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY post_flags
    ADD CONSTRAINT post_flags_pkey PRIMARY KEY (id);


--
-- Name: post_replacements post_replacements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY post_replacements
    ADD CONSTRAINT post_replacements_pkey PRIMARY KEY (id);


--
-- Name: post_votes post_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY post_votes
    ADD CONSTRAINT post_votes_pkey PRIMARY KEY (id);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: saved_searches saved_searches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY saved_searches
    ADD CONSTRAINT saved_searches_pkey PRIMARY KEY (id);


--
-- Name: super_voters super_voters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY super_voters
    ADD CONSTRAINT super_voters_pkey PRIMARY KEY (id);


--
-- Name: tag_aliases tag_aliases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tag_aliases
    ADD CONSTRAINT tag_aliases_pkey PRIMARY KEY (id);


--
-- Name: tag_implications tag_implications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tag_implications
    ADD CONSTRAINT tag_implications_pkey PRIMARY KEY (id);


--
-- Name: tag_subscriptions tag_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tag_subscriptions
    ADD CONSTRAINT tag_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: uploads uploads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY uploads
    ADD CONSTRAINT uploads_pkey PRIMARY KEY (id);


--
-- Name: user_feedback user_feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_feedback
    ADD CONSTRAINT user_feedback_pkey PRIMARY KEY (id);


--
-- Name: user_name_change_requests user_name_change_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_name_change_requests
    ADD CONSTRAINT user_name_change_requests_pkey PRIMARY KEY (id);


--
-- Name: user_password_reset_nonces user_password_reset_nonces_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_password_reset_nonces
    ADD CONSTRAINT user_password_reset_nonces_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: wiki_page_versions wiki_page_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY wiki_page_versions
    ADD CONSTRAINT wiki_page_versions_pkey PRIMARY KEY (id);


--
-- Name: wiki_pages wiki_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY wiki_pages
    ADD CONSTRAINT wiki_pages_pkey PRIMARY KEY (id);


--
-- Name: index_advertisement_hits_on_advertisement_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_advertisement_hits_on_advertisement_id ON advertisement_hits USING btree (advertisement_id);


--
-- Name: index_advertisement_hits_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_advertisement_hits_on_created_at ON advertisement_hits USING btree (created_at);


--
-- Name: index_advertisements_on_ad_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_advertisements_on_ad_type ON advertisements USING btree (ad_type);


--
-- Name: index_api_keys_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_api_keys_on_key ON api_keys USING btree (key);


--
-- Name: index_api_keys_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_api_keys_on_user_id ON api_keys USING btree (user_id);


--
-- Name: index_artist_commentaries_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_artist_commentaries_on_post_id ON artist_commentaries USING btree (post_id);


--
-- Name: index_artist_commentary_versions_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_commentary_versions_on_post_id ON artist_commentary_versions USING btree (post_id);


--
-- Name: index_artist_commentary_versions_on_updater_id_and_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_commentary_versions_on_updater_id_and_post_id ON artist_commentary_versions USING btree (updater_id, post_id);


--
-- Name: index_artist_commentary_versions_on_updater_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_commentary_versions_on_updater_ip_addr ON artist_commentary_versions USING btree (updater_ip_addr);


--
-- Name: index_artist_urls_on_artist_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_urls_on_artist_id ON artist_urls USING btree (artist_id);


--
-- Name: index_artist_urls_on_normalized_url; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_urls_on_normalized_url ON artist_urls USING btree (normalized_url);


--
-- Name: index_artist_urls_on_normalized_url_pattern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_urls_on_normalized_url_pattern ON artist_urls USING btree (normalized_url text_pattern_ops);


--
-- Name: index_artist_urls_on_url; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_urls_on_url ON artist_urls USING btree (url);


--
-- Name: index_artist_urls_on_url_pattern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_urls_on_url_pattern ON artist_urls USING btree (url text_pattern_ops);


--
-- Name: index_artist_versions_on_artist_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_versions_on_artist_id ON artist_versions USING btree (artist_id);


--
-- Name: index_artist_versions_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_versions_on_created_at ON artist_versions USING btree (created_at);


--
-- Name: index_artist_versions_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_versions_on_name ON artist_versions USING btree (name);


--
-- Name: index_artist_versions_on_updater_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_versions_on_updater_id ON artist_versions USING btree (updater_id);


--
-- Name: index_artist_versions_on_updater_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_versions_on_updater_ip_addr ON artist_versions USING btree (updater_ip_addr);


--
-- Name: index_artists_on_group_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artists_on_group_name ON artists USING btree (group_name);


--
-- Name: index_artists_on_group_name_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artists_on_group_name_trgm ON artists USING gin (group_name gin_trgm_ops);


--
-- Name: index_artists_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_artists_on_name ON artists USING btree (name);


--
-- Name: index_artists_on_name_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artists_on_name_trgm ON artists USING gin (name gin_trgm_ops);


--
-- Name: index_artists_on_other_names_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artists_on_other_names_index ON artists USING gin (other_names_index);


--
-- Name: index_artists_on_other_names_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artists_on_other_names_trgm ON artists USING gin (other_names gin_trgm_ops);


--
-- Name: index_bans_on_banner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bans_on_banner_id ON bans USING btree (banner_id);


--
-- Name: index_bans_on_expires_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bans_on_expires_at ON bans USING btree (expires_at);


--
-- Name: index_bans_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bans_on_user_id ON bans USING btree (user_id);


--
-- Name: index_comment_votes_on_comment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comment_votes_on_comment_id ON comment_votes USING btree (comment_id);


--
-- Name: index_comment_votes_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comment_votes_on_created_at ON comment_votes USING btree (created_at);


--
-- Name: index_comment_votes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comment_votes_on_user_id ON comment_votes USING btree (user_id);


--
-- Name: index_comments_on_body_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_body_index ON comments USING gin (body_index);


--
-- Name: index_comments_on_creator_id_and_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_creator_id_and_post_id ON comments USING btree (creator_id, post_id);


--
-- Name: index_comments_on_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_ip_addr ON comments USING btree (ip_addr);


--
-- Name: index_comments_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_post_id ON comments USING btree (post_id);


--
-- Name: index_delayed_jobs_on_locked_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delayed_jobs_on_locked_at ON delayed_jobs USING btree (locked_at);


--
-- Name: index_delayed_jobs_on_locked_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delayed_jobs_on_locked_by ON delayed_jobs USING btree (locked_by);


--
-- Name: index_delayed_jobs_on_run_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delayed_jobs_on_run_at ON delayed_jobs USING btree (run_at);


--
-- Name: index_dmail_filters_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_dmail_filters_on_user_id ON dmail_filters USING btree (user_id);


--
-- Name: index_dmails_on_creator_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dmails_on_creator_ip_addr ON dmails USING btree (creator_ip_addr);


--
-- Name: index_dmails_on_is_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dmails_on_is_deleted ON dmails USING btree (is_deleted);


--
-- Name: index_dmails_on_is_read; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dmails_on_is_read ON dmails USING btree (is_read);


--
-- Name: index_dmails_on_message_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dmails_on_message_index ON dmails USING gin (message_index);


--
-- Name: index_dmails_on_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dmails_on_owner_id ON dmails USING btree (owner_id);


--
-- Name: index_favorite_groups_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorite_groups_on_creator_id ON favorite_groups USING btree (creator_id);


--
-- Name: index_favorite_groups_on_lower_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorite_groups_on_lower_name ON favorite_groups USING btree (lower(name));


--
-- Name: index_favorites_0_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_0_on_post_id ON favorites_0 USING btree (post_id);


--
-- Name: index_favorites_0_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_0_on_user_id ON favorites_0 USING btree (user_id);


--
-- Name: index_favorites_10_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_10_on_post_id ON favorites_10 USING btree (post_id);


--
-- Name: index_favorites_10_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_10_on_user_id ON favorites_10 USING btree (user_id);


--
-- Name: index_favorites_11_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_11_on_post_id ON favorites_11 USING btree (post_id);


--
-- Name: index_favorites_11_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_11_on_user_id ON favorites_11 USING btree (user_id);


--
-- Name: index_favorites_12_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_12_on_post_id ON favorites_12 USING btree (post_id);


--
-- Name: index_favorites_12_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_12_on_user_id ON favorites_12 USING btree (user_id);


--
-- Name: index_favorites_13_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_13_on_post_id ON favorites_13 USING btree (post_id);


--
-- Name: index_favorites_13_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_13_on_user_id ON favorites_13 USING btree (user_id);


--
-- Name: index_favorites_14_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_14_on_post_id ON favorites_14 USING btree (post_id);


--
-- Name: index_favorites_14_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_14_on_user_id ON favorites_14 USING btree (user_id);


--
-- Name: index_favorites_15_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_15_on_post_id ON favorites_15 USING btree (post_id);


--
-- Name: index_favorites_15_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_15_on_user_id ON favorites_15 USING btree (user_id);


--
-- Name: index_favorites_16_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_16_on_post_id ON favorites_16 USING btree (post_id);


--
-- Name: index_favorites_16_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_16_on_user_id ON favorites_16 USING btree (user_id);


--
-- Name: index_favorites_17_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_17_on_post_id ON favorites_17 USING btree (post_id);


--
-- Name: index_favorites_17_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_17_on_user_id ON favorites_17 USING btree (user_id);


--
-- Name: index_favorites_18_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_18_on_post_id ON favorites_18 USING btree (post_id);


--
-- Name: index_favorites_18_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_18_on_user_id ON favorites_18 USING btree (user_id);


--
-- Name: index_favorites_19_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_19_on_post_id ON favorites_19 USING btree (post_id);


--
-- Name: index_favorites_19_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_19_on_user_id ON favorites_19 USING btree (user_id);


--
-- Name: index_favorites_1_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_1_on_post_id ON favorites_1 USING btree (post_id);


--
-- Name: index_favorites_1_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_1_on_user_id ON favorites_1 USING btree (user_id);


--
-- Name: index_favorites_20_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_20_on_post_id ON favorites_20 USING btree (post_id);


--
-- Name: index_favorites_20_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_20_on_user_id ON favorites_20 USING btree (user_id);


--
-- Name: index_favorites_21_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_21_on_post_id ON favorites_21 USING btree (post_id);


--
-- Name: index_favorites_21_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_21_on_user_id ON favorites_21 USING btree (user_id);


--
-- Name: index_favorites_22_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_22_on_post_id ON favorites_22 USING btree (post_id);


--
-- Name: index_favorites_22_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_22_on_user_id ON favorites_22 USING btree (user_id);


--
-- Name: index_favorites_23_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_23_on_post_id ON favorites_23 USING btree (post_id);


--
-- Name: index_favorites_23_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_23_on_user_id ON favorites_23 USING btree (user_id);


--
-- Name: index_favorites_24_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_24_on_post_id ON favorites_24 USING btree (post_id);


--
-- Name: index_favorites_24_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_24_on_user_id ON favorites_24 USING btree (user_id);


--
-- Name: index_favorites_25_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_25_on_post_id ON favorites_25 USING btree (post_id);


--
-- Name: index_favorites_25_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_25_on_user_id ON favorites_25 USING btree (user_id);


--
-- Name: index_favorites_26_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_26_on_post_id ON favorites_26 USING btree (post_id);


--
-- Name: index_favorites_26_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_26_on_user_id ON favorites_26 USING btree (user_id);


--
-- Name: index_favorites_27_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_27_on_post_id ON favorites_27 USING btree (post_id);


--
-- Name: index_favorites_27_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_27_on_user_id ON favorites_27 USING btree (user_id);


--
-- Name: index_favorites_28_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_28_on_post_id ON favorites_28 USING btree (post_id);


--
-- Name: index_favorites_28_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_28_on_user_id ON favorites_28 USING btree (user_id);


--
-- Name: index_favorites_29_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_29_on_post_id ON favorites_29 USING btree (post_id);


--
-- Name: index_favorites_29_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_29_on_user_id ON favorites_29 USING btree (user_id);


--
-- Name: index_favorites_2_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_2_on_post_id ON favorites_2 USING btree (post_id);


--
-- Name: index_favorites_2_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_2_on_user_id ON favorites_2 USING btree (user_id);


--
-- Name: index_favorites_30_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_30_on_post_id ON favorites_30 USING btree (post_id);


--
-- Name: index_favorites_30_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_30_on_user_id ON favorites_30 USING btree (user_id);


--
-- Name: index_favorites_31_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_31_on_post_id ON favorites_31 USING btree (post_id);


--
-- Name: index_favorites_31_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_31_on_user_id ON favorites_31 USING btree (user_id);


--
-- Name: index_favorites_32_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_32_on_post_id ON favorites_32 USING btree (post_id);


--
-- Name: index_favorites_32_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_32_on_user_id ON favorites_32 USING btree (user_id);


--
-- Name: index_favorites_33_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_33_on_post_id ON favorites_33 USING btree (post_id);


--
-- Name: index_favorites_33_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_33_on_user_id ON favorites_33 USING btree (user_id);


--
-- Name: index_favorites_34_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_34_on_post_id ON favorites_34 USING btree (post_id);


--
-- Name: index_favorites_34_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_34_on_user_id ON favorites_34 USING btree (user_id);


--
-- Name: index_favorites_35_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_35_on_post_id ON favorites_35 USING btree (post_id);


--
-- Name: index_favorites_35_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_35_on_user_id ON favorites_35 USING btree (user_id);


--
-- Name: index_favorites_36_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_36_on_post_id ON favorites_36 USING btree (post_id);


--
-- Name: index_favorites_36_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_36_on_user_id ON favorites_36 USING btree (user_id);


--
-- Name: index_favorites_37_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_37_on_post_id ON favorites_37 USING btree (post_id);


--
-- Name: index_favorites_37_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_37_on_user_id ON favorites_37 USING btree (user_id);


--
-- Name: index_favorites_38_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_38_on_post_id ON favorites_38 USING btree (post_id);


--
-- Name: index_favorites_38_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_38_on_user_id ON favorites_38 USING btree (user_id);


--
-- Name: index_favorites_39_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_39_on_post_id ON favorites_39 USING btree (post_id);


--
-- Name: index_favorites_39_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_39_on_user_id ON favorites_39 USING btree (user_id);


--
-- Name: index_favorites_3_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_3_on_post_id ON favorites_3 USING btree (post_id);


--
-- Name: index_favorites_3_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_3_on_user_id ON favorites_3 USING btree (user_id);


--
-- Name: index_favorites_40_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_40_on_post_id ON favorites_40 USING btree (post_id);


--
-- Name: index_favorites_40_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_40_on_user_id ON favorites_40 USING btree (user_id);


--
-- Name: index_favorites_41_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_41_on_post_id ON favorites_41 USING btree (post_id);


--
-- Name: index_favorites_41_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_41_on_user_id ON favorites_41 USING btree (user_id);


--
-- Name: index_favorites_42_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_42_on_post_id ON favorites_42 USING btree (post_id);


--
-- Name: index_favorites_42_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_42_on_user_id ON favorites_42 USING btree (user_id);


--
-- Name: index_favorites_43_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_43_on_post_id ON favorites_43 USING btree (post_id);


--
-- Name: index_favorites_43_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_43_on_user_id ON favorites_43 USING btree (user_id);


--
-- Name: index_favorites_44_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_44_on_post_id ON favorites_44 USING btree (post_id);


--
-- Name: index_favorites_44_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_44_on_user_id ON favorites_44 USING btree (user_id);


--
-- Name: index_favorites_45_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_45_on_post_id ON favorites_45 USING btree (post_id);


--
-- Name: index_favorites_45_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_45_on_user_id ON favorites_45 USING btree (user_id);


--
-- Name: index_favorites_46_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_46_on_post_id ON favorites_46 USING btree (post_id);


--
-- Name: index_favorites_46_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_46_on_user_id ON favorites_46 USING btree (user_id);


--
-- Name: index_favorites_47_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_47_on_post_id ON favorites_47 USING btree (post_id);


--
-- Name: index_favorites_47_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_47_on_user_id ON favorites_47 USING btree (user_id);


--
-- Name: index_favorites_48_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_48_on_post_id ON favorites_48 USING btree (post_id);


--
-- Name: index_favorites_48_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_48_on_user_id ON favorites_48 USING btree (user_id);


--
-- Name: index_favorites_49_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_49_on_post_id ON favorites_49 USING btree (post_id);


--
-- Name: index_favorites_49_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_49_on_user_id ON favorites_49 USING btree (user_id);


--
-- Name: index_favorites_4_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_4_on_post_id ON favorites_4 USING btree (post_id);


--
-- Name: index_favorites_4_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_4_on_user_id ON favorites_4 USING btree (user_id);


--
-- Name: index_favorites_50_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_50_on_post_id ON favorites_50 USING btree (post_id);


--
-- Name: index_favorites_50_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_50_on_user_id ON favorites_50 USING btree (user_id);


--
-- Name: index_favorites_51_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_51_on_post_id ON favorites_51 USING btree (post_id);


--
-- Name: index_favorites_51_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_51_on_user_id ON favorites_51 USING btree (user_id);


--
-- Name: index_favorites_52_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_52_on_post_id ON favorites_52 USING btree (post_id);


--
-- Name: index_favorites_52_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_52_on_user_id ON favorites_52 USING btree (user_id);


--
-- Name: index_favorites_53_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_53_on_post_id ON favorites_53 USING btree (post_id);


--
-- Name: index_favorites_53_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_53_on_user_id ON favorites_53 USING btree (user_id);


--
-- Name: index_favorites_54_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_54_on_post_id ON favorites_54 USING btree (post_id);


--
-- Name: index_favorites_54_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_54_on_user_id ON favorites_54 USING btree (user_id);


--
-- Name: index_favorites_55_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_55_on_post_id ON favorites_55 USING btree (post_id);


--
-- Name: index_favorites_55_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_55_on_user_id ON favorites_55 USING btree (user_id);


--
-- Name: index_favorites_56_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_56_on_post_id ON favorites_56 USING btree (post_id);


--
-- Name: index_favorites_56_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_56_on_user_id ON favorites_56 USING btree (user_id);


--
-- Name: index_favorites_57_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_57_on_post_id ON favorites_57 USING btree (post_id);


--
-- Name: index_favorites_57_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_57_on_user_id ON favorites_57 USING btree (user_id);


--
-- Name: index_favorites_58_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_58_on_post_id ON favorites_58 USING btree (post_id);


--
-- Name: index_favorites_58_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_58_on_user_id ON favorites_58 USING btree (user_id);


--
-- Name: index_favorites_59_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_59_on_post_id ON favorites_59 USING btree (post_id);


--
-- Name: index_favorites_59_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_59_on_user_id ON favorites_59 USING btree (user_id);


--
-- Name: index_favorites_5_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_5_on_post_id ON favorites_5 USING btree (post_id);


--
-- Name: index_favorites_5_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_5_on_user_id ON favorites_5 USING btree (user_id);


--
-- Name: index_favorites_60_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_60_on_post_id ON favorites_60 USING btree (post_id);


--
-- Name: index_favorites_60_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_60_on_user_id ON favorites_60 USING btree (user_id);


--
-- Name: index_favorites_61_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_61_on_post_id ON favorites_61 USING btree (post_id);


--
-- Name: index_favorites_61_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_61_on_user_id ON favorites_61 USING btree (user_id);


--
-- Name: index_favorites_62_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_62_on_post_id ON favorites_62 USING btree (post_id);


--
-- Name: index_favorites_62_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_62_on_user_id ON favorites_62 USING btree (user_id);


--
-- Name: index_favorites_63_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_63_on_post_id ON favorites_63 USING btree (post_id);


--
-- Name: index_favorites_63_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_63_on_user_id ON favorites_63 USING btree (user_id);


--
-- Name: index_favorites_64_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_64_on_post_id ON favorites_64 USING btree (post_id);


--
-- Name: index_favorites_64_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_64_on_user_id ON favorites_64 USING btree (user_id);


--
-- Name: index_favorites_65_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_65_on_post_id ON favorites_65 USING btree (post_id);


--
-- Name: index_favorites_65_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_65_on_user_id ON favorites_65 USING btree (user_id);


--
-- Name: index_favorites_66_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_66_on_post_id ON favorites_66 USING btree (post_id);


--
-- Name: index_favorites_66_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_66_on_user_id ON favorites_66 USING btree (user_id);


--
-- Name: index_favorites_67_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_67_on_post_id ON favorites_67 USING btree (post_id);


--
-- Name: index_favorites_67_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_67_on_user_id ON favorites_67 USING btree (user_id);


--
-- Name: index_favorites_68_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_68_on_post_id ON favorites_68 USING btree (post_id);


--
-- Name: index_favorites_68_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_68_on_user_id ON favorites_68 USING btree (user_id);


--
-- Name: index_favorites_69_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_69_on_post_id ON favorites_69 USING btree (post_id);


--
-- Name: index_favorites_69_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_69_on_user_id ON favorites_69 USING btree (user_id);


--
-- Name: index_favorites_6_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_6_on_post_id ON favorites_6 USING btree (post_id);


--
-- Name: index_favorites_6_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_6_on_user_id ON favorites_6 USING btree (user_id);


--
-- Name: index_favorites_70_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_70_on_post_id ON favorites_70 USING btree (post_id);


--
-- Name: index_favorites_70_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_70_on_user_id ON favorites_70 USING btree (user_id);


--
-- Name: index_favorites_71_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_71_on_post_id ON favorites_71 USING btree (post_id);


--
-- Name: index_favorites_71_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_71_on_user_id ON favorites_71 USING btree (user_id);


--
-- Name: index_favorites_72_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_72_on_post_id ON favorites_72 USING btree (post_id);


--
-- Name: index_favorites_72_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_72_on_user_id ON favorites_72 USING btree (user_id);


--
-- Name: index_favorites_73_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_73_on_post_id ON favorites_73 USING btree (post_id);


--
-- Name: index_favorites_73_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_73_on_user_id ON favorites_73 USING btree (user_id);


--
-- Name: index_favorites_74_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_74_on_post_id ON favorites_74 USING btree (post_id);


--
-- Name: index_favorites_74_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_74_on_user_id ON favorites_74 USING btree (user_id);


--
-- Name: index_favorites_75_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_75_on_post_id ON favorites_75 USING btree (post_id);


--
-- Name: index_favorites_75_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_75_on_user_id ON favorites_75 USING btree (user_id);


--
-- Name: index_favorites_76_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_76_on_post_id ON favorites_76 USING btree (post_id);


--
-- Name: index_favorites_76_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_76_on_user_id ON favorites_76 USING btree (user_id);


--
-- Name: index_favorites_77_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_77_on_post_id ON favorites_77 USING btree (post_id);


--
-- Name: index_favorites_77_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_77_on_user_id ON favorites_77 USING btree (user_id);


--
-- Name: index_favorites_78_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_78_on_post_id ON favorites_78 USING btree (post_id);


--
-- Name: index_favorites_78_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_78_on_user_id ON favorites_78 USING btree (user_id);


--
-- Name: index_favorites_79_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_79_on_post_id ON favorites_79 USING btree (post_id);


--
-- Name: index_favorites_79_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_79_on_user_id ON favorites_79 USING btree (user_id);


--
-- Name: index_favorites_7_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_7_on_post_id ON favorites_7 USING btree (post_id);


--
-- Name: index_favorites_7_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_7_on_user_id ON favorites_7 USING btree (user_id);


--
-- Name: index_favorites_80_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_80_on_post_id ON favorites_80 USING btree (post_id);


--
-- Name: index_favorites_80_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_80_on_user_id ON favorites_80 USING btree (user_id);


--
-- Name: index_favorites_81_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_81_on_post_id ON favorites_81 USING btree (post_id);


--
-- Name: index_favorites_81_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_81_on_user_id ON favorites_81 USING btree (user_id);


--
-- Name: index_favorites_82_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_82_on_post_id ON favorites_82 USING btree (post_id);


--
-- Name: index_favorites_82_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_82_on_user_id ON favorites_82 USING btree (user_id);


--
-- Name: index_favorites_83_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_83_on_post_id ON favorites_83 USING btree (post_id);


--
-- Name: index_favorites_83_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_83_on_user_id ON favorites_83 USING btree (user_id);


--
-- Name: index_favorites_84_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_84_on_post_id ON favorites_84 USING btree (post_id);


--
-- Name: index_favorites_84_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_84_on_user_id ON favorites_84 USING btree (user_id);


--
-- Name: index_favorites_85_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_85_on_post_id ON favorites_85 USING btree (post_id);


--
-- Name: index_favorites_85_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_85_on_user_id ON favorites_85 USING btree (user_id);


--
-- Name: index_favorites_86_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_86_on_post_id ON favorites_86 USING btree (post_id);


--
-- Name: index_favorites_86_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_86_on_user_id ON favorites_86 USING btree (user_id);


--
-- Name: index_favorites_87_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_87_on_post_id ON favorites_87 USING btree (post_id);


--
-- Name: index_favorites_87_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_87_on_user_id ON favorites_87 USING btree (user_id);


--
-- Name: index_favorites_88_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_88_on_post_id ON favorites_88 USING btree (post_id);


--
-- Name: index_favorites_88_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_88_on_user_id ON favorites_88 USING btree (user_id);


--
-- Name: index_favorites_89_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_89_on_post_id ON favorites_89 USING btree (post_id);


--
-- Name: index_favorites_89_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_89_on_user_id ON favorites_89 USING btree (user_id);


--
-- Name: index_favorites_8_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_8_on_post_id ON favorites_8 USING btree (post_id);


--
-- Name: index_favorites_8_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_8_on_user_id ON favorites_8 USING btree (user_id);


--
-- Name: index_favorites_90_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_90_on_post_id ON favorites_90 USING btree (post_id);


--
-- Name: index_favorites_90_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_90_on_user_id ON favorites_90 USING btree (user_id);


--
-- Name: index_favorites_91_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_91_on_post_id ON favorites_91 USING btree (post_id);


--
-- Name: index_favorites_91_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_91_on_user_id ON favorites_91 USING btree (user_id);


--
-- Name: index_favorites_92_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_92_on_post_id ON favorites_92 USING btree (post_id);


--
-- Name: index_favorites_92_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_92_on_user_id ON favorites_92 USING btree (user_id);


--
-- Name: index_favorites_93_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_93_on_post_id ON favorites_93 USING btree (post_id);


--
-- Name: index_favorites_93_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_93_on_user_id ON favorites_93 USING btree (user_id);


--
-- Name: index_favorites_94_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_94_on_post_id ON favorites_94 USING btree (post_id);


--
-- Name: index_favorites_94_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_94_on_user_id ON favorites_94 USING btree (user_id);


--
-- Name: index_favorites_95_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_95_on_post_id ON favorites_95 USING btree (post_id);


--
-- Name: index_favorites_95_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_95_on_user_id ON favorites_95 USING btree (user_id);


--
-- Name: index_favorites_96_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_96_on_post_id ON favorites_96 USING btree (post_id);


--
-- Name: index_favorites_96_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_96_on_user_id ON favorites_96 USING btree (user_id);


--
-- Name: index_favorites_97_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_97_on_post_id ON favorites_97 USING btree (post_id);


--
-- Name: index_favorites_97_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_97_on_user_id ON favorites_97 USING btree (user_id);


--
-- Name: index_favorites_98_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_98_on_post_id ON favorites_98 USING btree (post_id);


--
-- Name: index_favorites_98_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_98_on_user_id ON favorites_98 USING btree (user_id);


--
-- Name: index_favorites_99_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_99_on_post_id ON favorites_99 USING btree (post_id);


--
-- Name: index_favorites_99_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_99_on_user_id ON favorites_99 USING btree (user_id);


--
-- Name: index_favorites_9_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_9_on_post_id ON favorites_9 USING btree (post_id);


--
-- Name: index_favorites_9_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_9_on_user_id ON favorites_9 USING btree (user_id);


--
-- Name: index_forum_posts_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_posts_on_creator_id ON forum_posts USING btree (creator_id);


--
-- Name: index_forum_posts_on_text_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_posts_on_text_index ON forum_posts USING gin (text_index);


--
-- Name: index_forum_posts_on_topic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_posts_on_topic_id ON forum_posts USING btree (topic_id);


--
-- Name: index_forum_subscriptions_on_forum_topic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_subscriptions_on_forum_topic_id ON forum_subscriptions USING btree (forum_topic_id);


--
-- Name: index_forum_subscriptions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_subscriptions_on_user_id ON forum_subscriptions USING btree (user_id);


--
-- Name: index_forum_topic_visits_on_forum_topic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topic_visits_on_forum_topic_id ON forum_topic_visits USING btree (forum_topic_id);


--
-- Name: index_forum_topic_visits_on_last_read_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topic_visits_on_last_read_at ON forum_topic_visits USING btree (last_read_at);


--
-- Name: index_forum_topic_visits_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topic_visits_on_user_id ON forum_topic_visits USING btree (user_id);


--
-- Name: index_forum_topics_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topics_on_creator_id ON forum_topics USING btree (creator_id);


--
-- Name: index_forum_topics_on_is_sticky_and_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topics_on_is_sticky_and_updated_at ON forum_topics USING btree (is_sticky, updated_at);


--
-- Name: index_forum_topics_on_text_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topics_on_text_index ON forum_topics USING gin (text_index);


--
-- Name: index_forum_topics_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topics_on_updated_at ON forum_topics USING btree (updated_at);


--
-- Name: index_ip_bans_on_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ip_bans_on_ip_addr ON ip_bans USING btree (ip_addr);


--
-- Name: index_janitor_trials_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_janitor_trials_on_user_id ON janitor_trials USING btree (user_id);


--
-- Name: index_news_updates_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_news_updates_on_created_at ON news_updates USING btree (created_at);


--
-- Name: index_note_versions_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_note_versions_on_created_at ON note_versions USING btree (created_at);


--
-- Name: index_note_versions_on_note_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_note_versions_on_note_id ON note_versions USING btree (note_id);


--
-- Name: index_note_versions_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_note_versions_on_post_id ON note_versions USING btree (post_id);


--
-- Name: index_note_versions_on_updater_id_and_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_note_versions_on_updater_id_and_post_id ON note_versions USING btree (updater_id, post_id);


--
-- Name: index_note_versions_on_updater_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_note_versions_on_updater_ip_addr ON note_versions USING btree (updater_ip_addr);


--
-- Name: index_notes_on_body_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_body_index ON notes USING gin (body_index);


--
-- Name: index_notes_on_creator_id_and_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_creator_id_and_post_id ON notes USING btree (creator_id, post_id);


--
-- Name: index_notes_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_post_id ON notes USING btree (post_id);


--
-- Name: index_pixiv_ugoira_frame_data_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_pixiv_ugoira_frame_data_on_post_id ON pixiv_ugoira_frame_data USING btree (post_id);


--
-- Name: index_pools_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pools_on_creator_id ON pools USING btree (creator_id);


--
-- Name: index_pools_on_lower_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pools_on_lower_name ON pools USING btree (lower((name)::text));


--
-- Name: index_pools_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pools_on_name ON pools USING btree (name);


--
-- Name: index_pools_on_name_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pools_on_name_trgm ON pools USING gin (lower((name)::text) gin_trgm_ops);


--
-- Name: index_pools_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pools_on_updated_at ON pools USING btree (updated_at);


--
-- Name: index_post_appeals_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_appeals_on_created_at ON post_appeals USING btree (created_at);


--
-- Name: index_post_appeals_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_appeals_on_creator_id ON post_appeals USING btree (creator_id);


--
-- Name: index_post_appeals_on_creator_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_appeals_on_creator_ip_addr ON post_appeals USING btree (creator_ip_addr);


--
-- Name: index_post_appeals_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_appeals_on_post_id ON post_appeals USING btree (post_id);


--
-- Name: index_post_appeals_on_reason_tsvector; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_appeals_on_reason_tsvector ON post_appeals USING gin (to_tsvector('english'::regconfig, reason));


--
-- Name: index_post_approvals_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_approvals_on_post_id ON post_approvals USING btree (post_id);


--
-- Name: index_post_approvals_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_approvals_on_user_id ON post_approvals USING btree (user_id);


--
-- Name: index_post_disapprovals_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_disapprovals_on_post_id ON post_disapprovals USING btree (post_id);


--
-- Name: index_post_disapprovals_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_disapprovals_on_user_id ON post_disapprovals USING btree (user_id);


--
-- Name: index_post_flags_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_flags_on_creator_id ON post_flags USING btree (creator_id);


--
-- Name: index_post_flags_on_creator_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_flags_on_creator_ip_addr ON post_flags USING btree (creator_ip_addr);


--
-- Name: index_post_flags_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_flags_on_post_id ON post_flags USING btree (post_id);


--
-- Name: index_post_flags_on_reason_tsvector; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_flags_on_reason_tsvector ON post_flags USING gin (to_tsvector('english'::regconfig, reason));


--
-- Name: index_post_replacements_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_replacements_on_creator_id ON post_replacements USING btree (creator_id);


--
-- Name: index_post_replacements_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_replacements_on_post_id ON post_replacements USING btree (post_id);


--
-- Name: index_post_votes_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_votes_on_post_id ON post_votes USING btree (post_id);


--
-- Name: index_post_votes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_votes_on_user_id ON post_votes USING btree (user_id);


--
-- Name: index_posts_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_created_at ON posts USING btree (created_at);


--
-- Name: index_posts_on_file_size; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_file_size ON posts USING btree (file_size);


--
-- Name: index_posts_on_image_height; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_image_height ON posts USING btree (image_height);


--
-- Name: index_posts_on_image_width; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_image_width ON posts USING btree (image_width);


--
-- Name: index_posts_on_is_flagged; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_is_flagged ON posts USING btree (is_flagged) WHERE (is_flagged = true);


--
-- Name: index_posts_on_is_pending; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_is_pending ON posts USING btree (is_pending) WHERE (is_pending = true);


--
-- Name: index_posts_on_last_comment_bumped_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_last_comment_bumped_at ON posts USING btree (last_comment_bumped_at DESC NULLS LAST);


--
-- Name: index_posts_on_last_noted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_last_noted_at ON posts USING btree (last_noted_at DESC NULLS LAST);


--
-- Name: index_posts_on_md5; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_posts_on_md5 ON posts USING btree (md5);


--
-- Name: index_posts_on_mpixels; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_mpixels ON posts USING btree (((((image_width * image_height))::numeric / 1000000.0)));


--
-- Name: index_posts_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_parent_id ON posts USING btree (parent_id);


--
-- Name: index_posts_on_pixiv_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_pixiv_id ON posts USING btree (pixiv_id) WHERE (pixiv_id IS NOT NULL);


--
-- Name: index_posts_on_source_pattern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_source_pattern ON posts USING btree (sourcepattern(lower((source)::text)) text_pattern_ops);


--
-- Name: index_posts_on_tags_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_tags_index ON posts USING gin (tag_index);


--
-- Name: index_posts_on_uploader_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_uploader_id ON posts USING btree (uploader_id);


--
-- Name: index_saved_searches_on_labels; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_saved_searches_on_labels ON saved_searches USING gin (labels);


--
-- Name: index_saved_searches_on_query; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_saved_searches_on_query ON saved_searches USING btree (query);


--
-- Name: index_saved_searches_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_saved_searches_on_user_id ON saved_searches USING btree (user_id);


--
-- Name: index_tag_aliases_on_antecedent_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_aliases_on_antecedent_name ON tag_aliases USING btree (antecedent_name);


--
-- Name: index_tag_aliases_on_antecedent_name_pattern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_aliases_on_antecedent_name_pattern ON tag_aliases USING btree (antecedent_name text_pattern_ops);


--
-- Name: index_tag_aliases_on_consequent_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_aliases_on_consequent_name ON tag_aliases USING btree (consequent_name);


--
-- Name: index_tag_aliases_on_post_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_aliases_on_post_count ON tag_aliases USING btree (post_count);


--
-- Name: index_tag_implications_on_antecedent_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_implications_on_antecedent_name ON tag_implications USING btree (antecedent_name);


--
-- Name: index_tag_implications_on_consequent_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_implications_on_consequent_name ON tag_implications USING btree (consequent_name);


--
-- Name: index_tag_subscriptions_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_subscriptions_on_creator_id ON tag_subscriptions USING btree (creator_id);


--
-- Name: index_tag_subscriptions_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_subscriptions_on_name ON tag_subscriptions USING btree (name);


--
-- Name: index_tags_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tags_on_name ON tags USING btree (name);


--
-- Name: index_tags_on_name_pattern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tags_on_name_pattern ON tags USING btree (name text_pattern_ops);


--
-- Name: index_tags_on_name_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tags_on_name_trgm ON tags USING gin (name gin_trgm_ops);


--
-- Name: index_token_buckets_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_token_buckets_on_user_id ON token_buckets USING btree (user_id);


--
-- Name: index_uploads_on_uploader_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_uploads_on_uploader_id ON uploads USING btree (uploader_id);


--
-- Name: index_uploads_on_uploader_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_uploads_on_uploader_ip_addr ON uploads USING btree (uploader_ip_addr);


--
-- Name: index_user_feedback_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_feedback_on_created_at ON user_feedback USING btree (created_at);


--
-- Name: index_user_feedback_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_feedback_on_creator_id ON user_feedback USING btree (creator_id);


--
-- Name: index_user_feedback_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_feedback_on_user_id ON user_feedback USING btree (user_id);


--
-- Name: index_user_name_change_requests_on_original_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_name_change_requests_on_original_name ON user_name_change_requests USING btree (original_name);


--
-- Name: index_user_name_change_requests_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_name_change_requests_on_user_id ON user_name_change_requests USING btree (user_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_last_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_last_ip_addr ON users USING btree (last_ip_addr) WHERE (last_ip_addr IS NOT NULL);


--
-- Name: index_users_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_name ON users USING btree (lower((name)::text));


--
-- Name: index_users_on_name_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_name_trgm ON users USING gin (lower((name)::text) gin_trgm_ops);


--
-- Name: index_wiki_page_versions_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_page_versions_on_created_at ON wiki_page_versions USING btree (created_at);


--
-- Name: index_wiki_page_versions_on_updater_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_page_versions_on_updater_ip_addr ON wiki_page_versions USING btree (updater_ip_addr);


--
-- Name: index_wiki_page_versions_on_wiki_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_page_versions_on_wiki_page_id ON wiki_page_versions USING btree (wiki_page_id);


--
-- Name: index_wiki_pages_on_body_index_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_pages_on_body_index_index ON wiki_pages USING gin (body_index);


--
-- Name: index_wiki_pages_on_other_names_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_pages_on_other_names_index ON wiki_pages USING gin (other_names_index);


--
-- Name: index_wiki_pages_on_title; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_wiki_pages_on_title ON wiki_pages USING btree (title);


--
-- Name: index_wiki_pages_on_title_pattern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_pages_on_title_pattern ON wiki_pages USING btree (title text_pattern_ops);


--
-- Name: index_wiki_pages_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_pages_on_updated_at ON wiki_pages USING btree (updated_at);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: favorites insert_favorites_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER insert_favorites_trigger BEFORE INSERT ON favorites FOR EACH ROW EXECUTE PROCEDURE favorites_insert_trigger();


--
-- Name: artists trigger_artists_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_artists_on_update BEFORE INSERT OR UPDATE ON artists FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('other_names_index', 'public.danbooru', 'other_names');


--
-- Name: comments trigger_comments_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_comments_on_update BEFORE INSERT OR UPDATE ON comments FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('body_index', 'pg_catalog.english', 'body');


--
-- Name: dmails trigger_dmails_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_dmails_on_update BEFORE INSERT OR UPDATE ON dmails FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('message_index', 'pg_catalog.english', 'title', 'body');


--
-- Name: forum_posts trigger_forum_posts_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_forum_posts_on_update BEFORE INSERT OR UPDATE ON forum_posts FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('text_index', 'pg_catalog.english', 'body');


--
-- Name: forum_topics trigger_forum_topics_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_forum_topics_on_update BEFORE INSERT OR UPDATE ON forum_topics FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('text_index', 'pg_catalog.english', 'title');


--
-- Name: notes trigger_notes_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_notes_on_update BEFORE INSERT OR UPDATE ON notes FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('body_index', 'pg_catalog.english', 'body');


--
-- Name: posts trigger_posts_on_tag_index_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_posts_on_tag_index_update BEFORE INSERT OR UPDATE ON posts FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('tag_index', 'public.danbooru', 'tag_string', 'fav_string', 'pool_string');


--
-- Name: wiki_pages trigger_wiki_pages_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_wiki_pages_on_update BEFORE INSERT OR UPDATE ON wiki_pages FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('body_index', 'public.danbooru', 'body', 'title');


--
-- Name: wiki_pages trigger_wiki_pages_on_update_for_other_names; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_wiki_pages_on_update_for_other_names BEFORE INSERT OR UPDATE ON wiki_pages FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('other_names_index', 'public.danbooru', 'other_names');


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20100204211522');

INSERT INTO schema_migrations (version) VALUES ('20100204214746');

INSERT INTO schema_migrations (version) VALUES ('20100205162521');

INSERT INTO schema_migrations (version) VALUES ('20100205163027');

INSERT INTO schema_migrations (version) VALUES ('20100205224030');

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

INSERT INTO schema_migrations (version) VALUES ('20100826232512');

INSERT INTO schema_migrations (version) VALUES ('20110328215652');

INSERT INTO schema_migrations (version) VALUES ('20110328215701');

INSERT INTO schema_migrations (version) VALUES ('20110607194023');

INSERT INTO schema_migrations (version) VALUES ('20110717010705');

INSERT INTO schema_migrations (version) VALUES ('20110722211855');

INSERT INTO schema_migrations (version) VALUES ('20110815233456');

INSERT INTO schema_migrations (version) VALUES ('20111101212358');

INSERT INTO schema_migrations (version) VALUES ('20130106210658');

INSERT INTO schema_migrations (version) VALUES ('20130114154400');

INSERT INTO schema_migrations (version) VALUES ('20130219171111');

INSERT INTO schema_migrations (version) VALUES ('20130219184743');

INSERT INTO schema_migrations (version) VALUES ('20130221032344');

INSERT INTO schema_migrations (version) VALUES ('20130221035518');

INSERT INTO schema_migrations (version) VALUES ('20130221214811');

INSERT INTO schema_migrations (version) VALUES ('20130302214500');

INSERT INTO schema_migrations (version) VALUES ('20130305005138');

INSERT INTO schema_migrations (version) VALUES ('20130307225324');

INSERT INTO schema_migrations (version) VALUES ('20130308204213');

INSERT INTO schema_migrations (version) VALUES ('20130318002652');

INSERT INTO schema_migrations (version) VALUES ('20130318012517');

INSERT INTO schema_migrations (version) VALUES ('20130318030619');

INSERT INTO schema_migrations (version) VALUES ('20130318231740');

INSERT INTO schema_migrations (version) VALUES ('20130320070700');

INSERT INTO schema_migrations (version) VALUES ('20130322162059');

INSERT INTO schema_migrations (version) VALUES ('20130322173202');

INSERT INTO schema_migrations (version) VALUES ('20130322173859');

INSERT INTO schema_migrations (version) VALUES ('20130323160259');

INSERT INTO schema_migrations (version) VALUES ('20130326035904');

INSERT INTO schema_migrations (version) VALUES ('20130328092739');

INSERT INTO schema_migrations (version) VALUES ('20130331180246');

INSERT INTO schema_migrations (version) VALUES ('20130331182719');

INSERT INTO schema_migrations (version) VALUES ('20130401013601');

INSERT INTO schema_migrations (version) VALUES ('20130409191950');

INSERT INTO schema_migrations (version) VALUES ('20130417221643');

INSERT INTO schema_migrations (version) VALUES ('20130424121410');

INSERT INTO schema_migrations (version) VALUES ('20130506154136');

INSERT INTO schema_migrations (version) VALUES ('20130606224559');

INSERT INTO schema_migrations (version) VALUES ('20130618230158');

INSERT INTO schema_migrations (version) VALUES ('20130620215658');

INSERT INTO schema_migrations (version) VALUES ('20130712162600');

INSERT INTO schema_migrations (version) VALUES ('20130914175431');

INSERT INTO schema_migrations (version) VALUES ('20131006193238');

INSERT INTO schema_migrations (version) VALUES ('20131117150705');

INSERT INTO schema_migrations (version) VALUES ('20131118153503');

INSERT INTO schema_migrations (version) VALUES ('20131130190411');

INSERT INTO schema_migrations (version) VALUES ('20131209181023');

INSERT INTO schema_migrations (version) VALUES ('20131217025233');

INSERT INTO schema_migrations (version) VALUES ('20131225002748');

INSERT INTO schema_migrations (version) VALUES ('20140111191413');

INSERT INTO schema_migrations (version) VALUES ('20140204233337');

INSERT INTO schema_migrations (version) VALUES ('20140221213349');

INSERT INTO schema_migrations (version) VALUES ('20140428015134');

INSERT INTO schema_migrations (version) VALUES ('20140505000956');

INSERT INTO schema_migrations (version) VALUES ('20140603225334');

INSERT INTO schema_migrations (version) VALUES ('20140604002414');

INSERT INTO schema_migrations (version) VALUES ('20140613004559');

INSERT INTO schema_migrations (version) VALUES ('20140701224800');

INSERT INTO schema_migrations (version) VALUES ('20140722225753');

INSERT INTO schema_migrations (version) VALUES ('20140725003232');

INSERT INTO schema_migrations (version) VALUES ('20141009231234');

INSERT INTO schema_migrations (version) VALUES ('20141017231608');

INSERT INTO schema_migrations (version) VALUES ('20141120045943');

INSERT INTO schema_migrations (version) VALUES ('20150119191042');

INSERT INTO schema_migrations (version) VALUES ('20150120005624');

INSERT INTO schema_migrations (version) VALUES ('20150128005954');

INSERT INTO schema_migrations (version) VALUES ('20150403224949');

INSERT INTO schema_migrations (version) VALUES ('20150613010904');

INSERT INTO schema_migrations (version) VALUES ('20150623191904');

INSERT INTO schema_migrations (version) VALUES ('20150629235905');

INSERT INTO schema_migrations (version) VALUES ('20150705014135');

INSERT INTO schema_migrations (version) VALUES ('20150721214646');

INSERT INTO schema_migrations (version) VALUES ('20150728170433');

INSERT INTO schema_migrations (version) VALUES ('20150805010245');

INSERT INTO schema_migrations (version) VALUES ('20151217213321');

INSERT INTO schema_migrations (version) VALUES ('20160219004022');

INSERT INTO schema_migrations (version) VALUES ('20160219010854');

INSERT INTO schema_migrations (version) VALUES ('20160219172840');

INSERT INTO schema_migrations (version) VALUES ('20160222211328');

INSERT INTO schema_migrations (version) VALUES ('20160526174848');

INSERT INTO schema_migrations (version) VALUES ('20160820003534');

INSERT INTO schema_migrations (version) VALUES ('20160822230752');

INSERT INTO schema_migrations (version) VALUES ('20160919234407');

INSERT INTO schema_migrations (version) VALUES ('20161018221128');

INSERT INTO schema_migrations (version) VALUES ('20161024220345');

INSERT INTO schema_migrations (version) VALUES ('20161101003139');

INSERT INTO schema_migrations (version) VALUES ('20161221225849');

INSERT INTO schema_migrations (version) VALUES ('20161227003428');

INSERT INTO schema_migrations (version) VALUES ('20161229001201');

INSERT INTO schema_migrations (version) VALUES ('20170106012138');

INSERT INTO schema_migrations (version) VALUES ('20170112021922');

INSERT INTO schema_migrations (version) VALUES ('20170112060921');

INSERT INTO schema_migrations (version) VALUES ('20170117233040');

INSERT INTO schema_migrations (version) VALUES ('20170218104710');

INSERT INTO schema_migrations (version) VALUES ('20170302014435');

INSERT INTO schema_migrations (version) VALUES ('20170314235626');

INSERT INTO schema_migrations (version) VALUES ('20170316224630');

INSERT INTO schema_migrations (version) VALUES ('20170319000519');

INSERT INTO schema_migrations (version) VALUES ('20170329185605');

INSERT INTO schema_migrations (version) VALUES ('20170330230231');

INSERT INTO schema_migrations (version) VALUES ('20170413000209');

INSERT INTO schema_migrations (version) VALUES ('20170414005856');

INSERT INTO schema_migrations (version) VALUES ('20170414233426');

INSERT INTO schema_migrations (version) VALUES ('20170414233617');

INSERT INTO schema_migrations (version) VALUES ('20170416224142');

INSERT INTO schema_migrations (version) VALUES ('20170428220448');

INSERT INTO schema_migrations (version) VALUES ('20170512221200');

INSERT INTO schema_migrations (version) VALUES ('20170515235205');

INSERT INTO schema_migrations (version) VALUES ('20170519204506');

INSERT INTO schema_migrations (version) VALUES ('20170526183928');

INSERT INTO schema_migrations (version) VALUES ('20170608043651');

INSERT INTO schema_migrations (version) VALUES ('20170613200356');

INSERT INTO schema_migrations (version) VALUES ('20170709190409');

INSERT INTO schema_migrations (version) VALUES ('20170914200122');

INSERT INTO schema_migrations (version) VALUES ('20171106075030');

INSERT INTO schema_migrations (version) VALUES ('20171127195124');

INSERT INTO schema_migrations (version) VALUES ('20171218213037');

INSERT INTO schema_migrations (version) VALUES ('20171219001521');

INSERT INTO schema_migrations (version) VALUES ('20171230220225');

INSERT INTO schema_migrations (version) VALUES ('20180113211343');

INSERT INTO schema_migrations (version) VALUES ('20180116001101');

