SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: favorites_insert_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.favorites_insert_trigger() RETURNS trigger
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
-- Name: testprs_end(internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.testprs_end(internal) RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/test_parser', 'testprs_end';


--
-- Name: testprs_getlexeme(internal, internal, internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.testprs_getlexeme(internal, internal, internal) RETURNS internal
    LANGUAGE c STRICT
    AS '$libdir/test_parser', 'testprs_getlexeme';


--
-- Name: testprs_lextype(internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.testprs_lextype(internal) RETURNS internal
    LANGUAGE c STRICT
    AS '$libdir/test_parser', 'testprs_lextype';


--
-- Name: testprs_start(internal, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.testprs_start(internal, integer) RETURNS internal
    LANGUAGE c STRICT
    AS '$libdir/test_parser', 'testprs_start';


--
-- Name: testparser; Type: TEXT SEARCH PARSER; Schema: public; Owner: -
--

CREATE TEXT SEARCH PARSER public.testparser (
    START = public.testprs_start,
    GETTOKEN = public.testprs_getlexeme,
    END = public.testprs_end,
    HEADLINE = prsd_headline,
    LEXTYPES = public.testprs_lextype );


--
-- Name: danbooru; Type: TEXT SEARCH CONFIGURATION; Schema: public; Owner: -
--

CREATE TEXT SEARCH CONFIGURATION public.danbooru (
    PARSER = public.testparser );

ALTER TEXT SEARCH CONFIGURATION public.danbooru
    ADD MAPPING FOR word WITH simple;


SET default_tablespace = '';

--
-- Name: api_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.api_keys (
    id integer NOT NULL,
    user_id integer NOT NULL,
    key character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: api_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.api_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: api_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.api_keys_id_seq OWNED BY public.api_keys.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: artist_commentaries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.artist_commentaries (
    id integer NOT NULL,
    post_id integer NOT NULL,
    original_title text DEFAULT ''::text NOT NULL,
    original_description text DEFAULT ''::text NOT NULL,
    translated_title text DEFAULT ''::text NOT NULL,
    translated_description text DEFAULT ''::text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: artist_commentaries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.artist_commentaries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: artist_commentaries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.artist_commentaries_id_seq OWNED BY public.artist_commentaries.id;


--
-- Name: artist_commentary_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.artist_commentary_versions (
    id integer NOT NULL,
    post_id integer NOT NULL,
    updater_id integer NOT NULL,
    updater_ip_addr inet NOT NULL,
    original_title text DEFAULT ''::text NOT NULL,
    original_description text DEFAULT ''::text NOT NULL,
    translated_title text DEFAULT ''::text NOT NULL,
    translated_description text DEFAULT ''::text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: artist_commentary_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.artist_commentary_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: artist_commentary_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.artist_commentary_versions_id_seq OWNED BY public.artist_commentary_versions.id;


--
-- Name: artist_urls; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.artist_urls (
    id integer NOT NULL,
    artist_id integer NOT NULL,
    url text NOT NULL,
    normalized_url text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_active boolean DEFAULT true NOT NULL
);


--
-- Name: artist_urls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.artist_urls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: artist_urls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.artist_urls_id_seq OWNED BY public.artist_urls.id;


--
-- Name: artist_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.artist_versions (
    id integer NOT NULL,
    artist_id integer NOT NULL,
    name character varying NOT NULL,
    updater_id integer NOT NULL,
    updater_ip_addr inet NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    other_names text[] DEFAULT '{}'::text[] NOT NULL,
    group_name character varying DEFAULT ''::character varying NOT NULL,
    urls text[] DEFAULT '{}'::text[] NOT NULL,
    is_banned boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: artist_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.artist_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: artist_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.artist_versions_id_seq OWNED BY public.artist_versions.id;


--
-- Name: artists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.artists (
    id integer NOT NULL,
    name character varying NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    is_banned boolean DEFAULT false NOT NULL,
    other_names text[] DEFAULT '{}'::text[] NOT NULL,
    group_name character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: artists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.artists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: artists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.artists_id_seq OWNED BY public.artists.id;


--
-- Name: bans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bans (
    id integer NOT NULL,
    user_id integer,
    reason text NOT NULL,
    banner_id integer NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: bans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bans_id_seq OWNED BY public.bans.id;


--
-- Name: bulk_update_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bulk_update_requests (
    id integer NOT NULL,
    user_id integer NOT NULL,
    forum_topic_id integer,
    script text NOT NULL,
    status character varying DEFAULT 'pending'::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    approver_id integer,
    forum_post_id integer,
    tags text[] DEFAULT '{}'::text[] NOT NULL
);


--
-- Name: bulk_update_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bulk_update_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bulk_update_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bulk_update_requests_id_seq OWNED BY public.bulk_update_requests.id;


--
-- Name: comment_votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comment_votes (
    id integer NOT NULL,
    comment_id integer NOT NULL,
    user_id integer NOT NULL,
    score integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: comment_votes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comment_votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comment_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comment_votes_id_seq OWNED BY public.comment_votes.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    id integer NOT NULL,
    post_id integer NOT NULL,
    creator_id integer NOT NULL,
    body text NOT NULL,
    creator_ip_addr inet NOT NULL,
    body_index tsvector NOT NULL,
    score integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    updater_id integer,
    updater_ip_addr inet,
    do_not_bump_post boolean DEFAULT false NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    is_sticky boolean DEFAULT false NOT NULL
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delayed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0,
    attempts integer DEFAULT 0,
    handler text,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    queue character varying
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.delayed_jobs_id_seq OWNED BY public.delayed_jobs.id;


--
-- Name: dmails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dmails (
    id integer NOT NULL,
    owner_id integer NOT NULL,
    from_id integer NOT NULL,
    to_id integer NOT NULL,
    title text NOT NULL,
    body text NOT NULL,
    message_index tsvector NOT NULL,
    is_read boolean DEFAULT false NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    creator_ip_addr inet NOT NULL,
    is_spam boolean DEFAULT false
);


--
-- Name: dmails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dmails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dmails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dmails_id_seq OWNED BY public.dmails.id;


--
-- Name: dtext_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dtext_links (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    model_type character varying NOT NULL,
    model_id bigint NOT NULL,
    link_type integer NOT NULL,
    link_target character varying NOT NULL
);


--
-- Name: dtext_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dtext_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dtext_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dtext_links_id_seq OWNED BY public.dtext_links.id;


--
-- Name: email_addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.email_addresses (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_id bigint NOT NULL,
    address character varying NOT NULL,
    normalized_address character varying NOT NULL,
    is_verified boolean DEFAULT false NOT NULL,
    is_deliverable boolean DEFAULT true NOT NULL
);


--
-- Name: email_addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.email_addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.email_addresses_id_seq OWNED BY public.email_addresses.id;


--
-- Name: favorite_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorite_groups (
    id integer NOT NULL,
    name text NOT NULL,
    creator_id integer NOT NULL,
    post_ids integer[] DEFAULT '{}'::integer[] NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_public boolean DEFAULT true NOT NULL
);


--
-- Name: favorite_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.favorite_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: favorite_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.favorite_groups_id_seq OWNED BY public.favorite_groups.id;


--
-- Name: favorites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites (
    id integer NOT NULL,
    user_id integer,
    post_id integer
);


--
-- Name: favorites_0; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_0 (
    CONSTRAINT favorites_0_user_id_check CHECK (((user_id % 100) = 0))
)
INHERITS (public.favorites);


--
-- Name: favorites_1; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_1 (
    CONSTRAINT favorites_1_user_id_check CHECK (((user_id % 100) = 1))
)
INHERITS (public.favorites);


--
-- Name: favorites_10; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_10 (
    CONSTRAINT favorites_10_user_id_check CHECK (((user_id % 100) = 10))
)
INHERITS (public.favorites);


--
-- Name: favorites_11; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_11 (
    CONSTRAINT favorites_11_user_id_check CHECK (((user_id % 100) = 11))
)
INHERITS (public.favorites);


--
-- Name: favorites_12; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_12 (
    CONSTRAINT favorites_12_user_id_check CHECK (((user_id % 100) = 12))
)
INHERITS (public.favorites);


--
-- Name: favorites_13; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_13 (
    CONSTRAINT favorites_13_user_id_check CHECK (((user_id % 100) = 13))
)
INHERITS (public.favorites);


--
-- Name: favorites_14; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_14 (
    CONSTRAINT favorites_14_user_id_check CHECK (((user_id % 100) = 14))
)
INHERITS (public.favorites);


--
-- Name: favorites_15; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_15 (
    CONSTRAINT favorites_15_user_id_check CHECK (((user_id % 100) = 15))
)
INHERITS (public.favorites);


--
-- Name: favorites_16; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_16 (
    CONSTRAINT favorites_16_user_id_check CHECK (((user_id % 100) = 16))
)
INHERITS (public.favorites);


--
-- Name: favorites_17; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_17 (
    CONSTRAINT favorites_17_user_id_check CHECK (((user_id % 100) = 17))
)
INHERITS (public.favorites);


--
-- Name: favorites_18; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_18 (
    CONSTRAINT favorites_18_user_id_check CHECK (((user_id % 100) = 18))
)
INHERITS (public.favorites);


--
-- Name: favorites_19; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_19 (
    CONSTRAINT favorites_19_user_id_check CHECK (((user_id % 100) = 19))
)
INHERITS (public.favorites);


--
-- Name: favorites_2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_2 (
    CONSTRAINT favorites_2_user_id_check CHECK (((user_id % 100) = 2))
)
INHERITS (public.favorites);


--
-- Name: favorites_20; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_20 (
    CONSTRAINT favorites_20_user_id_check CHECK (((user_id % 100) = 20))
)
INHERITS (public.favorites);


--
-- Name: favorites_21; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_21 (
    CONSTRAINT favorites_21_user_id_check CHECK (((user_id % 100) = 21))
)
INHERITS (public.favorites);


--
-- Name: favorites_22; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_22 (
    CONSTRAINT favorites_22_user_id_check CHECK (((user_id % 100) = 22))
)
INHERITS (public.favorites);


--
-- Name: favorites_23; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_23 (
    CONSTRAINT favorites_23_user_id_check CHECK (((user_id % 100) = 23))
)
INHERITS (public.favorites);


--
-- Name: favorites_24; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_24 (
    CONSTRAINT favorites_24_user_id_check CHECK (((user_id % 100) = 24))
)
INHERITS (public.favorites);


--
-- Name: favorites_25; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_25 (
    CONSTRAINT favorites_25_user_id_check CHECK (((user_id % 100) = 25))
)
INHERITS (public.favorites);


--
-- Name: favorites_26; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_26 (
    CONSTRAINT favorites_26_user_id_check CHECK (((user_id % 100) = 26))
)
INHERITS (public.favorites);


--
-- Name: favorites_27; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_27 (
    CONSTRAINT favorites_27_user_id_check CHECK (((user_id % 100) = 27))
)
INHERITS (public.favorites);


--
-- Name: favorites_28; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_28 (
    CONSTRAINT favorites_28_user_id_check CHECK (((user_id % 100) = 28))
)
INHERITS (public.favorites);


--
-- Name: favorites_29; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_29 (
    CONSTRAINT favorites_29_user_id_check CHECK (((user_id % 100) = 29))
)
INHERITS (public.favorites);


--
-- Name: favorites_3; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_3 (
    CONSTRAINT favorites_3_user_id_check CHECK (((user_id % 100) = 3))
)
INHERITS (public.favorites);


--
-- Name: favorites_30; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_30 (
    CONSTRAINT favorites_30_user_id_check CHECK (((user_id % 100) = 30))
)
INHERITS (public.favorites);


--
-- Name: favorites_31; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_31 (
    CONSTRAINT favorites_31_user_id_check CHECK (((user_id % 100) = 31))
)
INHERITS (public.favorites);


--
-- Name: favorites_32; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_32 (
    CONSTRAINT favorites_32_user_id_check CHECK (((user_id % 100) = 32))
)
INHERITS (public.favorites);


--
-- Name: favorites_33; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_33 (
    CONSTRAINT favorites_33_user_id_check CHECK (((user_id % 100) = 33))
)
INHERITS (public.favorites);


--
-- Name: favorites_34; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_34 (
    CONSTRAINT favorites_34_user_id_check CHECK (((user_id % 100) = 34))
)
INHERITS (public.favorites);


--
-- Name: favorites_35; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_35 (
    CONSTRAINT favorites_35_user_id_check CHECK (((user_id % 100) = 35))
)
INHERITS (public.favorites);


--
-- Name: favorites_36; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_36 (
    CONSTRAINT favorites_36_user_id_check CHECK (((user_id % 100) = 36))
)
INHERITS (public.favorites);


--
-- Name: favorites_37; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_37 (
    CONSTRAINT favorites_37_user_id_check CHECK (((user_id % 100) = 37))
)
INHERITS (public.favorites);


--
-- Name: favorites_38; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_38 (
    CONSTRAINT favorites_38_user_id_check CHECK (((user_id % 100) = 38))
)
INHERITS (public.favorites);


--
-- Name: favorites_39; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_39 (
    CONSTRAINT favorites_39_user_id_check CHECK (((user_id % 100) = 39))
)
INHERITS (public.favorites);


--
-- Name: favorites_4; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_4 (
    CONSTRAINT favorites_4_user_id_check CHECK (((user_id % 100) = 4))
)
INHERITS (public.favorites);


--
-- Name: favorites_40; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_40 (
    CONSTRAINT favorites_40_user_id_check CHECK (((user_id % 100) = 40))
)
INHERITS (public.favorites);


--
-- Name: favorites_41; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_41 (
    CONSTRAINT favorites_41_user_id_check CHECK (((user_id % 100) = 41))
)
INHERITS (public.favorites);


--
-- Name: favorites_42; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_42 (
    CONSTRAINT favorites_42_user_id_check CHECK (((user_id % 100) = 42))
)
INHERITS (public.favorites);


--
-- Name: favorites_43; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_43 (
    CONSTRAINT favorites_43_user_id_check CHECK (((user_id % 100) = 43))
)
INHERITS (public.favorites);


--
-- Name: favorites_44; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_44 (
    CONSTRAINT favorites_44_user_id_check CHECK (((user_id % 100) = 44))
)
INHERITS (public.favorites);


--
-- Name: favorites_45; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_45 (
    CONSTRAINT favorites_45_user_id_check CHECK (((user_id % 100) = 45))
)
INHERITS (public.favorites);


--
-- Name: favorites_46; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_46 (
    CONSTRAINT favorites_46_user_id_check CHECK (((user_id % 100) = 46))
)
INHERITS (public.favorites);


--
-- Name: favorites_47; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_47 (
    CONSTRAINT favorites_47_user_id_check CHECK (((user_id % 100) = 47))
)
INHERITS (public.favorites);


--
-- Name: favorites_48; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_48 (
    CONSTRAINT favorites_48_user_id_check CHECK (((user_id % 100) = 48))
)
INHERITS (public.favorites);


--
-- Name: favorites_49; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_49 (
    CONSTRAINT favorites_49_user_id_check CHECK (((user_id % 100) = 49))
)
INHERITS (public.favorites);


--
-- Name: favorites_5; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_5 (
    CONSTRAINT favorites_5_user_id_check CHECK (((user_id % 100) = 5))
)
INHERITS (public.favorites);


--
-- Name: favorites_50; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_50 (
    CONSTRAINT favorites_50_user_id_check CHECK (((user_id % 100) = 50))
)
INHERITS (public.favorites);


--
-- Name: favorites_51; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_51 (
    CONSTRAINT favorites_51_user_id_check CHECK (((user_id % 100) = 51))
)
INHERITS (public.favorites);


--
-- Name: favorites_52; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_52 (
    CONSTRAINT favorites_52_user_id_check CHECK (((user_id % 100) = 52))
)
INHERITS (public.favorites);


--
-- Name: favorites_53; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_53 (
    CONSTRAINT favorites_53_user_id_check CHECK (((user_id % 100) = 53))
)
INHERITS (public.favorites);


--
-- Name: favorites_54; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_54 (
    CONSTRAINT favorites_54_user_id_check CHECK (((user_id % 100) = 54))
)
INHERITS (public.favorites);


--
-- Name: favorites_55; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_55 (
    CONSTRAINT favorites_55_user_id_check CHECK (((user_id % 100) = 55))
)
INHERITS (public.favorites);


--
-- Name: favorites_56; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_56 (
    CONSTRAINT favorites_56_user_id_check CHECK (((user_id % 100) = 56))
)
INHERITS (public.favorites);


--
-- Name: favorites_57; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_57 (
    CONSTRAINT favorites_57_user_id_check CHECK (((user_id % 100) = 57))
)
INHERITS (public.favorites);


--
-- Name: favorites_58; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_58 (
    CONSTRAINT favorites_58_user_id_check CHECK (((user_id % 100) = 58))
)
INHERITS (public.favorites);


--
-- Name: favorites_59; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_59 (
    CONSTRAINT favorites_59_user_id_check CHECK (((user_id % 100) = 59))
)
INHERITS (public.favorites);


--
-- Name: favorites_6; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_6 (
    CONSTRAINT favorites_6_user_id_check CHECK (((user_id % 100) = 6))
)
INHERITS (public.favorites);


--
-- Name: favorites_60; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_60 (
    CONSTRAINT favorites_60_user_id_check CHECK (((user_id % 100) = 60))
)
INHERITS (public.favorites);


--
-- Name: favorites_61; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_61 (
    CONSTRAINT favorites_61_user_id_check CHECK (((user_id % 100) = 61))
)
INHERITS (public.favorites);


--
-- Name: favorites_62; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_62 (
    CONSTRAINT favorites_62_user_id_check CHECK (((user_id % 100) = 62))
)
INHERITS (public.favorites);


--
-- Name: favorites_63; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_63 (
    CONSTRAINT favorites_63_user_id_check CHECK (((user_id % 100) = 63))
)
INHERITS (public.favorites);


--
-- Name: favorites_64; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_64 (
    CONSTRAINT favorites_64_user_id_check CHECK (((user_id % 100) = 64))
)
INHERITS (public.favorites);


--
-- Name: favorites_65; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_65 (
    CONSTRAINT favorites_65_user_id_check CHECK (((user_id % 100) = 65))
)
INHERITS (public.favorites);


--
-- Name: favorites_66; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_66 (
    CONSTRAINT favorites_66_user_id_check CHECK (((user_id % 100) = 66))
)
INHERITS (public.favorites);


--
-- Name: favorites_67; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_67 (
    CONSTRAINT favorites_67_user_id_check CHECK (((user_id % 100) = 67))
)
INHERITS (public.favorites);


--
-- Name: favorites_68; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_68 (
    CONSTRAINT favorites_68_user_id_check CHECK (((user_id % 100) = 68))
)
INHERITS (public.favorites);


--
-- Name: favorites_69; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_69 (
    CONSTRAINT favorites_69_user_id_check CHECK (((user_id % 100) = 69))
)
INHERITS (public.favorites);


--
-- Name: favorites_7; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_7 (
    CONSTRAINT favorites_7_user_id_check CHECK (((user_id % 100) = 7))
)
INHERITS (public.favorites);


--
-- Name: favorites_70; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_70 (
    CONSTRAINT favorites_70_user_id_check CHECK (((user_id % 100) = 70))
)
INHERITS (public.favorites);


--
-- Name: favorites_71; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_71 (
    CONSTRAINT favorites_71_user_id_check CHECK (((user_id % 100) = 71))
)
INHERITS (public.favorites);


--
-- Name: favorites_72; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_72 (
    CONSTRAINT favorites_72_user_id_check CHECK (((user_id % 100) = 72))
)
INHERITS (public.favorites);


--
-- Name: favorites_73; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_73 (
    CONSTRAINT favorites_73_user_id_check CHECK (((user_id % 100) = 73))
)
INHERITS (public.favorites);


--
-- Name: favorites_74; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_74 (
    CONSTRAINT favorites_74_user_id_check CHECK (((user_id % 100) = 74))
)
INHERITS (public.favorites);


--
-- Name: favorites_75; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_75 (
    CONSTRAINT favorites_75_user_id_check CHECK (((user_id % 100) = 75))
)
INHERITS (public.favorites);


--
-- Name: favorites_76; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_76 (
    CONSTRAINT favorites_76_user_id_check CHECK (((user_id % 100) = 76))
)
INHERITS (public.favorites);


--
-- Name: favorites_77; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_77 (
    CONSTRAINT favorites_77_user_id_check CHECK (((user_id % 100) = 77))
)
INHERITS (public.favorites);


--
-- Name: favorites_78; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_78 (
    CONSTRAINT favorites_78_user_id_check CHECK (((user_id % 100) = 78))
)
INHERITS (public.favorites);


--
-- Name: favorites_79; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_79 (
    CONSTRAINT favorites_79_user_id_check CHECK (((user_id % 100) = 79))
)
INHERITS (public.favorites);


--
-- Name: favorites_8; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_8 (
    CONSTRAINT favorites_8_user_id_check CHECK (((user_id % 100) = 8))
)
INHERITS (public.favorites);


--
-- Name: favorites_80; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_80 (
    CONSTRAINT favorites_80_user_id_check CHECK (((user_id % 100) = 80))
)
INHERITS (public.favorites);


--
-- Name: favorites_81; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_81 (
    CONSTRAINT favorites_81_user_id_check CHECK (((user_id % 100) = 81))
)
INHERITS (public.favorites);


--
-- Name: favorites_82; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_82 (
    CONSTRAINT favorites_82_user_id_check CHECK (((user_id % 100) = 82))
)
INHERITS (public.favorites);


--
-- Name: favorites_83; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_83 (
    CONSTRAINT favorites_83_user_id_check CHECK (((user_id % 100) = 83))
)
INHERITS (public.favorites);


--
-- Name: favorites_84; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_84 (
    CONSTRAINT favorites_84_user_id_check CHECK (((user_id % 100) = 84))
)
INHERITS (public.favorites);


--
-- Name: favorites_85; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_85 (
    CONSTRAINT favorites_85_user_id_check CHECK (((user_id % 100) = 85))
)
INHERITS (public.favorites);


--
-- Name: favorites_86; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_86 (
    CONSTRAINT favorites_86_user_id_check CHECK (((user_id % 100) = 86))
)
INHERITS (public.favorites);


--
-- Name: favorites_87; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_87 (
    CONSTRAINT favorites_87_user_id_check CHECK (((user_id % 100) = 87))
)
INHERITS (public.favorites);


--
-- Name: favorites_88; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_88 (
    CONSTRAINT favorites_88_user_id_check CHECK (((user_id % 100) = 88))
)
INHERITS (public.favorites);


--
-- Name: favorites_89; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_89 (
    CONSTRAINT favorites_89_user_id_check CHECK (((user_id % 100) = 89))
)
INHERITS (public.favorites);


--
-- Name: favorites_9; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_9 (
    CONSTRAINT favorites_9_user_id_check CHECK (((user_id % 100) = 9))
)
INHERITS (public.favorites);


--
-- Name: favorites_90; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_90 (
    CONSTRAINT favorites_90_user_id_check CHECK (((user_id % 100) = 90))
)
INHERITS (public.favorites);


--
-- Name: favorites_91; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_91 (
    CONSTRAINT favorites_91_user_id_check CHECK (((user_id % 100) = 91))
)
INHERITS (public.favorites);


--
-- Name: favorites_92; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_92 (
    CONSTRAINT favorites_92_user_id_check CHECK (((user_id % 100) = 92))
)
INHERITS (public.favorites);


--
-- Name: favorites_93; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_93 (
    CONSTRAINT favorites_93_user_id_check CHECK (((user_id % 100) = 93))
)
INHERITS (public.favorites);


--
-- Name: favorites_94; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_94 (
    CONSTRAINT favorites_94_user_id_check CHECK (((user_id % 100) = 94))
)
INHERITS (public.favorites);


--
-- Name: favorites_95; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_95 (
    CONSTRAINT favorites_95_user_id_check CHECK (((user_id % 100) = 95))
)
INHERITS (public.favorites);


--
-- Name: favorites_96; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_96 (
    CONSTRAINT favorites_96_user_id_check CHECK (((user_id % 100) = 96))
)
INHERITS (public.favorites);


--
-- Name: favorites_97; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_97 (
    CONSTRAINT favorites_97_user_id_check CHECK (((user_id % 100) = 97))
)
INHERITS (public.favorites);


--
-- Name: favorites_98; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_98 (
    CONSTRAINT favorites_98_user_id_check CHECK (((user_id % 100) = 98))
)
INHERITS (public.favorites);


--
-- Name: favorites_99; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites_99 (
    CONSTRAINT favorites_99_user_id_check CHECK (((user_id % 100) = 99))
)
INHERITS (public.favorites);


--
-- Name: favorites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.favorites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: favorites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.favorites_id_seq OWNED BY public.favorites.id;


--
-- Name: forum_post_votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.forum_post_votes (
    id bigint NOT NULL,
    forum_post_id integer NOT NULL,
    creator_id integer NOT NULL,
    score integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: forum_post_votes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.forum_post_votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forum_post_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.forum_post_votes_id_seq OWNED BY public.forum_post_votes.id;


--
-- Name: forum_posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.forum_posts (
    id integer NOT NULL,
    topic_id integer NOT NULL,
    creator_id integer NOT NULL,
    updater_id integer NOT NULL,
    body text NOT NULL,
    text_index tsvector NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: forum_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.forum_posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forum_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.forum_posts_id_seq OWNED BY public.forum_posts.id;


--
-- Name: forum_topic_visits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.forum_topic_visits (
    id integer NOT NULL,
    user_id integer,
    forum_topic_id integer,
    last_read_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: forum_topic_visits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.forum_topic_visits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forum_topic_visits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.forum_topic_visits_id_seq OWNED BY public.forum_topic_visits.id;


--
-- Name: forum_topics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.forum_topics (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    updater_id integer NOT NULL,
    title character varying NOT NULL,
    response_count integer DEFAULT 0 NOT NULL,
    is_sticky boolean DEFAULT false NOT NULL,
    is_locked boolean DEFAULT false NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    text_index tsvector NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    category_id integer DEFAULT 0 NOT NULL,
    min_level integer DEFAULT 0 NOT NULL
);


--
-- Name: forum_topics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.forum_topics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forum_topics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.forum_topics_id_seq OWNED BY public.forum_topics.id;


--
-- Name: note_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.note_versions (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    x integer NOT NULL,
    y integer NOT NULL,
    width integer NOT NULL,
    height integer NOT NULL,
    body text NOT NULL,
    updater_ip_addr inet NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    note_id integer NOT NULL,
    post_id integer NOT NULL,
    updater_id integer NOT NULL,
    version integer DEFAULT 0 NOT NULL
);


--
-- Name: posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.posts (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    uploader_id integer NOT NULL,
    score integer DEFAULT 0 NOT NULL,
    source character varying DEFAULT ''::character varying NOT NULL,
    md5 character varying NOT NULL,
    last_comment_bumped_at timestamp without time zone,
    rating character(1) DEFAULT 'q'::bpchar NOT NULL,
    image_width integer,
    image_height integer,
    uploader_ip_addr inet NOT NULL,
    tag_string text DEFAULT ''::text NOT NULL,
    is_note_locked boolean DEFAULT false NOT NULL,
    fav_count integer DEFAULT 0 NOT NULL,
    file_ext character varying NOT NULL,
    last_noted_at timestamp without time zone,
    is_rating_locked boolean DEFAULT false NOT NULL,
    parent_id integer,
    has_children boolean DEFAULT false NOT NULL,
    approver_id integer,
    tag_index tsvector,
    tag_count_general integer DEFAULT 0 NOT NULL,
    tag_count_artist integer DEFAULT 0 NOT NULL,
    tag_count_character integer DEFAULT 0 NOT NULL,
    tag_count_copyright integer DEFAULT 0 NOT NULL,
    file_size integer NOT NULL,
    is_status_locked boolean DEFAULT false NOT NULL,
    fav_string text DEFAULT ''::text NOT NULL,
    pool_string text DEFAULT ''::text NOT NULL,
    up_score integer DEFAULT 0 NOT NULL,
    down_score integer DEFAULT 0 NOT NULL,
    is_pending boolean DEFAULT false NOT NULL,
    is_flagged boolean DEFAULT false NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    tag_count integer DEFAULT 0 NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_banned boolean DEFAULT false NOT NULL,
    pixiv_id integer,
    last_commented_at timestamp without time zone,
    has_active_children boolean DEFAULT false,
    bit_flags bigint DEFAULT 0 NOT NULL,
    tag_count_meta integer DEFAULT 0 NOT NULL
);
ALTER TABLE ONLY public.posts ALTER COLUMN tag_index SET STATISTICS 2000;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name character varying NOT NULL,
    level integer DEFAULT 20 NOT NULL,
    inviter_id integer,
    created_at timestamp without time zone NOT NULL,
    last_logged_in_at timestamp without time zone DEFAULT now(),
    last_forum_read_at timestamp without time zone DEFAULT '1960-01-01 00:00:00'::timestamp without time zone,
    comment_threshold integer DEFAULT 0 NOT NULL,
    updated_at timestamp without time zone,
    default_image_size character varying DEFAULT 'large'::character varying NOT NULL,
    favorite_tags text,
    blacklisted_tags text DEFAULT 'spoilers
guro
scat
furry -rating:s'::text,
    time_zone character varying DEFAULT 'Eastern Time (US & Canada)'::character varying NOT NULL,
    post_update_count integer DEFAULT 0 NOT NULL,
    note_update_count integer DEFAULT 0 NOT NULL,
    favorite_count integer DEFAULT 0 NOT NULL,
    post_upload_count integer DEFAULT 0 NOT NULL,
    bcrypt_password_hash text,
    per_page integer DEFAULT 20 NOT NULL,
    custom_style text,
    bit_prefs bigint DEFAULT 0 NOT NULL,
    last_ip_addr inet,
    unread_dmail_count integer DEFAULT 0 NOT NULL,
    theme integer DEFAULT 0 NOT NULL,
    upload_points integer DEFAULT 1000 NOT NULL
);


--
-- Name: wiki_page_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wiki_page_versions (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    title character varying NOT NULL,
    body text NOT NULL,
    updater_id integer NOT NULL,
    updater_ip_addr inet NOT NULL,
    wiki_page_id integer NOT NULL,
    is_locked boolean NOT NULL,
    other_names text[] DEFAULT '{}'::text[] NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL
);


--
-- Name: ip_addresses; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.ip_addresses AS
 SELECT 'ArtistVersion'::text AS model_type,
    artist_versions.id AS model_id,
    artist_versions.updater_id AS user_id,
    artist_versions.updater_ip_addr AS ip_addr,
    artist_versions.created_at
   FROM public.artist_versions
UNION ALL
 SELECT 'ArtistCommentaryVersion'::text AS model_type,
    artist_commentary_versions.id AS model_id,
    artist_commentary_versions.updater_id AS user_id,
    artist_commentary_versions.updater_ip_addr AS ip_addr,
    artist_commentary_versions.created_at
   FROM public.artist_commentary_versions
UNION ALL
 SELECT 'Comment'::text AS model_type,
    comments.id AS model_id,
    comments.creator_id AS user_id,
    comments.creator_ip_addr AS ip_addr,
    comments.created_at
   FROM public.comments
UNION ALL
 SELECT 'Dmail'::text AS model_type,
    dmails.id AS model_id,
    dmails.from_id AS user_id,
    dmails.creator_ip_addr AS ip_addr,
    dmails.created_at
   FROM public.dmails
UNION ALL
 SELECT 'NoteVersion'::text AS model_type,
    note_versions.id AS model_id,
    note_versions.updater_id AS user_id,
    note_versions.updater_ip_addr AS ip_addr,
    note_versions.created_at
   FROM public.note_versions
UNION ALL
 SELECT 'Post'::text AS model_type,
    posts.id AS model_id,
    posts.uploader_id AS user_id,
    posts.uploader_ip_addr AS ip_addr,
    posts.created_at
   FROM public.posts
UNION ALL
 SELECT 'User'::text AS model_type,
    users.id AS model_id,
    users.id AS user_id,
    users.last_ip_addr AS ip_addr,
    users.created_at
   FROM public.users
  WHERE (users.last_ip_addr IS NOT NULL)
UNION ALL
 SELECT 'WikiPageVersion'::text AS model_type,
    wiki_page_versions.id AS model_id,
    wiki_page_versions.updater_id AS user_id,
    wiki_page_versions.updater_ip_addr AS ip_addr,
    wiki_page_versions.created_at
   FROM public.wiki_page_versions;


--
-- Name: ip_bans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ip_bans (
    creator_id integer NOT NULL,
    ip_addr inet NOT NULL,
    reason text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    id integer NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    category integer DEFAULT 0 NOT NULL,
    hit_count integer DEFAULT 0 NOT NULL,
    last_hit_at timestamp without time zone
);


--
-- Name: ip_bans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ip_bans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ip_bans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ip_bans_id_seq OWNED BY public.ip_bans.id;


--
-- Name: mod_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mod_actions (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    description text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    category integer
);


--
-- Name: mod_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mod_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mod_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mod_actions_id_seq OWNED BY public.mod_actions.id;


--
-- Name: moderation_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.moderation_reports (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    model_type character varying NOT NULL,
    model_id bigint NOT NULL,
    creator_id integer NOT NULL,
    reason text NOT NULL
);


--
-- Name: moderation_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.moderation_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: moderation_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.moderation_reports_id_seq OWNED BY public.moderation_reports.id;


--
-- Name: news_updates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.news_updates (
    id integer NOT NULL,
    message text NOT NULL,
    creator_id integer NOT NULL,
    updater_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: news_updates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.news_updates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: news_updates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.news_updates_id_seq OWNED BY public.news_updates.id;


--
-- Name: note_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.note_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: note_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.note_versions_id_seq OWNED BY public.note_versions.id;


--
-- Name: notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notes (
    id integer NOT NULL,
    post_id integer NOT NULL,
    x integer NOT NULL,
    y integer NOT NULL,
    width integer NOT NULL,
    height integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    body text NOT NULL,
    body_index tsvector NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    version integer DEFAULT 0 NOT NULL
);


--
-- Name: notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notes_id_seq OWNED BY public.notes.id;


--
-- Name: pixiv_ugoira_frame_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pixiv_ugoira_frame_data (
    id integer NOT NULL,
    post_id integer,
    data text NOT NULL,
    content_type character varying NOT NULL
);


--
-- Name: pixiv_ugoira_frame_data_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pixiv_ugoira_frame_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pixiv_ugoira_frame_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pixiv_ugoira_frame_data_id_seq OWNED BY public.pixiv_ugoira_frame_data.id;


--
-- Name: pools; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pools (
    id integer NOT NULL,
    name character varying,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    post_ids integer[] DEFAULT '{}'::integer[] NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    category character varying DEFAULT 'series'::character varying NOT NULL
);


--
-- Name: pools_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pools_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pools_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pools_id_seq OWNED BY public.pools.id;


--
-- Name: post_appeals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_appeals (
    id integer NOT NULL,
    post_id integer NOT NULL,
    creator_id integer NOT NULL,
    reason text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status integer DEFAULT 0 NOT NULL
);


--
-- Name: post_appeals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_appeals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_appeals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_appeals_id_seq OWNED BY public.post_appeals.id;


--
-- Name: post_approvals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_approvals (
    id integer NOT NULL,
    user_id integer NOT NULL,
    post_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: post_approvals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_approvals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_approvals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_approvals_id_seq OWNED BY public.post_approvals.id;


--
-- Name: post_disapprovals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_disapprovals (
    id integer NOT NULL,
    user_id integer NOT NULL,
    post_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    reason character varying NOT NULL,
    message text
);


--
-- Name: post_disapprovals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_disapprovals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_disapprovals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_disapprovals_id_seq OWNED BY public.post_disapprovals.id;


--
-- Name: post_flags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_flags (
    id integer NOT NULL,
    post_id integer NOT NULL,
    creator_id integer NOT NULL,
    reason text,
    is_resolved boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status integer DEFAULT 0 NOT NULL
);


--
-- Name: post_flags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_flags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_flags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_flags_id_seq OWNED BY public.post_flags.id;


--
-- Name: post_replacements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_replacements (
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

CREATE SEQUENCE public.post_replacements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_replacements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_replacements_id_seq OWNED BY public.post_replacements.id;


--
-- Name: post_votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_votes (
    id integer NOT NULL,
    post_id integer NOT NULL,
    user_id integer NOT NULL,
    score integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: post_votes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_votes_id_seq OWNED BY public.post_votes.id;


--
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.posts_id_seq OWNED BY public.posts.id;


--
-- Name: saved_searches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.saved_searches (
    id integer NOT NULL,
    user_id integer,
    query text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    labels text[] DEFAULT '{}'::text[] NOT NULL
);


--
-- Name: saved_searches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.saved_searches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: saved_searches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.saved_searches_id_seq OWNED BY public.saved_searches.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: tag_aliases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tag_aliases (
    id integer NOT NULL,
    antecedent_name character varying NOT NULL,
    consequent_name character varying NOT NULL,
    creator_id integer NOT NULL,
    forum_topic_id integer,
    status text DEFAULT 'pending'::text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    approver_id integer,
    forum_post_id integer
);


--
-- Name: tag_aliases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tag_aliases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tag_aliases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tag_aliases_id_seq OWNED BY public.tag_aliases.id;


--
-- Name: tag_implications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tag_implications (
    id integer NOT NULL,
    antecedent_name character varying NOT NULL,
    consequent_name character varying NOT NULL,
    creator_id integer NOT NULL,
    forum_topic_id integer,
    status text DEFAULT 'pending'::text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    approver_id integer,
    forum_post_id integer
);


--
-- Name: tag_implications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tag_implications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tag_implications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tag_implications_id_seq OWNED BY public.tag_implications.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
    id integer NOT NULL,
    name character varying NOT NULL,
    post_count integer DEFAULT 0 NOT NULL,
    category integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_locked boolean DEFAULT false NOT NULL
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;


--
-- Name: token_buckets; Type: TABLE; Schema: public; Owner: -
--

CREATE UNLOGGED TABLE public.token_buckets (
    user_id integer,
    last_touched_at timestamp without time zone NOT NULL,
    token_count real NOT NULL
);


--
-- Name: uploads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.uploads (
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
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    server text,
    parent_id integer,
    md5 character varying,
    file_ext character varying,
    file_size integer,
    image_width integer,
    image_height integer,
    artist_commentary_desc text,
    artist_commentary_title text,
    include_artist_commentary boolean,
    context text,
    referer_url text,
    translated_commentary_title text DEFAULT ''::text NOT NULL,
    translated_commentary_desc text DEFAULT ''::text NOT NULL
);


--
-- Name: uploads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.uploads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.uploads_id_seq OWNED BY public.uploads.id;


--
-- Name: user_feedback; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_feedback (
    id integer NOT NULL,
    user_id integer NOT NULL,
    creator_id integer NOT NULL,
    category character varying NOT NULL,
    body text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL
);


--
-- Name: user_feedback_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_feedback_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_feedback_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_feedback_id_seq OWNED BY public.user_feedback.id;


--
-- Name: user_name_change_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_name_change_requests (
    id integer NOT NULL,
    user_id integer NOT NULL,
    original_name character varying,
    desired_name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_name_change_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_name_change_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_name_change_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_name_change_requests_id_seq OWNED BY public.user_name_change_requests.id;


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: wiki_page_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.wiki_page_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wiki_page_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.wiki_page_versions_id_seq OWNED BY public.wiki_page_versions.id;


--
-- Name: wiki_pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wiki_pages (
    id integer NOT NULL,
    title character varying NOT NULL,
    body text NOT NULL,
    body_index tsvector NOT NULL,
    is_locked boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    other_names text[] DEFAULT '{}'::text[] NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL
);


--
-- Name: wiki_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.wiki_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wiki_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.wiki_pages_id_seq OWNED BY public.wiki_pages.id;


--
-- Name: api_keys id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_keys ALTER COLUMN id SET DEFAULT nextval('public.api_keys_id_seq'::regclass);


--
-- Name: artist_commentaries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_commentaries ALTER COLUMN id SET DEFAULT nextval('public.artist_commentaries_id_seq'::regclass);


--
-- Name: artist_commentary_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_commentary_versions ALTER COLUMN id SET DEFAULT nextval('public.artist_commentary_versions_id_seq'::regclass);


--
-- Name: artist_urls id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_urls ALTER COLUMN id SET DEFAULT nextval('public.artist_urls_id_seq'::regclass);


--
-- Name: artist_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_versions ALTER COLUMN id SET DEFAULT nextval('public.artist_versions_id_seq'::regclass);


--
-- Name: artists id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artists ALTER COLUMN id SET DEFAULT nextval('public.artists_id_seq'::regclass);


--
-- Name: bans id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bans ALTER COLUMN id SET DEFAULT nextval('public.bans_id_seq'::regclass);


--
-- Name: bulk_update_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bulk_update_requests ALTER COLUMN id SET DEFAULT nextval('public.bulk_update_requests_id_seq'::regclass);


--
-- Name: comment_votes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_votes ALTER COLUMN id SET DEFAULT nextval('public.comment_votes_id_seq'::regclass);


--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);


--
-- Name: delayed_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs ALTER COLUMN id SET DEFAULT nextval('public.delayed_jobs_id_seq'::regclass);


--
-- Name: dmails id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dmails ALTER COLUMN id SET DEFAULT nextval('public.dmails_id_seq'::regclass);


--
-- Name: dtext_links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dtext_links ALTER COLUMN id SET DEFAULT nextval('public.dtext_links_id_seq'::regclass);


--
-- Name: email_addresses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_addresses ALTER COLUMN id SET DEFAULT nextval('public.email_addresses_id_seq'::regclass);


--
-- Name: favorite_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorite_groups ALTER COLUMN id SET DEFAULT nextval('public.favorite_groups_id_seq'::regclass);


--
-- Name: favorites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_0 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_0 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_1 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_1 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_10 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_10 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_11 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_11 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_12 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_12 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_13 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_13 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_14 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_14 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_15 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_15 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_16 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_16 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_17 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_17 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_18 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_18 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_19 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_19 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_2 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_2 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_20 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_20 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_21 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_21 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_22 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_22 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_23 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_23 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_24 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_24 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_25 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_25 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_26 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_26 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_27 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_27 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_28 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_28 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_29 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_29 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_3 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_3 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_30 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_30 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_31 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_31 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_32 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_32 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_33 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_33 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_34 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_34 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_35 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_35 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_36 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_36 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_37 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_37 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_38 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_38 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_39 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_39 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_4 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_4 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_40 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_40 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_41 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_41 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_42 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_42 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_43 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_43 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_44 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_44 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_45 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_45 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_46 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_46 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_47 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_47 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_48 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_48 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_49 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_49 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_5 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_5 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_50 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_50 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_51 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_51 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_52 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_52 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_53 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_53 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_54 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_54 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_55 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_55 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_56 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_56 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_57 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_57 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_58 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_58 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_59 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_59 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_6 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_6 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_60 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_60 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_61 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_61 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_62 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_62 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_63 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_63 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_64 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_64 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_65 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_65 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_66 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_66 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_67 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_67 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_68 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_68 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_69 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_69 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_7 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_7 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_70 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_70 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_71 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_71 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_72 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_72 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_73 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_73 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_74 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_74 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_75 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_75 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_76 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_76 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_77 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_77 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_78 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_78 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_79 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_79 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_8 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_8 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_80 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_80 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_81 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_81 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_82 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_82 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_83 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_83 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_84 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_84 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_85 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_85 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_86 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_86 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_87 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_87 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_88 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_88 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_89 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_89 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_9 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_9 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_90 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_90 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_91 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_91 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_92 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_92 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_93 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_93 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_94 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_94 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_95 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_95 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_96 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_96 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_97 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_97 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_98 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_98 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: favorites_99 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites_99 ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: forum_post_votes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_post_votes ALTER COLUMN id SET DEFAULT nextval('public.forum_post_votes_id_seq'::regclass);


--
-- Name: forum_posts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_posts ALTER COLUMN id SET DEFAULT nextval('public.forum_posts_id_seq'::regclass);


--
-- Name: forum_topic_visits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_topic_visits ALTER COLUMN id SET DEFAULT nextval('public.forum_topic_visits_id_seq'::regclass);


--
-- Name: forum_topics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_topics ALTER COLUMN id SET DEFAULT nextval('public.forum_topics_id_seq'::regclass);


--
-- Name: ip_bans id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ip_bans ALTER COLUMN id SET DEFAULT nextval('public.ip_bans_id_seq'::regclass);


--
-- Name: mod_actions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_actions ALTER COLUMN id SET DEFAULT nextval('public.mod_actions_id_seq'::regclass);


--
-- Name: moderation_reports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_reports ALTER COLUMN id SET DEFAULT nextval('public.moderation_reports_id_seq'::regclass);


--
-- Name: news_updates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news_updates ALTER COLUMN id SET DEFAULT nextval('public.news_updates_id_seq'::regclass);


--
-- Name: note_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_versions ALTER COLUMN id SET DEFAULT nextval('public.note_versions_id_seq'::regclass);


--
-- Name: notes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes ALTER COLUMN id SET DEFAULT nextval('public.notes_id_seq'::regclass);


--
-- Name: pixiv_ugoira_frame_data id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pixiv_ugoira_frame_data ALTER COLUMN id SET DEFAULT nextval('public.pixiv_ugoira_frame_data_id_seq'::regclass);


--
-- Name: pools id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pools ALTER COLUMN id SET DEFAULT nextval('public.pools_id_seq'::regclass);


--
-- Name: post_appeals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_appeals ALTER COLUMN id SET DEFAULT nextval('public.post_appeals_id_seq'::regclass);


--
-- Name: post_approvals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_approvals ALTER COLUMN id SET DEFAULT nextval('public.post_approvals_id_seq'::regclass);


--
-- Name: post_disapprovals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_disapprovals ALTER COLUMN id SET DEFAULT nextval('public.post_disapprovals_id_seq'::regclass);


--
-- Name: post_flags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_flags ALTER COLUMN id SET DEFAULT nextval('public.post_flags_id_seq'::regclass);


--
-- Name: post_replacements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_replacements ALTER COLUMN id SET DEFAULT nextval('public.post_replacements_id_seq'::regclass);


--
-- Name: post_votes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_votes ALTER COLUMN id SET DEFAULT nextval('public.post_votes_id_seq'::regclass);


--
-- Name: posts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts ALTER COLUMN id SET DEFAULT nextval('public.posts_id_seq'::regclass);


--
-- Name: saved_searches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saved_searches ALTER COLUMN id SET DEFAULT nextval('public.saved_searches_id_seq'::regclass);


--
-- Name: tag_aliases id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_aliases ALTER COLUMN id SET DEFAULT nextval('public.tag_aliases_id_seq'::regclass);


--
-- Name: tag_implications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_implications ALTER COLUMN id SET DEFAULT nextval('public.tag_implications_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);


--
-- Name: uploads id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uploads ALTER COLUMN id SET DEFAULT nextval('public.uploads_id_seq'::regclass);


--
-- Name: user_feedback id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_feedback ALTER COLUMN id SET DEFAULT nextval('public.user_feedback_id_seq'::regclass);


--
-- Name: user_name_change_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_name_change_requests ALTER COLUMN id SET DEFAULT nextval('public.user_name_change_requests_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: wiki_page_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wiki_page_versions ALTER COLUMN id SET DEFAULT nextval('public.wiki_page_versions_id_seq'::regclass);


--
-- Name: wiki_pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wiki_pages ALTER COLUMN id SET DEFAULT nextval('public.wiki_pages_id_seq'::regclass);


--
-- Name: api_keys api_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: artist_commentaries artist_commentaries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_commentaries
    ADD CONSTRAINT artist_commentaries_pkey PRIMARY KEY (id);


--
-- Name: artist_commentary_versions artist_commentary_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_commentary_versions
    ADD CONSTRAINT artist_commentary_versions_pkey PRIMARY KEY (id);


--
-- Name: artist_urls artist_urls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_urls
    ADD CONSTRAINT artist_urls_pkey PRIMARY KEY (id);


--
-- Name: artist_versions artist_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_versions
    ADD CONSTRAINT artist_versions_pkey PRIMARY KEY (id);


--
-- Name: artists artists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artists
    ADD CONSTRAINT artists_pkey PRIMARY KEY (id);


--
-- Name: bans bans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bans
    ADD CONSTRAINT bans_pkey PRIMARY KEY (id);


--
-- Name: bulk_update_requests bulk_update_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bulk_update_requests
    ADD CONSTRAINT bulk_update_requests_pkey PRIMARY KEY (id);


--
-- Name: comment_votes comment_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_votes
    ADD CONSTRAINT comment_votes_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: dmails dmails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dmails
    ADD CONSTRAINT dmails_pkey PRIMARY KEY (id);


--
-- Name: dtext_links dtext_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dtext_links
    ADD CONSTRAINT dtext_links_pkey PRIMARY KEY (id);


--
-- Name: email_addresses email_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_addresses
    ADD CONSTRAINT email_addresses_pkey PRIMARY KEY (id);


--
-- Name: favorite_groups favorite_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorite_groups
    ADD CONSTRAINT favorite_groups_pkey PRIMARY KEY (id);


--
-- Name: favorites favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_pkey PRIMARY KEY (id);


--
-- Name: forum_post_votes forum_post_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_post_votes
    ADD CONSTRAINT forum_post_votes_pkey PRIMARY KEY (id);


--
-- Name: forum_posts forum_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_posts
    ADD CONSTRAINT forum_posts_pkey PRIMARY KEY (id);


--
-- Name: forum_topic_visits forum_topic_visits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_topic_visits
    ADD CONSTRAINT forum_topic_visits_pkey PRIMARY KEY (id);


--
-- Name: forum_topics forum_topics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_topics
    ADD CONSTRAINT forum_topics_pkey PRIMARY KEY (id);


--
-- Name: ip_bans ip_bans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ip_bans
    ADD CONSTRAINT ip_bans_pkey PRIMARY KEY (id);


--
-- Name: mod_actions mod_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_actions
    ADD CONSTRAINT mod_actions_pkey PRIMARY KEY (id);


--
-- Name: moderation_reports moderation_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_reports
    ADD CONSTRAINT moderation_reports_pkey PRIMARY KEY (id);


--
-- Name: news_updates news_updates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news_updates
    ADD CONSTRAINT news_updates_pkey PRIMARY KEY (id);


--
-- Name: note_versions note_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_versions
    ADD CONSTRAINT note_versions_pkey PRIMARY KEY (id);


--
-- Name: notes notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT notes_pkey PRIMARY KEY (id);


--
-- Name: pixiv_ugoira_frame_data pixiv_ugoira_frame_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pixiv_ugoira_frame_data
    ADD CONSTRAINT pixiv_ugoira_frame_data_pkey PRIMARY KEY (id);


--
-- Name: pools pools_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pools
    ADD CONSTRAINT pools_pkey PRIMARY KEY (id);


--
-- Name: post_appeals post_appeals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_appeals
    ADD CONSTRAINT post_appeals_pkey PRIMARY KEY (id);


--
-- Name: post_approvals post_approvals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_approvals
    ADD CONSTRAINT post_approvals_pkey PRIMARY KEY (id);


--
-- Name: post_disapprovals post_disapprovals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_disapprovals
    ADD CONSTRAINT post_disapprovals_pkey PRIMARY KEY (id);


--
-- Name: post_flags post_flags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_flags
    ADD CONSTRAINT post_flags_pkey PRIMARY KEY (id);


--
-- Name: post_replacements post_replacements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_replacements
    ADD CONSTRAINT post_replacements_pkey PRIMARY KEY (id);


--
-- Name: post_votes post_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_votes
    ADD CONSTRAINT post_votes_pkey PRIMARY KEY (id);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: saved_searches saved_searches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saved_searches
    ADD CONSTRAINT saved_searches_pkey PRIMARY KEY (id);


--
-- Name: tag_aliases tag_aliases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_aliases
    ADD CONSTRAINT tag_aliases_pkey PRIMARY KEY (id);


--
-- Name: tag_implications tag_implications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_implications
    ADD CONSTRAINT tag_implications_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: uploads uploads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uploads
    ADD CONSTRAINT uploads_pkey PRIMARY KEY (id);


--
-- Name: user_feedback user_feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_feedback
    ADD CONSTRAINT user_feedback_pkey PRIMARY KEY (id);


--
-- Name: user_name_change_requests user_name_change_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_name_change_requests
    ADD CONSTRAINT user_name_change_requests_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: wiki_page_versions wiki_page_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wiki_page_versions
    ADD CONSTRAINT wiki_page_versions_pkey PRIMARY KEY (id);


--
-- Name: wiki_pages wiki_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wiki_pages
    ADD CONSTRAINT wiki_pages_pkey PRIMARY KEY (id);


--
-- Name: index_api_keys_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_api_keys_on_key ON public.api_keys USING btree (key);


--
-- Name: index_api_keys_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_api_keys_on_user_id ON public.api_keys USING btree (user_id);


--
-- Name: index_artist_commentaries_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_artist_commentaries_on_post_id ON public.artist_commentaries USING btree (post_id);


--
-- Name: index_artist_commentary_versions_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_commentary_versions_on_created_at ON public.artist_commentary_versions USING btree (created_at);


--
-- Name: index_artist_commentary_versions_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_commentary_versions_on_post_id ON public.artist_commentary_versions USING btree (post_id);


--
-- Name: index_artist_commentary_versions_on_updater_id_and_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_commentary_versions_on_updater_id_and_post_id ON public.artist_commentary_versions USING btree (updater_id, post_id);


--
-- Name: index_artist_commentary_versions_on_updater_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_commentary_versions_on_updater_ip_addr ON public.artist_commentary_versions USING btree (updater_ip_addr);


--
-- Name: index_artist_urls_on_artist_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_urls_on_artist_id ON public.artist_urls USING btree (artist_id);


--
-- Name: index_artist_urls_on_normalized_url_pattern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_urls_on_normalized_url_pattern ON public.artist_urls USING btree (normalized_url text_pattern_ops);


--
-- Name: index_artist_urls_on_normalized_url_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_urls_on_normalized_url_trgm ON public.artist_urls USING gin (normalized_url public.gin_trgm_ops);


--
-- Name: index_artist_urls_on_url_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_urls_on_url_trgm ON public.artist_urls USING gin (url public.gin_trgm_ops);


--
-- Name: index_artist_versions_on_artist_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_versions_on_artist_id ON public.artist_versions USING btree (artist_id);


--
-- Name: index_artist_versions_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_versions_on_created_at ON public.artist_versions USING btree (created_at);


--
-- Name: index_artist_versions_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_versions_on_name ON public.artist_versions USING btree (name);


--
-- Name: index_artist_versions_on_updater_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_versions_on_updater_id ON public.artist_versions USING btree (updater_id);


--
-- Name: index_artist_versions_on_updater_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_versions_on_updater_ip_addr ON public.artist_versions USING btree (updater_ip_addr);


--
-- Name: index_artists_on_group_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artists_on_group_name ON public.artists USING btree (group_name);


--
-- Name: index_artists_on_group_name_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artists_on_group_name_trgm ON public.artists USING gin (group_name public.gin_trgm_ops);


--
-- Name: index_artists_on_is_banned; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artists_on_is_banned ON public.artists USING btree (is_banned);


--
-- Name: index_artists_on_is_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artists_on_is_deleted ON public.artists USING btree (is_deleted);


--
-- Name: index_artists_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_artists_on_name ON public.artists USING btree (name);


--
-- Name: index_artists_on_name_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artists_on_name_trgm ON public.artists USING gin (name public.gin_trgm_ops);


--
-- Name: index_artists_on_other_names; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artists_on_other_names ON public.artists USING gin (other_names);


--
-- Name: index_bans_on_banner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bans_on_banner_id ON public.bans USING btree (banner_id);


--
-- Name: index_bans_on_expires_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bans_on_expires_at ON public.bans USING btree (expires_at);


--
-- Name: index_bans_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bans_on_user_id ON public.bans USING btree (user_id);


--
-- Name: index_bulk_update_requests_on_forum_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bulk_update_requests_on_forum_post_id ON public.bulk_update_requests USING btree (forum_post_id);


--
-- Name: index_bulk_update_requests_on_tags; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bulk_update_requests_on_tags ON public.bulk_update_requests USING gin (tags);


--
-- Name: index_comment_votes_on_comment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comment_votes_on_comment_id ON public.comment_votes USING btree (comment_id);


--
-- Name: index_comment_votes_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comment_votes_on_created_at ON public.comment_votes USING btree (created_at);


--
-- Name: index_comment_votes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comment_votes_on_user_id ON public.comment_votes USING btree (user_id);


--
-- Name: index_comments_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_created_at ON public.comments USING btree (created_at);

--
-- Name: index_comments_on_body_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_body_index ON public.comments USING gin (body_index);


--
-- Name: index_comments_on_creator_id_and_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_creator_id_and_post_id ON public.comments USING btree (creator_id, post_id);


--
-- Name: index_comments_on_creator_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_creator_ip_addr ON public.comments USING btree (creator_ip_addr);


--
-- Name: index_comments_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_post_id ON public.comments USING btree (post_id);


--
-- Name: index_delayed_jobs_on_locked_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delayed_jobs_on_locked_at ON public.delayed_jobs USING btree (locked_at);


--
-- Name: index_delayed_jobs_on_locked_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delayed_jobs_on_locked_by ON public.delayed_jobs USING btree (locked_by);


--
-- Name: index_delayed_jobs_on_run_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delayed_jobs_on_run_at ON public.delayed_jobs USING btree (run_at);


--
-- Name: index_dmails_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dmails_on_created_at ON public.dmails USING btree (created_at);


--
-- Name: index_dmails_on_creator_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dmails_on_creator_ip_addr ON public.dmails USING btree (creator_ip_addr);


--
-- Name: index_dmails_on_from_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dmails_on_from_id ON public.dmails USING btree (from_id);


--
-- Name: index_dmails_on_is_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dmails_on_is_deleted ON public.dmails USING btree (is_deleted);


--
-- Name: index_dmails_on_is_read; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dmails_on_is_read ON public.dmails USING btree (is_read);


--
-- Name: index_dmails_on_message_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dmails_on_message_index ON public.dmails USING gin (message_index);


--
-- Name: index_dmails_on_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dmails_on_owner_id ON public.dmails USING btree (owner_id);


--
-- Name: index_dtext_links_on_link_target; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dtext_links_on_link_target ON public.dtext_links USING btree (link_target text_pattern_ops);


--
-- Name: index_dtext_links_on_link_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dtext_links_on_link_type ON public.dtext_links USING btree (link_type);


--
-- Name: index_dtext_links_on_model_type_and_model_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dtext_links_on_model_type_and_model_id ON public.dtext_links USING btree (model_type, model_id);


--
-- Name: index_email_addresses_on_address; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_email_addresses_on_address ON public.email_addresses USING btree (address);


--
-- Name: index_email_addresses_on_address_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_email_addresses_on_address_trgm ON public.email_addresses USING gin (address public.gin_trgm_ops);


--
-- Name: index_email_addresses_on_normalized_address; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_email_addresses_on_normalized_address ON public.email_addresses USING btree (normalized_address);


--
-- Name: index_email_addresses_on_normalized_address_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_email_addresses_on_normalized_address_trgm ON public.email_addresses USING gin (normalized_address public.gin_trgm_ops);


--
-- Name: index_email_addresses_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_email_addresses_on_user_id ON public.email_addresses USING btree (user_id);


--
-- Name: index_favorite_groups_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorite_groups_on_creator_id ON public.favorite_groups USING btree (creator_id);


--
-- Name: index_favorite_groups_on_is_public; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorite_groups_on_is_public ON public.favorite_groups USING btree (is_public);


--
-- Name: index_favorite_groups_on_lower_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorite_groups_on_lower_name ON public.favorite_groups USING btree (lower(name));


--
-- Name: index_favorite_groups_on_post_ids; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorite_groups_on_post_ids ON public.favorite_groups USING gin (post_ids);


--
-- Name: index_favorites_0_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_0_on_post_id ON public.favorites_0 USING btree (post_id);


--
-- Name: index_favorites_0_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_0_on_user_id ON public.favorites_0 USING btree (user_id);


--
-- Name: index_favorites_10_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_10_on_post_id ON public.favorites_10 USING btree (post_id);


--
-- Name: index_favorites_10_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_10_on_user_id ON public.favorites_10 USING btree (user_id);


--
-- Name: index_favorites_11_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_11_on_post_id ON public.favorites_11 USING btree (post_id);


--
-- Name: index_favorites_11_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_11_on_user_id ON public.favorites_11 USING btree (user_id);


--
-- Name: index_favorites_12_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_12_on_post_id ON public.favorites_12 USING btree (post_id);


--
-- Name: index_favorites_12_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_12_on_user_id ON public.favorites_12 USING btree (user_id);


--
-- Name: index_favorites_13_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_13_on_post_id ON public.favorites_13 USING btree (post_id);


--
-- Name: index_favorites_13_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_13_on_user_id ON public.favorites_13 USING btree (user_id);


--
-- Name: index_favorites_14_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_14_on_post_id ON public.favorites_14 USING btree (post_id);


--
-- Name: index_favorites_14_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_14_on_user_id ON public.favorites_14 USING btree (user_id);


--
-- Name: index_favorites_15_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_15_on_post_id ON public.favorites_15 USING btree (post_id);


--
-- Name: index_favorites_15_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_15_on_user_id ON public.favorites_15 USING btree (user_id);


--
-- Name: index_favorites_16_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_16_on_post_id ON public.favorites_16 USING btree (post_id);


--
-- Name: index_favorites_16_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_16_on_user_id ON public.favorites_16 USING btree (user_id);


--
-- Name: index_favorites_17_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_17_on_post_id ON public.favorites_17 USING btree (post_id);


--
-- Name: index_favorites_17_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_17_on_user_id ON public.favorites_17 USING btree (user_id);


--
-- Name: index_favorites_18_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_18_on_post_id ON public.favorites_18 USING btree (post_id);


--
-- Name: index_favorites_18_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_18_on_user_id ON public.favorites_18 USING btree (user_id);


--
-- Name: index_favorites_19_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_19_on_post_id ON public.favorites_19 USING btree (post_id);


--
-- Name: index_favorites_19_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_19_on_user_id ON public.favorites_19 USING btree (user_id);


--
-- Name: index_favorites_1_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_1_on_post_id ON public.favorites_1 USING btree (post_id);


--
-- Name: index_favorites_1_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_1_on_user_id ON public.favorites_1 USING btree (user_id);


--
-- Name: index_favorites_20_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_20_on_post_id ON public.favorites_20 USING btree (post_id);


--
-- Name: index_favorites_20_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_20_on_user_id ON public.favorites_20 USING btree (user_id);


--
-- Name: index_favorites_21_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_21_on_post_id ON public.favorites_21 USING btree (post_id);


--
-- Name: index_favorites_21_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_21_on_user_id ON public.favorites_21 USING btree (user_id);


--
-- Name: index_favorites_22_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_22_on_post_id ON public.favorites_22 USING btree (post_id);


--
-- Name: index_favorites_22_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_22_on_user_id ON public.favorites_22 USING btree (user_id);


--
-- Name: index_favorites_23_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_23_on_post_id ON public.favorites_23 USING btree (post_id);


--
-- Name: index_favorites_23_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_23_on_user_id ON public.favorites_23 USING btree (user_id);


--
-- Name: index_favorites_24_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_24_on_post_id ON public.favorites_24 USING btree (post_id);


--
-- Name: index_favorites_24_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_24_on_user_id ON public.favorites_24 USING btree (user_id);


--
-- Name: index_favorites_25_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_25_on_post_id ON public.favorites_25 USING btree (post_id);


--
-- Name: index_favorites_25_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_25_on_user_id ON public.favorites_25 USING btree (user_id);


--
-- Name: index_favorites_26_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_26_on_post_id ON public.favorites_26 USING btree (post_id);


--
-- Name: index_favorites_26_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_26_on_user_id ON public.favorites_26 USING btree (user_id);


--
-- Name: index_favorites_27_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_27_on_post_id ON public.favorites_27 USING btree (post_id);


--
-- Name: index_favorites_27_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_27_on_user_id ON public.favorites_27 USING btree (user_id);


--
-- Name: index_favorites_28_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_28_on_post_id ON public.favorites_28 USING btree (post_id);


--
-- Name: index_favorites_28_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_28_on_user_id ON public.favorites_28 USING btree (user_id);


--
-- Name: index_favorites_29_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_29_on_post_id ON public.favorites_29 USING btree (post_id);


--
-- Name: index_favorites_29_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_29_on_user_id ON public.favorites_29 USING btree (user_id);


--
-- Name: index_favorites_2_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_2_on_post_id ON public.favorites_2 USING btree (post_id);


--
-- Name: index_favorites_2_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_2_on_user_id ON public.favorites_2 USING btree (user_id);


--
-- Name: index_favorites_30_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_30_on_post_id ON public.favorites_30 USING btree (post_id);


--
-- Name: index_favorites_30_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_30_on_user_id ON public.favorites_30 USING btree (user_id);


--
-- Name: index_favorites_31_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_31_on_post_id ON public.favorites_31 USING btree (post_id);


--
-- Name: index_favorites_31_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_31_on_user_id ON public.favorites_31 USING btree (user_id);


--
-- Name: index_favorites_32_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_32_on_post_id ON public.favorites_32 USING btree (post_id);


--
-- Name: index_favorites_32_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_32_on_user_id ON public.favorites_32 USING btree (user_id);


--
-- Name: index_favorites_33_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_33_on_post_id ON public.favorites_33 USING btree (post_id);


--
-- Name: index_favorites_33_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_33_on_user_id ON public.favorites_33 USING btree (user_id);


--
-- Name: index_favorites_34_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_34_on_post_id ON public.favorites_34 USING btree (post_id);


--
-- Name: index_favorites_34_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_34_on_user_id ON public.favorites_34 USING btree (user_id);


--
-- Name: index_favorites_35_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_35_on_post_id ON public.favorites_35 USING btree (post_id);


--
-- Name: index_favorites_35_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_35_on_user_id ON public.favorites_35 USING btree (user_id);


--
-- Name: index_favorites_36_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_36_on_post_id ON public.favorites_36 USING btree (post_id);


--
-- Name: index_favorites_36_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_36_on_user_id ON public.favorites_36 USING btree (user_id);


--
-- Name: index_favorites_37_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_37_on_post_id ON public.favorites_37 USING btree (post_id);


--
-- Name: index_favorites_37_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_37_on_user_id ON public.favorites_37 USING btree (user_id);


--
-- Name: index_favorites_38_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_38_on_post_id ON public.favorites_38 USING btree (post_id);


--
-- Name: index_favorites_38_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_38_on_user_id ON public.favorites_38 USING btree (user_id);


--
-- Name: index_favorites_39_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_39_on_post_id ON public.favorites_39 USING btree (post_id);


--
-- Name: index_favorites_39_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_39_on_user_id ON public.favorites_39 USING btree (user_id);


--
-- Name: index_favorites_3_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_3_on_post_id ON public.favorites_3 USING btree (post_id);


--
-- Name: index_favorites_3_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_3_on_user_id ON public.favorites_3 USING btree (user_id);


--
-- Name: index_favorites_40_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_40_on_post_id ON public.favorites_40 USING btree (post_id);


--
-- Name: index_favorites_40_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_40_on_user_id ON public.favorites_40 USING btree (user_id);


--
-- Name: index_favorites_41_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_41_on_post_id ON public.favorites_41 USING btree (post_id);


--
-- Name: index_favorites_41_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_41_on_user_id ON public.favorites_41 USING btree (user_id);


--
-- Name: index_favorites_42_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_42_on_post_id ON public.favorites_42 USING btree (post_id);


--
-- Name: index_favorites_42_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_42_on_user_id ON public.favorites_42 USING btree (user_id);


--
-- Name: index_favorites_43_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_43_on_post_id ON public.favorites_43 USING btree (post_id);


--
-- Name: index_favorites_43_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_43_on_user_id ON public.favorites_43 USING btree (user_id);


--
-- Name: index_favorites_44_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_44_on_post_id ON public.favorites_44 USING btree (post_id);


--
-- Name: index_favorites_44_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_44_on_user_id ON public.favorites_44 USING btree (user_id);


--
-- Name: index_favorites_45_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_45_on_post_id ON public.favorites_45 USING btree (post_id);


--
-- Name: index_favorites_45_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_45_on_user_id ON public.favorites_45 USING btree (user_id);


--
-- Name: index_favorites_46_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_46_on_post_id ON public.favorites_46 USING btree (post_id);


--
-- Name: index_favorites_46_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_46_on_user_id ON public.favorites_46 USING btree (user_id);


--
-- Name: index_favorites_47_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_47_on_post_id ON public.favorites_47 USING btree (post_id);


--
-- Name: index_favorites_47_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_47_on_user_id ON public.favorites_47 USING btree (user_id);


--
-- Name: index_favorites_48_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_48_on_post_id ON public.favorites_48 USING btree (post_id);


--
-- Name: index_favorites_48_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_48_on_user_id ON public.favorites_48 USING btree (user_id);


--
-- Name: index_favorites_49_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_49_on_post_id ON public.favorites_49 USING btree (post_id);


--
-- Name: index_favorites_49_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_49_on_user_id ON public.favorites_49 USING btree (user_id);


--
-- Name: index_favorites_4_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_4_on_post_id ON public.favorites_4 USING btree (post_id);


--
-- Name: index_favorites_4_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_4_on_user_id ON public.favorites_4 USING btree (user_id);


--
-- Name: index_favorites_50_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_50_on_post_id ON public.favorites_50 USING btree (post_id);


--
-- Name: index_favorites_50_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_50_on_user_id ON public.favorites_50 USING btree (user_id);


--
-- Name: index_favorites_51_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_51_on_post_id ON public.favorites_51 USING btree (post_id);


--
-- Name: index_favorites_51_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_51_on_user_id ON public.favorites_51 USING btree (user_id);


--
-- Name: index_favorites_52_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_52_on_post_id ON public.favorites_52 USING btree (post_id);


--
-- Name: index_favorites_52_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_52_on_user_id ON public.favorites_52 USING btree (user_id);


--
-- Name: index_favorites_53_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_53_on_post_id ON public.favorites_53 USING btree (post_id);


--
-- Name: index_favorites_53_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_53_on_user_id ON public.favorites_53 USING btree (user_id);


--
-- Name: index_favorites_54_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_54_on_post_id ON public.favorites_54 USING btree (post_id);


--
-- Name: index_favorites_54_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_54_on_user_id ON public.favorites_54 USING btree (user_id);


--
-- Name: index_favorites_55_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_55_on_post_id ON public.favorites_55 USING btree (post_id);


--
-- Name: index_favorites_55_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_55_on_user_id ON public.favorites_55 USING btree (user_id);


--
-- Name: index_favorites_56_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_56_on_post_id ON public.favorites_56 USING btree (post_id);


--
-- Name: index_favorites_56_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_56_on_user_id ON public.favorites_56 USING btree (user_id);


--
-- Name: index_favorites_57_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_57_on_post_id ON public.favorites_57 USING btree (post_id);


--
-- Name: index_favorites_57_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_57_on_user_id ON public.favorites_57 USING btree (user_id);


--
-- Name: index_favorites_58_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_58_on_post_id ON public.favorites_58 USING btree (post_id);


--
-- Name: index_favorites_58_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_58_on_user_id ON public.favorites_58 USING btree (user_id);


--
-- Name: index_favorites_59_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_59_on_post_id ON public.favorites_59 USING btree (post_id);


--
-- Name: index_favorites_59_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_59_on_user_id ON public.favorites_59 USING btree (user_id);


--
-- Name: index_favorites_5_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_5_on_post_id ON public.favorites_5 USING btree (post_id);


--
-- Name: index_favorites_5_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_5_on_user_id ON public.favorites_5 USING btree (user_id);


--
-- Name: index_favorites_60_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_60_on_post_id ON public.favorites_60 USING btree (post_id);


--
-- Name: index_favorites_60_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_60_on_user_id ON public.favorites_60 USING btree (user_id);


--
-- Name: index_favorites_61_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_61_on_post_id ON public.favorites_61 USING btree (post_id);


--
-- Name: index_favorites_61_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_61_on_user_id ON public.favorites_61 USING btree (user_id);


--
-- Name: index_favorites_62_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_62_on_post_id ON public.favorites_62 USING btree (post_id);


--
-- Name: index_favorites_62_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_62_on_user_id ON public.favorites_62 USING btree (user_id);


--
-- Name: index_favorites_63_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_63_on_post_id ON public.favorites_63 USING btree (post_id);


--
-- Name: index_favorites_63_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_63_on_user_id ON public.favorites_63 USING btree (user_id);


--
-- Name: index_favorites_64_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_64_on_post_id ON public.favorites_64 USING btree (post_id);


--
-- Name: index_favorites_64_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_64_on_user_id ON public.favorites_64 USING btree (user_id);


--
-- Name: index_favorites_65_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_65_on_post_id ON public.favorites_65 USING btree (post_id);


--
-- Name: index_favorites_65_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_65_on_user_id ON public.favorites_65 USING btree (user_id);


--
-- Name: index_favorites_66_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_66_on_post_id ON public.favorites_66 USING btree (post_id);


--
-- Name: index_favorites_66_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_66_on_user_id ON public.favorites_66 USING btree (user_id);


--
-- Name: index_favorites_67_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_67_on_post_id ON public.favorites_67 USING btree (post_id);


--
-- Name: index_favorites_67_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_67_on_user_id ON public.favorites_67 USING btree (user_id);


--
-- Name: index_favorites_68_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_68_on_post_id ON public.favorites_68 USING btree (post_id);


--
-- Name: index_favorites_68_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_68_on_user_id ON public.favorites_68 USING btree (user_id);


--
-- Name: index_favorites_69_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_69_on_post_id ON public.favorites_69 USING btree (post_id);


--
-- Name: index_favorites_69_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_69_on_user_id ON public.favorites_69 USING btree (user_id);


--
-- Name: index_favorites_6_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_6_on_post_id ON public.favorites_6 USING btree (post_id);


--
-- Name: index_favorites_6_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_6_on_user_id ON public.favorites_6 USING btree (user_id);


--
-- Name: index_favorites_70_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_70_on_post_id ON public.favorites_70 USING btree (post_id);


--
-- Name: index_favorites_70_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_70_on_user_id ON public.favorites_70 USING btree (user_id);


--
-- Name: index_favorites_71_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_71_on_post_id ON public.favorites_71 USING btree (post_id);


--
-- Name: index_favorites_71_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_71_on_user_id ON public.favorites_71 USING btree (user_id);


--
-- Name: index_favorites_72_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_72_on_post_id ON public.favorites_72 USING btree (post_id);


--
-- Name: index_favorites_72_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_72_on_user_id ON public.favorites_72 USING btree (user_id);


--
-- Name: index_favorites_73_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_73_on_post_id ON public.favorites_73 USING btree (post_id);


--
-- Name: index_favorites_73_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_73_on_user_id ON public.favorites_73 USING btree (user_id);


--
-- Name: index_favorites_74_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_74_on_post_id ON public.favorites_74 USING btree (post_id);


--
-- Name: index_favorites_74_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_74_on_user_id ON public.favorites_74 USING btree (user_id);


--
-- Name: index_favorites_75_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_75_on_post_id ON public.favorites_75 USING btree (post_id);


--
-- Name: index_favorites_75_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_75_on_user_id ON public.favorites_75 USING btree (user_id);


--
-- Name: index_favorites_76_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_76_on_post_id ON public.favorites_76 USING btree (post_id);


--
-- Name: index_favorites_76_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_76_on_user_id ON public.favorites_76 USING btree (user_id);


--
-- Name: index_favorites_77_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_77_on_post_id ON public.favorites_77 USING btree (post_id);


--
-- Name: index_favorites_77_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_77_on_user_id ON public.favorites_77 USING btree (user_id);


--
-- Name: index_favorites_78_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_78_on_post_id ON public.favorites_78 USING btree (post_id);


--
-- Name: index_favorites_78_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_78_on_user_id ON public.favorites_78 USING btree (user_id);


--
-- Name: index_favorites_79_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_79_on_post_id ON public.favorites_79 USING btree (post_id);


--
-- Name: index_favorites_79_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_79_on_user_id ON public.favorites_79 USING btree (user_id);


--
-- Name: index_favorites_7_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_7_on_post_id ON public.favorites_7 USING btree (post_id);


--
-- Name: index_favorites_7_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_7_on_user_id ON public.favorites_7 USING btree (user_id);


--
-- Name: index_favorites_80_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_80_on_post_id ON public.favorites_80 USING btree (post_id);


--
-- Name: index_favorites_80_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_80_on_user_id ON public.favorites_80 USING btree (user_id);


--
-- Name: index_favorites_81_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_81_on_post_id ON public.favorites_81 USING btree (post_id);


--
-- Name: index_favorites_81_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_81_on_user_id ON public.favorites_81 USING btree (user_id);


--
-- Name: index_favorites_82_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_82_on_post_id ON public.favorites_82 USING btree (post_id);


--
-- Name: index_favorites_82_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_82_on_user_id ON public.favorites_82 USING btree (user_id);


--
-- Name: index_favorites_83_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_83_on_post_id ON public.favorites_83 USING btree (post_id);


--
-- Name: index_favorites_83_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_83_on_user_id ON public.favorites_83 USING btree (user_id);


--
-- Name: index_favorites_84_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_84_on_post_id ON public.favorites_84 USING btree (post_id);


--
-- Name: index_favorites_84_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_84_on_user_id ON public.favorites_84 USING btree (user_id);


--
-- Name: index_favorites_85_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_85_on_post_id ON public.favorites_85 USING btree (post_id);


--
-- Name: index_favorites_85_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_85_on_user_id ON public.favorites_85 USING btree (user_id);


--
-- Name: index_favorites_86_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_86_on_post_id ON public.favorites_86 USING btree (post_id);


--
-- Name: index_favorites_86_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_86_on_user_id ON public.favorites_86 USING btree (user_id);


--
-- Name: index_favorites_87_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_87_on_post_id ON public.favorites_87 USING btree (post_id);


--
-- Name: index_favorites_87_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_87_on_user_id ON public.favorites_87 USING btree (user_id);


--
-- Name: index_favorites_88_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_88_on_post_id ON public.favorites_88 USING btree (post_id);


--
-- Name: index_favorites_88_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_88_on_user_id ON public.favorites_88 USING btree (user_id);


--
-- Name: index_favorites_89_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_89_on_post_id ON public.favorites_89 USING btree (post_id);


--
-- Name: index_favorites_89_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_89_on_user_id ON public.favorites_89 USING btree (user_id);


--
-- Name: index_favorites_8_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_8_on_post_id ON public.favorites_8 USING btree (post_id);


--
-- Name: index_favorites_8_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_8_on_user_id ON public.favorites_8 USING btree (user_id);


--
-- Name: index_favorites_90_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_90_on_post_id ON public.favorites_90 USING btree (post_id);


--
-- Name: index_favorites_90_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_90_on_user_id ON public.favorites_90 USING btree (user_id);


--
-- Name: index_favorites_91_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_91_on_post_id ON public.favorites_91 USING btree (post_id);


--
-- Name: index_favorites_91_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_91_on_user_id ON public.favorites_91 USING btree (user_id);


--
-- Name: index_favorites_92_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_92_on_post_id ON public.favorites_92 USING btree (post_id);


--
-- Name: index_favorites_92_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_92_on_user_id ON public.favorites_92 USING btree (user_id);


--
-- Name: index_favorites_93_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_93_on_post_id ON public.favorites_93 USING btree (post_id);


--
-- Name: index_favorites_93_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_93_on_user_id ON public.favorites_93 USING btree (user_id);


--
-- Name: index_favorites_94_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_94_on_post_id ON public.favorites_94 USING btree (post_id);


--
-- Name: index_favorites_94_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_94_on_user_id ON public.favorites_94 USING btree (user_id);


--
-- Name: index_favorites_95_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_95_on_post_id ON public.favorites_95 USING btree (post_id);


--
-- Name: index_favorites_95_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_95_on_user_id ON public.favorites_95 USING btree (user_id);


--
-- Name: index_favorites_96_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_96_on_post_id ON public.favorites_96 USING btree (post_id);


--
-- Name: index_favorites_96_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_96_on_user_id ON public.favorites_96 USING btree (user_id);


--
-- Name: index_favorites_97_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_97_on_post_id ON public.favorites_97 USING btree (post_id);


--
-- Name: index_favorites_97_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_97_on_user_id ON public.favorites_97 USING btree (user_id);


--
-- Name: index_favorites_98_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_98_on_post_id ON public.favorites_98 USING btree (post_id);


--
-- Name: index_favorites_98_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_98_on_user_id ON public.favorites_98 USING btree (user_id);


--
-- Name: index_favorites_99_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_99_on_post_id ON public.favorites_99 USING btree (post_id);


--
-- Name: index_favorites_99_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_99_on_user_id ON public.favorites_99 USING btree (user_id);


--
-- Name: index_favorites_9_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_9_on_post_id ON public.favorites_9 USING btree (post_id);


--
-- Name: index_favorites_9_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_9_on_user_id ON public.favorites_9 USING btree (user_id);


--
-- Name: index_forum_post_votes_on_forum_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_post_votes_on_forum_post_id ON public.forum_post_votes USING btree (forum_post_id);


--
-- Name: index_forum_post_votes_on_forum_post_id_and_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_forum_post_votes_on_forum_post_id_and_creator_id ON public.forum_post_votes USING btree (forum_post_id, creator_id);


--
-- Name: index_forum_posts_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_posts_on_creator_id ON public.forum_posts USING btree (creator_id);


--
-- Name: index_forum_posts_on_text_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_posts_on_text_index ON public.forum_posts USING gin (text_index);


--
-- Name: index_forum_posts_on_topic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_posts_on_topic_id ON public.forum_posts USING btree (topic_id);


--
-- Name: index_forum_posts_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_posts_on_updated_at ON public.forum_posts USING btree (updated_at);


--
-- Name: index_forum_topic_visits_on_forum_topic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topic_visits_on_forum_topic_id ON public.forum_topic_visits USING btree (forum_topic_id);


--
-- Name: index_forum_topic_visits_on_last_read_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topic_visits_on_last_read_at ON public.forum_topic_visits USING btree (last_read_at);


--
-- Name: index_forum_topic_visits_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topic_visits_on_user_id ON public.forum_topic_visits USING btree (user_id);


--
-- Name: index_forum_topics_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topics_on_creator_id ON public.forum_topics USING btree (creator_id);


--
-- Name: index_forum_topics_on_is_sticky_and_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topics_on_is_sticky_and_updated_at ON public.forum_topics USING btree (is_sticky, updated_at);


--
-- Name: index_forum_topics_on_text_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topics_on_text_index ON public.forum_topics USING gin (text_index);


--
-- Name: index_forum_topics_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topics_on_updated_at ON public.forum_topics USING btree (updated_at);


--
-- Name: index_ip_bans_on_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ip_bans_on_category ON public.ip_bans USING btree (category);


--
-- Name: index_ip_bans_on_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ip_bans_on_ip_addr ON public.ip_bans USING btree (ip_addr);


--
-- Name: index_ip_bans_on_is_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ip_bans_on_is_deleted ON public.ip_bans USING btree (is_deleted);


--
-- Name: index_mod_actions_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mod_actions_on_created_at ON public.mod_actions USING btree (created_at);


--
-- Name: index_mod_actions_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mod_actions_on_creator_id ON public.mod_actions USING btree (creator_id);


--
-- Name: index_moderation_reports_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_moderation_reports_on_creator_id ON public.moderation_reports USING btree (creator_id);


--
-- Name: index_moderation_reports_on_model_type_and_model_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_moderation_reports_on_model_type_and_model_id ON public.moderation_reports USING btree (model_type, model_id);


--
-- Name: index_news_updates_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_news_updates_on_created_at ON public.news_updates USING btree (created_at);


--
-- Name: index_note_versions_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_note_versions_on_created_at ON public.note_versions USING btree (created_at);


--
-- Name: index_note_versions_on_note_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_note_versions_on_note_id ON public.note_versions USING btree (note_id);


--
-- Name: index_note_versions_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_note_versions_on_post_id ON public.note_versions USING btree (post_id);


--
-- Name: index_note_versions_on_updater_id_and_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_note_versions_on_updater_id_and_post_id ON public.note_versions USING btree (updater_id, post_id);


--
-- Name: index_note_versions_on_updater_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_note_versions_on_updater_ip_addr ON public.note_versions USING btree (updater_ip_addr);


--
-- Name: index_notes_on_body_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_body_index ON public.notes USING gin (body_index);


--
-- Name: index_notes_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_post_id ON public.notes USING btree (post_id);


--
-- Name: index_pixiv_ugoira_frame_data_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_pixiv_ugoira_frame_data_on_post_id ON public.pixiv_ugoira_frame_data USING btree (post_id);


--
-- Name: index_pools_on_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pools_on_category ON public.pools USING btree (category);


--
-- Name: index_pools_on_is_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pools_on_is_deleted ON public.pools USING btree (is_deleted);


--
-- Name: index_pools_on_lower_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pools_on_lower_name ON public.pools USING btree (lower((name)::text));


--
-- Name: index_pools_on_name_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pools_on_name_trgm ON public.pools USING gin (name public.gin_trgm_ops);


--
-- Name: index_pools_on_post_ids; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pools_on_post_ids ON public.pools USING gin (post_ids);


--
-- Name: index_pools_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pools_on_updated_at ON public.pools USING btree (updated_at);


--
-- Name: index_post_appeals_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_appeals_on_created_at ON public.post_appeals USING btree (created_at);


--
-- Name: index_post_appeals_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_appeals_on_creator_id ON public.post_appeals USING btree (creator_id);


--
-- Name: index_post_appeals_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_appeals_on_post_id ON public.post_appeals USING btree (post_id);


--
-- Name: index_post_appeals_on_reason_tsvector; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_appeals_on_reason_tsvector ON public.post_appeals USING gin (to_tsvector('english'::regconfig, reason));


--
-- Name: index_post_appeals_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_appeals_on_status ON public.post_appeals USING btree (status);


--
-- Name: index_post_approvals_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_approvals_on_post_id ON public.post_approvals USING btree (post_id);


--
-- Name: index_post_approvals_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_approvals_on_user_id ON public.post_approvals USING btree (user_id);


--
-- Name: index_post_disapprovals_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_disapprovals_on_post_id ON public.post_disapprovals USING btree (post_id);


--
-- Name: index_post_disapprovals_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_disapprovals_on_user_id ON public.post_disapprovals USING btree (user_id);


--
-- Name: index_post_flags_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_flags_on_creator_id ON public.post_flags USING btree (creator_id);


--
-- Name: index_post_flags_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_flags_on_post_id ON public.post_flags USING btree (post_id);


--
-- Name: index_post_flags_on_reason_tsvector; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_flags_on_reason_tsvector ON public.post_flags USING gin (to_tsvector('english'::regconfig, reason));


--
-- Name: index_post_flags_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_flags_on_status ON public.post_flags USING btree (status);


--
-- Name: index_post_replacements_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_replacements_on_creator_id ON public.post_replacements USING btree (creator_id);


--
-- Name: index_post_replacements_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_replacements_on_post_id ON public.post_replacements USING btree (post_id);


--
-- Name: index_post_votes_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_votes_on_created_at ON public.post_votes USING btree (created_at);


--
-- Name: index_post_votes_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_votes_on_post_id ON public.post_votes USING btree (post_id);


--
-- Name: index_post_votes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_votes_on_user_id ON public.post_votes USING btree (user_id);


--
-- Name: index_posts_on_approver_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_approver_id ON public.posts USING btree (approver_id) WHERE (approver_id IS NOT NULL);


--
-- Name: index_posts_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_created_at ON public.posts USING btree (created_at);


--
-- Name: index_posts_on_file_size; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_file_size ON public.posts USING btree (file_size);


--
-- Name: index_posts_on_image_height; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_image_height ON public.posts USING btree (image_height);


--
-- Name: index_posts_on_image_width; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_image_width ON public.posts USING btree (image_width);


--
-- Name: index_posts_on_is_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_is_deleted ON public.posts USING btree (is_deleted) WHERE (is_deleted = true);


--
-- Name: index_posts_on_is_flagged; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_is_flagged ON public.posts USING btree (is_flagged) WHERE (is_flagged = true);


--
-- Name: index_posts_on_is_pending; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_is_pending ON public.posts USING btree (is_pending) WHERE (is_pending = true);


--
-- Name: index_posts_on_last_comment_bumped_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_last_comment_bumped_at ON public.posts USING btree (last_comment_bumped_at DESC NULLS LAST);


--
-- Name: index_posts_on_last_noted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_last_noted_at ON public.posts USING btree (last_noted_at DESC NULLS LAST);


--
-- Name: index_posts_on_md5; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_posts_on_md5 ON public.posts USING btree (md5);


--
-- Name: index_posts_on_mpixels; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_mpixels ON public.posts USING btree (((((image_width * image_height))::numeric / 1000000.0)));


--
-- Name: index_posts_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_parent_id ON public.posts USING btree (parent_id) WHERE (parent_id IS NOT NULL);


--
-- Name: index_posts_on_pixiv_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_pixiv_id ON public.posts USING btree (pixiv_id) WHERE (pixiv_id IS NOT NULL);


--
-- Name: index_posts_on_source; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_source ON public.posts USING btree (lower((source)::text));


--
-- Name: index_posts_on_source_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_source_trgm ON public.posts USING gin (source public.gin_trgm_ops);


--
-- Name: index_posts_on_tags_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_tags_index ON public.posts USING gin (tag_index);


--
-- Name: index_posts_on_uploader_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_uploader_id ON public.posts USING btree (uploader_id) WHERE (uploader_id IS NOT NULL);


--
-- Name: index_posts_on_uploader_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_uploader_ip_addr ON public.posts USING btree (uploader_ip_addr);


--
-- Name: index_saved_searches_on_labels; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_saved_searches_on_labels ON public.saved_searches USING gin (labels);


--
-- Name: index_saved_searches_on_query; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_saved_searches_on_query ON public.saved_searches USING btree (query);


--
-- Name: index_saved_searches_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_saved_searches_on_user_id ON public.saved_searches USING btree (user_id);


--
-- Name: index_tag_aliases_on_antecedent_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_aliases_on_antecedent_name ON public.tag_aliases USING btree (antecedent_name);


--
-- Name: index_tag_aliases_on_antecedent_name_pattern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_aliases_on_antecedent_name_pattern ON public.tag_aliases USING btree (antecedent_name text_pattern_ops);


--
-- Name: index_tag_aliases_on_consequent_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_aliases_on_consequent_name ON public.tag_aliases USING btree (consequent_name);


--
-- Name: index_tag_aliases_on_forum_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_aliases_on_forum_post_id ON public.tag_aliases USING btree (forum_post_id);


--
-- Name: index_tag_implications_on_antecedent_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_implications_on_antecedent_name ON public.tag_implications USING btree (antecedent_name);


--
-- Name: index_tag_implications_on_consequent_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_implications_on_consequent_name ON public.tag_implications USING btree (consequent_name);


--
-- Name: index_tag_implications_on_forum_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_implications_on_forum_post_id ON public.tag_implications USING btree (forum_post_id);


--
-- Name: index_tags_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tags_on_name ON public.tags USING btree (name);


--
-- Name: index_tags_on_name_pattern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tags_on_name_pattern ON public.tags USING btree (name text_pattern_ops);


--
-- Name: index_tags_on_name_prefix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tags_on_name_prefix ON public.tags USING gin (regexp_replace((name)::text, '([a-z0-9])[a-z0-9'']*($|[^a-z0-9'']+)'::text, '\1'::text, 'g'::text) public.gin_trgm_ops);


--
-- Name: index_tags_on_name_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tags_on_name_trgm ON public.tags USING gin (name public.gin_trgm_ops);


--
-- Name: index_tags_on_post_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tags_on_post_count ON public.tags USING btree (post_count);


--
-- Name: index_token_buckets_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_token_buckets_on_user_id ON public.token_buckets USING btree (user_id);


--
-- Name: index_uploads_on_referer_url; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_uploads_on_referer_url ON public.uploads USING btree (referer_url);


--
-- Name: index_uploads_on_source; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_uploads_on_source ON public.uploads USING btree (source);


--
-- Name: index_uploads_on_uploader_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_uploads_on_uploader_id ON public.uploads USING btree (uploader_id);


--
-- Name: index_uploads_on_uploader_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_uploads_on_uploader_ip_addr ON public.uploads USING btree (uploader_ip_addr);


--
-- Name: index_user_feedback_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_feedback_on_created_at ON public.user_feedback USING btree (created_at);


--
-- Name: index_user_feedback_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_feedback_on_creator_id ON public.user_feedback USING btree (creator_id);


--
-- Name: index_user_feedback_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_feedback_on_user_id ON public.user_feedback USING btree (user_id);


--
-- Name: index_user_name_change_requests_on_original_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_name_change_requests_on_original_name ON public.user_name_change_requests USING btree (original_name);


--
-- Name: index_user_name_change_requests_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_name_change_requests_on_user_id ON public.user_name_change_requests USING btree (user_id);


--
-- Name: index_users_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_created_at ON public.users USING btree (created_at);


--
-- Name: index_users_on_inviter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_inviter_id ON public.users USING btree (inviter_id) WHERE (inviter_id IS NOT NULL);


--
-- Name: index_users_on_last_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_last_ip_addr ON public.users USING btree (last_ip_addr) WHERE (last_ip_addr IS NOT NULL);


--
-- Name: index_users_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_name ON public.users USING btree (lower((name)::text));


--
-- Name: index_users_on_name_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_name_trgm ON public.users USING gin (name public.gin_trgm_ops);


--
-- Name: index_wiki_page_versions_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_page_versions_on_created_at ON public.wiki_page_versions USING btree (created_at);


--
-- Name: index_wiki_page_versions_on_updater_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_page_versions_on_updater_id ON public.wiki_page_versions USING btree (updater_id);


--
-- Name: index_wiki_page_versions_on_updater_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_page_versions_on_updater_ip_addr ON public.wiki_page_versions USING btree (updater_ip_addr);


--
-- Name: index_wiki_page_versions_on_wiki_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_page_versions_on_wiki_page_id ON public.wiki_page_versions USING btree (wiki_page_id);


--
-- Name: index_wiki_pages_on_body_index_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_pages_on_body_index_index ON public.wiki_pages USING gin (body_index);


--
-- Name: index_wiki_pages_on_other_names; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_pages_on_other_names ON public.wiki_pages USING gin (other_names);


--
-- Name: index_wiki_pages_on_title; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_wiki_pages_on_title ON public.wiki_pages USING btree (title);


--
-- Name: index_wiki_pages_on_title_pattern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_pages_on_title_pattern ON public.wiki_pages USING btree (title text_pattern_ops);


--
-- Name: index_wiki_pages_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_pages_on_updated_at ON public.wiki_pages USING btree (updated_at);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- Name: favorites insert_favorites_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER insert_favorites_trigger BEFORE INSERT ON public.favorites FOR EACH ROW EXECUTE PROCEDURE public.favorites_insert_trigger();


--
-- Name: comments trigger_comments_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_comments_on_update BEFORE INSERT OR UPDATE ON public.comments FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('body_index', 'pg_catalog.english', 'body');


--
-- Name: dmails trigger_dmails_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_dmails_on_update BEFORE INSERT OR UPDATE ON public.dmails FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('message_index', 'pg_catalog.english', 'title', 'body');


--
-- Name: forum_posts trigger_forum_posts_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_forum_posts_on_update BEFORE INSERT OR UPDATE ON public.forum_posts FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('text_index', 'pg_catalog.english', 'body');


--
-- Name: forum_topics trigger_forum_topics_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_forum_topics_on_update BEFORE INSERT OR UPDATE ON public.forum_topics FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('text_index', 'pg_catalog.english', 'title');


--
-- Name: notes trigger_notes_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_notes_on_update BEFORE INSERT OR UPDATE ON public.notes FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('body_index', 'pg_catalog.english', 'body');


--
-- Name: posts trigger_posts_on_tag_index_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_posts_on_tag_index_update BEFORE INSERT OR UPDATE ON public.posts FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('tag_index', 'public.danbooru', 'tag_string', 'fav_string', 'pool_string');


--
-- Name: wiki_pages trigger_wiki_pages_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_wiki_pages_on_update BEFORE INSERT OR UPDATE ON public.wiki_pages FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('body_index', 'public.danbooru', 'body', 'title');


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20100204211522'),
('20100204214746'),
('20100205162521'),
('20100205163027'),
('20100205224030'),
('20100211025616'),
('20100211181944'),
('20100211191709'),
('20100211191716'),
('20100213181847'),
('20100213183712'),
('20100214080549'),
('20100214080557'),
('20100214080605'),
('20100215182234'),
('20100215213756'),
('20100215223541'),
('20100215224629'),
('20100215224635'),
('20100215225710'),
('20100215230642'),
('20100219230537'),
('20100221003655'),
('20100221005812'),
('20100223001012'),
('20100224171915'),
('20100224172146'),
('20100307073438'),
('20100309211553'),
('20100318213503'),
('20100826232512'),
('20110328215652'),
('20110328215701'),
('20110607194023'),
('20110717010705'),
('20110722211855'),
('20110815233456'),
('20111101212358'),
('20130106210658'),
('20130114154400'),
('20130219171111'),
('20130219184743'),
('20130221032344'),
('20130221035518'),
('20130221214811'),
('20130302214500'),
('20130305005138'),
('20130307225324'),
('20130308204213'),
('20130318002652'),
('20130318012517'),
('20130318030619'),
('20130318231740'),
('20130320070700'),
('20130322162059'),
('20130322173202'),
('20130322173859'),
('20130323160259'),
('20130326035904'),
('20130328092739'),
('20130331180246'),
('20130331182719'),
('20130401013601'),
('20130409191950'),
('20130417221643'),
('20130424121410'),
('20130506154136'),
('20130606224559'),
('20130618230158'),
('20130620215658'),
('20130712162600'),
('20130914175431'),
('20131006193238'),
('20131117150705'),
('20131118153503'),
('20131130190411'),
('20131209181023'),
('20131217025233'),
('20131225002748'),
('20140111191413'),
('20140204233337'),
('20140221213349'),
('20140428015134'),
('20140505000956'),
('20140603225334'),
('20140604002414'),
('20140613004559'),
('20140701224800'),
('20140722225753'),
('20140725003232'),
('20141009231234'),
('20141017231608'),
('20141120045943'),
('20150119191042'),
('20150120005624'),
('20150128005954'),
('20150403224949'),
('20150613010904'),
('20150623191904'),
('20150629235905'),
('20150705014135'),
('20150721214646'),
('20150728170433'),
('20150805010245'),
('20151217213321'),
('20160219004022'),
('20160219010854'),
('20160219172840'),
('20160222211328'),
('20160526174848'),
('20160820003534'),
('20160822230752'),
('20160919234407'),
('20161018221128'),
('20161024220345'),
('20161101003139'),
('20161221225849'),
('20161227003428'),
('20161229001201'),
('20170106012138'),
('20170112021922'),
('20170112060921'),
('20170117233040'),
('20170218104710'),
('20170302014435'),
('20170314235626'),
('20170316224630'),
('20170319000519'),
('20170329185605'),
('20170330230231'),
('20170413000209'),
('20170414005856'),
('20170414233426'),
('20170414233617'),
('20170416224142'),
('20170428220448'),
('20170512221200'),
('20170515235205'),
('20170519204506'),
('20170526183928'),
('20170608043651'),
('20170613200356'),
('20170709190409'),
('20170914200122'),
('20171106075030'),
('20171127195124'),
('20171218213037'),
('20171219001521'),
('20171230220225'),
('20180113211343'),
('20180116001101'),
('20180403231351'),
('20180413224239'),
('20180425194016'),
('20180516222413'),
('20180517190048'),
('20180518175154'),
('20180804203201'),
('20180816230604'),
('20180912185624'),
('20180913184128'),
('20180916002448'),
('20181108162204'),
('20181108205842'),
('20181113174914'),
('20181114180205'),
('20181114185032'),
('20181114202744'),
('20181130004740'),
('20181202172145'),
('20190109210822'),
('20190129012253'),
('20190712174818'),
('20190827013252'),
('20190827014726'),
('20190827233235'),
('20190827234625'),
('20190828005453'),
('20190829052629'),
('20190829055758'),
('20190902224045'),
('20190908031103'),
('20190908035317'),
('20190919175836'),
('20190923071044'),
('20190926000912'),
('20191023191749'),
('20191024194544'),
('20191111004329'),
('20191111024520'),
('20191116001441'),
('20191116021759'),
('20191116224228'),
('20191117074642'),
('20191117080647'),
('20191117081229'),
('20191117200404'),
('20191119061018'),
('20191223032633'),
('20200114204550'),
('20200115010442'),
('20200117220602'),
('20200118015014'),
('20200119184442'),
('20200119193110'),
('20200123184743'),
('20200217044719'),
('20200223042415'),
('20200223234015'),
('20200306202253'),
('20200307021204'),
('20200309035334'),
('20200309043653'),
('20200318224633'),
('20200325073456'),
('20200325074859'),
('20200403210353'),
('20200406054838'),
('20200427190519'),
('20200520060951'),
('20200803022359'),
('20200816175151');


