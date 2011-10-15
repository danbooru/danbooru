--
-- PostgreSQL database dump
--

-- Started on 2011-10-09 15:21:05 EDT

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- TOC entry 464 (class 2612 OID 16388)
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: -
--

CREATE PROCEDURAL LANGUAGE plpgsql;


SET search_path = public, pg_catalog;

--
-- TOC entry 315 (class 1247 OID 16390)
-- Dependencies: 3
-- Name: post_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE post_status AS ENUM (
    'deleted',
    'flagged',
    'pending',
    'active'
);


--
-- TOC entry 21 (class 1255 OID 16395)
-- Dependencies: 3 464
-- Name: block_delete(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION block_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
			 RAISE EXCEPTION 'Attempted to delete from note table';
			 RETURN NULL;
end;
$$;


--
-- TOC entry 22 (class 1255 OID 16396)
-- Dependencies: 3 464
-- Name: notes_block_delete(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION notes_block_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  raise exception 'cannot delete note';
end;
$$;


--
-- TOC entry 23 (class 1255 OID 16397)
-- Dependencies: 464 3
-- Name: pools_posts_delete_trg(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION pools_posts_delete_trg() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
				BEGIN
					UPDATE pools SET post_count = post_count - 1 WHERE id = OLD.pool_id;
					RETURN OLD;
				END;
				$$;


--
-- TOC entry 24 (class 1255 OID 16398)
-- Dependencies: 464 3
-- Name: pools_posts_insert_trg(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION pools_posts_insert_trg() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
				BEGIN
					UPDATE pools SET post_count = post_count + 1 WHERE id = NEW.pool_id;
					RETURN NEW;
				END;
				$$;


--
-- TOC entry 25 (class 1255 OID 16399)
-- Dependencies: 3
-- Name: rlike(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rlike(text, text) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$select $2 like $1$_$;


--
-- TOC entry 26 (class 1255 OID 16400)
-- Dependencies: 3
-- Name: testprs_end(internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION testprs_end(internal) RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/test_parser', 'testprs_end';


--
-- TOC entry 27 (class 1255 OID 16401)
-- Dependencies: 3
-- Name: testprs_getlexeme(internal, internal, internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION testprs_getlexeme(internal, internal, internal) RETURNS internal
    LANGUAGE c STRICT
    AS '$libdir/test_parser', 'testprs_getlexeme';


--
-- TOC entry 28 (class 1255 OID 16402)
-- Dependencies: 3
-- Name: testprs_lextype(internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION testprs_lextype(internal) RETURNS internal
    LANGUAGE c STRICT
    AS '$libdir/test_parser', 'testprs_lextype';


--
-- TOC entry 29 (class 1255 OID 16403)
-- Dependencies: 3
-- Name: testprs_start(internal, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION testprs_start(internal, integer) RETURNS internal
    LANGUAGE c STRICT
    AS '$libdir/test_parser', 'testprs_start';


--
-- TOC entry 30 (class 1255 OID 16404)
-- Dependencies: 464 3
-- Name: trg_posts_tags__delete(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION trg_posts_tags__delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        UPDATE tags SET post_count = post_count - 1 WHERE tags.id = OLD.tag_id;
        RETURN OLD;
      END;
      $$;


--
-- TOC entry 31 (class 1255 OID 16405)
-- Dependencies: 3 464
-- Name: trg_posts_tags__insert(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION trg_posts_tags__insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        UPDATE tags SET post_count = post_count + 1 WHERE tags.id = NEW.tag_id;
        RETURN NEW;
      END;
      $$;


--
-- TOC entry 1168 (class 2617 OID 16406)
-- Dependencies: 3 25
-- Name: ~~~; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR ~~~ (
    PROCEDURE = rlike,
    LEFTARG = text,
    RIGHTARG = text,
    COMMUTATOR = ~~
);


--
-- TOC entry 1282 (class 3601 OID 16407)
-- Dependencies: 26 3 29 27 28
-- Name: testparser; Type: TEXT SEARCH PARSER; Schema: public; Owner: -
--

CREATE TEXT SEARCH PARSER testparser (
    START = testprs_start,
    GETTOKEN = testprs_getlexeme,
    END = testprs_end,
    HEADLINE = prsd_headline,
    LEXTYPES = testprs_lextype );


--
-- TOC entry 1320 (class 3602 OID 16408)
-- Dependencies: 1282 3
-- Name: danbooru; Type: TEXT SEARCH CONFIGURATION; Schema: public; Owner: -
--

CREATE TEXT SEARCH CONFIGURATION danbooru (
    PARSER = testparser );

ALTER TEXT SEARCH CONFIGURATION danbooru
    ADD MAPPING FOR word WITH simple;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 1654 (class 1259 OID 16409)
-- Dependencies: 3
-- Name: advertisement_hits; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE advertisement_hits (
    id integer NOT NULL,
    advertisement_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    ip_addr inet
);


--
-- TOC entry 1655 (class 1259 OID 16415)
-- Dependencies: 1654 3
-- Name: advertisement_hits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE advertisement_hits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2337 (class 0 OID 0)
-- Dependencies: 1655
-- Name: advertisement_hits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE advertisement_hits_id_seq OWNED BY advertisement_hits.id;


--
-- TOC entry 1656 (class 1259 OID 16417)
-- Dependencies: 2009 2010 3
-- Name: advertisements; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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


--
-- TOC entry 1657 (class 1259 OID 16425)
-- Dependencies: 1656 3
-- Name: advertisements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE advertisements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2338 (class 0 OID 0)
-- Dependencies: 1657
-- Name: advertisements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE advertisements_id_seq OWNED BY advertisements.id;


--
-- TOC entry 1658 (class 1259 OID 16427)
-- Dependencies: 3
-- Name: artist_urls; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE artist_urls (
    id integer NOT NULL,
    artist_id integer NOT NULL,
    url text NOT NULL,
    normalized_url text NOT NULL
);


--
-- TOC entry 1659 (class 1259 OID 16433)
-- Dependencies: 1658 3
-- Name: artist_urls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE artist_urls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2339 (class 0 OID 0)
-- Dependencies: 1659
-- Name: artist_urls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE artist_urls_id_seq OWNED BY artist_urls.id;


--
-- TOC entry 1660 (class 1259 OID 16435)
-- Dependencies: 2013 2014 2016 3
-- Name: artist_versions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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


--
-- TOC entry 1661 (class 1259 OID 16443)
-- Dependencies: 1660 3
-- Name: artist_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE artist_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2340 (class 0 OID 0)
-- Dependencies: 1661
-- Name: artist_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE artist_versions_id_seq OWNED BY artist_versions.id;


--
-- TOC entry 1662 (class 1259 OID 16445)
-- Dependencies: 2017 2018 2019 2021 3
-- Name: artists; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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


--
-- TOC entry 1663 (class 1259 OID 16454)
-- Dependencies: 1662 3
-- Name: artists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE artists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2341 (class 0 OID 0)
-- Dependencies: 1663
-- Name: artists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE artists_id_seq OWNED BY artists.id;


--
-- TOC entry 1726 (class 1259 OID 38180)
-- Dependencies: 3
-- Name: banned_ips; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE banned_ips (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    ip_addr inet NOT NULL,
    reason text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- TOC entry 1725 (class 1259 OID 38178)
-- Dependencies: 3 1726
-- Name: banned_ips_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE banned_ips_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2342 (class 0 OID 0)
-- Dependencies: 1725
-- Name: banned_ips_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE banned_ips_id_seq OWNED BY banned_ips.id;


--
-- TOC entry 1664 (class 1259 OID 16456)
-- Dependencies: 3
-- Name: bans; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE bans (
    id integer NOT NULL,
    user_id integer NOT NULL,
    reason text NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    banned_by integer NOT NULL,
    old_level integer
);


--
-- TOC entry 1665 (class 1259 OID 16462)
-- Dependencies: 3 1664
-- Name: bans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2343 (class 0 OID 0)
-- Dependencies: 1665
-- Name: bans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bans_id_seq OWNED BY bans.id;


--
-- TOC entry 1666 (class 1259 OID 16464)
-- Dependencies: 3
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
-- TOC entry 1667 (class 1259 OID 16467)
-- Dependencies: 3 1666
-- Name: comment_votes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE comment_votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2344 (class 0 OID 0)
-- Dependencies: 1667
-- Name: comment_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE comment_votes_id_seq OWNED BY comment_votes.id;


--
-- TOC entry 1668 (class 1259 OID 16469)
-- Dependencies: 2024 3
-- Name: comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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


--
-- TOC entry 1669 (class 1259 OID 16476)
-- Dependencies: 1668 3
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2345 (class 0 OID 0)
-- Dependencies: 1669
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- TOC entry 1670 (class 1259 OID 16478)
-- Dependencies: 2026 3
-- Name: dmails; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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


--
-- TOC entry 1671 (class 1259 OID 16485)
-- Dependencies: 3 1670
-- Name: dmails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE dmails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2346 (class 0 OID 0)
-- Dependencies: 1671
-- Name: dmails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE dmails_id_seq OWNED BY dmails.id;


--
-- TOC entry 1672 (class 1259 OID 16487)
-- Dependencies: 2028 2029 2030 3
-- Name: tag_subscriptions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tag_subscriptions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    tag_query text NOT NULL,
    cached_post_ids text DEFAULT ''::text NOT NULL,
    name character varying(255) DEFAULT 'General'::character varying NOT NULL,
    is_visible_on_profile boolean DEFAULT true NOT NULL
);


--
-- TOC entry 1673 (class 1259 OID 16496)
-- Dependencies: 1672 3
-- Name: favorite_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorite_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2347 (class 0 OID 0)
-- Dependencies: 1673
-- Name: favorite_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorite_tags_id_seq OWNED BY tag_subscriptions.id;


--
-- TOC entry 1674 (class 1259 OID 16498)
-- Dependencies: 2032 3
-- Name: favorites; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites (
    id integer NOT NULL,
    post_id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 1675 (class 1259 OID 16502)
-- Dependencies: 1674 3
-- Name: favorites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2348 (class 0 OID 0)
-- Dependencies: 1675
-- Name: favorites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_id_seq OWNED BY favorites.id;


--
-- TOC entry 1676 (class 1259 OID 16504)
-- Dependencies: 3
-- Name: flagged_post_details; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE flagged_post_details (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    post_id integer NOT NULL,
    reason text NOT NULL,
    user_id integer NOT NULL,
    is_resolved boolean NOT NULL
);


--
-- TOC entry 1677 (class 1259 OID 16510)
-- Dependencies: 3 1676
-- Name: flagged_post_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE flagged_post_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2349 (class 0 OID 0)
-- Dependencies: 1677
-- Name: flagged_post_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE flagged_post_details_id_seq OWNED BY flagged_post_details.id;


--
-- TOC entry 1678 (class 1259 OID 16512)
-- Dependencies: 2035 2036 2037 3
-- Name: forum_posts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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


--
-- TOC entry 1679 (class 1259 OID 16521)
-- Dependencies: 3 1678
-- Name: forum_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE forum_posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2350 (class 0 OID 0)
-- Dependencies: 1679
-- Name: forum_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE forum_posts_id_seq OWNED BY forum_posts.id;


--
-- TOC entry 1680 (class 1259 OID 16523)
-- Dependencies: 2039 2040 3
-- Name: job_tasks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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


--
-- TOC entry 1681 (class 1259 OID 16531)
-- Dependencies: 3 1680
-- Name: job_tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2351 (class 0 OID 0)
-- Dependencies: 1681
-- Name: job_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE job_tasks_id_seq OWNED BY job_tasks.id;


--
-- TOC entry 1730 (class 1259 OID 247721)
-- Dependencies: 3
-- Name: mod_actions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE mod_actions (
    id integer NOT NULL,
    user_id integer,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- TOC entry 1729 (class 1259 OID 247719)
-- Dependencies: 3 1730
-- Name: mod_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE mod_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2352 (class 0 OID 0)
-- Dependencies: 1729
-- Name: mod_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE mod_actions_id_seq OWNED BY mod_actions.id;


--
-- TOC entry 1682 (class 1259 OID 16533)
-- Dependencies: 3
-- Name: mod_queue_posts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE mod_queue_posts (
    id integer NOT NULL,
    user_id integer NOT NULL,
    post_id integer NOT NULL
);


--
-- TOC entry 1683 (class 1259 OID 16536)
-- Dependencies: 1682 3
-- Name: mod_queue_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE mod_queue_posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2353 (class 0 OID 0)
-- Dependencies: 1683
-- Name: mod_queue_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE mod_queue_posts_id_seq OWNED BY mod_queue_posts.id;


--
-- TOC entry 1684 (class 1259 OID 16538)
-- Dependencies: 2043 3
-- Name: note_versions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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


--
-- TOC entry 1685 (class 1259 OID 16545)
-- Dependencies: 1684 3
-- Name: note_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE note_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2354 (class 0 OID 0)
-- Dependencies: 1685
-- Name: note_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE note_versions_id_seq OWNED BY note_versions.id;


--
-- TOC entry 1686 (class 1259 OID 16547)
-- Dependencies: 2045 2046 3
-- Name: notes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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


--
-- TOC entry 1687 (class 1259 OID 16555)
-- Dependencies: 3 1686
-- Name: notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2355 (class 0 OID 0)
-- Dependencies: 1687
-- Name: notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE notes_id_seq OWNED BY notes.id;


--
-- TOC entry 1688 (class 1259 OID 16557)
-- Dependencies: 3
-- Name: pixiv_proxies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pixiv_proxies (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- TOC entry 1689 (class 1259 OID 16560)
-- Dependencies: 1688 3
-- Name: pixiv_proxies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pixiv_proxies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2356 (class 0 OID 0)
-- Dependencies: 1689
-- Name: pixiv_proxies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pixiv_proxies_id_seq OWNED BY pixiv_proxies.id;


--
-- TOC entry 1690 (class 1259 OID 16562)
-- Dependencies: 2049 2050 2051 3
-- Name: pool_updates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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


--
-- TOC entry 1691 (class 1259 OID 16571)
-- Dependencies: 1690 3
-- Name: pool_updates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pool_updates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2357 (class 0 OID 0)
-- Dependencies: 1691
-- Name: pool_updates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pool_updates_id_seq OWNED BY pool_updates.id;


--
-- TOC entry 1692 (class 1259 OID 16573)
-- Dependencies: 2053 2054 2055 2056 3
-- Name: pools; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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


--
-- TOC entry 1693 (class 1259 OID 16583)
-- Dependencies: 3 1692
-- Name: pools_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pools_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2358 (class 0 OID 0)
-- Dependencies: 1693
-- Name: pools_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pools_id_seq OWNED BY pools.id;


--
-- TOC entry 1694 (class 1259 OID 16585)
-- Dependencies: 2058 3
-- Name: pools_posts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pools_posts (
    id integer NOT NULL,
    sequence integer DEFAULT 0 NOT NULL,
    pool_id integer NOT NULL,
    post_id integer NOT NULL,
    next_post_id integer,
    prev_post_id integer
);


--
-- TOC entry 1695 (class 1259 OID 16589)
-- Dependencies: 1694 3
-- Name: pools_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pools_posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2359 (class 0 OID 0)
-- Dependencies: 1695
-- Name: pools_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pools_posts_id_seq OWNED BY pools_posts.id;


--
-- TOC entry 1728 (class 1259 OID 246147)
-- Dependencies: 3
-- Name: post_appeals; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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


--
-- TOC entry 1727 (class 1259 OID 246145)
-- Dependencies: 1728 3
-- Name: post_appeals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE post_appeals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2360 (class 0 OID 0)
-- Dependencies: 1727
-- Name: post_appeals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE post_appeals_id_seq OWNED BY post_appeals.id;


--
-- TOC entry 1696 (class 1259 OID 16591)
-- Dependencies: 2060 2061 2062 2063 2064 2065 2066 2067 2068 2069 2070 2071 2072 3 315
-- Name: posts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
    file_size integer
);


--
-- TOC entry 1697 (class 1259 OID 16610)
-- Dependencies: 1696 3
-- Name: post_change_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE post_change_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2361 (class 0 OID 0)
-- Dependencies: 1697
-- Name: post_change_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE post_change_seq OWNED BY posts.change_seq;


--
-- TOC entry 1698 (class 1259 OID 16612)
-- Dependencies: 3
-- Name: post_tag_histories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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


--
-- TOC entry 1699 (class 1259 OID 16618)
-- Dependencies: 3 1698
-- Name: post_tag_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE post_tag_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2362 (class 0 OID 0)
-- Dependencies: 1699
-- Name: post_tag_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE post_tag_histories_id_seq OWNED BY post_tag_histories.id;


--
-- TOC entry 1700 (class 1259 OID 16620)
-- Dependencies: 2076 3
-- Name: post_votes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE post_votes (
    id integer NOT NULL,
    post_id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    score integer DEFAULT 0 NOT NULL
);


--
-- TOC entry 1701 (class 1259 OID 16624)
-- Dependencies: 1700 3
-- Name: post_votes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE post_votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2363 (class 0 OID 0)
-- Dependencies: 1701
-- Name: post_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE post_votes_id_seq OWNED BY post_votes.id;


--
-- TOC entry 1702 (class 1259 OID 16626)
-- Dependencies: 3 1696
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2364 (class 0 OID 0)
-- Dependencies: 1702
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE posts_id_seq OWNED BY posts.id;


--
-- TOC entry 1703 (class 1259 OID 16631)
-- Dependencies: 3
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- TOC entry 1704 (class 1259 OID 16634)
-- Dependencies: 3
-- Name: server_keys; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE server_keys (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    value text
);


--
-- TOC entry 1705 (class 1259 OID 16640)
-- Dependencies: 1704 3
-- Name: server_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE server_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2365 (class 0 OID 0)
-- Dependencies: 1705
-- Name: server_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE server_keys_id_seq OWNED BY server_keys.id;


--
-- TOC entry 1706 (class 1259 OID 16642)
-- Dependencies: 3
-- Name: table_data; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE table_data (
    name text NOT NULL,
    row_count integer NOT NULL
);


--
-- TOC entry 1707 (class 1259 OID 16648)
-- Dependencies: 2079 2080 3
-- Name: tag_aliases; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tag_aliases (
    id integer NOT NULL,
    name text NOT NULL,
    alias_id integer NOT NULL,
    is_pending boolean DEFAULT false NOT NULL,
    reason text DEFAULT ''::text NOT NULL,
    creator_id integer
);


--
-- TOC entry 1708 (class 1259 OID 16656)
-- Dependencies: 1707 3
-- Name: tag_aliases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tag_aliases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2366 (class 0 OID 0)
-- Dependencies: 1708
-- Name: tag_aliases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tag_aliases_id_seq OWNED BY tag_aliases.id;


--
-- TOC entry 1709 (class 1259 OID 16658)
-- Dependencies: 2082 2083 3
-- Name: tag_implications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tag_implications (
    id integer NOT NULL,
    consequent_id integer NOT NULL,
    predicate_id integer NOT NULL,
    is_pending boolean DEFAULT false NOT NULL,
    reason text DEFAULT ''::text NOT NULL,
    creator_id integer
);


--
-- TOC entry 1710 (class 1259 OID 16666)
-- Dependencies: 1709 3
-- Name: tag_implications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tag_implications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2367 (class 0 OID 0)
-- Dependencies: 1710
-- Name: tag_implications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tag_implications_id_seq OWNED BY tag_implications.id;


--
-- TOC entry 1711 (class 1259 OID 16668)
-- Dependencies: 2085 2086 2087 2088 2089 3
-- Name: tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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


--
-- TOC entry 1712 (class 1259 OID 16679)
-- Dependencies: 1711 3
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2368 (class 0 OID 0)
-- Dependencies: 1712
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- TOC entry 1713 (class 1259 OID 16681)
-- Dependencies: 3
-- Name: test_janitors; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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


--
-- TOC entry 1714 (class 1259 OID 16684)
-- Dependencies: 1713 3
-- Name: test_janitors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE test_janitors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2369 (class 0 OID 0)
-- Dependencies: 1714
-- Name: test_janitors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE test_janitors_id_seq OWNED BY test_janitors.id;


--
-- TOC entry 1715 (class 1259 OID 16686)
-- Dependencies: 3
-- Name: user_blacklisted_tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_blacklisted_tags (
    id integer NOT NULL,
    user_id integer NOT NULL,
    tags text NOT NULL
);


--
-- TOC entry 1716 (class 1259 OID 16692)
-- Dependencies: 3 1715
-- Name: user_blacklisted_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_blacklisted_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2370 (class 0 OID 0)
-- Dependencies: 1716
-- Name: user_blacklisted_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_blacklisted_tags_id_seq OWNED BY user_blacklisted_tags.id;


--
-- TOC entry 1717 (class 1259 OID 16694)
-- Dependencies: 2093 2095 3
-- Name: user_records; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_records (
    id integer NOT NULL,
    user_id integer NOT NULL,
    reported_by integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    body text NOT NULL,
    score integer DEFAULT 0 NOT NULL
);


--
-- TOC entry 1718 (class 1259 OID 16702)
-- Dependencies: 3 1717
-- Name: user_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2371 (class 0 OID 0)
-- Dependencies: 1718
-- Name: user_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_records_id_seq OWNED BY user_records.id;


--
-- TOC entry 1719 (class 1259 OID 16704)
-- Dependencies: 2096 2097 2098 2099 2100 2101 2102 2103 2104 2105 2106 2107 3
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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


--
-- TOC entry 1720 (class 1259 OID 16722)
-- Dependencies: 1719 3
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2372 (class 0 OID 0)
-- Dependencies: 1720
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- TOC entry 1721 (class 1259 OID 16724)
-- Dependencies: 2109 2110 3
-- Name: wiki_page_versions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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


--
-- TOC entry 1722 (class 1259 OID 16732)
-- Dependencies: 3 1721
-- Name: wiki_page_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE wiki_page_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2373 (class 0 OID 0)
-- Dependencies: 1722
-- Name: wiki_page_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE wiki_page_versions_id_seq OWNED BY wiki_page_versions.id;


--
-- TOC entry 1723 (class 1259 OID 16734)
-- Dependencies: 2112 2113 3
-- Name: wiki_pages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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


--
-- TOC entry 1724 (class 1259 OID 16742)
-- Dependencies: 1723 3
-- Name: wiki_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE wiki_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2374 (class 0 OID 0)
-- Dependencies: 1724
-- Name: wiki_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE wiki_pages_id_seq OWNED BY wiki_pages.id;


--
-- TOC entry 2008 (class 2604 OID 16744)
-- Dependencies: 1655 1654
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE advertisement_hits ALTER COLUMN id SET DEFAULT nextval('advertisement_hits_id_seq'::regclass);


--
-- TOC entry 2011 (class 2604 OID 16745)
-- Dependencies: 1657 1656
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE advertisements ALTER COLUMN id SET DEFAULT nextval('advertisements_id_seq'::regclass);


--
-- TOC entry 2012 (class 2604 OID 16746)
-- Dependencies: 1659 1658
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE artist_urls ALTER COLUMN id SET DEFAULT nextval('artist_urls_id_seq'::regclass);


--
-- TOC entry 2015 (class 2604 OID 16747)
-- Dependencies: 1661 1660
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE artist_versions ALTER COLUMN id SET DEFAULT nextval('artist_versions_id_seq'::regclass);


--
-- TOC entry 2020 (class 2604 OID 16748)
-- Dependencies: 1663 1662
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE artists ALTER COLUMN id SET DEFAULT nextval('artists_id_seq'::regclass);


--
-- TOC entry 2115 (class 2604 OID 38183)
-- Dependencies: 1726 1725 1726
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE banned_ips ALTER COLUMN id SET DEFAULT nextval('banned_ips_id_seq'::regclass);


--
-- TOC entry 2022 (class 2604 OID 16749)
-- Dependencies: 1665 1664
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE bans ALTER COLUMN id SET DEFAULT nextval('bans_id_seq'::regclass);


--
-- TOC entry 2023 (class 2604 OID 16750)
-- Dependencies: 1667 1666
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE comment_votes ALTER COLUMN id SET DEFAULT nextval('comment_votes_id_seq'::regclass);


--
-- TOC entry 2025 (class 2604 OID 16751)
-- Dependencies: 1669 1668
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- TOC entry 2027 (class 2604 OID 16752)
-- Dependencies: 1671 1670
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE dmails ALTER COLUMN id SET DEFAULT nextval('dmails_id_seq'::regclass);


--
-- TOC entry 2033 (class 2604 OID 16753)
-- Dependencies: 1675 1674
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- TOC entry 2034 (class 2604 OID 16754)
-- Dependencies: 1677 1676
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE flagged_post_details ALTER COLUMN id SET DEFAULT nextval('flagged_post_details_id_seq'::regclass);


--
-- TOC entry 2038 (class 2604 OID 16755)
-- Dependencies: 1679 1678
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE forum_posts ALTER COLUMN id SET DEFAULT nextval('forum_posts_id_seq'::regclass);


--
-- TOC entry 2041 (class 2604 OID 16756)
-- Dependencies: 1681 1680
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE job_tasks ALTER COLUMN id SET DEFAULT nextval('job_tasks_id_seq'::regclass);


--
-- TOC entry 2117 (class 2604 OID 247724)
-- Dependencies: 1730 1729 1730
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE mod_actions ALTER COLUMN id SET DEFAULT nextval('mod_actions_id_seq'::regclass);


--
-- TOC entry 2042 (class 2604 OID 16757)
-- Dependencies: 1683 1682
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE mod_queue_posts ALTER COLUMN id SET DEFAULT nextval('mod_queue_posts_id_seq'::regclass);


--
-- TOC entry 2044 (class 2604 OID 16758)
-- Dependencies: 1685 1684
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE note_versions ALTER COLUMN id SET DEFAULT nextval('note_versions_id_seq'::regclass);


--
-- TOC entry 2047 (class 2604 OID 16759)
-- Dependencies: 1687 1686
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE notes ALTER COLUMN id SET DEFAULT nextval('notes_id_seq'::regclass);


--
-- TOC entry 2048 (class 2604 OID 16760)
-- Dependencies: 1689 1688
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE pixiv_proxies ALTER COLUMN id SET DEFAULT nextval('pixiv_proxies_id_seq'::regclass);


--
-- TOC entry 2052 (class 2604 OID 16761)
-- Dependencies: 1691 1690
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE pool_updates ALTER COLUMN id SET DEFAULT nextval('pool_updates_id_seq'::regclass);


--
-- TOC entry 2057 (class 2604 OID 16762)
-- Dependencies: 1693 1692
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE pools ALTER COLUMN id SET DEFAULT nextval('pools_id_seq'::regclass);


--
-- TOC entry 2059 (class 2604 OID 16763)
-- Dependencies: 1695 1694
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE pools_posts ALTER COLUMN id SET DEFAULT nextval('pools_posts_id_seq'::regclass);


--
-- TOC entry 2116 (class 2604 OID 246150)
-- Dependencies: 1728 1727 1728
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE post_appeals ALTER COLUMN id SET DEFAULT nextval('post_appeals_id_seq'::regclass);


--
-- TOC entry 2075 (class 2604 OID 16764)
-- Dependencies: 1699 1698
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE post_tag_histories ALTER COLUMN id SET DEFAULT nextval('post_tag_histories_id_seq'::regclass);


--
-- TOC entry 2077 (class 2604 OID 16765)
-- Dependencies: 1701 1700
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE post_votes ALTER COLUMN id SET DEFAULT nextval('post_votes_id_seq'::regclass);


--
-- TOC entry 2073 (class 2604 OID 16766)
-- Dependencies: 1702 1696
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE posts ALTER COLUMN id SET DEFAULT nextval('posts_id_seq'::regclass);


--
-- TOC entry 2074 (class 2604 OID 16767)
-- Dependencies: 1697 1696
-- Name: change_seq; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE posts ALTER COLUMN change_seq SET DEFAULT nextval('post_change_seq'::regclass);


--
-- TOC entry 2078 (class 2604 OID 16768)
-- Dependencies: 1705 1704
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE server_keys ALTER COLUMN id SET DEFAULT nextval('server_keys_id_seq'::regclass);


--
-- TOC entry 2081 (class 2604 OID 16769)
-- Dependencies: 1708 1707
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE tag_aliases ALTER COLUMN id SET DEFAULT nextval('tag_aliases_id_seq'::regclass);


--
-- TOC entry 2084 (class 2604 OID 16770)
-- Dependencies: 1710 1709
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE tag_implications ALTER COLUMN id SET DEFAULT nextval('tag_implications_id_seq'::regclass);


--
-- TOC entry 2031 (class 2604 OID 16771)
-- Dependencies: 1673 1672
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE tag_subscriptions ALTER COLUMN id SET DEFAULT nextval('favorite_tags_id_seq'::regclass);


--
-- TOC entry 2090 (class 2604 OID 16772)
-- Dependencies: 1712 1711
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- TOC entry 2091 (class 2604 OID 16773)
-- Dependencies: 1714 1713
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE test_janitors ALTER COLUMN id SET DEFAULT nextval('test_janitors_id_seq'::regclass);


--
-- TOC entry 2092 (class 2604 OID 16774)
-- Dependencies: 1716 1715
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE user_blacklisted_tags ALTER COLUMN id SET DEFAULT nextval('user_blacklisted_tags_id_seq'::regclass);


--
-- TOC entry 2094 (class 2604 OID 16775)
-- Dependencies: 1718 1717
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE user_records ALTER COLUMN id SET DEFAULT nextval('user_records_id_seq'::regclass);


--
-- TOC entry 2108 (class 2604 OID 16776)
-- Dependencies: 1720 1719
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- TOC entry 2111 (class 2604 OID 16777)
-- Dependencies: 1722 1721
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE wiki_page_versions ALTER COLUMN id SET DEFAULT nextval('wiki_page_versions_id_seq'::regclass);


--
-- TOC entry 2114 (class 2604 OID 16778)
-- Dependencies: 1724 1723
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE wiki_pages ALTER COLUMN id SET DEFAULT nextval('wiki_pages_id_seq'::regclass);


--
-- TOC entry 2119 (class 2606 OID 29559)
-- Dependencies: 1654 1654
-- Name: advertisement_hits_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY advertisement_hits
    ADD CONSTRAINT advertisement_hits_pkey PRIMARY KEY (id);


--
-- TOC entry 2123 (class 2606 OID 29561)
-- Dependencies: 1656 1656
-- Name: advertisements_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY advertisements
    ADD CONSTRAINT advertisements_pkey PRIMARY KEY (id);


--
-- TOC entry 2125 (class 2606 OID 29563)
-- Dependencies: 1658 1658
-- Name: artist_urls_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY artist_urls
    ADD CONSTRAINT artist_urls_pkey PRIMARY KEY (id);


--
-- TOC entry 2130 (class 2606 OID 29565)
-- Dependencies: 1660 1660
-- Name: artist_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY artist_versions
    ADD CONSTRAINT artist_versions_pkey PRIMARY KEY (id);


--
-- TOC entry 2134 (class 2606 OID 29567)
-- Dependencies: 1662 1662
-- Name: artists_name_uniq; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY artists
    ADD CONSTRAINT artists_name_uniq UNIQUE (name);


--
-- TOC entry 2136 (class 2606 OID 29569)
-- Dependencies: 1662 1662
-- Name: artists_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY artists
    ADD CONSTRAINT artists_pkey PRIMARY KEY (id);


--
-- TOC entry 2263 (class 2606 OID 38188)
-- Dependencies: 1726 1726
-- Name: banned_ips_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY banned_ips
    ADD CONSTRAINT banned_ips_pkey PRIMARY KEY (id);


--
-- TOC entry 2139 (class 2606 OID 29571)
-- Dependencies: 1664 1664
-- Name: bans_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bans
    ADD CONSTRAINT bans_pkey PRIMARY KEY (id);


--
-- TOC entry 2142 (class 2606 OID 29573)
-- Dependencies: 1666 1666
-- Name: comment_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comment_votes
    ADD CONSTRAINT comment_votes_pkey PRIMARY KEY (id);


--
-- TOC entry 2147 (class 2606 OID 29575)
-- Dependencies: 1668 1668
-- Name: comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- TOC entry 2151 (class 2606 OID 29577)
-- Dependencies: 1670 1670
-- Name: dmails_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY dmails
    ADD CONSTRAINT dmails_pkey PRIMARY KEY (id);


--
-- TOC entry 2156 (class 2606 OID 29579)
-- Dependencies: 1672 1672
-- Name: favorite_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tag_subscriptions
    ADD CONSTRAINT favorite_tags_pkey PRIMARY KEY (id);


--
-- TOC entry 2160 (class 2606 OID 29581)
-- Dependencies: 1674 1674
-- Name: favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites
    ADD CONSTRAINT favorites_pkey PRIMARY KEY (id);


--
-- TOC entry 2164 (class 2606 OID 29590)
-- Dependencies: 1676 1676
-- Name: flagged_post_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY flagged_post_details
    ADD CONSTRAINT flagged_post_details_pkey PRIMARY KEY (id);


--
-- TOC entry 2168 (class 2606 OID 29592)
-- Dependencies: 1678 1678
-- Name: forum_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY forum_posts
    ADD CONSTRAINT forum_posts_pkey PRIMARY KEY (id);


--
-- TOC entry 2173 (class 2606 OID 29594)
-- Dependencies: 1680 1680
-- Name: job_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY job_tasks
    ADD CONSTRAINT job_tasks_pkey PRIMARY KEY (id);


--
-- TOC entry 2274 (class 2606 OID 247729)
-- Dependencies: 1730 1730
-- Name: mod_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mod_actions
    ADD CONSTRAINT mod_actions_pkey PRIMARY KEY (id);


--
-- TOC entry 2175 (class 2606 OID 29596)
-- Dependencies: 1682 1682
-- Name: mod_queue_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mod_queue_posts
    ADD CONSTRAINT mod_queue_posts_pkey PRIMARY KEY (id);


--
-- TOC entry 2180 (class 2606 OID 29598)
-- Dependencies: 1684 1684
-- Name: note_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY note_versions
    ADD CONSTRAINT note_versions_pkey PRIMARY KEY (id);


--
-- TOC entry 2184 (class 2606 OID 29600)
-- Dependencies: 1686 1686
-- Name: notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notes
    ADD CONSTRAINT notes_pkey PRIMARY KEY (id);


--
-- TOC entry 2187 (class 2606 OID 29602)
-- Dependencies: 1688 1688
-- Name: pixiv_proxies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pixiv_proxies
    ADD CONSTRAINT pixiv_proxies_pkey PRIMARY KEY (id);


--
-- TOC entry 2191 (class 2606 OID 29604)
-- Dependencies: 1690 1690
-- Name: pool_updates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pool_updates
    ADD CONSTRAINT pool_updates_pkey PRIMARY KEY (id);


--
-- TOC entry 2193 (class 2606 OID 29606)
-- Dependencies: 1692 1692
-- Name: pools_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pools
    ADD CONSTRAINT pools_pkey PRIMARY KEY (id);


--
-- TOC entry 2196 (class 2606 OID 29608)
-- Dependencies: 1694 1694
-- Name: pools_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pools_posts
    ADD CONSTRAINT pools_posts_pkey PRIMARY KEY (id);


--
-- TOC entry 2270 (class 2606 OID 246155)
-- Dependencies: 1728 1728
-- Name: post_appeals_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY post_appeals
    ADD CONSTRAINT post_appeals_pkey PRIMARY KEY (id);


--
-- TOC entry 2219 (class 2606 OID 29610)
-- Dependencies: 1698 1698
-- Name: post_tag_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY post_tag_histories
    ADD CONSTRAINT post_tag_histories_pkey PRIMARY KEY (id);


--
-- TOC entry 2224 (class 2606 OID 29612)
-- Dependencies: 1700 1700
-- Name: post_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY post_votes
    ADD CONSTRAINT post_votes_pkey PRIMARY KEY (id);


--
-- TOC entry 2215 (class 2606 OID 29614)
-- Dependencies: 1696 1696
-- Name: posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- TOC entry 2228 (class 2606 OID 29616)
-- Dependencies: 1704 1704
-- Name: server_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY server_keys
    ADD CONSTRAINT server_keys_pkey PRIMARY KEY (id);


--
-- TOC entry 2230 (class 2606 OID 29618)
-- Dependencies: 1706 1706
-- Name: table_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY table_data
    ADD CONSTRAINT table_data_pkey PRIMARY KEY (name);


--
-- TOC entry 2233 (class 2606 OID 29620)
-- Dependencies: 1707 1707
-- Name: tag_aliases_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tag_aliases
    ADD CONSTRAINT tag_aliases_pkey PRIMARY KEY (id);


--
-- TOC entry 2237 (class 2606 OID 29622)
-- Dependencies: 1709 1709
-- Name: tag_implications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tag_implications
    ADD CONSTRAINT tag_implications_pkey PRIMARY KEY (id);


--
-- TOC entry 2241 (class 2606 OID 29624)
-- Dependencies: 1711 1711
-- Name: tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- TOC entry 2244 (class 2606 OID 29626)
-- Dependencies: 1713 1713
-- Name: test_janitors_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY test_janitors
    ADD CONSTRAINT test_janitors_pkey PRIMARY KEY (id);


--
-- TOC entry 2247 (class 2606 OID 29628)
-- Dependencies: 1715 1715
-- Name: user_blacklisted_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_blacklisted_tags
    ADD CONSTRAINT user_blacklisted_tags_pkey PRIMARY KEY (id);


--
-- TOC entry 2249 (class 2606 OID 29630)
-- Dependencies: 1717 1717
-- Name: user_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_records
    ADD CONSTRAINT user_records_pkey PRIMARY KEY (id);


--
-- TOC entry 2252 (class 2606 OID 29632)
-- Dependencies: 1719 1719
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 2256 (class 2606 OID 29634)
-- Dependencies: 1721 1721
-- Name: wiki_page_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY wiki_page_versions
    ADD CONSTRAINT wiki_page_versions_pkey PRIMARY KEY (id);


--
-- TOC entry 2260 (class 2606 OID 29636)
-- Dependencies: 1723 1723
-- Name: wiki_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY wiki_pages
    ADD CONSTRAINT wiki_pages_pkey PRIMARY KEY (id);


--
-- TOC entry 2181 (class 1259 OID 29637)
-- Dependencies: 1686
-- Name: comments_text_search_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX comments_text_search_idx ON notes USING gin (text_search_index);


--
-- TOC entry 2166 (class 1259 OID 29638)
-- Dependencies: 1678 1678
-- Name: forum_posts__parent_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX forum_posts__parent_id_idx ON forum_posts USING btree (parent_id) WHERE (parent_id IS NULL);


--
-- TOC entry 2169 (class 1259 OID 29639)
-- Dependencies: 1678
-- Name: forum_posts_search_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX forum_posts_search_idx ON forum_posts USING gin (text_search_index);


--
-- TOC entry 2148 (class 1259 OID 29640)
-- Dependencies: 1668
-- Name: idx_comments__post; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_comments__post ON comments USING btree (post_id);


--
-- TOC entry 2161 (class 1259 OID 29641)
-- Dependencies: 1674
-- Name: idx_favorites__post; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_favorites__post ON favorites USING btree (post_id);


--
-- TOC entry 2162 (class 1259 OID 29650)
-- Dependencies: 1674
-- Name: idx_favorites__user; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_favorites__user ON favorites USING btree (user_id);


--
-- TOC entry 2176 (class 1259 OID 29651)
-- Dependencies: 1684
-- Name: idx_note_versions__post; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_note_versions__post ON note_versions USING btree (post_id);


--
-- TOC entry 2177 (class 1259 OID 29652)
-- Dependencies: 1684
-- Name: idx_notes__note; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_notes__note ON note_versions USING btree (note_id);


--
-- TOC entry 2182 (class 1259 OID 29653)
-- Dependencies: 1686
-- Name: idx_notes__post; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_notes__post ON notes USING btree (post_id);


--
-- TOC entry 2216 (class 1259 OID 29654)
-- Dependencies: 1698
-- Name: idx_post_tag_histories__post; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_post_tag_histories__post ON post_tag_histories USING btree (post_id);


--
-- TOC entry 2199 (class 1259 OID 29655)
-- Dependencies: 1696
-- Name: idx_posts__created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_posts__created_at ON posts USING btree (created_at);


--
-- TOC entry 2200 (class 1259 OID 29656)
-- Dependencies: 1696 1696
-- Name: idx_posts__last_commented_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_posts__last_commented_at ON posts USING btree (last_commented_at) WHERE (last_commented_at IS NOT NULL);


--
-- TOC entry 2201 (class 1259 OID 29657)
-- Dependencies: 1696 1696
-- Name: idx_posts__last_noted_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_posts__last_noted_at ON posts USING btree (last_noted_at) WHERE (last_noted_at IS NOT NULL);


--
-- TOC entry 2202 (class 1259 OID 29658)
-- Dependencies: 1696
-- Name: idx_posts__md5; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX idx_posts__md5 ON posts USING btree (md5);


--
-- TOC entry 2203 (class 1259 OID 29659)
-- Dependencies: 1696 1696
-- Name: idx_posts__users; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_posts__users ON posts USING btree (user_id) WHERE (user_id IS NOT NULL);


--
-- TOC entry 2204 (class 1259 OID 29660)
-- Dependencies: 1696 1696
-- Name: idx_posts_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_posts_parent_id ON posts USING btree (parent_id) WHERE (parent_id IS NOT NULL);


--
-- TOC entry 2231 (class 1259 OID 29750)
-- Dependencies: 1707
-- Name: idx_tag_aliases__name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX idx_tag_aliases__name ON tag_aliases USING btree (name);


--
-- TOC entry 2234 (class 1259 OID 29751)
-- Dependencies: 1709
-- Name: idx_tag_implications__child; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_tag_implications__child ON tag_implications USING btree (predicate_id);


--
-- TOC entry 2235 (class 1259 OID 29752)
-- Dependencies: 1709
-- Name: idx_tag_implications__parent; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_tag_implications__parent ON tag_implications USING btree (consequent_id);


--
-- TOC entry 2238 (class 1259 OID 29753)
-- Dependencies: 1711
-- Name: idx_tags__name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX idx_tags__name ON tags USING btree (name);


--
-- TOC entry 2239 (class 1259 OID 29754)
-- Dependencies: 1711
-- Name: idx_tags__post_count; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_tags__post_count ON tags USING btree (post_count);


--
-- TOC entry 2250 (class 1259 OID 29755)
-- Dependencies: 1719
-- Name: idx_users__name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_users__name ON users USING btree (lower(name));


--
-- TOC entry 2253 (class 1259 OID 29756)
-- Dependencies: 1721
-- Name: idx_wiki_page_versions__wiki_page; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_wiki_page_versions__wiki_page ON wiki_page_versions USING btree (wiki_page_id);


--
-- TOC entry 2257 (class 1259 OID 29757)
-- Dependencies: 1723
-- Name: idx_wiki_pages__title; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX idx_wiki_pages__title ON wiki_pages USING btree (title);


--
-- TOC entry 2258 (class 1259 OID 29758)
-- Dependencies: 1723
-- Name: idx_wiki_pages__updated_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_wiki_pages__updated_at ON wiki_pages USING btree (updated_at);


--
-- TOC entry 2120 (class 1259 OID 29759)
-- Dependencies: 1654
-- Name: index_advertisement_hits_on_advertisement_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_advertisement_hits_on_advertisement_id ON advertisement_hits USING btree (advertisement_id);


--
-- TOC entry 2121 (class 1259 OID 29760)
-- Dependencies: 1654
-- Name: index_advertisement_hits_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_advertisement_hits_on_created_at ON advertisement_hits USING btree (created_at);


--
-- TOC entry 2126 (class 1259 OID 29761)
-- Dependencies: 1658
-- Name: index_artist_urls_on_artist_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_artist_urls_on_artist_id ON artist_urls USING btree (artist_id);


--
-- TOC entry 2127 (class 1259 OID 29762)
-- Dependencies: 1658
-- Name: index_artist_urls_on_normalized_url; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_artist_urls_on_normalized_url ON artist_urls USING btree (normalized_url);


--
-- TOC entry 2128 (class 1259 OID 29763)
-- Dependencies: 1658
-- Name: index_artist_urls_on_url; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_artist_urls_on_url ON artist_urls USING btree (url);


--
-- TOC entry 2131 (class 1259 OID 29764)
-- Dependencies: 1660
-- Name: index_artist_versions_on_artist_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_artist_versions_on_artist_id ON artist_versions USING btree (artist_id);


--
-- TOC entry 2132 (class 1259 OID 29765)
-- Dependencies: 1660
-- Name: index_artist_versions_on_updater_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_artist_versions_on_updater_id ON artist_versions USING btree (updater_id);


--
-- TOC entry 2137 (class 1259 OID 29766)
-- Dependencies: 1662
-- Name: index_artists_on_other_names_array; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_artists_on_other_names_array ON artists USING btree (other_names_array);


--
-- TOC entry 2264 (class 1259 OID 38189)
-- Dependencies: 1726
-- Name: index_banned_ips_on_ip_addr; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_banned_ips_on_ip_addr ON banned_ips USING btree (ip_addr);


--
-- TOC entry 2140 (class 1259 OID 29767)
-- Dependencies: 1664
-- Name: index_bans_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bans_on_user_id ON bans USING btree (user_id);


--
-- TOC entry 2143 (class 1259 OID 29768)
-- Dependencies: 1666
-- Name: index_comment_votes_on_comment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comment_votes_on_comment_id ON comment_votes USING btree (comment_id);


--
-- TOC entry 2144 (class 1259 OID 29769)
-- Dependencies: 1666
-- Name: index_comment_votes_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comment_votes_on_created_at ON comment_votes USING btree (created_at);


--
-- TOC entry 2145 (class 1259 OID 29770)
-- Dependencies: 1666
-- Name: index_comment_votes_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comment_votes_on_user_id ON comment_votes USING btree (user_id);


--
-- TOC entry 2149 (class 1259 OID 29771)
-- Dependencies: 1668
-- Name: index_comments_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_user_id ON comments USING btree (user_id);


--
-- TOC entry 2152 (class 1259 OID 29772)
-- Dependencies: 1670
-- Name: index_dmails_on_from_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_dmails_on_from_id ON dmails USING btree (from_id);


--
-- TOC entry 2153 (class 1259 OID 29773)
-- Dependencies: 1670
-- Name: index_dmails_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_dmails_on_parent_id ON dmails USING btree (parent_id);


--
-- TOC entry 2154 (class 1259 OID 29774)
-- Dependencies: 1670
-- Name: index_dmails_on_to_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_dmails_on_to_id ON dmails USING btree (to_id);


--
-- TOC entry 2165 (class 1259 OID 29775)
-- Dependencies: 1676
-- Name: index_flagged_post_details_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_flagged_post_details_on_post_id ON flagged_post_details USING btree (post_id);


--
-- TOC entry 2170 (class 1259 OID 29776)
-- Dependencies: 1678
-- Name: index_forum_posts_on_creator_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_forum_posts_on_creator_id ON forum_posts USING btree (creator_id);


--
-- TOC entry 2171 (class 1259 OID 29777)
-- Dependencies: 1678
-- Name: index_forum_posts_on_updated_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_forum_posts_on_updated_at ON forum_posts USING btree (updated_at);


--
-- TOC entry 2271 (class 1259 OID 248487)
-- Dependencies: 1730
-- Name: index_mod_actions_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_mod_actions_on_created_at ON mod_actions USING btree (created_at);


--
-- TOC entry 2272 (class 1259 OID 247730)
-- Dependencies: 1730
-- Name: index_mod_actions_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_mod_actions_on_user_id ON mod_actions USING btree (user_id);


--
-- TOC entry 2178 (class 1259 OID 29778)
-- Dependencies: 1684
-- Name: index_note_versions_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_note_versions_on_user_id ON note_versions USING btree (user_id);


--
-- TOC entry 2188 (class 1259 OID 29779)
-- Dependencies: 1690
-- Name: index_pool_updates_on_pool_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_pool_updates_on_pool_id ON pool_updates USING btree (pool_id);


--
-- TOC entry 2189 (class 1259 OID 29780)
-- Dependencies: 1690
-- Name: index_pool_updates_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_pool_updates_on_user_id ON pool_updates USING btree (user_id);


--
-- TOC entry 2265 (class 1259 OID 248486)
-- Dependencies: 1728
-- Name: index_post_appeals_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_post_appeals_on_created_at ON post_appeals USING btree (created_at);


--
-- TOC entry 2266 (class 1259 OID 246158)
-- Dependencies: 1728
-- Name: index_post_appeals_on_ip_addr; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_post_appeals_on_ip_addr ON post_appeals USING btree (ip_addr);


--
-- TOC entry 2267 (class 1259 OID 246156)
-- Dependencies: 1728
-- Name: index_post_appeals_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_post_appeals_on_post_id ON post_appeals USING btree (post_id);


--
-- TOC entry 2268 (class 1259 OID 246157)
-- Dependencies: 1728
-- Name: index_post_appeals_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_post_appeals_on_user_id ON post_appeals USING btree (user_id);


--
-- TOC entry 2217 (class 1259 OID 29781)
-- Dependencies: 1698
-- Name: index_post_tag_histories_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_post_tag_histories_on_user_id ON post_tag_histories USING btree (user_id);


--
-- TOC entry 2220 (class 1259 OID 29790)
-- Dependencies: 1700
-- Name: index_post_votes_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_post_votes_on_created_at ON post_votes USING btree (created_at);


--
-- TOC entry 2221 (class 1259 OID 29791)
-- Dependencies: 1700
-- Name: index_post_votes_on_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_post_votes_on_post_id ON post_votes USING btree (post_id);


--
-- TOC entry 2222 (class 1259 OID 29792)
-- Dependencies: 1700
-- Name: index_post_votes_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_post_votes_on_user_id ON post_votes USING btree (user_id);


--
-- TOC entry 2205 (class 1259 OID 29793)
-- Dependencies: 1696
-- Name: index_posts_on_approver_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_posts_on_approver_id ON posts USING btree (approver_id);


--
-- TOC entry 2206 (class 1259 OID 29794)
-- Dependencies: 1696
-- Name: index_posts_on_change_seq; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_posts_on_change_seq ON posts USING btree (change_seq);


--
-- TOC entry 2207 (class 1259 OID 29795)
-- Dependencies: 1696
-- Name: index_posts_on_file_size; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_posts_on_file_size ON posts USING btree (file_size);


--
-- TOC entry 2208 (class 1259 OID 29796)
-- Dependencies: 1696
-- Name: index_posts_on_height; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_posts_on_height ON posts USING btree (height);


--
-- TOC entry 2209 (class 1259 OID 29797)
-- Dependencies: 1696
-- Name: index_posts_on_source; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_posts_on_source ON posts USING btree (source);


--
-- TOC entry 2210 (class 1259 OID 29798)
-- Dependencies: 1696
-- Name: index_posts_on_tags_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_posts_on_tags_index ON posts USING gin (tags_index);


--
-- TOC entry 2211 (class 1259 OID 29799)
-- Dependencies: 1696
-- Name: index_posts_on_width; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_posts_on_width ON posts USING btree (width);


--
-- TOC entry 2226 (class 1259 OID 29800)
-- Dependencies: 1704
-- Name: index_server_keys_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_server_keys_on_name ON server_keys USING btree (name);


--
-- TOC entry 2157 (class 1259 OID 29801)
-- Dependencies: 1672
-- Name: index_tag_subscriptions_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_tag_subscriptions_on_name ON tag_subscriptions USING btree (name);


--
-- TOC entry 2158 (class 1259 OID 29802)
-- Dependencies: 1672
-- Name: index_tag_subscriptions_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_tag_subscriptions_on_user_id ON tag_subscriptions USING btree (user_id);


--
-- TOC entry 2242 (class 1259 OID 29803)
-- Dependencies: 1713
-- Name: index_test_janitors_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_test_janitors_on_user_id ON test_janitors USING btree (user_id);


--
-- TOC entry 2245 (class 1259 OID 29804)
-- Dependencies: 1715
-- Name: index_user_blacklisted_tags_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_blacklisted_tags_on_user_id ON user_blacklisted_tags USING btree (user_id);


--
-- TOC entry 2254 (class 1259 OID 29805)
-- Dependencies: 1721
-- Name: index_wiki_page_versions_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_wiki_page_versions_on_user_id ON wiki_page_versions USING btree (user_id);


--
-- TOC entry 2185 (class 1259 OID 29806)
-- Dependencies: 1686
-- Name: notes_text_search_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX notes_text_search_idx ON notes USING gin (text_search_index);


--
-- TOC entry 2197 (class 1259 OID 29807)
-- Dependencies: 1694
-- Name: pools_posts_pool_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX pools_posts_pool_id_idx ON pools_posts USING btree (pool_id);


--
-- TOC entry 2198 (class 1259 OID 29808)
-- Dependencies: 1694
-- Name: pools_posts_post_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX pools_posts_post_id_idx ON pools_posts USING btree (post_id);


--
-- TOC entry 2194 (class 1259 OID 29809)
-- Dependencies: 1692
-- Name: pools_user_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX pools_user_id_idx ON pools USING btree (user_id);


--
-- TOC entry 2212 (class 1259 OID 29810)
-- Dependencies: 1696 1696 315
-- Name: post_status_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX post_status_idx ON posts USING btree (status) WHERE (status < 'active'::post_status);


--
-- TOC entry 2213 (class 1259 OID 29811)
-- Dependencies: 1696 1696
-- Name: posts_mpixels; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX posts_mpixels ON posts USING btree (((((width * height))::numeric / 1000000.0)));


--
-- TOC entry 2225 (class 1259 OID 29812)
-- Dependencies: 1703
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- TOC entry 2261 (class 1259 OID 29813)
-- Dependencies: 1723
-- Name: wiki_pages_search_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX wiki_pages_search_idx ON wiki_pages USING gin (text_search_index);


--
-- TOC entry 2329 (class 2620 OID 29814)
-- Dependencies: 1694 23
-- Name: pools_posts_delete_trg; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER pools_posts_delete_trg
    BEFORE DELETE ON pools_posts
    FOR EACH ROW
    EXECUTE PROCEDURE pools_posts_delete_trg();


--
-- TOC entry 2330 (class 2620 OID 29815)
-- Dependencies: 1694 24
-- Name: pools_posts_insert_trg; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER pools_posts_insert_trg
    BEFORE INSERT ON pools_posts
    FOR EACH ROW
    EXECUTE PROCEDURE pools_posts_insert_trg();


--
-- TOC entry 2326 (class 2620 OID 29816)
-- Dependencies: 1668
-- Name: trg_comment_search_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_comment_search_update
    BEFORE INSERT OR UPDATE ON comments
    FOR EACH ROW
    EXECUTE PROCEDURE tsvector_update_trigger('text_search_index', 'pg_catalog.english', 'body');


--
-- TOC entry 2327 (class 2620 OID 29817)
-- Dependencies: 1678
-- Name: trg_forum_post_search_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_forum_post_search_update
    BEFORE INSERT OR UPDATE ON forum_posts
    FOR EACH ROW
    EXECUTE PROCEDURE tsvector_update_trigger('text_search_index', 'pg_catalog.english', 'title', 'body');


--
-- TOC entry 2328 (class 2620 OID 29818)
-- Dependencies: 1686
-- Name: trg_note_search_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_note_search_update
    BEFORE INSERT OR UPDATE ON notes
    FOR EACH ROW
    EXECUTE PROCEDURE tsvector_update_trigger('text_search_index', 'pg_catalog.english', 'body');


--
-- TOC entry 2331 (class 2620 OID 29821)
-- Dependencies: 1696
-- Name: trg_posts_tags_index_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_posts_tags_index_update
    BEFORE INSERT OR UPDATE ON posts
    FOR EACH ROW
    EXECUTE PROCEDURE tsvector_update_trigger('tags_index', 'public.danbooru', 'cached_tags');


--
-- TOC entry 2332 (class 2620 OID 29822)
-- Dependencies: 1723
-- Name: trg_wiki_page_search_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_wiki_page_search_update
    BEFORE INSERT OR UPDATE ON wiki_pages
    FOR EACH ROW
    EXECUTE PROCEDURE tsvector_update_trigger('text_search_index', 'pg_catalog.english', 'title', 'body');


--
-- TOC entry 2275 (class 2606 OID 29823)
-- Dependencies: 2135 1658 1662
-- Name: artist_urls_artist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY artist_urls
    ADD CONSTRAINT artist_urls_artist_id_fkey FOREIGN KEY (artist_id) REFERENCES artists(id) ON DELETE CASCADE;


--
-- TOC entry 2276 (class 2606 OID 29828)
-- Dependencies: 1662 2251 1719
-- Name: artists_updater_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY artists
    ADD CONSTRAINT artists_updater_id_fkey FOREIGN KEY (updater_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- TOC entry 2277 (class 2606 OID 29833)
-- Dependencies: 1664 2251 1719
-- Name: bans_banned_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bans
    ADD CONSTRAINT bans_banned_by_fkey FOREIGN KEY (banned_by) REFERENCES users(id) ON DELETE CASCADE;


--
-- TOC entry 2278 (class 2606 OID 29838)
-- Dependencies: 1719 2251 1664
-- Name: bans_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bans
    ADD CONSTRAINT bans_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- TOC entry 2279 (class 2606 OID 29843)
-- Dependencies: 1668 2146 1666
-- Name: comment_votes_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY comment_votes
    ADD CONSTRAINT comment_votes_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES comments(id) ON DELETE CASCADE;


--
-- TOC entry 2280 (class 2606 OID 29848)
-- Dependencies: 1719 1666 2251
-- Name: comment_votes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY comment_votes
    ADD CONSTRAINT comment_votes_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- TOC entry 2283 (class 2606 OID 29853)
-- Dependencies: 1670 2251 1719
-- Name: dmails_from_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY dmails
    ADD CONSTRAINT dmails_from_id_fkey FOREIGN KEY (from_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- TOC entry 2284 (class 2606 OID 29858)
-- Dependencies: 2150 1670 1670
-- Name: dmails_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY dmails
    ADD CONSTRAINT dmails_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES dmails(id);


--
-- TOC entry 2285 (class 2606 OID 29863)
-- Dependencies: 1719 1670 2251
-- Name: dmails_to_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY dmails
    ADD CONSTRAINT dmails_to_id_fkey FOREIGN KEY (to_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- TOC entry 2281 (class 2606 OID 29868)
-- Dependencies: 1668 2214 1696
-- Name: fk_comments__post; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT fk_comments__post FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE;


--
-- TOC entry 2282 (class 2606 OID 29873)
-- Dependencies: 2251 1668 1719
-- Name: fk_comments__user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT fk_comments__user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- TOC entry 2287 (class 2606 OID 29881)
-- Dependencies: 2214 1674 1696
-- Name: fk_favorites__post; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites
    ADD CONSTRAINT fk_favorites__post FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE;


--
-- TOC entry 2288 (class 2606 OID 29898)
-- Dependencies: 1719 1674 2251
-- Name: fk_favorites__user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites
    ADD CONSTRAINT fk_favorites__user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- TOC entry 2296 (class 2606 OID 29903)
-- Dependencies: 2183 1686 1684
-- Name: fk_note_versions__note; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY note_versions
    ADD CONSTRAINT fk_note_versions__note FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE;


--
-- TOC entry 2297 (class 2606 OID 29908)
-- Dependencies: 1684 2214 1696
-- Name: fk_note_versions__post; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY note_versions
    ADD CONSTRAINT fk_note_versions__post FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE;


--
-- TOC entry 2298 (class 2606 OID 29913)
-- Dependencies: 2251 1684 1719
-- Name: fk_note_versions__user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY note_versions
    ADD CONSTRAINT fk_note_versions__user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- TOC entry 2299 (class 2606 OID 29918)
-- Dependencies: 1696 2214 1686
-- Name: fk_notes__post; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY notes
    ADD CONSTRAINT fk_notes__post FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE;


--
-- TOC entry 2300 (class 2606 OID 29923)
-- Dependencies: 1686 2251 1719
-- Name: fk_notes__user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY notes
    ADD CONSTRAINT fk_notes__user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- TOC entry 2310 (class 2606 OID 29928)
-- Dependencies: 1696 1698 2214
-- Name: fk_post_tag_histories__post; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY post_tag_histories
    ADD CONSTRAINT fk_post_tag_histories__post FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE;


--
-- TOC entry 2307 (class 2606 OID 29933)
-- Dependencies: 2251 1719 1696
-- Name: fk_posts__user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT fk_posts__user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- TOC entry 2314 (class 2606 OID 29964)
-- Dependencies: 2240 1707 1711
-- Name: fk_tag_aliases__alias; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tag_aliases
    ADD CONSTRAINT fk_tag_aliases__alias FOREIGN KEY (alias_id) REFERENCES tags(id) ON DELETE CASCADE;


--
-- TOC entry 2316 (class 2606 OID 29969)
-- Dependencies: 1709 2240 1711
-- Name: fk_tag_implications__child; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tag_implications
    ADD CONSTRAINT fk_tag_implications__child FOREIGN KEY (predicate_id) REFERENCES tags(id) ON DELETE CASCADE;


--
-- TOC entry 2317 (class 2606 OID 29974)
-- Dependencies: 2240 1711 1709
-- Name: fk_tag_implications__parent; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tag_implications
    ADD CONSTRAINT fk_tag_implications__parent FOREIGN KEY (consequent_id) REFERENCES tags(id) ON DELETE CASCADE;


--
-- TOC entry 2323 (class 2606 OID 29979)
-- Dependencies: 2251 1721 1719
-- Name: fk_wiki_page_versions__user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY wiki_page_versions
    ADD CONSTRAINT fk_wiki_page_versions__user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- TOC entry 2324 (class 2606 OID 29984)
-- Dependencies: 1721 1723 2259
-- Name: fk_wiki_page_versions__wiki_page; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY wiki_page_versions
    ADD CONSTRAINT fk_wiki_page_versions__wiki_page FOREIGN KEY (wiki_page_id) REFERENCES wiki_pages(id) ON DELETE CASCADE;


--
-- TOC entry 2325 (class 2606 OID 29989)
-- Dependencies: 2251 1719 1723
-- Name: fk_wiki_pages__user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY wiki_pages
    ADD CONSTRAINT fk_wiki_pages__user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- TOC entry 2289 (class 2606 OID 29994)
-- Dependencies: 2214 1676 1696
-- Name: flagged_post_details_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY flagged_post_details
    ADD CONSTRAINT flagged_post_details_post_id_fkey FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE;


--
-- TOC entry 2290 (class 2606 OID 29999)
-- Dependencies: 2251 1676 1719
-- Name: flagged_post_details_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY flagged_post_details
    ADD CONSTRAINT flagged_post_details_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- TOC entry 2291 (class 2606 OID 30004)
-- Dependencies: 1719 1678 2251
-- Name: forum_posts_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY forum_posts
    ADD CONSTRAINT forum_posts_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- TOC entry 2292 (class 2606 OID 30009)
-- Dependencies: 1719 1678 2251
-- Name: forum_posts_last_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY forum_posts
    ADD CONSTRAINT forum_posts_last_updated_by_fkey FOREIGN KEY (last_updated_by) REFERENCES users(id) ON DELETE SET NULL;


--
-- TOC entry 2293 (class 2606 OID 30014)
-- Dependencies: 1678 2167 1678
-- Name: forum_posts_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY forum_posts
    ADD CONSTRAINT forum_posts_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES forum_posts(id) ON DELETE CASCADE;


--
-- TOC entry 2294 (class 2606 OID 30019)
-- Dependencies: 2214 1696 1682
-- Name: mod_queue_posts_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY mod_queue_posts
    ADD CONSTRAINT mod_queue_posts_post_id_fkey FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE;


--
-- TOC entry 2295 (class 2606 OID 30024)
-- Dependencies: 1719 2251 1682
-- Name: mod_queue_posts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY mod_queue_posts
    ADD CONSTRAINT mod_queue_posts_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- TOC entry 2301 (class 2606 OID 30029)
-- Dependencies: 1692 2192 1690
-- Name: pool_updates_pool_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pool_updates
    ADD CONSTRAINT pool_updates_pool_id_fkey FOREIGN KEY (pool_id) REFERENCES pools(id) ON DELETE CASCADE;


--
-- TOC entry 2303 (class 2606 OID 30034)
-- Dependencies: 2214 1696 1694
-- Name: pools_posts_next_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pools_posts
    ADD CONSTRAINT pools_posts_next_post_id_fkey FOREIGN KEY (next_post_id) REFERENCES posts(id) ON DELETE SET NULL;


--
-- TOC entry 2304 (class 2606 OID 30039)
-- Dependencies: 2192 1692 1694
-- Name: pools_posts_pool_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pools_posts
    ADD CONSTRAINT pools_posts_pool_id_fkey FOREIGN KEY (pool_id) REFERENCES pools(id) ON DELETE CASCADE;


--
-- TOC entry 2305 (class 2606 OID 30044)
-- Dependencies: 2214 1694 1696
-- Name: pools_posts_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pools_posts
    ADD CONSTRAINT pools_posts_post_id_fkey FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE;


--
-- TOC entry 2306 (class 2606 OID 30049)
-- Dependencies: 2214 1694 1696
-- Name: pools_posts_prev_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pools_posts
    ADD CONSTRAINT pools_posts_prev_post_id_fkey FOREIGN KEY (prev_post_id) REFERENCES posts(id) ON DELETE SET NULL;


--
-- TOC entry 2302 (class 2606 OID 30054)
-- Dependencies: 1719 2251 1692
-- Name: pools_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pools
    ADD CONSTRAINT pools_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- TOC entry 2311 (class 2606 OID 30059)
-- Dependencies: 1719 1698 2251
-- Name: post_tag_histories_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY post_tag_histories
    ADD CONSTRAINT post_tag_histories_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- TOC entry 2312 (class 2606 OID 30064)
-- Dependencies: 1696 1700 2214
-- Name: post_votes_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY post_votes
    ADD CONSTRAINT post_votes_post_id_fkey FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE;


--
-- TOC entry 2313 (class 2606 OID 30069)
-- Dependencies: 2251 1700 1719
-- Name: post_votes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY post_votes
    ADD CONSTRAINT post_votes_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- TOC entry 2308 (class 2606 OID 30074)
-- Dependencies: 2251 1696 1719
-- Name: posts_approver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT posts_approver_id_fkey FOREIGN KEY (approver_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- TOC entry 2309 (class 2606 OID 30079)
-- Dependencies: 1696 1696 2214
-- Name: posts_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT posts_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES posts(id) ON DELETE SET NULL;


--
-- TOC entry 2315 (class 2606 OID 30084)
-- Dependencies: 1707 2251 1719
-- Name: tag_aliases_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tag_aliases
    ADD CONSTRAINT tag_aliases_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- TOC entry 2318 (class 2606 OID 30089)
-- Dependencies: 1719 1709 2251
-- Name: tag_implications_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tag_implications
    ADD CONSTRAINT tag_implications_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- TOC entry 2286 (class 2606 OID 30094)
-- Dependencies: 2251 1672 1719
-- Name: tag_subscriptions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tag_subscriptions
    ADD CONSTRAINT tag_subscriptions_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- TOC entry 2319 (class 2606 OID 30099)
-- Dependencies: 1719 1713 2251
-- Name: test_janitors_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY test_janitors
    ADD CONSTRAINT test_janitors_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- TOC entry 2320 (class 2606 OID 30104)
-- Dependencies: 2251 1719 1715
-- Name: user_blacklisted_tags_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_blacklisted_tags
    ADD CONSTRAINT user_blacklisted_tags_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- TOC entry 2321 (class 2606 OID 30109)
-- Dependencies: 1719 2251 1717
-- Name: user_records_reported_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_records
    ADD CONSTRAINT user_records_reported_by_fkey FOREIGN KEY (reported_by) REFERENCES users(id) ON DELETE CASCADE;


--
-- TOC entry 2322 (class 2606 OID 30114)
-- Dependencies: 2251 1717 1719
-- Name: user_records_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_records
    ADD CONSTRAINT user_records_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


-- Completed on 2011-10-09 15:21:08 EDT

--
-- PostgreSQL database dump complete
--

