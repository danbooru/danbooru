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
-- Name: favorites; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_0; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_0 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
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
    user_id integer,
    post_id integer
);


--
-- Name: favorites_10; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_10 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_10_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_10_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_10_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_10_id_seq OWNED BY favorites_10.id;


--
-- Name: favorites_11; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_11 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_11_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_11_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_11_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_11_id_seq OWNED BY favorites_11.id;


--
-- Name: favorites_12; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_12 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_12_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_12_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_12_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_12_id_seq OWNED BY favorites_12.id;


--
-- Name: favorites_13; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_13 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_13_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_13_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_13_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_13_id_seq OWNED BY favorites_13.id;


--
-- Name: favorites_14; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_14 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_14_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_14_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_14_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_14_id_seq OWNED BY favorites_14.id;


--
-- Name: favorites_15; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_15 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_15_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_15_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_15_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_15_id_seq OWNED BY favorites_15.id;


--
-- Name: favorites_16; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_16 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_16_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_16_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_16_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_16_id_seq OWNED BY favorites_16.id;


--
-- Name: favorites_17; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_17 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_17_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_17_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_17_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_17_id_seq OWNED BY favorites_17.id;


--
-- Name: favorites_18; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_18 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_18_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_18_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_18_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_18_id_seq OWNED BY favorites_18.id;


--
-- Name: favorites_19; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_19 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_19_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_19_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_19_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_19_id_seq OWNED BY favorites_19.id;


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
    user_id integer,
    post_id integer
);


--
-- Name: favorites_20; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_20 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_20_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_20_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_20_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_20_id_seq OWNED BY favorites_20.id;


--
-- Name: favorites_21; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_21 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_21_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_21_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_21_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_21_id_seq OWNED BY favorites_21.id;


--
-- Name: favorites_22; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_22 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_22_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_22_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_22_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_22_id_seq OWNED BY favorites_22.id;


--
-- Name: favorites_23; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_23 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_23_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_23_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_23_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_23_id_seq OWNED BY favorites_23.id;


--
-- Name: favorites_24; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_24 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_24_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_24_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_24_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_24_id_seq OWNED BY favorites_24.id;


--
-- Name: favorites_25; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_25 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_25_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_25_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_25_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_25_id_seq OWNED BY favorites_25.id;


--
-- Name: favorites_26; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_26 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_26_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_26_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_26_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_26_id_seq OWNED BY favorites_26.id;


--
-- Name: favorites_27; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_27 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_27_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_27_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_27_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_27_id_seq OWNED BY favorites_27.id;


--
-- Name: favorites_28; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_28 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_28_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_28_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_28_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_28_id_seq OWNED BY favorites_28.id;


--
-- Name: favorites_29; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_29 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_29_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_29_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_29_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_29_id_seq OWNED BY favorites_29.id;


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
    user_id integer,
    post_id integer
);


--
-- Name: favorites_30; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_30 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_30_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_30_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_30_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_30_id_seq OWNED BY favorites_30.id;


--
-- Name: favorites_31; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_31 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_31_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_31_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_31_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_31_id_seq OWNED BY favorites_31.id;


--
-- Name: favorites_32; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_32 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_32_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_32_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_32_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_32_id_seq OWNED BY favorites_32.id;


--
-- Name: favorites_33; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_33 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_33_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_33_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_33_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_33_id_seq OWNED BY favorites_33.id;


--
-- Name: favorites_34; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_34 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_34_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_34_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_34_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_34_id_seq OWNED BY favorites_34.id;


--
-- Name: favorites_35; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_35 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_35_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_35_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_35_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_35_id_seq OWNED BY favorites_35.id;


--
-- Name: favorites_36; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_36 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_36_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_36_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_36_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_36_id_seq OWNED BY favorites_36.id;


--
-- Name: favorites_37; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_37 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_37_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_37_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_37_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_37_id_seq OWNED BY favorites_37.id;


--
-- Name: favorites_38; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_38 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_38_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_38_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_38_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_38_id_seq OWNED BY favorites_38.id;


--
-- Name: favorites_39; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_39 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_39_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_39_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_39_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_39_id_seq OWNED BY favorites_39.id;


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
    user_id integer,
    post_id integer
);


--
-- Name: favorites_40; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_40 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_40_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_40_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_40_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_40_id_seq OWNED BY favorites_40.id;


--
-- Name: favorites_41; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_41 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_41_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_41_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_41_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_41_id_seq OWNED BY favorites_41.id;


--
-- Name: favorites_42; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_42 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_42_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_42_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_42_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_42_id_seq OWNED BY favorites_42.id;


--
-- Name: favorites_43; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_43 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_43_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_43_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_43_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_43_id_seq OWNED BY favorites_43.id;


--
-- Name: favorites_44; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_44 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_44_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_44_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_44_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_44_id_seq OWNED BY favorites_44.id;


--
-- Name: favorites_45; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_45 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_45_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_45_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_45_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_45_id_seq OWNED BY favorites_45.id;


--
-- Name: favorites_46; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_46 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_46_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_46_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_46_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_46_id_seq OWNED BY favorites_46.id;


--
-- Name: favorites_47; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_47 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_47_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_47_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_47_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_47_id_seq OWNED BY favorites_47.id;


--
-- Name: favorites_48; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_48 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_48_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_48_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_48_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_48_id_seq OWNED BY favorites_48.id;


--
-- Name: favorites_49; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_49 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_49_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_49_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_49_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_49_id_seq OWNED BY favorites_49.id;


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
    user_id integer,
    post_id integer
);


--
-- Name: favorites_50; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_50 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_50_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_50_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_50_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_50_id_seq OWNED BY favorites_50.id;


--
-- Name: favorites_51; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_51 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_51_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_51_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_51_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_51_id_seq OWNED BY favorites_51.id;


--
-- Name: favorites_52; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_52 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_52_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_52_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_52_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_52_id_seq OWNED BY favorites_52.id;


--
-- Name: favorites_53; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_53 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_53_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_53_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_53_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_53_id_seq OWNED BY favorites_53.id;


--
-- Name: favorites_54; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_54 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_54_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_54_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_54_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_54_id_seq OWNED BY favorites_54.id;


--
-- Name: favorites_55; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_55 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_55_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_55_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_55_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_55_id_seq OWNED BY favorites_55.id;


--
-- Name: favorites_56; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_56 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_56_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_56_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_56_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_56_id_seq OWNED BY favorites_56.id;


--
-- Name: favorites_57; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_57 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_57_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_57_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_57_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_57_id_seq OWNED BY favorites_57.id;


--
-- Name: favorites_58; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_58 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_58_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_58_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_58_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_58_id_seq OWNED BY favorites_58.id;


--
-- Name: favorites_59; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_59 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_59_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_59_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_59_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_59_id_seq OWNED BY favorites_59.id;


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
    user_id integer,
    post_id integer
);


--
-- Name: favorites_60; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_60 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_60_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_60_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_60_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_60_id_seq OWNED BY favorites_60.id;


--
-- Name: favorites_61; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_61 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_61_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_61_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_61_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_61_id_seq OWNED BY favorites_61.id;


--
-- Name: favorites_62; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_62 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_62_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_62_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_62_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_62_id_seq OWNED BY favorites_62.id;


--
-- Name: favorites_63; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_63 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_63_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_63_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_63_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_63_id_seq OWNED BY favorites_63.id;


--
-- Name: favorites_64; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_64 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_64_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_64_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_64_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_64_id_seq OWNED BY favorites_64.id;


--
-- Name: favorites_65; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_65 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_65_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_65_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_65_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_65_id_seq OWNED BY favorites_65.id;


--
-- Name: favorites_66; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_66 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_66_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_66_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_66_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_66_id_seq OWNED BY favorites_66.id;


--
-- Name: favorites_67; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_67 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_67_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_67_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_67_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_67_id_seq OWNED BY favorites_67.id;


--
-- Name: favorites_68; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_68 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_68_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_68_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_68_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_68_id_seq OWNED BY favorites_68.id;


--
-- Name: favorites_69; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_69 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_69_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_69_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_69_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_69_id_seq OWNED BY favorites_69.id;


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
    user_id integer,
    post_id integer
);


--
-- Name: favorites_70; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_70 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_70_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_70_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_70_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_70_id_seq OWNED BY favorites_70.id;


--
-- Name: favorites_71; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_71 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_71_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_71_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_71_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_71_id_seq OWNED BY favorites_71.id;


--
-- Name: favorites_72; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_72 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_72_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_72_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_72_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_72_id_seq OWNED BY favorites_72.id;


--
-- Name: favorites_73; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_73 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_73_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_73_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_73_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_73_id_seq OWNED BY favorites_73.id;


--
-- Name: favorites_74; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_74 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_74_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_74_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_74_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_74_id_seq OWNED BY favorites_74.id;


--
-- Name: favorites_75; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_75 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_75_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_75_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_75_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_75_id_seq OWNED BY favorites_75.id;


--
-- Name: favorites_76; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_76 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_76_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_76_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_76_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_76_id_seq OWNED BY favorites_76.id;


--
-- Name: favorites_77; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_77 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_77_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_77_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_77_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_77_id_seq OWNED BY favorites_77.id;


--
-- Name: favorites_78; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_78 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_78_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_78_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_78_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_78_id_seq OWNED BY favorites_78.id;


--
-- Name: favorites_79; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_79 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_79_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_79_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_79_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_79_id_seq OWNED BY favorites_79.id;


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
    user_id integer,
    post_id integer
);


--
-- Name: favorites_80; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_80 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_80_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_80_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_80_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_80_id_seq OWNED BY favorites_80.id;


--
-- Name: favorites_81; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_81 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_81_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_81_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_81_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_81_id_seq OWNED BY favorites_81.id;


--
-- Name: favorites_82; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_82 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_82_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_82_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_82_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_82_id_seq OWNED BY favorites_82.id;


--
-- Name: favorites_83; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_83 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_83_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_83_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_83_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_83_id_seq OWNED BY favorites_83.id;


--
-- Name: favorites_84; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_84 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_84_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_84_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_84_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_84_id_seq OWNED BY favorites_84.id;


--
-- Name: favorites_85; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_85 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_85_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_85_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_85_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_85_id_seq OWNED BY favorites_85.id;


--
-- Name: favorites_86; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_86 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_86_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_86_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_86_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_86_id_seq OWNED BY favorites_86.id;


--
-- Name: favorites_87; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_87 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_87_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_87_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_87_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_87_id_seq OWNED BY favorites_87.id;


--
-- Name: favorites_88; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_88 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_88_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_88_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_88_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_88_id_seq OWNED BY favorites_88.id;


--
-- Name: favorites_89; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_89 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_89_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_89_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_89_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_89_id_seq OWNED BY favorites_89.id;


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
    user_id integer,
    post_id integer
);


--
-- Name: favorites_90; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_90 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_90_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_90_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_90_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_90_id_seq OWNED BY favorites_90.id;


--
-- Name: favorites_91; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_91 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_91_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_91_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_91_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_91_id_seq OWNED BY favorites_91.id;


--
-- Name: favorites_92; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_92 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_92_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_92_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_92_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_92_id_seq OWNED BY favorites_92.id;


--
-- Name: favorites_93; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_93 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_93_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_93_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_93_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_93_id_seq OWNED BY favorites_93.id;


--
-- Name: favorites_94; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_94 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_94_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_94_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_94_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_94_id_seq OWNED BY favorites_94.id;


--
-- Name: favorites_95; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_95 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_95_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_95_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_95_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_95_id_seq OWNED BY favorites_95.id;


--
-- Name: favorites_96; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_96 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_96_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_96_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_96_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_96_id_seq OWNED BY favorites_96.id;


--
-- Name: favorites_97; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_97 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_97_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_97_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_97_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_97_id_seq OWNED BY favorites_97.id;


--
-- Name: favorites_98; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_98 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_98_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_98_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_98_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_98_id_seq OWNED BY favorites_98.id;


--
-- Name: favorites_99; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites_99 (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_99_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_99_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_99_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_99_id_seq OWNED BY favorites_99.id;


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
-- Name: favorites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_id_seq OWNED BY favorites.id;


--
-- Name: forum_posts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE forum_posts (
    id integer NOT NULL,
    topic_id integer NOT NULL,
    creator_id integer NOT NULL,
    updater_id integer NOT NULL,
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
    updater_id integer NOT NULL,
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
    creator_id integer NOT NULL,
    user_id integer NOT NULL,
    original_level integer NOT NULL,
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
    is_active boolean DEFAULT true NOT NULL,
    post_ids text DEFAULT ''::text NOT NULL,
    post_count integer DEFAULT 0 NOT NULL,
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
-- Name: post_appeals; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE post_appeals (
    id integer NOT NULL,
    post_id integer NOT NULL,
    creator_id integer NOT NULL,
    creator_ip_addr integer NOT NULL,
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
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: post_appeals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE post_appeals_id_seq OWNED BY post_appeals.id;


--
-- Name: post_disapprovals; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE post_disapprovals (
    id integer NOT NULL,
    user_id integer NOT NULL,
    post_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: post_disapprovals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE post_disapprovals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: post_disapprovals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE post_disapprovals_id_seq OWNED BY post_disapprovals.id;


--
-- Name: post_flags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: post_flags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE post_flags_id_seq OWNED BY post_flags.id;


--
-- Name: post_versions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE post_versions (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    post_id integer NOT NULL,
    add_tags text DEFAULT ''::text NOT NULL,
    del_tags text DEFAULT ''::text NOT NULL,
    rating character(1),
    parent_id integer,
    source text,
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
    up_score integer DEFAULT 0 NOT NULL,
    down_score integer DEFAULT 0 NOT NULL,
    score integer DEFAULT 0 NOT NULL,
    source character varying(255),
    md5 character varying(255) NOT NULL,
    rating character(1) DEFAULT 'q'::bpchar NOT NULL,
    is_note_locked boolean DEFAULT false NOT NULL,
    is_rating_locked boolean DEFAULT false NOT NULL,
    is_pending boolean DEFAULT false NOT NULL,
    is_flagged boolean DEFAULT false NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    uploader_id integer NOT NULL,
    uploader_ip_addr inet NOT NULL,
    approver_id integer,
    fav_string text DEFAULT ''::text NOT NULL,
    pool_string text DEFAULT ''::text NOT NULL,
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
    is_public boolean DEFAULT true NOT NULL,
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
    level integer DEFAULT 0 NOT NULL,
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

ALTER TABLE favorites ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


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

ALTER TABLE favorites_10 ALTER COLUMN id SET DEFAULT nextval('favorites_10_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_11 ALTER COLUMN id SET DEFAULT nextval('favorites_11_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_12 ALTER COLUMN id SET DEFAULT nextval('favorites_12_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_13 ALTER COLUMN id SET DEFAULT nextval('favorites_13_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_14 ALTER COLUMN id SET DEFAULT nextval('favorites_14_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_15 ALTER COLUMN id SET DEFAULT nextval('favorites_15_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_16 ALTER COLUMN id SET DEFAULT nextval('favorites_16_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_17 ALTER COLUMN id SET DEFAULT nextval('favorites_17_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_18 ALTER COLUMN id SET DEFAULT nextval('favorites_18_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_19 ALTER COLUMN id SET DEFAULT nextval('favorites_19_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_2 ALTER COLUMN id SET DEFAULT nextval('favorites_2_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_20 ALTER COLUMN id SET DEFAULT nextval('favorites_20_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_21 ALTER COLUMN id SET DEFAULT nextval('favorites_21_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_22 ALTER COLUMN id SET DEFAULT nextval('favorites_22_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_23 ALTER COLUMN id SET DEFAULT nextval('favorites_23_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_24 ALTER COLUMN id SET DEFAULT nextval('favorites_24_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_25 ALTER COLUMN id SET DEFAULT nextval('favorites_25_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_26 ALTER COLUMN id SET DEFAULT nextval('favorites_26_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_27 ALTER COLUMN id SET DEFAULT nextval('favorites_27_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_28 ALTER COLUMN id SET DEFAULT nextval('favorites_28_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_29 ALTER COLUMN id SET DEFAULT nextval('favorites_29_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_3 ALTER COLUMN id SET DEFAULT nextval('favorites_3_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_30 ALTER COLUMN id SET DEFAULT nextval('favorites_30_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_31 ALTER COLUMN id SET DEFAULT nextval('favorites_31_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_32 ALTER COLUMN id SET DEFAULT nextval('favorites_32_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_33 ALTER COLUMN id SET DEFAULT nextval('favorites_33_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_34 ALTER COLUMN id SET DEFAULT nextval('favorites_34_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_35 ALTER COLUMN id SET DEFAULT nextval('favorites_35_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_36 ALTER COLUMN id SET DEFAULT nextval('favorites_36_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_37 ALTER COLUMN id SET DEFAULT nextval('favorites_37_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_38 ALTER COLUMN id SET DEFAULT nextval('favorites_38_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_39 ALTER COLUMN id SET DEFAULT nextval('favorites_39_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_4 ALTER COLUMN id SET DEFAULT nextval('favorites_4_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_40 ALTER COLUMN id SET DEFAULT nextval('favorites_40_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_41 ALTER COLUMN id SET DEFAULT nextval('favorites_41_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_42 ALTER COLUMN id SET DEFAULT nextval('favorites_42_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_43 ALTER COLUMN id SET DEFAULT nextval('favorites_43_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_44 ALTER COLUMN id SET DEFAULT nextval('favorites_44_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_45 ALTER COLUMN id SET DEFAULT nextval('favorites_45_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_46 ALTER COLUMN id SET DEFAULT nextval('favorites_46_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_47 ALTER COLUMN id SET DEFAULT nextval('favorites_47_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_48 ALTER COLUMN id SET DEFAULT nextval('favorites_48_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_49 ALTER COLUMN id SET DEFAULT nextval('favorites_49_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_5 ALTER COLUMN id SET DEFAULT nextval('favorites_5_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_50 ALTER COLUMN id SET DEFAULT nextval('favorites_50_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_51 ALTER COLUMN id SET DEFAULT nextval('favorites_51_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_52 ALTER COLUMN id SET DEFAULT nextval('favorites_52_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_53 ALTER COLUMN id SET DEFAULT nextval('favorites_53_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_54 ALTER COLUMN id SET DEFAULT nextval('favorites_54_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_55 ALTER COLUMN id SET DEFAULT nextval('favorites_55_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_56 ALTER COLUMN id SET DEFAULT nextval('favorites_56_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_57 ALTER COLUMN id SET DEFAULT nextval('favorites_57_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_58 ALTER COLUMN id SET DEFAULT nextval('favorites_58_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_59 ALTER COLUMN id SET DEFAULT nextval('favorites_59_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_6 ALTER COLUMN id SET DEFAULT nextval('favorites_6_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_60 ALTER COLUMN id SET DEFAULT nextval('favorites_60_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_61 ALTER COLUMN id SET DEFAULT nextval('favorites_61_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_62 ALTER COLUMN id SET DEFAULT nextval('favorites_62_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_63 ALTER COLUMN id SET DEFAULT nextval('favorites_63_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_64 ALTER COLUMN id SET DEFAULT nextval('favorites_64_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_65 ALTER COLUMN id SET DEFAULT nextval('favorites_65_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_66 ALTER COLUMN id SET DEFAULT nextval('favorites_66_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_67 ALTER COLUMN id SET DEFAULT nextval('favorites_67_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_68 ALTER COLUMN id SET DEFAULT nextval('favorites_68_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_69 ALTER COLUMN id SET DEFAULT nextval('favorites_69_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_7 ALTER COLUMN id SET DEFAULT nextval('favorites_7_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_70 ALTER COLUMN id SET DEFAULT nextval('favorites_70_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_71 ALTER COLUMN id SET DEFAULT nextval('favorites_71_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_72 ALTER COLUMN id SET DEFAULT nextval('favorites_72_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_73 ALTER COLUMN id SET DEFAULT nextval('favorites_73_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_74 ALTER COLUMN id SET DEFAULT nextval('favorites_74_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_75 ALTER COLUMN id SET DEFAULT nextval('favorites_75_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_76 ALTER COLUMN id SET DEFAULT nextval('favorites_76_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_77 ALTER COLUMN id SET DEFAULT nextval('favorites_77_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_78 ALTER COLUMN id SET DEFAULT nextval('favorites_78_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_79 ALTER COLUMN id SET DEFAULT nextval('favorites_79_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_8 ALTER COLUMN id SET DEFAULT nextval('favorites_8_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_80 ALTER COLUMN id SET DEFAULT nextval('favorites_80_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_81 ALTER COLUMN id SET DEFAULT nextval('favorites_81_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_82 ALTER COLUMN id SET DEFAULT nextval('favorites_82_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_83 ALTER COLUMN id SET DEFAULT nextval('favorites_83_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_84 ALTER COLUMN id SET DEFAULT nextval('favorites_84_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_85 ALTER COLUMN id SET DEFAULT nextval('favorites_85_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_86 ALTER COLUMN id SET DEFAULT nextval('favorites_86_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_87 ALTER COLUMN id SET DEFAULT nextval('favorites_87_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_88 ALTER COLUMN id SET DEFAULT nextval('favorites_88_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_89 ALTER COLUMN id SET DEFAULT nextval('favorites_89_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_9 ALTER COLUMN id SET DEFAULT nextval('favorites_9_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_90 ALTER COLUMN id SET DEFAULT nextval('favorites_90_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_91 ALTER COLUMN id SET DEFAULT nextval('favorites_91_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_92 ALTER COLUMN id SET DEFAULT nextval('favorites_92_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_93 ALTER COLUMN id SET DEFAULT nextval('favorites_93_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_94 ALTER COLUMN id SET DEFAULT nextval('favorites_94_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_95 ALTER COLUMN id SET DEFAULT nextval('favorites_95_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_96 ALTER COLUMN id SET DEFAULT nextval('favorites_96_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_97 ALTER COLUMN id SET DEFAULT nextval('favorites_97_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_98 ALTER COLUMN id SET DEFAULT nextval('favorites_98_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites_99 ALTER COLUMN id SET DEFAULT nextval('favorites_99_id_seq'::regclass);


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

ALTER TABLE post_appeals ALTER COLUMN id SET DEFAULT nextval('post_appeals_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE post_disapprovals ALTER COLUMN id SET DEFAULT nextval('post_disapprovals_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE post_flags ALTER COLUMN id SET DEFAULT nextval('post_flags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE post_versions ALTER COLUMN id SET DEFAULT nextval('post_versions_id_seq'::regclass);


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
-- Name: favorites_10_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_10
    ADD CONSTRAINT favorites_10_pkey PRIMARY KEY (id);


--
-- Name: favorites_11_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_11
    ADD CONSTRAINT favorites_11_pkey PRIMARY KEY (id);


--
-- Name: favorites_12_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_12
    ADD CONSTRAINT favorites_12_pkey PRIMARY KEY (id);


--
-- Name: favorites_13_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_13
    ADD CONSTRAINT favorites_13_pkey PRIMARY KEY (id);


--
-- Name: favorites_14_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_14
    ADD CONSTRAINT favorites_14_pkey PRIMARY KEY (id);


--
-- Name: favorites_15_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_15
    ADD CONSTRAINT favorites_15_pkey PRIMARY KEY (id);


--
-- Name: favorites_16_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_16
    ADD CONSTRAINT favorites_16_pkey PRIMARY KEY (id);


--
-- Name: favorites_17_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_17
    ADD CONSTRAINT favorites_17_pkey PRIMARY KEY (id);


--
-- Name: favorites_18_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_18
    ADD CONSTRAINT favorites_18_pkey PRIMARY KEY (id);


--
-- Name: favorites_19_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_19
    ADD CONSTRAINT favorites_19_pkey PRIMARY KEY (id);


--
-- Name: favorites_1_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_1
    ADD CONSTRAINT favorites_1_pkey PRIMARY KEY (id);


--
-- Name: favorites_20_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_20
    ADD CONSTRAINT favorites_20_pkey PRIMARY KEY (id);


--
-- Name: favorites_21_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_21
    ADD CONSTRAINT favorites_21_pkey PRIMARY KEY (id);


--
-- Name: favorites_22_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_22
    ADD CONSTRAINT favorites_22_pkey PRIMARY KEY (id);


--
-- Name: favorites_23_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_23
    ADD CONSTRAINT favorites_23_pkey PRIMARY KEY (id);


--
-- Name: favorites_24_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_24
    ADD CONSTRAINT favorites_24_pkey PRIMARY KEY (id);


--
-- Name: favorites_25_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_25
    ADD CONSTRAINT favorites_25_pkey PRIMARY KEY (id);


--
-- Name: favorites_26_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_26
    ADD CONSTRAINT favorites_26_pkey PRIMARY KEY (id);


--
-- Name: favorites_27_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_27
    ADD CONSTRAINT favorites_27_pkey PRIMARY KEY (id);


--
-- Name: favorites_28_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_28
    ADD CONSTRAINT favorites_28_pkey PRIMARY KEY (id);


--
-- Name: favorites_29_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_29
    ADD CONSTRAINT favorites_29_pkey PRIMARY KEY (id);


--
-- Name: favorites_2_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_2
    ADD CONSTRAINT favorites_2_pkey PRIMARY KEY (id);


--
-- Name: favorites_30_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_30
    ADD CONSTRAINT favorites_30_pkey PRIMARY KEY (id);


--
-- Name: favorites_31_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_31
    ADD CONSTRAINT favorites_31_pkey PRIMARY KEY (id);


--
-- Name: favorites_32_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_32
    ADD CONSTRAINT favorites_32_pkey PRIMARY KEY (id);


--
-- Name: favorites_33_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_33
    ADD CONSTRAINT favorites_33_pkey PRIMARY KEY (id);


--
-- Name: favorites_34_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_34
    ADD CONSTRAINT favorites_34_pkey PRIMARY KEY (id);


--
-- Name: favorites_35_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_35
    ADD CONSTRAINT favorites_35_pkey PRIMARY KEY (id);


--
-- Name: favorites_36_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_36
    ADD CONSTRAINT favorites_36_pkey PRIMARY KEY (id);


--
-- Name: favorites_37_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_37
    ADD CONSTRAINT favorites_37_pkey PRIMARY KEY (id);


--
-- Name: favorites_38_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_38
    ADD CONSTRAINT favorites_38_pkey PRIMARY KEY (id);


--
-- Name: favorites_39_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_39
    ADD CONSTRAINT favorites_39_pkey PRIMARY KEY (id);


--
-- Name: favorites_3_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_3
    ADD CONSTRAINT favorites_3_pkey PRIMARY KEY (id);


--
-- Name: favorites_40_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_40
    ADD CONSTRAINT favorites_40_pkey PRIMARY KEY (id);


--
-- Name: favorites_41_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_41
    ADD CONSTRAINT favorites_41_pkey PRIMARY KEY (id);


--
-- Name: favorites_42_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_42
    ADD CONSTRAINT favorites_42_pkey PRIMARY KEY (id);


--
-- Name: favorites_43_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_43
    ADD CONSTRAINT favorites_43_pkey PRIMARY KEY (id);


--
-- Name: favorites_44_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_44
    ADD CONSTRAINT favorites_44_pkey PRIMARY KEY (id);


--
-- Name: favorites_45_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_45
    ADD CONSTRAINT favorites_45_pkey PRIMARY KEY (id);


--
-- Name: favorites_46_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_46
    ADD CONSTRAINT favorites_46_pkey PRIMARY KEY (id);


--
-- Name: favorites_47_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_47
    ADD CONSTRAINT favorites_47_pkey PRIMARY KEY (id);


--
-- Name: favorites_48_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_48
    ADD CONSTRAINT favorites_48_pkey PRIMARY KEY (id);


--
-- Name: favorites_49_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_49
    ADD CONSTRAINT favorites_49_pkey PRIMARY KEY (id);


--
-- Name: favorites_4_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_4
    ADD CONSTRAINT favorites_4_pkey PRIMARY KEY (id);


--
-- Name: favorites_50_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_50
    ADD CONSTRAINT favorites_50_pkey PRIMARY KEY (id);


--
-- Name: favorites_51_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_51
    ADD CONSTRAINT favorites_51_pkey PRIMARY KEY (id);


--
-- Name: favorites_52_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_52
    ADD CONSTRAINT favorites_52_pkey PRIMARY KEY (id);


--
-- Name: favorites_53_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_53
    ADD CONSTRAINT favorites_53_pkey PRIMARY KEY (id);


--
-- Name: favorites_54_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_54
    ADD CONSTRAINT favorites_54_pkey PRIMARY KEY (id);


--
-- Name: favorites_55_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_55
    ADD CONSTRAINT favorites_55_pkey PRIMARY KEY (id);


--
-- Name: favorites_56_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_56
    ADD CONSTRAINT favorites_56_pkey PRIMARY KEY (id);


--
-- Name: favorites_57_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_57
    ADD CONSTRAINT favorites_57_pkey PRIMARY KEY (id);


--
-- Name: favorites_58_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_58
    ADD CONSTRAINT favorites_58_pkey PRIMARY KEY (id);


--
-- Name: favorites_59_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_59
    ADD CONSTRAINT favorites_59_pkey PRIMARY KEY (id);


--
-- Name: favorites_5_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_5
    ADD CONSTRAINT favorites_5_pkey PRIMARY KEY (id);


--
-- Name: favorites_60_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_60
    ADD CONSTRAINT favorites_60_pkey PRIMARY KEY (id);


--
-- Name: favorites_61_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_61
    ADD CONSTRAINT favorites_61_pkey PRIMARY KEY (id);


--
-- Name: favorites_62_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_62
    ADD CONSTRAINT favorites_62_pkey PRIMARY KEY (id);


--
-- Name: favorites_63_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_63
    ADD CONSTRAINT favorites_63_pkey PRIMARY KEY (id);


--
-- Name: favorites_64_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_64
    ADD CONSTRAINT favorites_64_pkey PRIMARY KEY (id);


--
-- Name: favorites_65_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_65
    ADD CONSTRAINT favorites_65_pkey PRIMARY KEY (id);


--
-- Name: favorites_66_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_66
    ADD CONSTRAINT favorites_66_pkey PRIMARY KEY (id);


--
-- Name: favorites_67_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_67
    ADD CONSTRAINT favorites_67_pkey PRIMARY KEY (id);


--
-- Name: favorites_68_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_68
    ADD CONSTRAINT favorites_68_pkey PRIMARY KEY (id);


--
-- Name: favorites_69_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_69
    ADD CONSTRAINT favorites_69_pkey PRIMARY KEY (id);


--
-- Name: favorites_6_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_6
    ADD CONSTRAINT favorites_6_pkey PRIMARY KEY (id);


--
-- Name: favorites_70_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_70
    ADD CONSTRAINT favorites_70_pkey PRIMARY KEY (id);


--
-- Name: favorites_71_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_71
    ADD CONSTRAINT favorites_71_pkey PRIMARY KEY (id);


--
-- Name: favorites_72_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_72
    ADD CONSTRAINT favorites_72_pkey PRIMARY KEY (id);


--
-- Name: favorites_73_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_73
    ADD CONSTRAINT favorites_73_pkey PRIMARY KEY (id);


--
-- Name: favorites_74_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_74
    ADD CONSTRAINT favorites_74_pkey PRIMARY KEY (id);


--
-- Name: favorites_75_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_75
    ADD CONSTRAINT favorites_75_pkey PRIMARY KEY (id);


--
-- Name: favorites_76_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_76
    ADD CONSTRAINT favorites_76_pkey PRIMARY KEY (id);


--
-- Name: favorites_77_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_77
    ADD CONSTRAINT favorites_77_pkey PRIMARY KEY (id);


--
-- Name: favorites_78_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_78
    ADD CONSTRAINT favorites_78_pkey PRIMARY KEY (id);


--
-- Name: favorites_79_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_79
    ADD CONSTRAINT favorites_79_pkey PRIMARY KEY (id);


--
-- Name: favorites_7_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_7
    ADD CONSTRAINT favorites_7_pkey PRIMARY KEY (id);


--
-- Name: favorites_80_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_80
    ADD CONSTRAINT favorites_80_pkey PRIMARY KEY (id);


--
-- Name: favorites_81_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_81
    ADD CONSTRAINT favorites_81_pkey PRIMARY KEY (id);


--
-- Name: favorites_82_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_82
    ADD CONSTRAINT favorites_82_pkey PRIMARY KEY (id);


--
-- Name: favorites_83_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_83
    ADD CONSTRAINT favorites_83_pkey PRIMARY KEY (id);


--
-- Name: favorites_84_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_84
    ADD CONSTRAINT favorites_84_pkey PRIMARY KEY (id);


--
-- Name: favorites_85_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_85
    ADD CONSTRAINT favorites_85_pkey PRIMARY KEY (id);


--
-- Name: favorites_86_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_86
    ADD CONSTRAINT favorites_86_pkey PRIMARY KEY (id);


--
-- Name: favorites_87_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_87
    ADD CONSTRAINT favorites_87_pkey PRIMARY KEY (id);


--
-- Name: favorites_88_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_88
    ADD CONSTRAINT favorites_88_pkey PRIMARY KEY (id);


--
-- Name: favorites_89_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_89
    ADD CONSTRAINT favorites_89_pkey PRIMARY KEY (id);


--
-- Name: favorites_8_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_8
    ADD CONSTRAINT favorites_8_pkey PRIMARY KEY (id);


--
-- Name: favorites_90_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_90
    ADD CONSTRAINT favorites_90_pkey PRIMARY KEY (id);


--
-- Name: favorites_91_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_91
    ADD CONSTRAINT favorites_91_pkey PRIMARY KEY (id);


--
-- Name: favorites_92_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_92
    ADD CONSTRAINT favorites_92_pkey PRIMARY KEY (id);


--
-- Name: favorites_93_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_93
    ADD CONSTRAINT favorites_93_pkey PRIMARY KEY (id);


--
-- Name: favorites_94_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_94
    ADD CONSTRAINT favorites_94_pkey PRIMARY KEY (id);


--
-- Name: favorites_95_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_95
    ADD CONSTRAINT favorites_95_pkey PRIMARY KEY (id);


--
-- Name: favorites_96_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_96
    ADD CONSTRAINT favorites_96_pkey PRIMARY KEY (id);


--
-- Name: favorites_97_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_97
    ADD CONSTRAINT favorites_97_pkey PRIMARY KEY (id);


--
-- Name: favorites_98_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_98
    ADD CONSTRAINT favorites_98_pkey PRIMARY KEY (id);


--
-- Name: favorites_99_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_99
    ADD CONSTRAINT favorites_99_pkey PRIMARY KEY (id);


--
-- Name: favorites_9_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites_9
    ADD CONSTRAINT favorites_9_pkey PRIMARY KEY (id);


--
-- Name: favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites
    ADD CONSTRAINT favorites_pkey PRIMARY KEY (id);


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
-- Name: post_appeals_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY post_appeals
    ADD CONSTRAINT post_appeals_pkey PRIMARY KEY (id);


--
-- Name: post_disapprovals_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY post_disapprovals
    ADD CONSTRAINT post_disapprovals_pkey PRIMARY KEY (id);


--
-- Name: post_flags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY post_flags
    ADD CONSTRAINT post_flags_pkey PRIMARY KEY (id);


--
-- Name: post_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY post_versions
    ADD CONSTRAINT post_versions_pkey PRIMARY KEY (id);


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
-- Name: index_favorites_0_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

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
-- Name: index_note_versions_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_note_versions_on_post_id ON note_versions USING btree (post_id);


--
-- Name: index_note_versions_on_updater_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_note_versions_on_updater_id ON note_versions USING btree (updater_id);


--
-- Name: index_note_versions_on_updater_ip_addr; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_note_versions_on_updater_ip_addr ON note_versions USING btree (updater_ip_addr);


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
-- Name: index_post_appeals_on_creator_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_post_appeals_on_creator_id ON post_appeals USING btree (creator_id);


--
-- Name: index_post_appeals_on_creator_ip_addr; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_post_appeals_on_creator_ip_addr ON post_appeals USING btree (creator_ip_addr);


--
-- Name: index_post_appeals_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_post_appeals_on_post_id ON post_appeals USING btree (post_id);


--
-- Name: index_post_disapprovals_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_post_disapprovals_on_post_id ON post_disapprovals USING btree (post_id);


--
-- Name: index_post_disapprovals_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_post_disapprovals_on_user_id ON post_disapprovals USING btree (user_id);


--
-- Name: index_post_flags_on_creator_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_post_flags_on_creator_id ON post_flags USING btree (creator_id);


--
-- Name: index_post_flags_on_creator_ip_addr; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_post_flags_on_creator_ip_addr ON post_flags USING btree (creator_ip_addr);


--
-- Name: index_post_flags_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_post_flags_on_post_id ON post_flags USING btree (post_id);


--
-- Name: index_post_versions_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_post_versions_on_post_id ON post_versions USING btree (post_id);


--
-- Name: index_post_versions_on_updater_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_post_versions_on_updater_id ON post_versions USING btree (updater_id);


--
-- Name: index_post_versions_on_updater_ip_addr; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_post_versions_on_updater_ip_addr ON post_versions USING btree (updater_ip_addr);


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
-- Name: index_user_feedback_on_creator_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_feedback_on_creator_id ON user_feedback USING btree (creator_id);


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
    EXECUTE PROCEDURE tsvector_update_trigger('tag_index', 'public.danbooru', 'tag_string', 'fav_string', 'pool_string');


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